import SwiftUI

struct SinglePageView: View {
   @Binding var pages: [[AppGridItem]]
   @Binding var draggedItem: AppGridItem?
   let pageIndex: Int
   let settings: LaunchpadSettings
   let isFolderOpen: Bool
   let onItemTap: (AppGridItem) -> Void
   
   var body: some View {
      GeometryReader { pageGeo in
         let layout = LayoutMetrics(size: pageGeo.size, columns: settings.columns, rows: settings.rows, iconSize: settings.iconSize)
         
         ScrollView(.horizontal, showsIndicators: false) {
            LazyVGrid(
               columns: GridLayoutUtility.createGridColumns(count: settings.columns, cellWidth: layout.cellWidth, spacing: layout.hSpacing),
               spacing: layout.hSpacing
            ) {
               ForEach(pages[pageIndex]) { item in
                  GridItemView(item: item, layout: layout, isDragged: draggedItem?.id == item.id, transparency: settings.transparency
                  )
                  .opacity(isFolderOpen ? LaunchPadConstants.folderOpenOpacity : 1)
                  .onTapGesture { onItemTap(item)  }
                  .contextMenu {
                     if case .app(let app) = item {
                        CategoryContextMenu(app: app)
                        
                        Divider()
                        
                        Button(action: {
                           AppManager.shared.hideApp(path: app.path, appsPerPage: settings.appsPerPage)
                        }) {
                           Label(L10n.hideApp, systemImage: "eye.slash")
                        }
                     } else if case .widget(let widget) = item {
                        Button(role: .destructive, action: {
                           AppManager.shared.removeWidget(id: widget.id, appsPerPage: settings.appsPerPage)
                        }) {
                           Label(L10n.removeWidget, systemImage: "trash")
                        }
                     }
                  }
                  .onDrag {
                     draggedItem = item
                     return NSItemProvider(object: item.id.uuidString as NSString)
                  }
                  .onDrop(
                     of: [.text],
                     delegate: ItemDropDelegate(
                        pages: $pages,
                        draggedItem: $draggedItem,
                        dropDelay: settings.dropDelay,
                        targetItem: item,
                        targetPage: pageIndex,
                        appsPerPage: settings.appsPerPage
                     ))
               }
            }
            .padding(.horizontal, layout.hPadding)
            .padding(.bottom, layout.vPadding)
            .frame(minHeight: pageGeo.size.height - layout.vPadding, alignment: .top)
         }
         .onDrop(of: [.text], delegate: PageDropDelegate(
            pages: $pages,
            draggedItem: $draggedItem,
            targetPage: pageIndex,
            appsPerPage: settings.appsPerPage
         ))
      }
   }
}
