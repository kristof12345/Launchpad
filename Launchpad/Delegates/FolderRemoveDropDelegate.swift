import SwiftUI

struct FolderRemoveDropDelegate: DropDelegate {
    @Binding var folder: Folder
    @Binding var draggedApp: AppInfo?
    let onRemoveApp: ((AppInfo) -> Void)
    
    func dropEntered(info: DropInfo) {
        // Visual feedback when hovering over remove area
        // This could trigger a visual state change in the parent view
    }
    
    func dropExited(info: DropInfo) {
        // Reset visual feedback when leaving remove area
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedApp = draggedApp else { return true }
        
        if let index = folder.apps.firstIndex(where: { $0.id == draggedApp.id }) {
            let removedApp = folder.apps.remove(at: index)
            
            // Enhanced removal animation
            DropAnimationHelper.performAppRemoval {
                self.draggedApp = nil
                onRemoveApp(removedApp)
            }
        }
        
        return true
    }
}
