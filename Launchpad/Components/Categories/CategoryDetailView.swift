import SwiftUI

struct CategoryDetailView: View {
   @Binding var category: Category?
   let allApps: [AppInfo]
   let settings: LaunchpadSettings
   let onItemTap: (AppGridItem) -> Void
   
   @State private var editingName = false
   @State private var isAnimatingIn = false
   @State private var opacity: Double = 0
   @State private var headerOffset: CGFloat = -20
   @Environment(\.colorScheme) private var colorScheme
   
   var categoryApps: [AppInfo] {
      guard let category = category else { return [] }
      return CategoryManager.shared.getAppsForCategory(category: category, from: allApps)
   }
   
   var body: some View {
      if category != nil {
         ZStack {
            Color.clear
               .contentShape(Rectangle())
               .onTapGesture {
                  dismissWithAnimation()
               }
            
            VStack(spacing: 10) {
               CategoryNameView(category: Binding(get: { category! }, set: { category = $0 }), editingName: $editingName, opacity: opacity, offset: headerOffset)
               GeometryReader { geo in
                  let layout = LayoutMetrics(size: geo.size, columns: settings.folderColumns, rows: settings.folderRows + 1, iconSize: settings.iconSize)
                  
                  ScrollView(.vertical, showsIndicators: false) {
                     LazyVGrid(
                        columns: GridLayoutUtility.createGridColumns(count: settings.folderColumns, cellWidth: layout.cellWidth, spacing: layout.hSpacing),
                        spacing: layout.vSpacing
                     ) {
                        ForEach(categoryApps) { app in
                           AppIconView(app: app, layout: layout, isDragged: false)
                              .onTapGesture { onItemTap(.app(app))  }
                        }
                     }
                     .padding(.vertical, 20)
                  }
                  .scrollBounceBehavior(.basedOnSize)
               }
               .opacity(opacity)
            }
            .frame(width: LaunchPadConstants.settingsWindowWidth, height: LaunchPadConstants.settingsWindowHeight)
            .glassEffect()
            .shadow(color: .black.opacity(0.15 * settings.transparency), radius: 40, x: 0, y: 20)
            .shadow(color: .black.opacity(0.1 * settings.transparency), radius: 10, x: 0, y: 5)
            .scaleEffect(isAnimatingIn ? 1.0 : 0.85)
            .opacity(isAnimatingIn ? 1.0 : 0.0)
            .onAppear {
               performEntranceAnimation()
            }
            .onTapGesture { editingName = false }
         }
      }
   }
   
   private func performEntranceAnimation() {
      withAnimation(.smooth(duration: 0.4, extraBounce: 0.1)) {
         isAnimatingIn = true
      }
      
      withAnimation(.smooth(duration: 0.3)) {
         opacity = 1.0
      }
      
      withAnimation(.smooth(duration: 0.4, extraBounce: 0.1)) {
         headerOffset = 0
      }
   }
   
   private func dismissWithAnimation() {
      withAnimation(.smooth(duration: 0.2)) {
         opacity = 0
         headerOffset = -20
         isAnimatingIn = false
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
         category = nil
      }
   }
}
