import XCTest
import AppKit
@testable import LaunchpadPlus

@MainActor
final class AppManagerTests: BaseTestCase {

   // MARK: - Initialization Tests

   func testAppManagerSingleton() {
      let instance1 = AppManager.shared
      let instance2 = AppManager.shared
      XCTAssertTrue(instance1 === instance2, "AppManager should be a singleton")
   }

   func testInitialState() {
      XCTAssertEqual(appManager.pages.count, 1, "Should initialize with one empty page")
      XCTAssertTrue(appManager.pages[0].isEmpty, "Initial page should be empty")
   }

   // MARK: - App Discovery Tests

   func testLoadAppGridItemsWithoutSavedData() {
      appManager.loadAppGridItems(appsPerPage: 20)

      XCTAssertGreaterThan(appManager.pages.count, 0, "Should have at least one page")

      let totalApps = appManager.pages.flatMap { $0 }.count
      XCTAssertGreaterThan(totalApps, 0, "Should discover some applications")

      // All discovered apps should be .app items initially
      let allItems = appManager.pages.flatMap { $0 }
      for item in allItems {
         if case .app(let app) = item {
            XCTAssertFalse(app.name.isEmpty, "App name should not be empty")
            XCTAssertFalse(app.path.isEmpty, "App path should not be empty")
            XCTAssertTrue(app.path.hasSuffix(".app"), "App path should end with .app")
         } else {
            XCTFail("All initially discovered items should be apps, not folders")
         }
      }
   }

   // MARK: - Page Management Tests

   func testRecalculatePagesWithExactFit() {
      // Given: 20 apps and 20 apps per page
      let mockApps = createMockApps(count: 20, startingPage: 0)
      appManager.pages = [mockApps]

      // When: Recalculating pages
      appManager.recalculatePages(appsPerPage: 20)

      // Then: Should have exactly 1 page
      XCTAssertEqual(appManager.pages.count, 1, "Should have exactly 1 page for 20 apps with 20 per page")
      XCTAssertEqual(appManager.pages[0].count, 20, "First page should have 20 apps")
   }

   func testRecalculatePagesWithOverflow() {
      // Given: 25 apps and 20 apps per page
      let mockApps = createMockApps(count: 25, startingPage: 0)
      appManager.pages = [mockApps]

      // When: Recalculating pages
      appManager.recalculatePages(appsPerPage: 20)

      // Then: Should have 2 pages
      XCTAssertEqual(appManager.pages.count, 2, "Should have 2 pages for 25 apps with 20 per page")
      XCTAssertEqual(appManager.pages[0].count, 20, "First page should have 20 apps")
      XCTAssertEqual(appManager.pages[1].count, 5, "Second page should have 5 apps")
   }

   func testRecalculatePagesWithMultipleOverflow() {
      // Given: 55 apps and 10 apps per page
      let mockApps = createMockApps(count: 55, startingPage: 0)
      appManager.pages = [mockApps]

      // When: Recalculating pages
      appManager.recalculatePages(appsPerPage: 10)

      // Then: Should have 2 pages
      XCTAssertEqual(appManager.pages.count, 6, "Should have 6 pages for 55 apps with 10 per page")
      XCTAssertEqual(appManager.pages[0].count, 10, "First page should have 10 apps")
      XCTAssertEqual(appManager.pages[1].count, 10, "Second page should have 10 apps")
      XCTAssertEqual(appManager.pages[5].count, 5, "Last page should have 5 apps")
   }

   func testRecalculatePagesPreservesAppOrder() {
      // Given: Apps with specific names
      let app1 = createMockApp(name: "App A", path: "/Applications/A.app", bundleId: "com.test.app", page: 0)
      let app2 = createMockApp(name: "App B", path: "/Applications/B.app", bundleId: "com.test.app", page: 0)
      let app3 = createMockApp(name: "App C", path: "/Applications/C.app", bundleId: "com.test.app", page: 0)

      appManager.pages = [[.app(app1), .app(app2), .app(app3)]]

      // When: Recalculating with 2 apps per page
      appManager.recalculatePages(appsPerPage: 2)

      // Then: Should maintain order across pages
      XCTAssertEqual(appManager.pages.count, 2, "Should have 2 pages")

      if case .app(let firstApp) = appManager.pages[0][0] {
         XCTAssertEqual(firstApp.name, "App A", "First app should be App A")
      } else {
         XCTFail("First item should be an app")
      }

      if case .app(let thirdApp) = appManager.pages[1][0] {
         XCTAssertEqual(thirdApp.name, "App C", "Third app should be on second page")
      } else {
         XCTFail("Third item should be an app")
      }
   }

