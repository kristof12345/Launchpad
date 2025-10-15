import SwiftUI

/// Constants used throughout the LaunchPad application
enum LaunchPadConstants {

   // MARK: - Animation Constants
   static let springAnimation = Animation.interpolatingSpring(stiffness: 300, damping: 100)
   static let fadeAnimation = Animation.easeInOut(duration: 0.3)
   static let quickFadeAnimation = Animation.easeInOut(duration: 0.2)
   static let appLaunchAnimation = Animation.interpolatingSpring(stiffness: 280, damping: 20).speed(1.5)
   static let folderCreationAnimation = Animation.interpolatingSpring(stiffness: 320, damping: 25)

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
   static let appLaunchScale: CGFloat = 1.8
   static let folderOutlineScale: CGFloat = 1.15
   static let folderCreationScale: CGFloat = 0.5

   // MARK: - Activation Constants
   static let productKey = ""
}
