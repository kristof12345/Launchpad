import XCTest
@testable import LaunchpadPlus

@MainActor
final class DropHelperTests: XCTestCase {
   
   // MARK: - calculateMoveOffset Tests
   
   func testCalculateMoveOffsetMovingForward() {
      // When moving from index 2 to index 5
      let offset = DropHelper.calculateMoveOffset(fromIndex: 2, toIndex: 5)
      
      // Should return toIndex + 1 since we're moving forward
      XCTAssertEqual(offset, 6, "Moving forward should return toIndex + 1")
   }
   
   func testCalculateMoveOffsetMovingBackward() {
      // When moving from index 5 to index 2
      let offset = DropHelper.calculateMoveOffset(fromIndex: 5, toIndex: 2)
      
      // Should return toIndex since we're moving backward
      XCTAssertEqual(offset, 2, "Moving backward should return toIndex")
   }
   
   func testCalculateMoveOffsetSameIndex() {
      // When from and to are the same
      let offset = DropHelper.calculateMoveOffset(fromIndex: 3, toIndex: 3)
      
      // Should return toIndex + 1 (moving forward logic)
      XCTAssertEqual(offset, 4, "Same index should be treated as forward move")
   }
   
   func testCalculateMoveOffsetAdjacentForward() {
      // When moving from index 3 to index 4 (adjacent forward)
      let offset = DropHelper.calculateMoveOffset(fromIndex: 3, toIndex: 4)
      
      XCTAssertEqual(offset, 5, "Adjacent forward move should return toIndex + 1")
   }
   
   func testCalculateMoveOffsetAdjacentBackward() {
      // When moving from index 4 to index 3 (adjacent backward)
      let offset = DropHelper.calculateMoveOffset(fromIndex: 4, toIndex: 3)
      
      XCTAssertEqual(offset, 3, "Adjacent backward move should return toIndex")
   }
   
   func testCalculateMoveOffsetFromZero() {
      // When moving from index 0
      let offsetForward = DropHelper.calculateMoveOffset(fromIndex: 0, toIndex: 3)
      let offsetBackward = DropHelper.calculateMoveOffset(fromIndex: 0, toIndex: 0)
      
      XCTAssertEqual(offsetForward, 4, "Moving from 0 forward should work correctly")
      XCTAssertEqual(offsetBackward, 1, "Moving from 0 to 0 should return 1")
   }
   
   // MARK: - performDelayedMove Tests
   
   func testPerformedDelayedMoveExecutesAction() async {
      // Given: A flag to track if action was executed
      var actionExecuted = false
      let expectation = expectation(description: "Action should be executed")
      
      // When: Calling performDelayedMove with short delay
      DropHelper.performDelayedMove(delay: 0.1) {
         actionExecuted = true
         expectation.fulfill()
      }
      
      // Then: Action should be executed after delay
      await fulfillment(of: [expectation], timeout: 1.0)
      XCTAssertTrue(actionExecuted, "Action should have been executed")
   }
   
   func testPerformedDelayedMoveRespectsDelay() async {
      // Given: A timestamp to measure delay
      let startTime = Date()
      let expectedDelay: TimeInterval = 0.2
      let expectation = expectation(description: "Action should be delayed")
      var actualDelay: TimeInterval = 0
      
      // When: Calling performDelayedMove
      DropHelper.performDelayedMove(delay: expectedDelay) {
         actualDelay = Date().timeIntervalSince(startTime)
         expectation.fulfill()
      }
      
      // Then: Action should be delayed by at least the specified amount
      await fulfillment(of: [expectation], timeout: 1.0)
      XCTAssertGreaterThanOrEqual(actualDelay, expectedDelay * 0.9, "Delay should be at least 90% of expected")
   }
}
