import SwiftUI

struct PageIndicatorView: View {
   
   @Binding var currentPage: Int
   let pageCount: Int
   let isFolderOpen: Bool
   let searchText: String
   let settings: LaunchpadSettings
   @Environment(\.colorScheme) private var colorScheme
   @State private var hoveredIndex: Int? = nil
   
   var body: some View {
      HStack(spacing: LaunchPadConstants.pageIndicatorSpacing) {
         ForEach(0..<pageCount, id: \.self) { index in
            Circle()
               .fill(
                  index == currentPage
                  ? (colorScheme == .dark ? Color.white : Color.primary)
                  : (colorScheme == .dark ? Color.gray.opacity(0.4 * settings.transparency) : Color.gray.opacity(0.6 * settings.transparency))
               )
               .frame(width: LaunchPadConstants.pageIndicatorSize, height: LaunchPadConstants.pageIndicatorSize)
               .scaleEffect(
                  index == currentPage 
                  ? LaunchPadConstants.pageIndicatorActiveScale 
                  : (hoveredIndex == index ? 1.1 : 1.0)
               )
               .animation(LaunchPadConstants.quickFadeAnimation, value: currentPage)
               .animation(LaunchPadConstants.quickFadeAnimation, value: hoveredIndex)
               .onHover { hovering in
                  hoveredIndex = hovering ? index : nil
               }
               .onTapGesture {
                  withAnimation(LaunchPadConstants.springAnimation) {
                     currentPage = index
                  }
               }
         }
      }
      .padding(.top, 16)
      .padding(.bottom, settings.showDock ? 120 : 40)
      .opacity(searchText.isEmpty && !isFolderOpen ? 1 : 0)
      .animation(LaunchPadConstants.fadeAnimation, value: searchText.isEmpty)
      .animation(LaunchPadConstants.fadeAnimation, value: isFolderOpen)
   }
}
