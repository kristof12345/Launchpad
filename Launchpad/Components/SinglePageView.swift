import SwiftUI

struct SinglePageView: View {
   @Binding var pages: [[AppGridItem]]
   @Binding var draggedItem: AppGridItem?
   @Binding var launchingItem: AppGridItem?
   @Binding var folderPreviewTarget: AppGridItem?
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
                  GridItemView(
                     item: item,
                     layout: layout,
                     isDragged: draggedItem?.id == item.id,
                     transparency: settings.transparency,
                     isLaunching: launchingItem?.id == item.id,
                     showFolderPreview: folderPreviewTarget?.id == item.id
                  )
                  .opacity(isFolderOpen ? LaunchPadConstants.folderOpenOpacity : 1)
                  .onTapGesture { onItemTap(item)  }
                  .onDrag {
                     draggedItem = item
                     return NSItemProvider(object: item.id.uuidString as NSString)
                  }
                  .onDrop(
                     of: [.text],
                     delegate: ItemDropDelegate(
                        pages: $pages,
                        draggedItem: $draggedItem,
                        folderPreviewTarget: $folderPreviewTarget,
                        dropDelay: settings.dropDelay,
                        targetItem: item,
                        targetPage: pageIndex,
                        appsPerPage: settings.appsPerPage
                     ))
               }
            }
            .padding(.horizontal, layout.hPadding)
            .padding(.vertical, layout.vPadding)
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
