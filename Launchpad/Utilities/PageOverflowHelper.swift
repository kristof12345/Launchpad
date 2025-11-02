import SwiftUI

/// Utility for handling page overflow when items exceed the maximum items per page
struct PageOverflowHelper {
   
   /// Handles page overflow by moving excess items to the next page
   /// - Parameters:
   ///   - pages: The array of pages to manage
   ///   - pageIndex: The index of the page that has overflow (must be valid)
   ///   - appsPerPage: Maximum number of items allowed per page (must be positive)
   static func handleOverflow(pages: inout [[AppGridItem]], pageIndex: Int, appsPerPage: Int) {
      guard pageIndex >= 0 && pageIndex < pages.count && appsPerPage > 0 else { return }
      
      while pages[pageIndex].count > appsPerPage {
         let overflowItem = pages[pageIndex].removeLast()
         let nextPageNumber = pageIndex + 1
         let updatedOverflowItem = overflowItem.withUpdatedPage(nextPageNumber)
         
         if nextPageNumber >= pages.count {
            pages.append([updatedOverflowItem])
         } else {
            pages[nextPageNumber].insert(updatedOverflowItem, at: 0)
            handleOverflow(pages: &pages, pageIndex: nextPageNumber, appsPerPage: appsPerPage)
         }
      }
   }
}
