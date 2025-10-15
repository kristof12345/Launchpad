import SwiftUI

/// Constants used throughout the LaunchPad application
enum LaunchPadConstants {

   // MARK: - Animation Constants
   static let springAnimation = Animation.interpolatingSpring(stiffness: 350, damping: 30)
   static let fadeAnimation = Animation.easeInOut(duration: 0.25)
   static let quickFadeAnimation = Animation.easeInOut(duration: 0.15)
   static let appLaunchAnimation = Animation.interpolatingSpring(stiffness: 300, damping: 22).speed(1.6)
   static let folderCreationAnimation = Animation.interpolatingSpring(stiffness: 380, damping: 28)
   static let folderPreviewAnimation = Animation.interpolatingSpring(stiffness: 400, damping: 30)
   static let bounceAnimation = Animation.interpolatingSpring(stiffness: 500, damping: 25)
   static let hoverAnimation = Animation.easeOut(duration: 0.12)
   static let itemRearrangeAnimation = Animation.interpolatingSpring(stiffness: 400, damping: 32)
   static let smoothMoveAnimation = Animation.interpolatingSpring(stiffness: 360, damping: 28)

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
   static let draggedItemScale: CGFloat = 0.85
   static let draggedItemOpacity: Double = 0.6
   static let folderOpenOpacity: Double = 0.2
   static let draggedAppScale: CGFloat = 0.96
   static let draggedAppOpacity: Double = 0.75
   static let appLaunchScale: CGFloat = 1.0
   static let folderOutlineScale: CGFloat = 1.25
   static let folderOutlineOpacity: Double = 0.9
   static let folderCreationScale: CGFloat = 0.5

   // MARK: - Activation Constants
   static let productKey = ""
}
