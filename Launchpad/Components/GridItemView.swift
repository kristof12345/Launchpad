import SwiftUI

struct GridItemView: View {
   let item: AppGridItem
   let layout: LayoutMetrics
   let isDragged: Bool
   let transparency: Double
   let isLaunching: Bool
   let showFolderPreview: Bool
   
   var body: some View {
      Group {
         switch item {
         case .app(let app):
            AppIconView(app: app, layout: layout, isDragged: isDragged, isLaunching: isLaunching)
               .overlay(
                  ZStack {
                     // Folder-like background
                     RoundedRectangle(cornerRadius: layout.iconSize * LaunchPadConstants.folderCornerRadiusMultiplier)
                        .fill(Color.accentColor.opacity(0.15))
                        .scaleEffect(showFolderPreview ? LaunchPadConstants.folderOutlineScale : 1.0)
                        .opacity(showFolderPreview ? LaunchPadConstants.folderOutlineOpacity : 0.0)
                     
                     // Folder outline
                     RoundedRectangle(cornerRadius: layout.iconSize * LaunchPadConstants.folderCornerRadiusMultiplier)
                        .stroke(Color.accentColor, lineWidth: 3)
                        .scaleEffect(showFolderPreview ? LaunchPadConstants.folderOutlineScale : 1.0)
                        .opacity(showFolderPreview ? LaunchPadConstants.folderOutlineOpacity : 0.0)
                  }
                  .animation(LaunchPadConstants.folderPreviewAnimation, value: showFolderPreview)
               )
         case .folder(let folder):
            FolderIconView(folder: folder, layout: layout, isDragged: isDragged, transparency: transparency)
         }
      }
   }
}
