import Foundation

/// Utility class for handling search result navigation in grid layouts
struct SearchNavigationHelper {
   
   /// Navigate to the previous item in a linear sequence, wrapping to the end if at the start
   /// - Parameters:
   ///   - currentIndex: The current selected index
   ///   - itemCount: Total number of items
   /// - Returns: The new index after navigation
   static func navigateLeft(currentIndex: Int, itemCount: Int) -> Int {
      guard itemCount > 0 else { return currentIndex }
      
      if currentIndex > 0 {
         return currentIndex - 1
      } else {
         return itemCount - 1
      }
   }
   
   /// Navigate to the next item in a linear sequence, wrapping to the start if at the end
   /// - Parameters:
   ///   - currentIndex: The current selected index
   ///   - itemCount: Total number of items
   /// - Returns: The new index after navigation
   static func navigateRight(currentIndex: Int, itemCount: Int) -> Int {
      guard itemCount > 0 else { return currentIndex }
      
      if currentIndex < itemCount - 1 {
         return currentIndex + 1
      } else {
         return 0
      }
   }
   
   /// Navigate up in a grid layout, wrapping to the bottom row if at the top
   /// - Parameters:
   ///   - currentIndex: The current selected index
   ///   - itemCount: Total number of items
   ///   - columns: Number of columns in the grid
   /// - Returns: The new index after navigation
   static func navigateUp(currentIndex: Int, itemCount: Int, columns: Int) -> Int {
      guard itemCount > 0 else { return currentIndex }
      
      let newIndex = currentIndex - columns
      if newIndex >= 0 {
         return newIndex
      } else {
         // Wrap to bottom row
         let lastRowStartIndex = (itemCount - 1) / columns * columns
         let columnOffset = currentIndex % columns
         return min(lastRowStartIndex + columnOffset, itemCount - 1)
      }
   }
   
   /// Navigate down in a grid layout, wrapping to the top row if at the bottom
   /// - Parameters:
   ///   - currentIndex: The current selected index
   ///   - itemCount: Total number of items
   ///   - columns: Number of columns in the grid
   /// - Returns: The new index after navigation
   static func navigateDown(currentIndex: Int, itemCount: Int, columns: Int) -> Int {
      guard itemCount > 0 else { return currentIndex }
      
      let newIndex = currentIndex + columns
      if newIndex < itemCount {
         return newIndex
      } else {
         // Wrap to top row
         let columnOffset = currentIndex % columns
         return min(columnOffset, itemCount - 1)
      }
   }
}
