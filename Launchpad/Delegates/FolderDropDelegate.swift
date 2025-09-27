import SwiftUI

struct FolderDropDelegate: DropDelegate {
    @Binding var folder: Folder
    @Binding var draggedApp: AppInfo?
    let dropDelay: Double
    let targetApp: AppInfo
    
    func dropEntered(info: DropInfo) {
        guard let draggedApp = draggedApp,
              draggedApp.id != targetApp.id,
              let fromIndex = folder.apps.firstIndex(where: { $0.id == draggedApp.id }),
              let toIndex = folder.apps.firstIndex(where: { $0.id == targetApp.id })
        else { return }
        
        // Enhanced reorder animation with spring physics
        DropAnimationHelper.performDelayedMove(
            delay: dropDelay,
            animation: .spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.2)
        ) {
            if self.draggedApp != nil {
                folder.apps.move(
                    fromOffsets: IndexSet([fromIndex]), 
                    toOffset: DropAnimationHelper.calculateMoveOffset(fromIndex: fromIndex, toIndex: toIndex)
                )
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        // Smooth completion animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            draggedApp = nil
        }
        return true
    }
}
