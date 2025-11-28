import SwiftUI

struct FolderBackgroundDropDelegate: DropDelegate {
   @Binding var folder: Folder
   @Binding var draggedApp: AppInfo?

   func performDrop(info: DropInfo) -> Bool {
      guard let draggedApp = draggedApp,
            let currentIndex = folder.apps.firstIndex(where: { $0.id == draggedApp.id }) else {
         return false
      }

      withAnimation(LaunchpadConstants.dragDropAnimation) {
         let app = folder.apps.remove(at: currentIndex)
         folder.apps.append(app)
      }

      AppManager.shared.saveAppGridItems()
      self.draggedApp = nil
      return true
   }

   func dropUpdated(info: DropInfo) -> DropProposal? {
      DropProposal(operation: .move)
   }
}
