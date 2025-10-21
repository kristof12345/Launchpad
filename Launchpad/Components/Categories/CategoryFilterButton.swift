import SwiftUI

struct CategoryFilterButton: View {
   let name: String
   let isSelected: Bool
   let transparency: Double
   let action: () -> Void
   
   var body: some View {
      Button(action: action) {
         Text(name)
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .foregroundColor(isSelected ? .white : .primary)
      }
      .buttonStyle(.plain)
      .glassEffect()
      .hoverEffect()
      .animation(.smooth(duration: 0.3), value: isSelected)
   }
}