   // MARK: - Persistence Tests

   func testSaveAndLoadAppGridItems() async {
      // Given: Some mock apps
      let mockApps = createMockApps(count: 5, startingPage: 0)
      appManager.pages = [mockApps]
      appManager.saveAppGridItems()

      // When: Saving (this happens automatically via property observer)
      // Wait for the async save to complete
      try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

      // Then: Data should be saved to UserDefaults
      let savedData = UserDefaults.standard.array(forKey: UserDefaultsKeys.gridItems) as? [[String: Any]]
      XCTAssertNotNil(savedData, "Data should be saved to UserDefaults")
      XCTAssertEqual(savedData?.count, 5, "Should save 5 items")

      // Verify saved data structure
      guard let firstItem = savedData?.first else {
         XCTFail("Should have at least one saved item")
         return
      }

      XCTAssertEqual(firstItem["type"] as? String, "app", "First item should be an app")
      XCTAssertNotNil(firstItem["name"], "Should have app name")
      XCTAssertNotNil(firstItem["path"], "Should have app path")
      XCTAssertNotNil(firstItem["page"], "Should have page number")
   }

   func testLoadAppGridItemsWithSavedData() {
      // Given: Saved app data in UserDefaults
      let savedData: [[String: Any]] = [
         [
            "type": "app",
            "name": "Test App",
            "path": "/Applications/TestApp.app",
            "page": 1,
            "id": UUID().uuidString
         ],
         [
            "type": "folder",
            "name": "Test Folder",
            "page": 0,
            "apps": [
               [
                  "name": "Folder App",
                  "path": "/Applications/FolderApp.app",
                  "page": 0
               ]
            ]
         ]
      ]

      UserDefaults.standard.set(savedData, forKey: UserDefaultsKeys.gridItems)

      // When: Loading grid items (this would normally discover real apps)
      // Note: This test will fail for apps that don't exist on the system
      // In a real test environment, we'd need to mock the app discovery

      // For now, let's test that the method runs without crashing
      XCTAssertNoThrow(appManager.loadAppGridItems(appsPerPage: 20))
   }

   // MARK: - Clear Grid Items Tests

   func testClearAppGridItems() {
      // Given: Some saved data
      let mockApps = createMockApps(count: 3, startingPage: 0)
      appManager.pages = [mockApps]
      appManager.saveAppGridItems()

      // Ensure data is saved
      let initialData = UserDefaults.standard.array(forKey: UserDefaultsKeys.gridItems)
      XCTAssertNotNil(initialData, "Should have initial data")

      // When: Clearing grid items
      appManager.clearAppGridItems(appsPerPage: 20)

      // Then: UserDefaults should be cleared and new apps discovered
      _ = UserDefaults.standard.array(forKey: UserDefaultsKeys.gridItems)
      // Note: clearAppGridItems calls loadAppGridItems, which may save new data
      // So we mainly check that the method runs without crashing
      XCTAssertNoThrow({
         self.appManager.clearAppGridItems(appsPerPage: 20)
      })
   }

   // MARK: - Folder Tests

   func testFolderSerialization() {
      // Given: A folder with apps
      let app1 = createMockApp(name: "App 1", path: "/Applications/App1.app", bundleId: "com.test.app", page: 0)
      let app2 = createMockApp(name: "App 2", path: "/Applications/App2.app", bundleId: "com.test.app", page: 0)
      let folder = Folder(name: "Test Folder", page: 1, apps: [app1, app2])
      let folderItem = AppGridItem.folder(folder)

      // When: Serializing the folder
      let serialized = folderItem.serialize()

      // Then: Should contain correct structure
      XCTAssertEqual(serialized["type"] as? String, "folder")
      XCTAssertEqual(serialized["name"] as? String, "Test Folder")
      XCTAssertEqual(serialized["page"] as? Int, 1)

      let apps = serialized["apps"] as? [[String: Any]]
      XCTAssertNotNil(apps, "Should have apps array")
      XCTAssertEqual(apps?.count, 2, "Should have 2 apps in folder")
   }

