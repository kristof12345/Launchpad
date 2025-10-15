import AppKit
import SwiftUI

struct AppIconView: View {
   let app: AppInfo
   let layout: LayoutMetrics
   let isDragged: Bool
   let isLaunching: Bool
   
   @State private var isHovered: Bool = false
   
   var body: some View {
      VStack(spacing: 8) {
         Image(nsImage: app.icon)
            .interpolation(.high)
            .antialiased(true)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: layout.iconSize, height: layout.iconSize)
            .shadow(color: .black.opacity(isHovered ? 0.25 : 0.15), radius: isHovered ? 4 : 2, x: 0, y: isHovered ? 2 : 1)
            .scaleEffect(isHovered && !isDragged && !isLaunching ? 1.05 : 1.0)
            .animation(LaunchPadConstants.quickFadeAnimation, value: isHovered)
         
         Text(app.name)
            .font(.system(size: layout.fontSize))
            .multilineTextAlignment(.center)
            .frame(width: layout.cellWidth)
            .opacity(isHovered && !isDragged ? 1.0 : 0.9)
            .animation(LaunchPadConstants.quickFadeAnimation, value: isHovered)
      }
      .scaleEffect(isLaunching ? LaunchPadConstants.appLaunchScale : (isDragged ? LaunchPadConstants.draggedItemScale : 1.0))
      .opacity(isDragged ? LaunchPadConstants.draggedItemOpacity : 1.0)
      .onHover { hovering in
         isHovered = hovering
      }
   }
}
