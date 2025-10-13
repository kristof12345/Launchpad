import XCTest
@testable import Launchpad

@MainActor
final class DockMenuBarSettingsTests: XCTestCase {
    
    // MARK: - Default Values Tests
    
    func testDefaultShowDockIsTrue() {
        let settings = LaunchpadSettings()
        XCTAssertTrue(settings.showDock, "Default showDock should be true")
    }
    
    func testDefaultShowMenuBarIsFalse() {
        let settings = LaunchpadSettings()
        XCTAssertFalse(settings.showMenuBar, "Default showMenuBar should be false")
    }
    
    // MARK: - Independent Control Tests
    
    func testShowDockAndMenuBarAreIndependent() {
        var settings = LaunchpadSettings()
        
        // Test all four combinations
        settings.showDock = true
        settings.showMenuBar = true
        XCTAssertTrue(settings.showDock, "showDock should be true")
        XCTAssertTrue(settings.showMenuBar, "showMenuBar should be true")
        
        settings.showDock = true
        settings.showMenuBar = false
        XCTAssertTrue(settings.showDock, "showDock should be true")
        XCTAssertFalse(settings.showMenuBar, "showMenuBar should be false")
        
        settings.showDock = false
        settings.showMenuBar = true
        XCTAssertFalse(settings.showDock, "showDock should be false")
        XCTAssertTrue(settings.showMenuBar, "showMenuBar should be true")
        
        settings.showDock = false
        settings.showMenuBar = false
        XCTAssertFalse(settings.showDock, "showDock should be false")
        XCTAssertFalse(settings.showMenuBar, "showMenuBar should be false")
    }
    
    // MARK: - Encoding/Decoding Tests
    
    func testShowMenuBarEncodingDecoding() throws {
        var settings = LaunchpadSettings()
        settings.showDock = true
        settings.showMenuBar = true
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(settings)
        
        // Decode
        let decoder = JSONDecoder()
        let decodedSettings = try decoder.decode(LaunchpadSettings.self, from: data)
        
        XCTAssertEqual(decodedSettings.showDock, true, "showDock should survive encoding/decoding")
        XCTAssertEqual(decodedSettings.showMenuBar, true, "showMenuBar should survive encoding/decoding")
    }
    
    func testBackwardCompatibilityWithOldSettings() throws {
        // Simulate old settings JSON that doesn't have showMenuBar field
        let oldSettingsJSON = """
        {
            "columns": 7,
            "rows": 5,
            "iconSize": 100,
            "dropDelay": 0.5,
            "folderColumns": 5,
            "folderRows": 3,
            "scrollDebounceInterval": 0.8,
            "scrollActivationThreshold": 80,
            "showDock": true,
            "transparency": 1.0,
            "startAtLogin": false,
            "productKey": ""
        }
        """
        
        let data = oldSettingsJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        let decodedSettings = try decoder.decode(LaunchpadSettings.self, from: data)
        
        // Old settings should decode successfully with default showMenuBar value
        XCTAssertEqual(decodedSettings.showDock, true, "showDock should decode from old settings")
        XCTAssertEqual(decodedSettings.showMenuBar, false, "showMenuBar should default to false for old settings")
    }
    
    // MARK: - Initialization Tests
    
    func testInitializationWithCustomValues() {
        let settings = LaunchpadSettings(
            showDock: false,
            showMenuBar: true
        )
        
        XCTAssertFalse(settings.showDock, "Custom showDock value should be set")
        XCTAssertTrue(settings.showMenuBar, "Custom showMenuBar value should be set")
    }
    
    func testInitializationWithAllDefaults() {
        let settings = LaunchpadSettings()
        
        XCTAssertEqual(settings.columns, LaunchpadSettings.defaultColumns)
        XCTAssertEqual(settings.rows, LaunchpadSettings.defaultRows)
        XCTAssertEqual(settings.showDock, LaunchpadSettings.defaultShowDock)
        XCTAssertEqual(settings.showMenuBar, LaunchpadSettings.defaultShowMenuBar)
    }
}
