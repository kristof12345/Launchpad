import SwiftUI

struct GridLayoutUtility {
   static func createGridColumns(count: Int, cellWidth: CGFloat, spacing: CGFloat) -> [GridItem] {
      var columns = [GridItem]()
      columns.reserveCapacity(count)
      for _ in 0..<count {
         columns.append(GridItem(.fixed(cellWidth), spacing: spacing))
      }
      return columns
   }
   
   static func createFlexibleGridColumns(count: Int, spacing: CGFloat = 0) -> [GridItem] {
      var columns = [GridItem]()
      columns.reserveCapacity(count)
      for _ in 0..<count {
         columns.append(GridItem(.flexible(), spacing: spacing, alignment: .top))
      }
      return columns
   }
}
