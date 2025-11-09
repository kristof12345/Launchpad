import SwiftUI

class LaunchpadConstants {

   // MARK: - Animation Constants
   static let springAnimation = Animation.interpolatingSpring(stiffness: 400, damping: 35)
   static let fadeAnimation = Animation.easeInOut(duration: 0.3)
   static let easeInOutAnimation = Animation.easeInOut(duration: 0.2)
   static let easeInAnimation = Animation.easeIn(duration: 0.2)
   static let easeOutAnimation = Animation.easeOut(duration: 0.2)
   static let jiggleAnimation = Animation.easeInOut(duration: 0.2).repeatForever(autoreverses: true)
   static let dragDropAnimation = Animation.spring(response: 0.3, dampingFraction: 1.0)

   // MARK: - Layout Constants
   static let folderPreviewCount = 9 // Apps shown in folder preview (3x3 grid)
   static let folderPreviewIconSize: CGFloat = 0.2 // Size of icons inside folder preview
   static let folderPreviewSpace: CGFloat = 1.5
   static let iconDisplaySize: CGFloat = 256
   static let folderSizeMultiplier: CGFloat = 0.82
   static let categoryBoxSize: Int = 440

   // MARK: - Timing Constants
   static let hoverDelay: TimeInterval = 0.8
   static let focusDelay: TimeInterval = 0.2

   // MARK: - Opacity Constants
   static let overlayOpacity: Double = 0.3
   static let dimmedOpacity: Double = 0.2

   // MARK: - UI Constants
   static let searchBarWidth: CGFloat = 480
   static let searchBarHeight: CGFloat = 36
   static let folderWidth: CGFloat = 1200
   static let folderHeight: CGFloat = 800
   static let pageIndicatorSize: CGFloat = 10
   static let pageIndicatorActiveScale: CGFloat = 1.2
   static let pageIndicatorSpacing: CGFloat = 20
   static let dropZoneWidth: CGFloat = 60

   // MARK: - Scale Constants
   static let hoveredItemScale: CGFloat = 1.1
   static let draggedItemScale: CGFloat = 1.0
   static let folderCreationScale: CGFloat = 1.2

   // MARK: - Edit Mode Constants
   static let jiggleRotation: Double = 4.0  // degrees
}
