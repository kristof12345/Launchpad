import XCTest
@testable import LaunchpadPlus

final class UserDefaultsKeysTests: XCTestCase {
   
   // MARK: - Key Value Tests
   
   func testGridItemsKey() {
      XCTAssertEqual(UserDefaultsKeys.gridItems, "LaunchpadAppGridItems",
                     "Grid items key should match expected value")
   }
   
   func testHiddenAppsKey() {
      XCTAssertEqual(UserDefaultsKeys.hiddenApps, "LaunchpadHiddenApps",
                     "Hidden apps key should match expected value")
   }
   
   func testSettingsKey() {
      XCTAssertEqual(UserDefaultsKeys.settings, "LaunchpadSettings",
                     "Settings key should match expected value")
   }
   
   // MARK: - Key Uniqueness Tests
   
   func testAllKeysAreUnique() {
      let keys: Set<String> = [
         UserDefaultsKeys.gridItems,
         UserDefaultsKeys.hiddenApps,
         UserDefaultsKeys.settings
      ]
      
      XCTAssertEqual(keys.count, 3, "All UserDefaults keys should be unique")
   }
   
   // MARK: - Key Prefix Tests
   
   func testAllKeysHaveLaunchpadPrefix() {
      XCTAssertTrue(UserDefaultsKeys.gridItems.hasPrefix("Launchpad"),
                    "Grid items key should have Launchpad prefix")
      XCTAssertTrue(UserDefaultsKeys.hiddenApps.hasPrefix("Launchpad"),
                    "Hidden apps key should have Launchpad prefix")
      XCTAssertTrue(UserDefaultsKeys.settings.hasPrefix("Launchpad"),
                    "Settings key should have Launchpad prefix")
   }
   
   // MARK: - Key Format Tests
   
   func testKeysAreNotEmpty() {
      XCTAssertFalse(UserDefaultsKeys.gridItems.isEmpty, "Grid items key should not be empty")
      XCTAssertFalse(UserDefaultsKeys.hiddenApps.isEmpty, "Hidden apps key should not be empty")
      XCTAssertFalse(UserDefaultsKeys.settings.isEmpty, "Settings key should not be empty")
   }
   
   func testKeysDoNotContainWhitespace() {
      XCTAssertFalse(UserDefaultsKeys.gridItems.contains(" "),
                     "Grid items key should not contain whitespace")
      XCTAssertFalse(UserDefaultsKeys.hiddenApps.contains(" "),
                     "Hidden apps key should not contain whitespace")
      XCTAssertFalse(UserDefaultsKeys.settings.contains(" "),
                     "Settings key should not contain whitespace")
   }
}
