import SwiftUI

struct PageIndicatorView: View {
   
   @Binding var currentPage: Int
   let pageCount: Int
   let isFolderOpen: Bool
   let searchText: String
   let settings: LaunchpadSettings
   @Environment(\.colorScheme) private var colorScheme
   
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
               .scaleEffect(index == currentPage ? LaunchPadConstants.pageIndicatorActiveScale : 1.0)
               .glassEffect(index == currentPage ? .selected : .normal)
               .animation(.smooth(duration: 0.3), value: currentPage)
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
   }
}
