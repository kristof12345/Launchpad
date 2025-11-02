import XCTest
@testable import LaunchpadPlus

@MainActor
final class ActivationSettingsTests: XCTestCase {

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

   // MARK: - Product Key Tests

   func testDefaultProductKeyIsEmpty() {
      let settings = LaunchpadSettings()
      XCTAssertEqual(settings.productKey, "", "Default product key should be empty")
   }

   func testValidProductKeyActivatesApp() {
      var settings = LaunchpadSettings()
      settings.productKey = "BASIC"
      XCTAssertTrue(settings.isActivated, "Should be activated with valid product key")
   }

   // MARK: - Settings Persistence Tests

   func testProductKeyPersistence() {
      let testKey = "TEST-KEY-12345"

      // Update settings with product key
      var updatedSettings = settingsManager.settings
      updatedSettings.productKey = testKey
      settingsManager.saveSettings(newSettings: updatedSettings)

      // Verify it's saved
      XCTAssertEqual(settingsManager.settings.productKey, testKey, "Product key should be saved in settings")
   }

   func testActivationPersistence() {
      // Set valid product key
      var updatedSettings = settingsManager.settings
      updatedSettings.productKey = "BASIC"
      settingsManager.saveSettings(newSettings: updatedSettings)

      // Verify activation status
      XCTAssertTrue(settingsManager.settings.isActivated, "Settings should show as activated")
      XCTAssertEqual(settingsManager.settings.productKey, "BASIC", "Product key should match constant")
   }

   func testProductKeyInSettingsInit() {
      let customKey = "CUSTOM-KEY"
      let settings = LaunchpadSettings(productKey: customKey)
      XCTAssertEqual(settings.productKey, customKey, "Custom product key should be set in init")
   }

   // MARK: - Settings Codable Tests

   func testProductKeyEncodingDecoding() throws {
      var settings = LaunchpadSettings()
      settings.productKey = "ENCODED-KEY"

      // Encode
      let encoder = JSONEncoder()
      let data = try encoder.encode(settings)

      // Decode
      let decoder = JSONDecoder()
      let decodedSettings = try decoder.decode(LaunchpadSettings.self, from: data)

      XCTAssertEqual(decodedSettings.productKey, "ENCODED-KEY", "Product key should survive encoding/decoding")
      XCTAssertEqual(settings, decodedSettings, "Settings should be equal after encoding/decoding")
   }

   func testActivationStatusAfterDecoding() throws {
      var settings = LaunchpadSettings()
      settings.productKey = "BASIC"

      // Encode
      let encoder = JSONEncoder()
      let data = try encoder.encode(settings)

      // Decode
      let decoder = JSONDecoder()
      let decodedSettings = try decoder.decode(LaunchpadSettings.self, from: data)

      XCTAssertTrue(decodedSettings.isActivated, "Activation status should be preserved after decoding")
   }
}
