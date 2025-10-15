import SwiftUI

struct SearchBarView: View {
   var searchText: String
   var transparency: Double
   @State private var isVisible = false
   
   var body: some View {
      HStack {
         Spacer()
         Text(searchText.isEmpty ? L10n.searchPlaceholder : searchText)
            .textFieldStyle(.plain)
            .font(.system(size: 16, weight: .regular))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(width: LaunchPadConstants.searchBarWidth, height: LaunchPadConstants.searchBarHeight)
            .background(
               RoundedRectangle(cornerRadius: 24, style: .continuous)
                  .fill(Color(NSColor.windowBackgroundColor).opacity(0.4 * transparency))
            )
            .shadow(color: Color.black.opacity(0.2 * transparency), radius: searchText.isEmpty ? 10 : 15, x: 0, y: searchText.isEmpty ? 3 : 5)
            .scaleEffect(searchText.isEmpty ? 1.0 : 1.02)
            .animation(LaunchPadConstants.quickFadeAnimation, value: searchText.isEmpty)
         Spacer()
      }
      .padding(.top, 40)
      .opacity(isVisible ? 1 : 0)
      .offset(y: isVisible ? 0 : -20)
      .onAppear {
         withAnimation(LaunchPadConstants.fadeAnimation.delay(0.1)) {
            isVisible = true
         }
      }
   }
}
