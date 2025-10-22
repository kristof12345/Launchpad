import SwiftUI

struct SearchBarView: View {
   @Binding var searchText: String
   @Binding var sortOrder: SortOrder
   var onSortChange: ((SortOrder) -> Void)?
   var onSettingsOpen: (() -> Void)?
   var transparency: Double
   var showIcons: Bool
   
   @State private var showSortMenu = false
   @State private var hoveredItem: SortOrder?
   @FocusState private var isFocused: Bool
   
   var body: some View {
      HStack(spacing: 12) {
         Spacer()
         
         // Sort button
         if showIcons {
            Button(action: { showSortMenu.toggle() }) {
               Image(systemName: "arrow.up.arrow.down")
                  .font(.system(size: 16, weight: .medium))
                  .foregroundColor(.white)
                  .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .glassEffect()
            
            .shadow(color: Color.black.opacity(0.2 * transparency), radius: 10, x: 0, y: 3)
            .popover(isPresented: $showSortMenu, arrowEdge: .bottom) {
               VStack(alignment: .leading, spacing: 0) {
                  ForEach(SortOrder.allCases, id: \.self) { order in
                     Button(action: {
                        sortOrder = order
                        onSortChange?(order)
                        showSortMenu = false
                     }) {
                        HStack(spacing: 12) {
                           Text(order.displayName)
                              .font(.system(size: 14))
                              .foregroundColor(.primary)
                           Spacer()
                           if sortOrder == order {
                              Image(systemName: "checkmark")
                                 .font(.system(size: 13, weight: .semibold))
                                 .foregroundColor(.blue)
                           }
                        }
                        .contentShape(Rectangle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                           Rectangle()
                              .fill(hoveredItem == order ? Color.primary.opacity(0.06) : Color.clear)
                        )
                     }
                     .buttonStyle(SortMenuItemButtonStyle())
                     
                     .onHover { hovering in
                        withAnimation(.smooth(duration: 0.12)) {
                           hoveredItem = hovering ? order : nil
                        }
                     }
                  }
               }
               .padding(.vertical, 4)
               .frame(minWidth: 220)
            }
         }
         
         // Search bar
         HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
               .foregroundColor(.secondary)
               .font(.system(size: 14))
            
            TextField(L10n.searchPlaceholder, text: $searchText)
               .textFieldStyle(.plain)
               .font(.system(size: 16, weight: .regular))
               .focused($isFocused)
               .tint(.gray)
            
            if !searchText.isEmpty {
               Button(action: {
                  searchText = "";
                  isFocused = true
               }) {
                  Image(systemName: "xmark.circle.fill")
                     .foregroundColor(.secondary)
                     .font(.system(size: 14))
               }
               .buttonStyle(.plain)
               
               .keyboardShortcut(.cancelAction)
            }
         }
         .padding(.horizontal, 12)
         .padding(.vertical, 6)
         .frame(width: LaunchPadConstants.searchBarWidth, height: LaunchPadConstants.searchBarHeight)
         .glassEffect()
         .shadow(color: Color.black.opacity(0.2 * transparency), radius: 10, x: 0, y: 3)
         
         // Settings button
         if showIcons {
            Button(action: { onSettingsOpen?() }) {
               Image(systemName: "gearshape.fill")
                  .font(.system(size: 16, weight: .medium))
                  .foregroundColor(.white)
                  .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .glassEffect()
            
            .shadow(color: Color.black.opacity(0.2 * transparency), radius: 10, x: 0, y: 3)
         }
         Spacer()
      }
      .padding(.top, 40)
      .onAppear {
         isFocused = true
      }
   }
}
