import SwiftUI

struct SinglePageView: View {
    @Binding var pages: [[AppGridItem]]
    @Binding var draggedItem: AppGridItem?
    @Binding var isEditMode: Bool
    let canEdit: Bool
    let pageIndex: Int
    let settings: LaunchpadSettings
    let isFolderOpen: Bool
    let isAppearing: Bool
    let onItemTap: (AppGridItem) -> Void
    
    @State private var hoveredItem: AppGridItem?
    
    private func itemOpacity() -> Double {
        if isFolderOpen {
            return LaunchpadConstants.dimmedOpacity
        }
        return isAppearing ? 1 : 0
    }
    
    var body: some View {
        GeometryReader { geo in
            let layout = LayoutMetrics(size: geo.size, columns: settings.columns, rows: settings.rows, iconSize: settings.iconSize, margin: settings.margin)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyVGrid(
                    columns: GridLayoutUtility.createGridColumns(count: settings.columns, cellWidth: layout.cellWidth, spacing: layout.hSpacing),
                    spacing: layout.hSpacing
                ) {
                    ForEach(Array(pages[pageIndex].enumerated()), id: \.element.id) { index, item in
                        let staggerDelay = Double(index) * LaunchpadConstants.floatInStaggerDelay
                        
                        AppGridItemView(
                            item: item, 
                            layout: layout,
                            isDragged: draggedItem?.id == item.id,
                            isDraggedOn: hoveredItem?.id == item.id && draggedItem != nil && draggedItem?.id != item.id,
                            isHovered: hoveredItem?.id == item.id,
                            isEditMode: isEditMode,
                            settings: settings
                        )
                        .opacity(itemOpacity())
                        .scaleEffect(isAppearing ? 1 : LaunchpadConstants.floatInInitialScale)
                        .offset(y: isAppearing ? 0 : LaunchpadConstants.floatInInitialOffset)
                        .animation(LaunchpadConstants.floatInAnimation.delay(staggerDelay), value: isAppearing)
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
