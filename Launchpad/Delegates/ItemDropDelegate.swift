import SwiftUI

struct ItemDropDelegate: DropDelegate {
   @Binding var pages: [[AppGridItem]]
   @Binding var draggedItem: AppGridItem?
   @Binding var folderPreviewTarget: AppGridItem?
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

      AppManager.shared.saveGridItems()
      self.draggedItem = nil
      self.folderPreviewTarget = nil
      return true
   }

   func dropEntered(info: DropInfo) {
      guard let draggedItem = draggedItem else { return }

      // Show folder preview when dragging app onto another app
      if case .app = draggedItem, case .app = targetItem, draggedItem.id != targetItem.id {
         folderPreviewTarget = targetItem
      }

      if draggedItem.page == targetItem.page {
         DropHelper.performDelayedMove(delay: dropDelay) {
            if self.draggedItem != nil {
               let fromIndex = pages[draggedItem.page].firstIndex(where: { $0.id == draggedItem.id })!
               let toIndex = pages[targetItem.page].firstIndex(where: { $0.id == targetItem.id })!
               pages[draggedItem.page].move(fromOffsets: IndexSet([fromIndex]), toOffset: DropHelper.calculateMoveOffset(fromIndex: fromIndex, toIndex: toIndex))
            }
         }
      } else {
         let fromIndex = pages[draggedItem.page].firstIndex(where: { $0.id == draggedItem.id })!
         let toIndex = pages[targetItem.page].firstIndex(where: { $0.id == targetItem.id })!
         let item = pages[draggedItem.page][fromIndex]

         let updatedItem = item.withUpdatedPage(targetPage)

         pages[targetItem.page].insert(updatedItem, at: toIndex)
         pages[draggedItem.page].remove(at: fromIndex)

         self.draggedItem = updatedItem

         handlePageOverflow(targetPageIndex: targetItem.page)
      }
   }

   func dropExited(info: DropInfo) {
      folderPreviewTarget = nil
   }

   private func handlePageOverflow(targetPageIndex: Int) {
      while pages[targetPageIndex].count > appsPerPage {
         let overflowItem = pages[targetPageIndex].removeLast()

         let nextPageNumber = targetPageIndex + 1

         let updatedOverflowItem = overflowItem.withUpdatedPage(nextPageNumber)

         if nextPageNumber >= pages.count {
            pages.append([updatedOverflowItem])
         } else {
            pages[nextPageNumber].insert(updatedOverflowItem, at: 0)
            handlePageOverflow(targetPageIndex: nextPageNumber)
         }
      }
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

      if app1.page == app2.page {
         let indices = [app1Index, app2Index].sorted(by: >)
         for index in indices {
            pages[app1.page].remove(at: index)
         }
         let insertIndex = min(adjustedTargetIndex, pages[app2.page].count)
         
         // Animate folder creation
         withAnimation(LaunchPadConstants.folderCreationAnimation) {
            pages[app2.page].insert(folderItem, at: insertIndex)
         }
      } else {
         pages[app1.page].remove(at: app1Index)
         pages[app2.page].remove(at: app2Index)

         let insertIndex = min(app2Index, pages[app2.page].count)
         
         // Animate folder creation
         withAnimation(LaunchPadConstants.folderCreationAnimation) {
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

      pages[targetFolder.page][folderIndex] = updatedFolderItem
      pages[app.page].remove(at: appIndex)
   }
}
