import XCTest
@testable import LaunchpadPlus

final class KeyCodeConstantsTests: XCTestCase {
   
   // MARK: - Key Code Value Tests
   
   func testEscapeKeyCode() {
      XCTAssertEqual(KeyCodeConstants.escape, 53, "Escape key code should be 53")
   }
   
   func testLeftArrowKeyCode() {
      XCTAssertEqual(KeyCodeConstants.leftArrow, 123, "Left arrow key code should be 123")
   }
   
   func testRightArrowKeyCode() {
      XCTAssertEqual(KeyCodeConstants.rightArrow, 124, "Right arrow key code should be 124")
   }
   
   func testDownArrowKeyCode() {
      XCTAssertEqual(KeyCodeConstants.downArrow, 125, "Down arrow key code should be 125")
   }
   
   func testUpArrowKeyCode() {
      XCTAssertEqual(KeyCodeConstants.upArrow, 126, "Up arrow key code should be 126")
   }
   
   func testEnterKeyCode() {
      XCTAssertEqual(KeyCodeConstants.enter, 36, "Enter key code should be 36")
   }
   
   func testCommaKeyCode() {
      XCTAssertEqual(KeyCodeConstants.comma, 43, "Comma key code should be 43")
   }
   
   // MARK: - Key Code Uniqueness Tests
   
   func testAllKeyCodesAreUnique() {
      let keyCodes: Set<UInt16> = [
         KeyCodeConstants.escape,
         KeyCodeConstants.leftArrow,
         KeyCodeConstants.rightArrow,
         KeyCodeConstants.downArrow,
         KeyCodeConstants.upArrow,
         KeyCodeConstants.enter,
         KeyCodeConstants.comma
      ]
      
      XCTAssertEqual(keyCodes.count, 7, "All key codes should be unique")
   }
   
   // MARK: - Arrow Key Grouping Tests
   
   func testArrowKeysAreSequential() {
      // Arrow keys should be in sequence: 123, 124, 125, 126
      XCTAssertEqual(KeyCodeConstants.rightArrow - KeyCodeConstants.leftArrow, 1,
                     "Right arrow should be one more than left arrow")
      XCTAssertEqual(KeyCodeConstants.downArrow - KeyCodeConstants.rightArrow, 1,
                     "Down arrow should be one more than right arrow")
      XCTAssertEqual(KeyCodeConstants.upArrow - KeyCodeConstants.downArrow, 1,
                     "Up arrow should be one more than down arrow")
   }
}
