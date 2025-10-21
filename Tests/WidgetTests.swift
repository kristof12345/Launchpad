import XCTest
import AppKit
@testable import Launchpad

@MainActor
final class WidgetTests: XCTestCase {
   
   var appManager: AppManager!
   let testSuiteName = "test.launchpad.widgets"
   
   override func setUp() {
      super.setUp()
      appManager = AppManager.shared
      
      // Clear test data
      UserDefaults.standard.removeObject(forKey: "LaunchpadGridItems")
      UserDefaults.standard.synchronize()
   }
   
   override func tearDown() {
      UserDefaults.standard.removeObject(forKey: "LaunchpadGridItems")
      UserDefaults.standard.synchronize()
      super.tearDown()
   }
   
   // MARK: - Widget Model Tests
   
   func testWidgetCreation() {
      let widget = Widget(name: "Clock", type: .clock, size: .medium, page: 0)
      
      XCTAssertEqual(widget.name, "Clock")
      XCTAssertEqual(widget.type, .clock)
      XCTAssertEqual(widget.size, .medium)
      XCTAssertEqual(widget.page, 0)
      XCTAssertTrue(widget.configuration.isEmpty)
   }
   
   func testWidgetWithConfiguration() {
      let config = ["timezone": "UTC", "format": "24h"]
      let widget = Widget(name: "World Clock", type: .clock, size: .large, page: 1, configuration: config)
      
      XCTAssertEqual(widget.configuration["timezone"], "UTC")
      XCTAssertEqual(widget.configuration["format"], "24h")
   }
   
   func testWidgetTypeDefaultSize() {
      XCTAssertEqual(WidgetType.clock.defaultSize, .medium)
      XCTAssertEqual(WidgetType.calendar.defaultSize, .medium)
      XCTAssertEqual(WidgetType.weather.defaultSize, .small)
      XCTAssertEqual(WidgetType.notes.defaultSize, .large)
   }
   
   func testWidgetSizeGridSpan() {
      XCTAssertEqual(WidgetSize.small.gridSpan, 1)
      XCTAssertEqual(WidgetSize.medium.gridSpan, 2)
      XCTAssertEqual(WidgetSize.large.gridSpan, 3)
   }
   
   // MARK: - AppGridItem Widget Tests
   
   func testAppGridItemWidgetCase() {
      let widget = Widget(name: "Test Widget", type: .clock, size: .small, page: 0)
      let gridItem = AppGridItem.widget(widget)
      
      XCTAssertEqual(gridItem.name, "Test Widget")
      XCTAssertEqual(gridItem.page, 0)
      XCTAssertFalse(gridItem.isFolder)
      XCTAssertNotNil(gridItem.widget)
      XCTAssertNil(gridItem.appInfo)
      XCTAssertNil(gridItem.folder)
   }
   
   func testWidgetEquality() {
      let widget1 = Widget(id: UUID(), name: "Clock", type: .clock, size: .medium, page: 0)
      let widget2 = Widget(id: widget1.id, name: "Clock", type: .clock, size: .medium, page: 0)
      let widget3 = Widget(id: UUID(), name: "Calendar", type: .calendar, size: .medium, page: 0)
      
      let item1 = AppGridItem.widget(widget1)
      let item2 = AppGridItem.widget(widget2)
      let item3 = AppGridItem.widget(widget3)
      
      XCTAssertEqual(item1, item2)
      XCTAssertNotEqual(item1, item3)
   }
   
   // MARK: - Widget Serialization Tests
   
   func testWidgetSerialization() {
      let widget = Widget(name: "Clock Widget", type: .clock, size: .medium, page: 1, configuration: ["format": "12h"])
      let gridItem = AppGridItem.widget(widget)
      
      let serialized = gridItem.serialize()
      
      XCTAssertEqual(serialized["type"] as? String, "widget")
      XCTAssertEqual(serialized["name"] as? String, "Clock Widget")
      XCTAssertEqual(serialized["widgetType"] as? String, "clock")
      XCTAssertEqual(serialized["size"] as? String, "medium")
      XCTAssertEqual(serialized["page"] as? Int, 1)
      XCTAssertNotNil(serialized["id"])
      
      let config = serialized["configuration"] as? [String: String]
      XCTAssertEqual(config?["format"], "12h")
   }
   
   // MARK: - Widget Manager Tests
   
