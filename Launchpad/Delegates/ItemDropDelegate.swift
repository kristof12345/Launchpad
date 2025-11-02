import SwiftUI

struct ItemDropDelegate: DropDelegate {
   @Binding var pages: [[AppGridItem]]
   @Binding var draggedItem: AppGridItem?
   @Binding var hoveredItem: AppGridItem?
   let dropDelay: Double
   let targetItem: AppGridItem
   let targetPage: Int
   let appsPerPage: Int
   
   func performDrop(info: DropInfo) -> Bool {
      guard let draggedItem = draggedItem else { return false }
      
      if draggedItem.id != targetItem.id {
         switch (draggedItem, targetItem) {
         case (.app(let draggedApp), .app(let targetApp)):
            createFolder(with: draggedApp, and: targetApp)
         case (.app(let draggedApp), .folder(let targetFolder)):
            addAppToFolder(app: draggedApp, targetFolder: targetFolder)
         default:
            break
         }
      }
      
      AppManager.shared.saveAppGridItems()
      self.draggedItem = nil
      self.hoveredItem = nil
      return true
   }
   
   func dropEntered(info: DropInfo) {
      guard let draggedItem = draggedItem else { return }
      
      hoveredItem = targetItem
      
      if draggedItem.page == targetItem.page {
         DropHelper.performDelayedMove(delay: dropDelay) {
            if self.draggedItem != nil {
               guard
                  let fromIndex = pages[draggedItem.page].firstIndex(where: { $0.id == draggedItem.id }),
                  let toIndex = pages[targetItem.page].firstIndex(where: { $0.id == targetItem.id })
               else {
                  return
               }
               withAnimation(LaunchpadConstants.dragDropAnimation) {
                  pages[draggedItem.page].move(
                     fromOffsets: IndexSet([fromIndex]),
                     toOffset: DropHelper.calculateMoveOffset(fromIndex: fromIndex, toIndex: toIndex))
               }
            }
         }
      } else {
         guard let fromIndex = pages[draggedItem.page].firstIndex(where: { $0.id == draggedItem.id }),
               let toIndex = pages[targetItem.page].firstIndex(where: { $0.id == targetItem.id })
         else {
            return
         }
         let item = pages[draggedItem.page][fromIndex]
         
         let updatedItem = item.withUpdatedPage(targetPage)
         
         withAnimation(LaunchpadConstants.dragDropAnimation) {
            pages[targetItem.page].insert(updatedItem, at: toIndex)
            pages[draggedItem.page].remove(at: fromIndex)
         }
         
         self.draggedItem = updatedItem
         
         handlePageOverflow(targetPageIndex: targetItem.page)
      }
   }
   
   func dropExited(info: DropInfo) {
      if hoveredItem?.id == targetItem.id {
         hoveredItem = nil
      }
   }
   
   private func handlePageOverflow(targetPageIndex: Int) {
      PageOverflowHelper.handleOverflow(pages: &pages, pageIndex: targetPageIndex, appsPerPage: appsPerPage)
   }
   
   private func createFolder(with app1: AppInfo, and app2: AppInfo) {
      guard
         let app1Index = pages[app1.page].firstIndex(where: {
            if case .app(let app) = $0 { return app.id == app1.id }
            return false
         }),
         let app2Index = pages[app2.page].firstIndex(where: {
            if case .app(let app) = $0 { return app.id == app2.id }
            return false
         })
      else { return }
      
      let folderName = L10n.newFolder
      let folder = Folder(name: folderName, page: app2.page, apps: [app1, app2])
      let folderItem = AppGridItem.folder(folder)
      let adjustedTargetIndex = app1Index < app2Index ? app2Index - 1 : app2Index
      
      withAnimation(LaunchpadConstants.dragDropAnimation) {
         if app1.page == app2.page {
            let indices = [app1Index, app2Index].sorted(by: >)
            for index in indices {
               pages[app1.page].remove(at: index)
            }
            let insertIndex = min(adjustedTargetIndex, pages[app2.page].count)
            pages[app2.page].insert(folderItem, at: insertIndex)
         } else {
            pages[app1.page].remove(at: app1Index)
            pages[app2.page].remove(at: app2Index)
            
            let insertIndex = min(app2Index, pages[app2.page].count)
            pages[app2.page].insert(folderItem, at: insertIndex)
         }
      }
   }
   
   private func addAppToFolder(app: AppInfo, targetFolder: Folder) {
      guard
         let appIndex = pages[app.page].firstIndex(where: {
            if case .app(let appInfo) = $0 { return appInfo.id == app.id }
            return false
         }),
         let folderIndex = pages[targetFolder.page].firstIndex(where: {
            if case .folder(let folderInfo) = $0 { return folderInfo.id == targetFolder.id }
            return false
         })
      else { return }
      
      var updatedApps = targetFolder.apps
      updatedApps.append(app)
      let updatedFolder = Folder(name: targetFolder.name, page: targetFolder.page, apps: updatedApps)
      let updatedFolderItem = AppGridItem.folder(updatedFolder)
      
      withAnimation(LaunchpadConstants.dragDropAnimation) {
         pages[targetFolder.page][folderIndex] = updatedFolderItem
         pages[app.page].remove(at: appIndex)
      }
   }
   
   func dropUpdated(info: DropInfo) -> DropProposal? {
      return DropProposal(operation: .move)
   }
}
