import SwiftUI

enum DropZoneDirection {
   case left
   case right
}

struct DropZoneView: View {
   let direction: DropZoneDirection
   let currentPage: Int
   let totalPages: Int
   let draggedItem: AppGridItem?
   let onNavigate: () -> Void
   let transparency: Double

   @State private var isHovered = false
   @State private var hoverTimer: Timer?

   private let hoverDelay: TimeInterval = LaunchPadConstants.hoverDelay

   private var canNavigate: Bool {
      switch direction {
      case .left: return currentPage > 0
      case .right: return true // Always allow right navigation to create new page
      }
   }

   private var chevronIcon: String {
      direction == .left ? "chevron.left" : "chevron.right"
   }

   private var alignment: Alignment {
      direction == .left ? .leading : .trailing
   }

   private var padding: EdgeInsets {
      direction == .left
      ? EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
      : EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20)
   }

   private var shouldShowChevron: Bool {
      isHovered && draggedItem != nil && canNavigate
   }

   var body: some View {
      Rectangle()
         .fill(shouldShowChevron ? Color.accentColor.opacity(0.2 * transparency) : Color.clear)
         .frame(width: LaunchPadConstants.dropZoneWidth)
         .glassEffect(shouldShowChevron ? .selected : .normal)
         .overlay(alignment: alignment) {
            if shouldShowChevron {
               VStack {
                  Spacer()
                  Image(systemName: chevronIcon)
                     .font(.system(size: 20, weight: .medium))
                     .foregroundColor(.accentColor)
                     .opacity(0.8 * transparency)
                  Spacer()
               }
               .padding(padding)
            }
         }
         .animation(.smooth(duration: 0.3), value: shouldShowChevron)
         .onDrop(of: [.text], isTargeted: $isHovered) { _ in false }
         .onChange(of: isHovered) { _, newValue in
            handleHoverChange(newValue)
         }
         .onDisappear {
            cancelTimer()
         }
   }

   private func handleHoverChange(_ isHovering: Bool) {
      if isHovering && draggedItem != nil && canNavigate {
         startTimer()
      } else {
         cancelTimer()
      }
   }

   private func startTimer() {
      hoverTimer = Timer.scheduledTimer(withTimeInterval: hoverDelay, repeats: false) { _ in
         DispatchQueue.main.async {
            onNavigate()
         }
      }
   }

   private func cancelTimer() {
      hoverTimer?.invalidate()
      hoverTimer = nil
   }
}
