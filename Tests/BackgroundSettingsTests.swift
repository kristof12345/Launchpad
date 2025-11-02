import XCTest
@testable import LaunchpadPlus

@MainActor
final class BackgroundSettingsTests: XCTestCase {

   var settingsManager: SettingsManager!

   override func setUp() {
      super.setUp()
      settingsManager = SettingsManager.shared

      // Clear test data
      UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.settings)
      UserDefaults.standard.synchronize()
   }

   override func tearDown() {
      UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.settings)
      UserDefaults.standard.synchronize()
      super.tearDown()
   }

   // MARK: - Default Values Tests

   func testDefaultBackgroundTypeIsDefault() {
      let settings = LaunchpadSettings()
      XCTAssertEqual(settings.backgroundType, .default, "Default background type should be .default")
   }

   func testDefaultCustomBackgroundPathIsEmpty() {
      let settings = LaunchpadSettings()
      XCTAssertEqual(settings.customBackgroundPath, "", "Default custom background path should be empty")
   }

   // MARK: - Background Type Tests

   func testBackgroundTypeCanBeSetToWallpaper() {
      var settings = LaunchpadSettings()
      settings.backgroundType = .wallpaper
      XCTAssertEqual(settings.backgroundType, .wallpaper, "Background type should be .wallpaper")
   }

   func testBackgroundTypeCanBeSetToCustom() {
      var settings = LaunchpadSettings()
      settings.backgroundType = .custom
      XCTAssertEqual(settings.backgroundType, .custom, "Background type should be .custom")
   }

   func testAllBackgroundTypesAreAvailable() {
      let allCases = BackgroundType.allCases
      XCTAssertEqual(allCases.count, 3, "Should have exactly 3 background types")
      XCTAssertTrue(allCases.contains(.default), "Should include .default")
      XCTAssertTrue(allCases.contains(.wallpaper), "Should include .wallpaper")
      XCTAssertTrue(allCases.contains(.custom), "Should include .custom")
   }

   // MARK: - Custom Background Path Tests

   func testCustomBackgroundPathCanBeSet() {
      var settings = LaunchpadSettings()
      let testPath = "/Users/test/Pictures/background.png"
      settings.customBackgroundPath = testPath
      XCTAssertEqual(settings.customBackgroundPath, testPath, "Custom background path should be set")
   }

   // MARK: - Settings Persistence Tests

   func testBackgroundTypePersistence() {
      // Update settings with wallpaper background
      var updatedSettings = settingsManager.settings
      updatedSettings.backgroundType = .wallpaper
      settingsManager.saveSettings(newSettings: updatedSettings)

      // Verify it's saved
      XCTAssertEqual(settingsManager.settings.backgroundType, .wallpaper, "Background type should be saved")
   }

   func testCustomBackgroundPathPersistence() {
      let testPath = "/Users/test/Pictures/custom.jpg"

      // Update settings with custom path
      var updatedSettings = settingsManager.settings
      updatedSettings.backgroundType = .custom
      updatedSettings.customBackgroundPath = testPath
      settingsManager.saveSettings(newSettings: updatedSettings)

      // Verify both are saved
      XCTAssertEqual(settingsManager.settings.backgroundType, .custom, "Background type should be saved")
      XCTAssertEqual(settingsManager.settings.customBackgroundPath, testPath, "Custom path should be saved")
   }

   // MARK: - Settings Initialization Tests

   func testBackgroundSettingsInInit() {
      let settings = LaunchpadSettings(
         backgroundType: .custom,
         customBackgroundPath: "/test/path.png"
      )
      XCTAssertEqual(settings.backgroundType, .custom, "Background type should be set in init")
      XCTAssertEqual(settings.customBackgroundPath, "/test/path.png", "Custom path should be set in init")
   }

   // MARK: - Settings Codable Tests

   func testBackgroundSettingsEncodingDecoding() throws {
      var settings = LaunchpadSettings()
      settings.backgroundType = .wallpaper
      settings.customBackgroundPath = "/test/wallpaper.png"

      // Encode
      let encoder = JSONEncoder()
      let data = try encoder.encode(settings)

      // Decode
      let decoder = JSONDecoder()
      let decodedSettings = try decoder.decode(LaunchpadSettings.self, from: data)

      XCTAssertEqual(decodedSettings.backgroundType, .wallpaper, "Background type should survive encoding/decoding")
      XCTAssertEqual(decodedSettings.customBackgroundPath, "/test/wallpaper.png", "Custom path should survive encoding/decoding")
      XCTAssertEqual(settings, decodedSettings, "Settings should be equal after encoding/decoding")
   }

   func testBackgroundTypeRawValues() {
      XCTAssertEqual(BackgroundType.default.rawValue, "default", "Default raw value should be 'default'")
      XCTAssertEqual(BackgroundType.wallpaper.rawValue, "wallpaper", "Wallpaper raw value should be 'wallpaper'")
      XCTAssertEqual(BackgroundType.custom.rawValue, "custom", "Custom raw value should be 'custom'")
   }

   func testBackgroundTypeFromRawValue() {
      XCTAssertEqual(BackgroundType(rawValue: "default"), .default, "Should create .default from raw value")
      XCTAssertEqual(BackgroundType(rawValue: "wallpaper"), .wallpaper, "Should create .wallpaper from raw value")
      XCTAssertEqual(BackgroundType(rawValue: "custom"), .custom, "Should create .custom from raw value")
      XCTAssertNil(BackgroundType(rawValue: "invalid"), "Should return nil for invalid raw value")
   }

   // MARK: - Integration Tests

   func testBackgroundSettingsWithOtherSettings() {
      let settings = LaunchpadSettings(
         columns: 8,
         rows: 6,
         backgroundType: .custom,
         customBackgroundPath: "/path/to/image.png"
      )

      XCTAssertEqual(settings.columns, 8, "Columns should be preserved")
      XCTAssertEqual(settings.rows, 6, "Rows should be preserved")
      XCTAssertEqual(settings.backgroundType, .custom, "Background type should be set")
      XCTAssertEqual(settings.customBackgroundPath, "/path/to/image.png", "Custom path should be set")
   }

   func testResetToDefaultsResetsBackground() {
      // Set custom background
      var settings = LaunchpadSettings()
      settings.backgroundType = .custom
      settings.customBackgroundPath = "/some/path.jpg"
      settingsManager.saveSettings(newSettings: settings)

      // Reset to defaults
      settingsManager.resetToDefaults()

      // Verify reset
      XCTAssertEqual(settingsManager.settings.backgroundType, .default, "Background type should be reset to default")
      XCTAssertEqual(settingsManager.settings.customBackgroundPath, "", "Custom path should be reset to empty")
   }
}
