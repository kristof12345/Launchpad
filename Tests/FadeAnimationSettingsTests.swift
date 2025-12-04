import XCTest
@testable import LaunchpadPlus

@MainActor
final class FadeAnimationSettingsTests: XCTestCase {

   var settingsManager: SettingsManager!

   override func setUp() {
      super.setUp()
      settingsManager = SettingsManager.shared

      // Clear test data
      UserDefaults.standard.removeObject(forKey: "LaunchpadSettings")
      UserDefaults.standard.synchronize()
   }

   override func tearDown() {
      UserDefaults.standard.removeObject(forKey: "LaunchpadSettings")
      UserDefaults.standard.synchronize()
      super.tearDown()
   }

   // MARK: - Default Values Tests

   func testDefaultEnableFadeAnimationIsTrue() {
      let settings = LaunchpadSettings()
      XCTAssertTrue(settings.enableFadeAnimation, "Default fade animation should be enabled")
   }

   func testStaticDefaultEnableFadeAnimationIsTrue() {
      XCTAssertTrue(LaunchpadSettings.defaultEnableFadeAnimation, "Static default fade animation should be true")
   }

   // MARK: - Fade Animation Tests

   func testEnableFadeAnimationCanBeDisabled() {
      var settings = LaunchpadSettings()
      settings.enableFadeAnimation = false
      XCTAssertFalse(settings.enableFadeAnimation, "Fade animation should be disabled")
   }

   func testEnableFadeAnimationCanBeEnabled() {
      var settings = LaunchpadSettings(enableFadeAnimation: false)
      settings.enableFadeAnimation = true
      XCTAssertTrue(settings.enableFadeAnimation, "Fade animation should be enabled")
   }

   // MARK: - Settings Persistence Tests

   func testFadeAnimationPersistence() {
      // Update settings to disable fade animation
      var updatedSettings = settingsManager.settings
      updatedSettings.enableFadeAnimation = false
      settingsManager.saveSettings(newSettings: updatedSettings)

      // Verify it's saved
      XCTAssertFalse(settingsManager.settings.enableFadeAnimation, "Fade animation setting should be saved")
   }

   func testFadeAnimationPersistenceWhenEnabled() {
      // Update settings to enable fade animation
      var updatedSettings = settingsManager.settings
      updatedSettings.enableFadeAnimation = true
      settingsManager.saveSettings(newSettings: updatedSettings)

      // Verify it's saved
      XCTAssertTrue(settingsManager.settings.enableFadeAnimation, "Fade animation setting should be saved")
   }

   // MARK: - Settings Initialization Tests

   func testFadeAnimationInInit() {
      let settings = LaunchpadSettings(enableFadeAnimation: false)
      XCTAssertFalse(settings.enableFadeAnimation, "Fade animation should be disabled in init")
   }

   func testFadeAnimationDefaultInInit() {
      let settings = LaunchpadSettings()
      XCTAssertTrue(settings.enableFadeAnimation, "Fade animation should default to enabled in init")
   }

   // MARK: - Settings Codable Tests

   func testFadeAnimationEncodingDecoding() throws {
      var settings = LaunchpadSettings()
      settings.enableFadeAnimation = false

      // Encode
      let encoder = JSONEncoder()
      let data = try encoder.encode(settings)

      // Decode
      let decoder = JSONDecoder()
      let decodedSettings = try decoder.decode(LaunchpadSettings.self, from: data)

      XCTAssertFalse(decodedSettings.enableFadeAnimation, "Fade animation should survive encoding/decoding")
      XCTAssertEqual(settings, decodedSettings, "Settings should be equal after encoding/decoding")
   }

   func testFadeAnimationEnabledEncodingDecoding() throws {
      var settings = LaunchpadSettings()
      settings.enableFadeAnimation = true

      // Encode
      let encoder = JSONEncoder()
      let data = try encoder.encode(settings)

      // Decode
      let decoder = JSONDecoder()
      let decodedSettings = try decoder.decode(LaunchpadSettings.self, from: data)

      XCTAssertTrue(decodedSettings.enableFadeAnimation, "Fade animation should survive encoding/decoding")
      XCTAssertEqual(settings, decodedSettings, "Settings should be equal after encoding/decoding")
   }

   // MARK: - Integration Tests

   func testFadeAnimationWithOtherAnimationSettings() {
      let settings = LaunchpadSettings(
         enableIconAnimation: false,
         enableFadeAnimation: true
      )

      XCTAssertFalse(settings.enableIconAnimation, "Icon animation should be disabled")
      XCTAssertTrue(settings.enableFadeAnimation, "Fade animation should be enabled")
   }

   func testResetToDefaultsResetsFadeAnimation() {
      // Disable fade animation
      var settings = LaunchpadSettings()
      settings.enableFadeAnimation = false
      settingsManager.saveSettings(newSettings: settings)

      // Reset to defaults
      settingsManager.resetToDefaults()

      // Verify reset
      XCTAssertTrue(settingsManager.settings.enableFadeAnimation, "Fade animation should be reset to default (true)")
   }

   func testFadeAnimationIndependentOfIconAnimation() {
      // Test that changing icon animation doesn't affect fade animation
      var settings = LaunchpadSettings()
      settings.enableIconAnimation = false
      settings.enableFadeAnimation = true

      XCTAssertFalse(settings.enableIconAnimation, "Icon animation should be independent")
      XCTAssertTrue(settings.enableFadeAnimation, "Fade animation should be independent")

      // Test opposite
      settings.enableIconAnimation = true
      settings.enableFadeAnimation = false

      XCTAssertTrue(settings.enableIconAnimation, "Icon animation should be independent")
      XCTAssertFalse(settings.enableFadeAnimation, "Fade animation should be independent")
   }
}
