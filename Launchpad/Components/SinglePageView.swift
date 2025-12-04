import SwiftUI

struct SinglePageView: View {
    @Binding var pages: [[AppGridItem]]
    @Binding var draggedItem: AppGridItem?
    @Binding var isEditMode: Bool
    @Binding var allowBackgroundDrag: Bool
    let canEdit: Bool
    let pageIndex: Int
    let settings: LaunchpadSettings
    let isFolderOpen: Bool
    let onItemTap: (AppGridItem) -> Void
    
    @State private var hoveredItem: AppGridItem?
    
    var body: some View {
        GeometryReader { geo in
            let layout = LayoutMetrics(size: geo.size, columns: settings.columns, rows: settings.rows, iconSize: settings.iconSize, margin: settings.margin)
            
            ZStack {
                // Background layer to detect clicks on empty space
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Background clicked
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                allowBackgroundDrag = true
                            }
                    )
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyVGrid(
                        columns: GridLayoutUtility.createGridColumns(count: settings.columns, cellWidth: layout.cellWidth, spacing: layout.hSpacing),
                        spacing: layout.hSpacing
                    ) {
                        ForEach(pages[pageIndex]) { item in
                            AppGridItemView(
                                item: item, 
                                layout: layout,
                                isDragged: draggedItem?.id == item.id,
                                isDraggedOn: hoveredItem?.id == item.id && draggedItem != nil && draggedItem?.id != item.id,
                                isHovered: hoveredItem?.id == item.id,
                                isEditMode: isEditMode,
                                settings: settings
                            )
                            .opacity(isFolderOpen ? LaunchpadConstants.dimmedOpacity : 1)
                            .onHover { isHovering in
                                hoveredItem = isHovering ? item : nil
                            }
                            .onTapGesture { onItemTap(item)  }
                            .onDrag {
                                draggedItem = item
                                return NSItemProvider(object: item.id.uuidString as NSString)
                            } preview: {
                                AppGridItemView(
                                    item: item,
                                    layout: layout,
                                    isDragged: false,
                                    isDraggedOn: false,
                                    isHovered: false,
                                    isEditMode: false,
                                    settings: settings
                                )
                                .frame(width: layout.cellWidth, height: layout.cellWidth + layout.fontSize + 16)
                            }
                            .onDrop(
                                of: [.text],
                                delegate: ItemDropDelegate(
                                    pages: $pages,
                                    draggedItem: $draggedItem,
                                    hoveredItem: $hoveredItem,
                                    dropDelay: settings.dropDelay,
                                    targetItem: item,
                                    targetPage: pageIndex,
                                    appsPerPage: settings.appsPerPage,
                                    isEditMode: isEditMode,
                                    canEdit: canEdit
                                ))
                        }
                    }
                    .padding(.horizontal, layout.hPadding)
                    .padding(.vertical, layout.vPadding)
                    .frame(minHeight: geo.size.height - layout.vPadding, alignment: .top)
                }
                .onDrop(of: [.text], delegate: PageDropDelegate(
                    pages: $pages,
                    draggedItem: $draggedItem,
                    targetPage: pageIndex,
                    appsPerPage: settings.appsPerPage,
                    canEdit: canEdit
                ))
            }
        }
    }
}
