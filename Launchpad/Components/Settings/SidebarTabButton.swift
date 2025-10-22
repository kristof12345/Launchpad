import SwiftUI

struct SidebarTabButton: View {
   let icon: String
   let label: String
   let isSelected: Bool
   let action: () -> Void

   var body: some View {
      Button(action: action) {
         HStack(spacing: 8) {
            Image(systemName: icon)
               .font(.system(size: 14))
               .frame(width: 16)
            Text(label)
               .font(.system(size: 13))
            Spacer()
         }
         .padding(.horizontal, 10)
         .padding(.vertical, 8)
         .frame(maxWidth: .infinity, alignment: .leading)
         .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .foregroundColor(isSelected ? .primary : .secondary)
      .glassEffect()
      
      .animation(.smooth(duration: 0.3), value: isSelected)
   }
}
