import SwiftUI

@MainActor
struct DropAnimationHelper {
    static func performDelayedMove(
        delay: Double,
        animation: Animation = .spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.1),
        action: @escaping () -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(animation) {
                action()
            }
        }
    }
    
    static func performImmediateMove(
        animation: Animation = .spring(response: 0.3, dampingFraction: 0.6),
        action: @escaping () -> Void
    ) {
        withAnimation(animation) {
            action()
        }
    }
    
    static func performFolderCreation(
        delay: Double = 0.1,
        action: @escaping () -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.2)) {
                action()
            }
        }
    }
    
    static func performAppRemoval(
        delay: Double = 0.05,
        action: @escaping () -> Void
    ) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1)) {
            action()
        }
    }

    static func calculateMoveOffset(fromIndex: Int, toIndex: Int) -> Int {
        return toIndex > fromIndex ? toIndex + 1 : toIndex
    }
}
