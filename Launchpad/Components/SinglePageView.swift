import SwiftUI

struct SinglePageView: View {
    @Binding var pages: [[AppGridItem]]
    @Binding var draggedItem: AppGridItem?
    let layout: LayoutMetrics
    let pageIndex: Int
    let settings: LaunchpadSettings
    let isFolderOpen: Bool
    let onItemTap: (AppGridItem) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyVGrid(
                columns: GridLayoutUtility.createGridColumns(count: settings.columns, cellWidth: layout.cellWidth, spacing: layout.hSpacing),
                spacing: layout.vSpacing) {
                    ForEach(pages[pageIndex]) { item in
                        GridItemView(
                            item: item,
                            layout: layout,
                            isDragged: draggedItem?.id == item.id
                        )
                        .opacity(isFolderOpen ? 0.2 : 1)
                        .onTapGesture {
                            onItemTap(item)
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
                .frame(width: layout.size.width, height: layout.size.height, alignment: .top)
        }
    }
}
