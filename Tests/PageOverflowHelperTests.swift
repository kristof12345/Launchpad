import XCTest
import AppKit
@testable import LaunchpadPlus

@MainActor
final class PageOverflowHelperTests: XCTestCase {
   
   private func createMockApp(name: String, page: Int) -> AppInfo {
      let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
      return AppInfo(
         name: name,
         icon: mockIcon,
         path: "/Applications/\(name).app",
         bundleId: "com.test.\(name.lowercased())",
         lastOpenedDate: nil,
         installDate: nil,
         page: page
      )
   }
   
   // MARK: - Basic Overflow Tests
   
   func testHandleOverflowWithExactlyMaxItems() {
      // Given: A page with exactly the max number of items
      var pages: [[AppGridItem]] = [
         [
            .app(createMockApp(name: "App1", page: 0)),
            .app(createMockApp(name: "App2", page: 0)),
            .app(createMockApp(name: "App3", page: 0))
         ]
      ]
      let appsPerPage = 3
      
      // When: Handling overflow
      PageOverflowHelper.handleOverflow(pages: &pages, pageIndex: 0, appsPerPage: appsPerPage)
      
      // Then: No overflow should occur
      XCTAssertEqual(pages.count, 1, "Should still have 1 page")
      XCTAssertEqual(pages[0].count, 3, "First page should still have 3 items")
   }
   
   func testHandleOverflowWithOneExtraItem() {
      // Given: A page with one extra item
      var pages: [[AppGridItem]] = [
         [
            .app(createMockApp(name: "App1", page: 0)),
            .app(createMockApp(name: "App2", page: 0)),
            .app(createMockApp(name: "App3", page: 0)),
            .app(createMockApp(name: "App4", page: 0))
         ]
      ]
      let appsPerPage = 3
      
      // When: Handling overflow
      PageOverflowHelper.handleOverflow(pages: &pages, pageIndex: 0, appsPerPage: appsPerPage)
      
      // Then: One item should move to a new page
      XCTAssertEqual(pages.count, 2, "Should have 2 pages after overflow")
      XCTAssertEqual(pages[0].count, 3, "First page should have max items")
      XCTAssertEqual(pages[1].count, 1, "Second page should have overflow item")
   }
   
   func testHandleOverflowWithMultipleExtraItems() {
      // Given: A page with multiple extra items
      var pages: [[AppGridItem]] = [
         [
            .app(createMockApp(name: "App1", page: 0)),
            .app(createMockApp(name: "App2", page: 0)),
            .app(createMockApp(name: "App3", page: 0)),
            .app(createMockApp(name: "App4", page: 0)),
            .app(createMockApp(name: "App5", page: 0))
         ]
      ]
      let appsPerPage = 3
      
      // When: Handling overflow
      PageOverflowHelper.handleOverflow(pages: &pages, pageIndex: 0, appsPerPage: appsPerPage)
      
      // Then: Extra items should move to a new page
      XCTAssertEqual(pages.count, 2, "Should have 2 pages after overflow")
      XCTAssertEqual(pages[0].count, 3, "First page should have max items")
      XCTAssertEqual(pages[1].count, 2, "Second page should have overflow items")
   }
   
   // MARK: - Cascading Overflow Tests
   
   func testHandleOverflowWithCascadingToExistingPage() {
      // Given: Two pages where overflow will cascade
      var pages: [[AppGridItem]] = [
         [
            .app(createMockApp(name: "App1", page: 0)),
            .app(createMockApp(name: "App2", page: 0)),
            .app(createMockApp(name: "App3", page: 0)),
            .app(createMockApp(name: "App4", page: 0))
         ],
         [
            .app(createMockApp(name: "App5", page: 1)),
            .app(createMockApp(name: "App6", page: 1)),
            .app(createMockApp(name: "App7", page: 1))
         ]
      ]
      let appsPerPage = 3
      
      // When: Handling overflow on first page
      PageOverflowHelper.handleOverflow(pages: &pages, pageIndex: 0, appsPerPage: appsPerPage)
      
      // Then: Overflow should cascade to next page
      XCTAssertEqual(pages.count, 3, "Should have 3 pages after cascading overflow")
      XCTAssertEqual(pages[0].count, 3, "First page should have max items")
      XCTAssertEqual(pages[1].count, 3, "Second page should have max items")
      XCTAssertEqual(pages[2].count, 1, "Third page should have cascaded overflow")
   }
   
