import XCTest
import AppKit
@testable import LaunchpadPlus

@MainActor
final class CustomLocationsTests: XCTestCase {
   
   var settingsManager: SettingsManager!
   var appManager: AppManager!
   var testDirectory: URL!
   
   override func setUp() {
      super.setUp()
      
      settingsManager = SettingsManager.shared
      appManager = AppManager.shared
      
      // Create a temporary directory for test files
      testDirectory = FileManager.default.temporaryDirectory
         .appendingPathComponent("LaunchpadCustomLocationsTests")
         .appendingPathComponent(UUID().uuidString)
      
      try? FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)
      
      // Reset settings to defaults
      settingsManager.resetToDefaults()
      
      // Clear test data
      UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.gridItems)
      UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.settings)
   }
   
   override func tearDown() {
      // Clean up test files and data
      try? FileManager.default.removeItem(at: testDirectory)
      UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.gridItems)
      UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.settings)
      settingsManager.resetToDefaults()
      super.tearDown()
   }
   
   // MARK: - Settings Model Tests
   
   func testDefaultSettingsHasEmptyCustomLocations() {
      // Given/When: Creating default settings
      let settings = LaunchpadSettings()
      
      // Then: Custom locations should be empty
      XCTAssertTrue(settings.customAppLocations.isEmpty, "Default settings should have empty custom locations")
   }
   
   func testSettingsWithCustomLocations() {
      // Given: Some custom locations
      let locations = ["/Users/test/Applications", "/opt/homebrew"]
      
      // When: Creating settings with custom locations
      let settings = LaunchpadSettings(customAppLocations: locations)
      
      // Then: Custom locations should be set
      XCTAssertEqual(settings.customAppLocations, locations, "Settings should store custom locations")
   }
   
   func testSettingsPersistence() {
      // Given: Settings with custom locations
      let locations = ["/Users/test/Apps", "/Applications/Custom"]
      
      // When: Updating settings
      var updatedSettings = settingsManager.settings
      updatedSettings.customAppLocations = locations
      settingsManager.saveSettings(newSettings: updatedSettings)
      
      // Then: Settings should be persisted
      XCTAssertEqual(settingsManager.settings.customAppLocations, locations, "Custom locations should be persisted")
      
      // And: Should be loadable from UserDefaults
      let loadedSettings = SettingsManager.shared.settings
      XCTAssertEqual(loadedSettings.customAppLocations, locations, "Custom locations should be loaded from UserDefaults")
   }
   
   // MARK: - Settings Manager Tests
   
   func testUpdateSettingsWithCustomLocations() {
      // Given: Initial settings with no custom locations
      XCTAssertTrue(settingsManager.settings.customAppLocations.isEmpty)
      
      // When: Updating with custom locations
      let newLocations = ["/Users/test/Applications"]
      var updatedSettings = settingsManager.settings
      updatedSettings.customAppLocations = newLocations
      settingsManager.saveSettings(newSettings: updatedSettings)
      
      // Then: Settings should be updated
      XCTAssertEqual(settingsManager.settings.customAppLocations, newLocations)
   }
   
   func testUpdateSettingsPreservesOtherSettings() {
      // Given: Settings with specific values
      var initialSettings = settingsManager.settings
      initialSettings.columns = 8
      initialSettings.rows = 6
      settingsManager.saveSettings(newSettings: initialSettings)
      
      // When: Updating only custom locations
      let locations = ["/opt/apps"]
      var updatedSettings = settingsManager.settings
      updatedSettings.customAppLocations = locations
      settingsManager.saveSettings(newSettings: updatedSettings)
      
      // Then: Other settings should be preserved
      XCTAssertEqual(settingsManager.settings.columns, 8)
      XCTAssertEqual(settingsManager.settings.rows, 6)
      XCTAssertEqual(settingsManager.settings.customAppLocations, locations)
   }
   
   // MARK: - App Discovery Tests
   
   func testDiscoverAppsWithCustomLocation() {
      // Given: A test directory with a mock app
      let mockAppPath = testDirectory.appendingPathComponent("TestApp.app")
      try? FileManager.default.createDirectory(at: mockAppPath, withIntermediateDirectories: true)
      
      // When: Adding custom location and loading apps
      var updatedSettings = settingsManager.settings
      updatedSettings.customAppLocations = [testDirectory.path]
      settingsManager.saveSettings(newSettings: updatedSettings)
      appManager.loadAppGridItems(appsPerPage: 20)
      
      // Then: Apps should be discovered from both default and custom locations
      let allItems = appManager.pages.flatMap { $0 }
      XCTAssertGreaterThan(allItems.count, 0, "Should discover apps")
      
      // Check if custom location app is discovered
      let appPaths = allItems.compactMap { item -> String? in
         if case .app(let app) = item {
            return app.path
         }
         return nil
      }
      
      let hasCustomApp = appPaths.contains { $0.hasPrefix(testDirectory.path) }
      XCTAssertTrue(hasCustomApp, "Should discover app from custom location")
   }
   
   func testDiscoverAppsWithMultipleCustomLocations() {
      // Given: Multiple test directories with mock apps
      let customDir1 = testDirectory.appendingPathComponent("CustomApps1")
      let customDir2 = testDirectory.appendingPathComponent("CustomApps2")
      try? FileManager.default.createDirectory(at: customDir1, withIntermediateDirectories: true)
      try? FileManager.default.createDirectory(at: customDir2, withIntermediateDirectories: true)
      
      let mockApp1 = customDir1.appendingPathComponent("App1.app")
      let mockApp2 = customDir2.appendingPathComponent("App2.app")
      try? FileManager.default.createDirectory(at: mockApp1, withIntermediateDirectories: true)
      try? FileManager.default.createDirectory(at: mockApp2, withIntermediateDirectories: true)
      
      // When: Adding multiple custom locations
      var updatedSettings = settingsManager.settings
      updatedSettings.customAppLocations = [customDir1.path, customDir2.path]
      settingsManager.saveSettings(newSettings: updatedSettings)
      appManager.loadAppGridItems(appsPerPage: 20)
      
      // Then: Apps should be discovered from all locations
      let allItems = appManager.pages.flatMap { $0 }
      let appPaths = allItems.compactMap { item -> String? in
         if case .app(let app) = item {
            return app.path
         }
         return nil
      }
      
      let hasApp1 = appPaths.contains { $0.hasPrefix(customDir1.path) }
      let hasApp2 = appPaths.contains { $0.hasPrefix(customDir2.path) }
      XCTAssertTrue(hasApp1 || hasApp2, "Should discover apps from multiple custom locations")
   }
   
   func testDiscoverAppsWithInvalidCustomLocation() {
      // Given: An invalid path that doesn't exist
      let invalidPath = "/this/path/does/not/exist"
      
      // When: Adding invalid custom location
      var updatedSettings = settingsManager.settings
      updatedSettings.customAppLocations = [invalidPath]
      settingsManager.saveSettings(newSettings: updatedSettings)
      
      // Then: Should not crash and should still discover default apps
      XCTAssertNoThrow(appManager.loadAppGridItems(appsPerPage: 20))
      XCTAssertGreaterThan(appManager.pages.count, 0, "Should have at least one page")
   }
   
   // MARK: - Codable Tests
   
   func testSettingsCodable() throws {
      // Given: Settings with custom locations
      let locations = ["/custom/path1", "/custom/path2"]
      let settings = LaunchpadSettings(
         columns: 7,
         rows: 5,
         customAppLocations: locations
      )
      
      // When: Encoding and decoding
      let encoder = JSONEncoder()
      let data = try encoder.encode(settings)
      
      let decoder = JSONDecoder()
      let decodedSettings = try decoder.decode(LaunchpadSettings.self, from: data)
      
      // Then: Settings should match
      XCTAssertEqual(decodedSettings.customAppLocations, locations)
      XCTAssertEqual(decodedSettings.columns, 7)
      XCTAssertEqual(decodedSettings.rows, 5)
   }
   
   func testSettingsEquatable() {
      // Given: Two settings with same custom locations
      let locations = ["/custom/path"]
      let settings1 = LaunchpadSettings(customAppLocations: locations)
      let settings2 = LaunchpadSettings(customAppLocations: locations)
      
      // Then: Should be equal
      XCTAssertEqual(settings1, settings2)
      
      // Given: Settings with different custom locations
      let settings3 = LaunchpadSettings(customAppLocations: ["/different/path"])
      
      // Then: Should not be equal
      XCTAssertNotEqual(settings1, settings3)
   }
}
