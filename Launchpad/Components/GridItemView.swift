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
                  RoundedRectangle(cornerRadius: layout.iconSize * LaunchPadConstants.folderCornerRadiusMultiplier)
                     .stroke(Color.accentColor, lineWidth: 3)
                     .scaleEffect(showFolderPreview ? LaunchPadConstants.folderOutlineScale : 1.0)
                     .opacity(showFolderPreview ? 0.8 : 0.0)
                     .animation(LaunchPadConstants.quickFadeAnimation, value: showFolderPreview)
               )
         case .folder(let folder):
            FolderIconView(folder: folder, layout: layout, isDragged: isDragged, transparency: transparency)
         }
      }
   }
}
