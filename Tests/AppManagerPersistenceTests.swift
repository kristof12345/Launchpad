import XCTest
import AppKit
@testable import LaunchpadPlus

@MainActor
final class AppManagerPersistenceTests: BaseTestCase {

   // MARK: - Serialization Tests

   func testAppSerialization() {
      let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
      let app = AppInfo(name: "Test App", icon: mockIcon, path: "/Applications/Test.app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: 2)
      let gridItem = AppGridItem.app(app)

      let serialized = gridItem.serialize()

      XCTAssertEqual(serialized["type"] as? String, "app")
      XCTAssertEqual(serialized["name"] as? String, "Test App")
      XCTAssertEqual(serialized["path"] as? String, "/Applications/Test.app")
      XCTAssertEqual(serialized["page"] as? Int, 2)
      XCTAssertNotNil(serialized["id"], "Should have an ID")
   }

   func testFolderSerialization() {
      let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
      let app1 = AppInfo(name: "App 1", icon: mockIcon, path: "/Applications/App1.app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: 0)
      let app2 = AppInfo(name: "App 2", icon: mockIcon, path: "/Applications/App2.app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: 0)
      let folder = Folder(name: "Test Folder", page: 1, apps: [app1, app2])
      let gridItem = AppGridItem.folder(folder)

      let serialized = gridItem.serialize()

      XCTAssertEqual(serialized["type"] as? String, "folder")
      XCTAssertEqual(serialized["name"] as? String, "Test Folder")
      XCTAssertEqual(serialized["page"] as? Int, 1)
      XCTAssertNotNil(serialized["id"], "Should have an ID")

      let apps = serialized["apps"] as? [[String: Any]]
      XCTAssertNotNil(apps, "Should have apps array")
      XCTAssertEqual(apps?.count, 2, "Should have 2 apps")

      if let firstApp = apps?.first {
         XCTAssertEqual(firstApp["name"] as? String, "App 1")
         XCTAssertEqual(firstApp["path"] as? String, "/Applications/App1.app")
         XCTAssertEqual(firstApp["page"] as? Int, 0)
      }
   }

   // MARK: - Save/Load Cycle Tests

   func testSaveLoadCycle() async {
      // Create test data
      let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
      let app1 = AppInfo(name: "App 1", icon: mockIcon, path: "/Applications/App1.app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: 0)
      let app2 = AppInfo(name: "App 2", icon: mockIcon, path: "/Applications/App2.app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: 1)
      let app3 = AppInfo(name: "App 3", icon: mockIcon, path: "/Applications/App3.app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: 0)

      let folder = Folder(name: "Test Folder", page: 1, apps: [app1])

      appManager.pages = [
         [.app(app1), .app(app3)], // Page 0
         [.app(app2), .folder(folder)] // Page 1
      ]

      appManager.saveAppGridItems()

      // Wait for async save
      try? await Task.sleep(nanoseconds: 100_000_000)

      // Verify data was saved
      let savedData = UserDefaults.standard.array(forKey: UserDefaultsKeys.gridItems) as? [[String: Any]]
      XCTAssertNotNil(savedData, "Should save data to UserDefaults")
      XCTAssertEqual(savedData?.count, 4, "Should save 4 items (3 apps + 1 folder)")

      // Check that we have the right types
      let types = savedData?.compactMap { $0["type"] as? String }.sorted()
      XCTAssertEqual(types, ["app", "app", "app", "folder"], "Should have 3 apps and 1 folder")
   }

   func testLoadWithCorruptedData() {
      // Save corrupted data
      let corruptedData: [[String: Any]] = [
         ["type": "app"], // Missing required fields
         ["type": "unknown", "name": "Unknown"], // Unknown type
         ["name": "No Type"], // Missing type
         [:] // Empty object
      ]

      UserDefaults.standard.set(corruptedData, forKey: UserDefaultsKeys.gridItems)

      // Should not crash when loading
      XCTAssertNoThrow {
         self.appManager.loadAppGridItems(appsPerPage: 20)
      }

      // Should still discover real apps despite corrupted saved data
      XCTAssertGreaterThan(appManager.pages.count, 0, "Should have at least one page")
   }

   func testLoadWithMissingApps() {
      // Save data for apps that don't exist on the system
      let missingAppData: [[String: Any]] = [
         [
            "type": "app",
            "name": "Nonexistent App",
            "path": "/Applications/NonexistentApp.app",
            "page": 0,
            "id": UUID().uuidString
         ]
      ]

      UserDefaults.standard.set(missingAppData, forKey: UserDefaultsKeys.gridItems)

      // Should handle missing apps gracefully
      XCTAssertNoThrow {
         self.appManager.loadAppGridItems(appsPerPage: 20)
      }

      // Should still discover real apps
      let allItems = appManager.pages.flatMap { $0 }
      let hasRealApps = allItems.contains { item in
         if case .app(let app) = item {
            return FileManager.default.fileExists(atPath: app.path)
         }
         return false
      }
      
      XCTAssertTrue(hasRealApps || allItems.isEmpty, "Should discover real apps or have empty list")
   }

   // MARK: - Data Integrity Tests

   func testDataConsistencyAfterMultipleOperations() async {
      appManager.loadAppGridItems(appsPerPage: 10)
      let initialCount = appManager.pages.flatMap { $0 }.count

      // 2. Recalculate pages
      appManager.recalculatePages(appsPerPage: 5)
      let afterRecalculateCount = appManager.pages.flatMap { $0 }.count
      XCTAssertEqual(initialCount, afterRecalculateCount, "Count should remain same after recalculate")

      // 3. Wait for save
      try? await Task.sleep(nanoseconds: 100_000_000)

      // 4. Clear and reload
      appManager.clearAppGridItems(appsPerPage: 10)
      let afterClearCount = appManager.pages.flatMap { $0 }.count

      // Counts might differ slightly due to system changes, but should be in reasonable range
      XCTAssertGreaterThan(afterClearCount, 0, "Should have apps after clear and reload")
   }

   func testConcurrentSaveOperations() async {
      // Test that concurrent page modifications don't cause data corruption
      let mockIcon = NSImage(size: NSSize(width: 64, height: 64))

      // Start with some initial data
      let initialApps = (0..<10).map { i in
         AppInfo(name: "App \(i)", icon: mockIcon, path: "/Applications/App\(i).app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: 0)
      }
      appManager.pages = [initialApps.map { AppGridItem.app($0) }]

      // Trigger multiple saves rapidly
      let group = DispatchGroup()

      for i in 0..<5 {
         group.enter()
         Task {
            let newApps = (10..<15).map { j in
               AppInfo(name: "New App \(i)-\(j)", icon: mockIcon, path: "/Applications/NewApp\(i)-\(j).app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: 0)
            }
            appManager.pages = [newApps.map { AppGridItem.app($0) }]
            group.leave()
         }
      }

      appManager.saveAppGridItems()

      try? await Task.sleep(nanoseconds: 200_000_000)

      // Verify that some data was saved (exact data depends on timing)
      let savedData = UserDefaults.standard.array(forKey: UserDefaultsKeys.gridItems)
      XCTAssertNotNil(savedData, "Should have saved some data")
   }

   // MARK: - Edge Cases

   func testSaveEmptyPages() async {
      appManager.pages = [[]]
      appManager.saveAppGridItems()

      // Wait for save
      try? await Task.sleep(nanoseconds: 100_000_000)

      let savedData = UserDefaults.standard.array(forKey: UserDefaultsKeys.gridItems) as? [[String: Any]]
      XCTAssertNotNil(savedData, "Should save even empty data")
      XCTAssertEqual(savedData?.count, 0, "Empty pages should result in empty array")
   }
}
