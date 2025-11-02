import XCTest
import SwiftUI
@testable import LaunchpadPlus

final class GridLayoutUtilityTests: XCTestCase {
   
   // MARK: - createGridColumns Tests
   
   func testCreateGridColumnsWithStandardParameters() {
      let columns = GridLayoutUtility.createGridColumns(count: 5, cellWidth: 100, spacing: 10)
      
      XCTAssertEqual(columns.count, 5, "Should create 5 columns")
   }
   
   func testCreateGridColumnsWithZeroCount() {
      let columns = GridLayoutUtility.createGridColumns(count: 0, cellWidth: 100, spacing: 10)
      
      XCTAssertEqual(columns.count, 0, "Should create 0 columns when count is 0")
   }
   
   func testCreateGridColumnsWithSingleColumn() {
      let columns = GridLayoutUtility.createGridColumns(count: 1, cellWidth: 200, spacing: 5)
      
      XCTAssertEqual(columns.count, 1, "Should create 1 column")
   }
   
   func testCreateGridColumnsWithLargeCount() {
      let columns = GridLayoutUtility.createGridColumns(count: 20, cellWidth: 50, spacing: 8)
      
      XCTAssertEqual(columns.count, 20, "Should create 20 columns")
   }
   
   func testCreateGridColumnsWithZeroSpacing() {
      let columns = GridLayoutUtility.createGridColumns(count: 3, cellWidth: 100, spacing: 0)
      
      XCTAssertEqual(columns.count, 3, "Should create columns with zero spacing")
   }
   
   func testCreateGridColumnsWithNegativeSpacing() {
      let columns = GridLayoutUtility.createGridColumns(count: 4, cellWidth: 100, spacing: -5)
      
      XCTAssertEqual(columns.count, 4, "Should create columns even with negative spacing")
   }
   
   // MARK: - createFlexibleGridColumns Tests
   
   func testCreateFlexibleGridColumnsWithStandardParameters() {
      let columns = GridLayoutUtility.createFlexibleGridColumns(count: 6, spacing: 15)
      
      XCTAssertEqual(columns.count, 6, "Should create 6 flexible columns")
   }
   
   func testCreateFlexibleGridColumnsWithDefaultSpacing() {
      let columns = GridLayoutUtility.createFlexibleGridColumns(count: 4)
      
      XCTAssertEqual(columns.count, 4, "Should create 4 flexible columns with default spacing")
   }
   
   func testCreateFlexibleGridColumnsWithZeroCount() {
      let columns = GridLayoutUtility.createFlexibleGridColumns(count: 0, spacing: 10)
      
      XCTAssertEqual(columns.count, 0, "Should create 0 columns when count is 0")
   }
   
   func testCreateFlexibleGridColumnsWithSingleColumn() {
      let columns = GridLayoutUtility.createFlexibleGridColumns(count: 1, spacing: 5)
      
      XCTAssertEqual(columns.count, 1, "Should create 1 flexible column")
   }
   
   func testCreateFlexibleGridColumnsWithLargeCount() {
      let columns = GridLayoutUtility.createFlexibleGridColumns(count: 15, spacing: 12)
      
      XCTAssertEqual(columns.count, 15, "Should create 15 flexible columns")
   }
   
   func testCreateFlexibleGridColumnsWithZeroSpacing() {
      let columns = GridLayoutUtility.createFlexibleGridColumns(count: 3, spacing: 0)
      
      XCTAssertEqual(columns.count, 3, "Should create flexible columns with zero spacing")
   }
   
   // MARK: - Consistency Tests
   
   func testBothMethodsProduceSameCount() {
      let fixedColumns = GridLayoutUtility.createGridColumns(count: 7, cellWidth: 100, spacing: 10)
      let flexibleColumns = GridLayoutUtility.createFlexibleGridColumns(count: 7, spacing: 10)
      
      XCTAssertEqual(fixedColumns.count, flexibleColumns.count, "Both methods should produce same number of columns")
   }
   
   func testRepeatedCallsProduceSameResults() {
      let columns1 = GridLayoutUtility.createGridColumns(count: 5, cellWidth: 100, spacing: 10)
      let columns2 = GridLayoutUtility.createGridColumns(count: 5, cellWidth: 100, spacing: 10)
      
      XCTAssertEqual(columns1.count, columns2.count, "Repeated calls should produce same results")
   }
}
