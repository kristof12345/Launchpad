import SwiftUI

struct SidebarTabButton: View {
   let icon: String
   let label: String
   let isSelected: Bool
   let action: () -> Void
   
   @State private var isHovered: Bool = false

   var body: some View {
      Button(action: action) {
         HStack(spacing: 8) {
            Image(systemName: icon)
               .font(.system(size: 14))
               .frame(width: 16)
               .scaleEffect(isSelected ? 1.1 : (isHovered ? 1.05 : 1.0))
            Text(label)
               .font(.system(size: 13))
            Spacer()
         }
         .padding(.horizontal, 10)
         .padding(.vertical, 8)
         .frame(maxWidth: .infinity, alignment: .leading)
         .contentShape(Rectangle())
         .background(
            RoundedRectangle(cornerRadius: 6)
               .fill(isSelected ? Color.accentColor.opacity(0.15) : (isHovered ? Color.accentColor.opacity(0.05) : Color.clear))
         )
         .overlay(
            RoundedRectangle(cornerRadius: 6)
               .stroke(isSelected ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
         )
         .scaleEffect(isHovered && !isSelected ? 1.02 : 1.0)
      }
      .buttonStyle(.plain)
      .foregroundColor(isSelected ? .primary : .secondary)
      .animation(LaunchPadConstants.hoverAnimation, value: isSelected)
      .animation(LaunchPadConstants.hoverAnimation, value: isHovered)
      .onHover { hovering in
         isHovered = hovering
      }
   }
}