   func testAddWidget() {
      appManager.pages = [[]]
      
      appManager.addWidget(type: .clock, size: .medium, page: 0, appsPerPage: 12)
      
      XCTAssertFalse(appManager.pages.isEmpty)
      
      let firstPageItems = appManager.pages[0]
      let widgetItems = firstPageItems.filter { if case .widget = $0 { return true } else { return false } }
      
      XCTAssertEqual(widgetItems.count, 1)
      
      if case .widget(let widget) = widgetItems.first {
         XCTAssertEqual(widget.type, .clock)
         XCTAssertEqual(widget.size, .medium)
      } else {
         XCTFail("Expected widget item")
      }
   }
   
   func testAddMultipleWidgets() {
      appManager.pages = [[]]
      
      appManager.addWidget(type: .clock, size: .small, page: 0, appsPerPage: 12)
      appManager.addWidget(type: .weather, size: .small, page: 0, appsPerPage: 12)
      
      let allItems = appManager.pages.flatMap { $0 }
      let widgetItems = allItems.filter { if case .widget = $0 { return true } else { return false } }
      
      XCTAssertEqual(widgetItems.count, 2)
   }
   
   func testRemoveWidget() {
      let widget = Widget(name: "Test", type: .clock, size: .small, page: 0)
      appManager.pages = [[.widget(widget)]]
      
      appManager.removeWidget(id: widget.id, appsPerPage: 12)
      
      let allItems = appManager.pages.flatMap { $0 }
      let widgetItems = allItems.filter { if case .widget = $0 { return true } else { return false } }
      
      XCTAssertEqual(widgetItems.count, 0)
   }
   
   func testRemoveNonExistentWidget() {
      let widget = Widget(name: "Test", type: .clock, size: .small, page: 0)
      appManager.pages = [[.widget(widget)]]
      
      let nonExistentId = UUID()
      appManager.removeWidget(id: nonExistentId, appsPerPage: 12)
      
      let allItems = appManager.pages.flatMap { $0 }
      let widgetItems = allItems.filter { if case .widget = $0 { return true } else { return false } }
      
      // Should still have the original widget
      XCTAssertEqual(widgetItems.count, 1)
   }
   
   // MARK: - Widget Persistence Tests
   
   func testWidgetPersistence() {
      // Create and save widget
      let widget = Widget(name: "Clock", type: .clock, size: .medium, page: 0)
      appManager.pages = [[.widget(widget)]]
      appManager.saveGridItems()
      
      // Clear pages
      appManager.pages = [[]]
      
      // Load and verify
      appManager.loadGridItems(appsPerPage: 12)
      
      let allItems = appManager.pages.flatMap { $0 }
      let widgetItems = allItems.filter { if case .widget = $0 { return true } else { return false } }
      
      XCTAssertGreaterThanOrEqual(widgetItems.count, 1)
      
      if case .widget(let loadedWidget) = widgetItems.first {
         XCTAssertEqual(loadedWidget.name, "Clock")
         XCTAssertEqual(loadedWidget.type, .clock)
         XCTAssertEqual(loadedWidget.size, .medium)
      } else {
         XCTFail("Expected widget item")
      }
   }
   
   func testMixedItemsPersistence() {
      // Create mixed items
      let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
      let app = AppInfo(name: "Test App", icon: mockIcon, path: "/Applications/Test.app", bundleId: "com.test", lastOpenedDate: nil, installDate: nil, page: 0)
      let widget = Widget(name: "Clock", type: .clock, size: .small, page: 0)
      
      appManager.pages = [[.app(app), .widget(widget)]]
      appManager.saveGridItems()
      
      // Clear and reload
      appManager.pages = [[]]
      appManager.loadGridItems(appsPerPage: 12)
      
      let allItems = appManager.pages.flatMap { $0 }
      let widgetItems = allItems.filter { if case .widget = $0 { return true } else { return false } }
      
      XCTAssertGreaterThanOrEqual(widgetItems.count, 1)
   }
   
   // MARK: - Widget Update Page Tests
   
   func testWidgetUpdatePage() {
      let widget = Widget(name: "Clock", type: .clock, size: .medium, page: 0)
      let gridItem = AppGridItem.widget(widget)
      
      let updatedItem = gridItem.withUpdatedPage(2)
      
      XCTAssertEqual(updatedItem.page, 2)
      
      if case .widget(let updatedWidget) = updatedItem {
         XCTAssertEqual(updatedWidget.page, 2)
         XCTAssertEqual(updatedWidget.name, "Clock")
         XCTAssertEqual(updatedWidget.type, .clock)
         XCTAssertEqual(updatedWidget.size, .medium)
      } else {
         XCTFail("Expected widget item")
      }
   }
}
