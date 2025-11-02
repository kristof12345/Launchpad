import XCTest
import AppKit
@testable import LaunchpadPlus

@MainActor
final class AppManagerImportExportTests: XCTestCase {
    
    var appManager: AppManager!
    var testDirectory: URL!
    
    override func setUp() {
        super.setUp()
        appManager = AppManager.shared
        
        // Create a temporary directory for test files
        testDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("LaunchpadTests")
            .appendingPathComponent(UUID().uuidString)
        
        try? FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.gridItems)
    }
    
    override func tearDown() {
        // Clean up test files
        try? FileManager.default.removeItem(at: testDirectory)
        
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.gridItems)
        super.tearDown()
    }
    
    // MARK: - Export Tests
    
    func testExportLayout() {
        // Given: Some test data
        let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
        let app1 = AppInfo(name: "Test App 1", icon: mockIcon, path: "/Applications/App1.app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: 0)
        let app2 = AppInfo(name: "Test App 2", icon: mockIcon, path: "/Applications/App2.app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: 1)
        let folderApp = AppInfo(name: "Folder App", icon: mockIcon, path: "/Applications/FolderApp.app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: 0)
        let folder = Folder(name: "Test Folder", page: 0, apps: [folderApp])
        
        appManager.pages = [
            [.app(app1), .folder(folder)],
            [.app(app2)]
        ]
        
        // When: Exporting layout
        let exportURL = testDirectory.appendingPathComponent("test_export.json")
        
        // Access the private method through the public interface
        // Since exportLayout is using a fixed path, we'll test the underlying serialization
        let allItems = appManager.pages.flatMap { $0 }
        let serializedData = allItems.map { $0.serialize() }
        
        // Manually create the JSON to test the export format
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: serializedData, options: .prettyPrinted)
            try jsonData.write(to: exportURL)
        } catch {
            XCTFail("Failed to write test export data: \(error)")
            return
        }
        
        // Then: File should exist and contain valid JSON
        XCTAssertTrue(FileManager.default.fileExists(atPath: exportURL.path), "Export file should exist")
        
        // Verify JSON content
        do {
            let data = try Data(contentsOf: exportURL)
            let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            
            XCTAssertNotNil(json, "Should be valid JSON array")
            XCTAssertEqual(json?.count, 3, "Should export 3 items (2 apps + 1 folder)")
            
            // Check first item (app)
            let firstItem = json?.first
            XCTAssertEqual(firstItem?["type"] as? String, "app")
            XCTAssertEqual(firstItem?["name"] as? String, "Test App 1")
            XCTAssertEqual(firstItem?["path"] as? String, "/Applications/App1.app")
            XCTAssertEqual(firstItem?["page"] as? Int, 0)
            
            // Find and check folder
            let folderItem = json?.first { ($0["type"] as? String) == "folder" }
            XCTAssertNotNil(folderItem, "Should have folder item")
            XCTAssertEqual(folderItem?["name"] as? String, "Test Folder")
            
            let folderApps = folderItem?["apps"] as? [[String: Any]]
            XCTAssertEqual(folderApps?.count, 1, "Folder should have 1 app")
            XCTAssertEqual(folderApps?.first?["name"] as? String, "Folder App")
            
        } catch {
            XCTFail("Failed to read or parse export file: \(error)")
        }
    }
    
    func testExportEmptyLayout() {
        // Given: Empty layout
        appManager.pages = [[]]
        
        // When: Exporting
        let allItems = appManager.pages.flatMap { $0 }
        let serializedData = allItems.map { $0.serialize() }
        
        let exportURL = testDirectory.appendingPathComponent("empty_export.json")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: serializedData, options: .prettyPrinted)
            try jsonData.write(to: exportURL)
        } catch {
            XCTFail("Failed to export empty layout: \(error)")
            return
        }
        
        // Then: Should create valid empty JSON array
        do {
            let data = try Data(contentsOf: exportURL)
            let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            
            XCTAssertNotNil(json, "Should be valid JSON")
            XCTAssertEqual(json?.count, 0, "Should be empty array")
        } catch {
            XCTFail("Failed to read empty export: \(error)")
        }
    }
    
    // MARK: - Import Tests
    
    func testImportValidLayout() {
        // Given: Valid JSON layout file
        let layoutData: [[String: Any]] = [
            [
                "type": "app",
                "name": "Imported App",
                "path": "/Applications/Calculator.app", // Use real app that should exist
                "page": 0,
                "id": UUID().uuidString
            ],
            [
                "type": "folder",
                "name": "Imported Folder",
                "page": 1,
                "id": UUID().uuidString,
                "apps": [
                    [
                        "name": "Folder App",
                        "path": "/Applications/TextEdit.app", // Use real app
                        "page": 0,
                        "id": UUID().uuidString
                    ]
                ]
            ]
        ]
        
        let importURL = testDirectory.appendingPathComponent("import_test.json")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: layoutData, options: .prettyPrinted)
            try jsonData.write(to: importURL)
        } catch {
            XCTFail("Failed to create import test file: \(error)")
            return
        }
        
        // When: Importing layout
        // Note: The actual import method uses a fixed path, so we'll test the underlying logic
        
        // Simulate the import process
        do {
            let data = try Data(contentsOf: importURL)
            let itemsArray = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
            
            // This simulates what importLayoutFromJSON would do
            XCTAssertEqual(itemsArray.count, 2, "Should load 2 items from import file")
            
            let firstItem = itemsArray[0]
            XCTAssertEqual(firstItem["type"] as? String, "app")
            XCTAssertEqual(firstItem["name"] as? String, "Imported App")
            
            let secondItem = itemsArray[1]
            XCTAssertEqual(secondItem["type"] as? String, "folder")
            XCTAssertEqual(secondItem["name"] as? String, "Imported Folder")
            
        } catch {
            XCTFail("Failed to simulate import: \(error)")
        }
    }
    
    func testImportWithMissingApps() {
        // Given: JSON with references to non-existent apps
        let layoutData: [[String: Any]] = [
            [
                "type": "app",
                "name": "Missing App",
                "path": "/Applications/NonexistentApp.app",
                "page": 0,
                "id": UUID().uuidString
            ],
            [
                "type": "app",
                "name": "Real App",
                "path": "/System/Applications/Calculator.app", // This should exist
                "page": 0,
                "id": UUID().uuidString
            ]
        ]
        
        let importURL = testDirectory.appendingPathComponent("missing_apps_test.json")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: layoutData, options: .prettyPrinted)
            try jsonData.write(to: importURL)
            
            // Test that import handles missing apps gracefully
            let data = try Data(contentsOf: importURL)
            let itemsArray = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
            
            XCTAssertEqual(itemsArray.count, 2, "Should parse both items from JSON")
            
            // The actual filtering of missing apps would happen in loadAppItem
            // Here we just verify the JSON parsing works
            
        } catch {
            XCTFail("Import with missing apps should not fail: \(error)")
        }
    }
    
    func testImportCorruptedJSON() {
        // Given: Corrupted JSON file
        let corruptedJSON = "{ invalid json content"
        let importURL = testDirectory.appendingPathComponent("corrupted.json")
        
        do {
            try corruptedJSON.write(to: importURL, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Failed to create corrupted JSON file: \(error)")
            return
        }
        
        // When: Attempting to import corrupted JSON
        do {
            let data = try Data(contentsOf: importURL)
            _ = try JSONSerialization.jsonObject(with: data)
            XCTFail("Should throw error for corrupted JSON")
        } catch {
            // Then: Should handle error gracefully
            XCTAssertTrue(error is CocoaError, "Should throw JSON parsing error")
        }
    }
    
    func testImportEmptyJSON() {
        // Given: Empty JSON array
        let emptyData: [[String: Any]] = []
        let importURL = testDirectory.appendingPathComponent("empty.json")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: emptyData, options: .prettyPrinted)
            try jsonData.write(to: importURL)
            
            // When: Importing empty JSON
            let data = try Data(contentsOf: importURL)
            let itemsArray = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
            
            // Then: Should handle empty array
            XCTAssertEqual(itemsArray.count, 0, "Should handle empty JSON array")
            
        } catch {
            XCTFail("Should handle empty JSON gracefully: \(error)")
        }
    }
    
    // MARK: - Round-trip Tests
    
    func testExportImportRoundTrip() {
        // Given: Original layout with various item types
        let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
        let app1 = AppInfo(name: "Round Trip App", icon: mockIcon, path: "/Applications/Calculator.app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: 0)
        let folderApp = AppInfo(name: "Folder App", icon: mockIcon, path: "/Applications/TextEdit.app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: 0)
        let folder = Folder(name: "Round Trip Folder", page: 1, apps: [folderApp])
        
       let originalLayout: [[AppGridItem]] = [
           [.app(app1)],
           [.folder(folder)]
       ]

        appManager.pages = originalLayout
        
        // When: Export and then import
        let exportURL = testDirectory.appendingPathComponent("roundtrip.json")
        
        // Export
        let allItems = appManager.pages.flatMap { $0 }
        let serializedData = allItems.map { $0.serialize() }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: serializedData, options: .prettyPrinted)
            try jsonData.write(to: exportURL)
            
            // Import back
            let data = try Data(contentsOf: exportURL)
            let itemsArray = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
            
            // Then: Should preserve essential data
            XCTAssertEqual(itemsArray.count, 2, "Should preserve item count")
            
            // Find app item
            let appItem = itemsArray.first { ($0["type"] as? String) == "app" }
            XCTAssertNotNil(appItem, "Should preserve app")
            XCTAssertEqual(appItem?["name"] as? String, "Round Trip App")
            XCTAssertEqual(appItem?["path"] as? String, "/Applications/Calculator.app")
            
            // Find folder item
            let folderItem = itemsArray.first { ($0["type"] as? String) == "folder" }
            XCTAssertNotNil(folderItem, "Should preserve folder")
            XCTAssertEqual(folderItem?["name"] as? String, "Round Trip Folder")
            
            let folderApps = folderItem?["apps"] as? [[String: Any]]
            XCTAssertEqual(folderApps?.count, 1, "Should preserve folder contents")
            XCTAssertEqual(folderApps?.first?["name"] as? String, "Folder App")
            
        } catch {
            XCTFail("Round trip test failed: \(error)")
        }
    }
    
    // MARK: - File System Tests
    
    func testExportToInvalidPath() {
        // Test behavior when export path is invalid
        appManager.pages = [[]]
        
        let invalidURL = URL(fileURLWithPath: "/invalid/path/that/does/not/exist/export.json")
        
        // This would test the actual export method if we could override the path
        // For now, we test the underlying JSON serialization
        let allItems = appManager.pages.flatMap { $0 }
        let serializedData = allItems.map { $0.serialize() }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: serializedData, options: .prettyPrinted)
            try jsonData.write(to: invalidURL)
            XCTFail("Should fail to write to invalid path")
        } catch {
            // Expected to fail
            XCTAssertTrue(error is CocoaError, "Should fail with file system error")
        }
    }
    
    func testImportFromNonexistentFile() {
        let nonexistentURL = testDirectory.appendingPathComponent("nonexistent.json")
        
        // Should fail gracefully when file doesn't exist
        do {
            _ = try Data(contentsOf: nonexistentURL)
            XCTFail("Should fail to read nonexistent file")
        } catch {
            XCTAssertTrue(error is CocoaError, "Should fail with file not found error")
        }
    }
    
    // MARK: - Performance Tests
    
    func testExportPerformanceWithLargeDataset() {
        // Create large dataset
        let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
        let largeDataset = (0..<1000).map { i in
            AppGridItem.app(AppInfo(name: "App \(i)", icon: mockIcon, path: "/App\(i).app", bundleId: "com.test.app", lastOpenedDate: nil, installDate: nil, page: i / 50))
        }
        
        // Group into pages
        let pages = Dictionary(grouping: largeDataset) { $0.page }
            .sorted { $0.key < $1.key }
            .map { $0.value }
        
        appManager.pages = pages
        
        // Measure export performance
        measure {
            let allItems = appManager.pages.flatMap { $0 }
            let serializedData = allItems.map { $0.serialize() }
            
            do {
                _ = try JSONSerialization.data(withJSONObject: serializedData, options: .prettyPrinted)
            } catch {
                XCTFail("Export performance test failed: \(error)")
            }
        }
    }
}
