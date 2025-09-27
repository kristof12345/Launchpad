import SwiftUI

struct ItemDropDelegate: DropDelegate {
   private let appManager = AppManager.shared
   @Binding var pages: [[AppGridItem]]
   @Binding var draggedItem: AppGridItem?
   let dropDelay: Double
   let targetItem: AppGridItem
   let targetPage: Int
   let appsPerPage: Int

   func dropEntered(info: DropInfo) {
      guard let draggedItem = draggedItem else {
         return
      }

      guard let fromIndex = pages[draggedItem.page].firstIndex(where: { $0.id == draggedItem.id }),
            let toIndex = pages[targetItem.page].firstIndex(where: { $0.id == targetItem.id })
      else {
         return
      }

      if draggedItem.page == targetItem.page {

         DropAnimationHelper.performDelayedMove(delay: dropDelay) {
            if self.draggedItem != nil {
               pages[draggedItem.page].move( fromOffsets: IndexSet([fromIndex]), toOffset: DropAnimationHelper.calculateMoveOffset(fromIndex: fromIndex, toIndex: toIndex))
            }
         }
      } else {
         let item = pages[draggedItem.page][fromIndex]

         let updatedItem: AppGridItem
         switch item {
         case .app(let app):
            updatedItem = .app(
               AppInfo(name: app.name, icon: app.icon, path: app.path, page: targetPage))
         case .folder(let folder):
            updatedItem = .folder(
               Folder(name: folder.name, page: targetPage, apps: folder.apps))
         }

         pages[targetItem.page].insert(updatedItem, at: toIndex)
         pages[draggedItem.page].remove(at: fromIndex)

         self.draggedItem = updatedItem

         handlePageOverflow(targetPageIndex: targetItem.page)
      }
   }

   func dropUpdated(info: DropInfo) -> DropProposal? {
      return DropProposal(operation: .move)
   }

   func performDrop(info: DropInfo) -> Bool {
      guard let draggedItem = draggedItem else {
         self.draggedItem = nil
         return true
      }

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

      self.draggedItem = nil
      appManager.pages = pages
      return true
   }

   private func handlePageOverflow(targetPageIndex: Int) {
      while pages[targetPageIndex].count > appsPerPage {
         let overflowItem = pages[targetPageIndex].removeLast()

         let nextPageNumber = targetPageIndex + 1

         let updatedOverflowItem: AppGridItem
         switch overflowItem {
         case .app(let app):
            updatedOverflowItem = .app(
               AppInfo(name: app.name, icon: app.icon, path: app.path, page: nextPageNumber))
         case .folder(let folder):
            updatedOverflowItem = .folder(
               Folder(name: folder.name, page: nextPageNumber, apps: folder.apps))
         }

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

      // Enhanced folder creation animation
      DropAnimationHelper.performFolderCreation {
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

      // Enhanced app-to-folder animation
      DropAnimationHelper.performDelayedMove(delay: 0.1) {
         pages[targetFolder.page][folderIndex] = updatedFolderItem
         pages[app.page].remove(at: appIndex)
      }
   }
}