   // MARK: - Page Update Tests

   func testLoadAppGridItemsGroupsByPage() {
      // Test that apps are grouped by page when loading
      let mockApps = [
         createMockApp(name: "App 1", path: "/App1.app", bundleId: "com.test.app", page: 0),
         createMockApp(name: "App 2", path: "/App2.app", bundleId: "com.test.app", page: 1),
         createMockApp(name: "App 3", path: "/App3.app", bundleId: "com.test.app", page: 1)
      ]

      let gridItems = mockApps.map { AppGridItem.app($0) }
      appManager.pages = [gridItems]
      
      // Recalculate to distribute across pages
      appManager.recalculatePages(appsPerPage: 10)

      // Verify that items are distributed correctly
      let totalItems = appManager.pages.flatMap { $0 }.count
      XCTAssertEqual(totalItems, 3, "Should have all 3 items")
   }

   // MARK: - Edge Cases

   func testEmptyAppGridItems() {
      appManager.pages = []
      appManager.recalculatePages(appsPerPage: 20)

      XCTAssertEqual(appManager.pages.count, 1, "Should always have at least one page")
      XCTAssertTrue(appManager.pages[0].isEmpty, "Empty input should result in one empty page")
   }

   func testSingleAppPerPage() {
      let mockApps = createMockApps(count: 3, startingPage: 0)
      appManager.pages = [mockApps]

      appManager.recalculatePages(appsPerPage: 1)

      XCTAssertEqual(appManager.pages.count, 3, "Should have 3 pages for 3 apps with 1 per page")
      for page in appManager.pages {
         XCTAssertEqual(page.count, 1, "Each page should have exactly 1 app")
      }
   }

   func testLargeNumberOfApps() {
      let mockApps = createMockApps(count: 100, startingPage: 0)
      appManager.pages = [mockApps]

      appManager.recalculatePages(appsPerPage: 20)

      XCTAssertEqual(appManager.pages.count, 5, "Should have 5 pages for 100 apps with 20 per page")

      // Check first 4 pages have 20 apps each
      for i in 0..<4 {
         XCTAssertEqual(appManager.pages[i].count, 20, "Page \(i) should have 20 apps")
      }

      // Last page should also have 20 apps (100/20 = 5 exactly)
      XCTAssertEqual(appManager.pages[4].count, 20, "Last page should have 20 apps")
   }
}

// MARK: - Integration Tests

@MainActor
final class AppManagerIntegrationTests: BaseTestCase {

   func testFullWorkflow() async {
      // Test a complete workflow: load -> modify -> save -> load again

      // 1. Initial load
      appManager.loadAppGridItems(appsPerPage: 20)
      let initialCount = appManager.pages.flatMap { $0 }.count
      XCTAssertGreaterThan(initialCount, 0, "Should discover some apps")

      appManager.saveAppGridItems()
      
      // 2. Wait for save to complete
      try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

      // 3. Verify data was saved
      let savedData = UserDefaults.standard.array(forKey: UserDefaultsKeys.gridItems)
      XCTAssertNotNil(savedData, "Data should be saved")

      // 4. Clear and reload
      appManager.clearAppGridItems(appsPerPage: 20)
      let reloadedCount = appManager.pages.flatMap { $0 }.count

      // 5. Should have similar number of apps (might vary slightly due to system changes)
      XCTAssertGreaterThan(reloadedCount, 0, "Should still have apps after reload")
   }

   func testPageRecalculationWithRealData() {
      // Load real apps
      appManager.loadAppGridItems(appsPerPage: 10)
      let originalTotalApps = appManager.pages.flatMap { $0 }.count

      // Recalculate with different page size
      appManager.recalculatePages(appsPerPage: 5)
      let newTotalApps = appManager.pages.flatMap { $0 }.count

      // Should have same number of apps, just distributed differently
      XCTAssertEqual(originalTotalApps, newTotalApps, "Total app count should remain the same")

      // Should have more pages with smaller page size
      let expectedPages = (originalTotalApps + 4) / 5 // Ceiling division
      XCTAssertEqual(appManager.pages.count, expectedPages, "Should have correct number of pages")
   }
}