   func testHandleOverflowWithMultipleCascades() {
      // Given: Pages that will trigger multiple cascades
      var pages: [[AppGridItem]] = [
         [
            .app(createMockApp(name: "App1", page: 0)),
            .app(createMockApp(name: "App2", page: 0)),
            .app(createMockApp(name: "App3", page: 0)),
            .app(createMockApp(name: "App4", page: 0)),
            .app(createMockApp(name: "App5", page: 0))
         ],
         [
            .app(createMockApp(name: "App6", page: 1)),
            .app(createMockApp(name: "App7", page: 1)),
            .app(createMockApp(name: "App8", page: 1))
         ]
      ]
      let appsPerPage = 3
      
      // When: Handling overflow
      PageOverflowHelper.handleOverflow(pages: &pages, pageIndex: 0, appsPerPage: appsPerPage)
      
      // Then: Multiple cascades should occur
      XCTAssertEqual(pages.count, 3, "Should have 3 pages after cascading")
      XCTAssertEqual(pages[0].count, 3, "First page should have max items")
      XCTAssertEqual(pages[1].count, 3, "Second page should have max items")
      XCTAssertEqual(pages[2].count, 2, "Third page should have remaining items")
   }
   
   // MARK: - Page Number Update Tests
   
   func testOverflowUpdatesPageNumbers() {
      // Given: A page with overflow
      var pages: [[AppGridItem]] = [
         [
            .app(createMockApp(name: "App1", page: 0)),
            .app(createMockApp(name: "App2", page: 0)),
            .app(createMockApp(name: "App3", page: 0)),
            .app(createMockApp(name: "App4", page: 0))
         ]
      ]
      let appsPerPage = 3
      
      // When: Handling overflow
      PageOverflowHelper.handleOverflow(pages: &pages, pageIndex: 0, appsPerPage: appsPerPage)
      
      // Then: Page numbers should be updated
      XCTAssertEqual(pages[0][0].page, 0, "Items on page 0 should have page 0")
      XCTAssertEqual(pages[1][0].page, 1, "Items on page 1 should have page 1")
   }
   
   // MARK: - Edge Cases
   
   func testHandleOverflowWithEmptyPage() {
      // Given: An empty page
      var pages: [[AppGridItem]] = [[]]
      let appsPerPage = 3
      
      // When: Handling overflow
      PageOverflowHelper.handleOverflow(pages: &pages, pageIndex: 0, appsPerPage: appsPerPage)
      
      // Then: Nothing should change
      XCTAssertEqual(pages.count, 1, "Should still have 1 page")
      XCTAssertEqual(pages[0].count, 0, "Page should still be empty")
   }
   
   func testHandleOverflowWithMiddlePage() {
      // Given: Three pages where the middle one has overflow
      var pages: [[AppGridItem]] = [
         [
            .app(createMockApp(name: "App1", page: 0)),
            .app(createMockApp(name: "App2", page: 0))
         ],
         [
            .app(createMockApp(name: "App3", page: 1)),
            .app(createMockApp(name: "App4", page: 1)),
            .app(createMockApp(name: "App5", page: 1)),
            .app(createMockApp(name: "App6", page: 1))
         ],
         [
            .app(createMockApp(name: "App7", page: 2))
         ]
      ]
      let appsPerPage = 3
      
      // When: Handling overflow on middle page
      PageOverflowHelper.handleOverflow(pages: &pages, pageIndex: 1, appsPerPage: appsPerPage)
      
      // Then: Overflow should go to next page
      XCTAssertEqual(pages.count, 3, "Should still have 3 pages")
      XCTAssertEqual(pages[1].count, 3, "Middle page should have max items")
      XCTAssertEqual(pages[2].count, 2, "Last page should have overflow item")
   }
}
