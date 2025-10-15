import SwiftUI

struct FolderDropDelegate: DropDelegate {
   @Binding var folder: Folder
   @Binding var draggedApp: AppInfo?
   let dropDelay: Double
   let targetApp: AppInfo

   func performDrop(info: DropInfo) -> Bool {
      guard draggedApp != nil else { return false }

      AppManager.shared.saveGridItems()
      self.draggedApp = nil
      return true
   }

   func dropEntered(info: DropInfo) {
      guard let draggedApp = draggedApp else { return }

      DropHelper.performDelayedMove(delay: dropDelay, animation: LaunchPadConstants.itemRearrangeAnimation) {
         if self.draggedApp != nil {
            let fromIndex = folder.apps.firstIndex(where: { $0.id == draggedApp.id })!
            let toIndex = folder.apps.firstIndex(where: { $0.id == targetApp.id })!
            folder.apps.move(fromOffsets: IndexSet([fromIndex]), toOffset: DropHelper.calculateMoveOffset(fromIndex: fromIndex, toIndex: toIndex))
         }
      }
   }
}
