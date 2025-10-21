import AppKit
import SwiftUI

struct AppIconView: View {
   let app: AppInfo
   let layout: LayoutMetrics
   let isDragged: Bool
   
   var body: some View {
      VStack(spacing: 8) {
         Image(nsImage: app.icon)
            .interpolation(.high)
            .antialiased(true)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: layout.iconSize, height: layout.iconSize)
            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
         
         Text(app.name)
            .font(.system(size: layout.fontSize))
            .multilineTextAlignment(.center)
            .frame(width: layout.cellWidth)
      }
      .scaleEffect(isDragged ? LaunchPadConstants.draggedItemScale : 1.0)
      .opacity(isDragged ? LaunchPadConstants.draggedItemOpacity : 1.0)
      .animation(.smooth(duration: 0.2), value: isDragged)
   }
}
