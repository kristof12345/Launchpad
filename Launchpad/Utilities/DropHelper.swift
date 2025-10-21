import SwiftUI

/// Helper for performing delayed drop animations with smooth transitions
@MainActor
struct DropHelper {
  static func performDelayedMove(
    delay: Double,
    animation: Animation = .smooth(duration: 0.2),
    action: @escaping () -> Void
  ) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      withAnimation(animation) {
        action()
      }
    }
  }

  static func calculateMoveOffset(fromIndex: Int, toIndex: Int) -> Int {
    return toIndex > fromIndex ? toIndex + 1 : toIndex
  }
}
