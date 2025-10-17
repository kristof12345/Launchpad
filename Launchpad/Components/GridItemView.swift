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
                     // Frosted glass folder background
                     RoundedRectangle(cornerRadius: 16)
                        .fill(
                           LinearGradient(
                              gradient: Gradient(colors: [
                                 Color.white.opacity(0.15),
                                 Color.white.opacity(0.05)
                              ]),
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing
                           )
                        )
                        .aspectRatio(1.0, contentMode: .fit)
                        .scaleEffect(showFolderPreview ? 1.02 : 1.0)
                        .opacity(showFolderPreview ? 1.0 : 0.0)
                        .blur(radius: showFolderPreview ? 2 : 0)
                     
                     // Liquid glass outline
                     RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                           LinearGradient(
                              gradient: Gradient(colors: [
                                 Color.white.opacity(0.6),
                                 Color.white.opacity(0.2),
                                 Color.white.opacity(0.5)
                              ]),
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing
                           ),
                           lineWidth: 1.5
                        )
                        .aspectRatio(1.0, contentMode: .fit)
                        .scaleEffect(showFolderPreview ? 1.02 : 1.0)
                        .opacity(showFolderPreview ? 0.8 : 0.0)
                        .shadow(color: Color.white.opacity(0.3), radius: 6, x: 0, y: 0)
                        .shadow(color: Color.white.opacity(0.15), radius: 12, x: 0, y: 0)
                  }
                  .animation(LaunchPadConstants.folderPreviewAnimation, value: showFolderPreview)
               )
         case .folder(let folder):
            FolderIconView(folder: folder, layout: layout, isDragged: isDragged, transparency: transparency)
         }
      }
   }
}
