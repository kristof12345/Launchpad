import SwiftUI

/// Constants used throughout the LaunchPad application
class LaunchPadConstants {

   // MARK: - Animation Constants
   static let springAnimation = Animation.smooth(duration: 0.4, extraBounce: 0.1)
   static let fadeAnimation = Animation.smooth(duration: 0.3)
   static let quickFadeAnimation = Animation.smooth(duration: 0.2)

   // MARK: - Layout Constants
   static let folderPreviewSize = 9 // Maximum apps shown in folder preview (3x3 grid)
   static let iconDisplaySize: CGFloat = 256
   static let folderCornerRadiusMultiplier: CGFloat = 0.2
   static let folderSizeMultiplier: CGFloat = 0.82

   // MARK: - Timing Constants
   static let hoverDelay: TimeInterval = 0.8
   static let animationDelay: TimeInterval = 0.2
   static let quickAnimationDelay: TimeInterval = 0.1

   // MARK: - UI Constants
   static let searchBarWidth: CGFloat = 480
   static let searchBarHeight: CGFloat = 36
   static let settingsWindowWidth: CGFloat = 1200
   static let settingsWindowHeight: CGFloat = 800
   static let pageIndicatorSize: CGFloat = 10
   static let pageIndicatorActiveScale: CGFloat = 1.2
   static let pageIndicatorSpacing: CGFloat = 20
   static let dropZoneWidth: CGFloat = 60

   // MARK: - Drag & Drop Constants
   static let draggedItemScale: CGFloat = 0.8
   static let draggedItemOpacity: Double = 0.5
   static let folderOpenOpacity: Double = 0.2
   static let draggedAppScale: CGFloat = 0.95
   static let draggedAppOpacity: Double = 0.7
}


