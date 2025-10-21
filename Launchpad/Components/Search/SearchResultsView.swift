import SwiftUI

struct SearchResultsView: View {
   let apps: [AppInfo]
   let settings: LaunchpadSettings
   let selectedIndex: Int
   let onItemTap: (AppGridItem) -> Void
   
   var body: some View {
      GeometryReader { geo in
         let layout = LayoutMetrics(size: geo.size, columns: settings.columns, rows: settings.rows, iconSize: settings.iconSize)
         let shouldCenterAlign = apps.count < settings.columns

         if apps.isEmpty {
            EmptySearchView()
         } else {
            ScrollViewReader { proxy in
               ScrollView(.vertical, showsIndicators: false) {
                  Group {
                     if shouldCenterAlign {
                        HStack {
                           Spacer()
                           LazyVGrid(
                              columns: GridLayoutUtility.createGridColumns(count: apps.count, cellWidth: layout.cellWidth, spacing: layout.hSpacing),
                              spacing: layout.hSpacing
                           ) {
                              gridContent(layout: layout)
                           }
                           Spacer()
                        }
                     } else {
                        LazyVGrid(
                           columns: GridLayoutUtility.createGridColumns(count: settings.columns, cellWidth: layout.cellWidth, spacing: layout.hSpacing),
                           spacing: layout.hSpacing
                        ) {
                           gridContent(layout: layout)
                        }
                     }
                  }
                  .padding(.horizontal, layout.hPadding)
                  .padding(.bottom, layout.vPadding)
               }
               .onChange(of: selectedIndex) { _, newIndex in
                  guard newIndex >= 0 && newIndex < apps.count else { return }
                  withAnimation(.smooth(duration: 0.2)) {
                     proxy.scrollTo(apps[newIndex].id, anchor: .center)
                  }
               }
            }
         }
      }
   }

   @ViewBuilder
   private func gridContent(layout: LayoutMetrics) -> some View {
      ForEach(Array(apps.enumerated()), id: \.element.id) { index, app in
         AppIconView(app: app, layout: layout, isDragged: false)
            .id(app.id)
            .background(
               RoundedRectangle(cornerRadius: 12)
                  .fill(index == selectedIndex ? Color.gray.opacity(0.3) : Color.clear)
                  .padding(-8)
                  .aspectRatio(1.0, contentMode: .fit)
            )
            .onTapGesture {
               onItemTap(.app(app))
            }
            .contextMenu {
               CategoryContextMenu(app: app)
               
               Divider()
               
               Button(action: {
                  AppManager.shared.hideApp(path: app.path, appsPerPage: settings.appsPerPage)
               }) {
                  Label(L10n.hideApp, systemImage: "eye.slash")
               }
            }
      }
   }
}
