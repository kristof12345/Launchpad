import XCTest
@testable import LaunchpadPlus

final class SearchNavigationHelperTests: XCTestCase {
   
   // MARK: - Navigate Left Tests
   
   func testNavigateLeftFromMiddle() {
      let newIndex = SearchNavigationHelper.navigateLeft(currentIndex: 5, itemCount: 10)
      XCTAssertEqual(newIndex, 4, "Should move left by one position")
   }
   
   func testNavigateLeftFromStart() {
      let newIndex = SearchNavigationHelper.navigateLeft(currentIndex: 0, itemCount: 10)
      XCTAssertEqual(newIndex, 9, "Should wrap to the end when at start")
   }
   
   func testNavigateLeftWithEmptyList() {
      let newIndex = SearchNavigationHelper.navigateLeft(currentIndex: 0, itemCount: 0)
      XCTAssertEqual(newIndex, 0, "Should stay at same index for empty list")
   }
   
   func testNavigateLeftWithSingleItem() {
      let newIndex = SearchNavigationHelper.navigateLeft(currentIndex: 0, itemCount: 1)
      XCTAssertEqual(newIndex, 0, "Should wrap to same position with single item")
   }
   
   // MARK: - Navigate Right Tests
   
   func testNavigateRightFromMiddle() {
      let newIndex = SearchNavigationHelper.navigateRight(currentIndex: 5, itemCount: 10)
      XCTAssertEqual(newIndex, 6, "Should move right by one position")
   }
   
   func testNavigateRightFromEnd() {
      let newIndex = SearchNavigationHelper.navigateRight(currentIndex: 9, itemCount: 10)
      XCTAssertEqual(newIndex, 0, "Should wrap to the start when at end")
   }
   
   func testNavigateRightWithEmptyList() {
      let newIndex = SearchNavigationHelper.navigateRight(currentIndex: 0, itemCount: 0)
      XCTAssertEqual(newIndex, 0, "Should stay at same index for empty list")
   }
   
   func testNavigateRightWithSingleItem() {
      let newIndex = SearchNavigationHelper.navigateRight(currentIndex: 0, itemCount: 1)
      XCTAssertEqual(newIndex, 0, "Should wrap to same position with single item")
   }
   
   // MARK: - Navigate Up Tests
   
   func testNavigateUpFromSecondRow() {
      // Grid: 5 columns, starting from index 7 (second row, third column)
      let newIndex = SearchNavigationHelper.navigateUp(currentIndex: 7, itemCount: 15, columns: 5)
      XCTAssertEqual(newIndex, 2, "Should move up one row (7 - 5 = 2)")
   }
   
   func testNavigateUpFromFirstRow() {
      // Grid: 5 columns, starting from index 2 (first row, third column)
      let newIndex = SearchNavigationHelper.navigateUp(currentIndex: 2, itemCount: 15, columns: 5)
      XCTAssertEqual(newIndex, 12, "Should wrap to bottom row, same column")
   }
   
   func testNavigateUpFromFirstRowLastColumn() {
      // Grid: 5 columns, 13 items total, starting from index 4 (first row, last column)
      // Last row has 3 items (10, 11, 12)
      let newIndex = SearchNavigationHelper.navigateUp(currentIndex: 4, itemCount: 13, columns: 5)
      XCTAssertEqual(newIndex, 12, "Should wrap to last valid item in bottom row")
   }
   
   func testNavigateUpWithEmptyList() {
      let newIndex = SearchNavigationHelper.navigateUp(currentIndex: 0, itemCount: 0, columns: 5)
      XCTAssertEqual(newIndex, 0, "Should stay at same index for empty list")
   }
   
   func testNavigateUpWithSingleRow() {
      // Only 3 items in a 5-column grid
      let newIndex = SearchNavigationHelper.navigateUp(currentIndex: 2, itemCount: 3, columns: 5)
      XCTAssertEqual(newIndex, 2, "Should wrap to same position in single row")
   }
   
   // MARK: - Navigate Down Tests
   
   func testNavigateDownFromFirstRow() {
      // Grid: 5 columns, starting from index 2 (first row, third column)
      let newIndex = SearchNavigationHelper.navigateDown(currentIndex: 2, itemCount: 15, columns: 5)
      XCTAssertEqual(newIndex, 7, "Should move down one row (2 + 5 = 7)")
   }
   
   func testNavigateDownFromLastRow() {
      // Grid: 5 columns, starting from index 12 (last row, third column)
      let newIndex = SearchNavigationHelper.navigateDown(currentIndex: 12, itemCount: 15, columns: 5)
      XCTAssertEqual(newIndex, 2, "Should wrap to top row, same column")
   }
   
   func testNavigateDownFromLastRowToShorterRow() {
      // Grid: 5 columns, 13 items, starting from index 11 (last row, second column)
      let newIndex = SearchNavigationHelper.navigateDown(currentIndex: 11, itemCount: 13, columns: 5)
      XCTAssertEqual(newIndex, 1, "Should wrap to top row, same column offset")
   }
   
   func testNavigateDownWhenNextRowIsShorter() {
      // Grid: 5 columns, 13 items, starting from index 9 (third row, last column)
      // Next row would be index 14, but only 13 items exist
      let newIndex = SearchNavigationHelper.navigateDown(currentIndex: 9, itemCount: 13, columns: 5)
      XCTAssertEqual(newIndex, 4, "Should wrap to top row when next row doesn't exist")
   }
   
   func testNavigateDownWithEmptyList() {
      let newIndex = SearchNavigationHelper.navigateDown(currentIndex: 0, itemCount: 0, columns: 5)
      XCTAssertEqual(newIndex, 0, "Should stay at same index for empty list")
   }
   
   func testNavigateDownWithSingleRow() {
      // Only 3 items in a 5-column grid
      let newIndex = SearchNavigationHelper.navigateDown(currentIndex: 1, itemCount: 3, columns: 5)
      XCTAssertEqual(newIndex, 1, "Should wrap to same column in top row")
   }
   
   // MARK: - Edge Case Tests
   
   func testNavigationWithOneColumn() {
      // Vertical list (1 column)
      let upIndex = SearchNavigationHelper.navigateUp(currentIndex: 2, itemCount: 5, columns: 1)
      let downIndex = SearchNavigationHelper.navigateDown(currentIndex: 2, itemCount: 5, columns: 1)
      
      XCTAssertEqual(upIndex, 1, "Should move up in vertical list")
      XCTAssertEqual(downIndex, 3, "Should move down in vertical list")
   }
   
   func testNavigationWithManyColumns() {
      // Horizontal list (more columns than items)
      let upIndex = SearchNavigationHelper.navigateUp(currentIndex: 2, itemCount: 3, columns: 10)
      let downIndex = SearchNavigationHelper.navigateDown(currentIndex: 2, itemCount: 3, columns: 10)
      
      XCTAssertEqual(upIndex, 2, "Should wrap to same position when row doesn't exist")
      XCTAssertEqual(downIndex, 2, "Should wrap to same position when row doesn't exist")
   }
}
