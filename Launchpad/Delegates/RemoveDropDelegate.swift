import SwiftUI

struct RemoveDropDelegate: DropDelegate {
   @Binding var pages: [[AppGridItem]]
   @Binding var folder: Folder
   @Binding var draggedApp: AppInfo?
   let appsPerPage: Int
   
   func performDrop(info: DropInfo) -> Bool {
      guard let draggedApp = draggedApp else { return false }
      
      if let index = folder.apps.firstIndex(where: { $0.id == draggedApp.id }) {
         withAnimation(LaunchPadConstants.quickFadeAnimation) {
            let removedApp = folder.apps.remove(at: index)
            addAppToPage(app: removedApp)
         }
      }
      
      AppManager.shared.saveGridItems()
      self.draggedApp = nil
      return true
   }
   
   private func addAppToPage(app: AppInfo) {
      guard let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == folder.id }) }) else { return }
      let updatedApp = AppInfo(name: app.name, icon: app.icon, path: app.path, page: pageIndex)
      withAnimation(LaunchPadConstants.smoothMoveAnimation) {
         pages[pageIndex].append(.app(updatedApp))
      }
      handlePageOverflow(pageIndex: pageIndex)
   }
   
   private func handlePageOverflow(pageIndex: Int) {
      while pages[pageIndex].count > appsPerPage {
         let overflowItem = pages[pageIndex].removeLast()
         let nextPage = pageIndex + 1
         let updatedOverflowItem = overflowItem.withUpdatedPage(nextPage)
         withAnimation(LaunchPadConstants.smoothMoveAnimation) {
            if nextPage >= pages.count {
               pages.append([updatedOverflowItem])
            } else {
               pages[nextPage].insert(updatedOverflowItem, at: 0)
               handlePageOverflow(pageIndex: nextPage)
            }
         }
      }
   }
}
