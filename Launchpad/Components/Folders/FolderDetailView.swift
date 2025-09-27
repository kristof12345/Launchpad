import Foundation
import SwiftUI

struct FolderDetailView: View {
    @Binding var pages: [[AppGridItem]]
    @Binding var folder: Folder?
    let settings: LaunchpadSettings
    
    @State private var editingName = false
    @State private var draggedApp: AppInfo?
    @State private var isAnimatingIn = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if folder != nil {
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onDrop(
                        of: [.text],
                        delegate: FolderRemoveDropDelegate(folder: Binding(get: { folder! }, set: { folder = $0 }), draggedApp: $draggedApp, onRemoveApp: addAppToPage)
                    )
                    .onTapGesture {
                        saveFolder()
                    }
                
                VStack(spacing: 24) {
                    HStack {
                        Spacer()
                        if editingName {
                            TextField(L10n.folderNamePlaceholder, text: Binding(get: { folder!.name }, set: { folder!.name = $0 }))
                                .textFieldStyle(.roundedBorder)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .onSubmit { editingName = false }
                        } else {
                            Text(folder!.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(colorScheme == .dark ? .white : .primary)
                                .onTapGesture { editingName = true }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    GeometryReader { geo in
                        let layout = LayoutMetrics(size: geo.size, columns: settings.folderColumns, rows: settings.folderRows, iconSize: settings.iconSize)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVGrid(
                                columns: GridLayoutUtility.createGridColumns(count: settings.folderColumns, cellWidth: layout.cellWidth, spacing: layout.hSpacing),
                                spacing: layout.vSpacing
                            ) {
                                ForEach(folder!.apps) { app in
                                    AppIconView(app: app, layout: layout)
                                        .onDrag {
                                            draggedApp = app
                                            return NSItemProvider(object: app.id.uuidString as NSString)
                                        }
                                        .onDrop(
                                            of: [.text],
                                            delegate: FolderDropDelegate(
                                                folder: Binding(get: { self.folder! }, set: { self.folder = $0 }),
                                                draggedApp: $draggedApp,
                                                dropDelay: settings.dropDelay,
                                                targetApp: app
                                            ))
                                }
                            }
                        }
                    }
                }
                .frame(width: 1200, height: 800)
                .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).cornerRadius(16))
                .shadow(
                    color: colorScheme == .dark ? .black.opacity(0.5) : .black.opacity(0.2),
                    radius: 30, x: 0, y: 15
                )
                .shadow(
                    color: colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.08),
                    radius: 5, x: 0, y: 2
                )
                .scaleEffect(isAnimatingIn ? 1.0 : 0.9)
                .opacity(isAnimatingIn ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) { isAnimatingIn = true }
                }
                .onTapGesture { }
            }
        }
    }
    
    private func saveFolder() {
        guard let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == folder!.id }) }),
              let itemIndex = pages[pageIndex].firstIndex(where: { $0.id == folder!.id }) else {
            return
        }
        let newFolder = Folder(name: folder!.name, page: folder!.page, apps: folder!.apps)
        pages[pageIndex][itemIndex] = .folder(newFolder)
        folder = nil
    }
    
    private func addAppToPage(app: AppInfo) {
        guard let folder = folder,
              let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == folder.id }) }) else { return }
        let updatedApp = AppInfo(name: app.name, icon: app.icon, path: app.path, page: pageIndex)
        pages[pageIndex].append(.app(updatedApp))
        handlePageOverflow(pageIndex: pageIndex)
    }
    
    private func handlePageOverflow(pageIndex: Int) {
        while pages[pageIndex].count > settings.appsPerPage {
            let overflowItem = pages[pageIndex].removeLast()
            let nextPage = pageIndex + 1
            let updatedOverflowItem: AppGridItem
            switch overflowItem {
            case .app(let app):
                updatedOverflowItem = .app(AppInfo(name: app.name, icon: app.icon, path: app.path, page: nextPage))
            case .folder(let folder):
                updatedOverflowItem = .folder(Folder(name: folder.name, page: nextPage, apps: folder.apps))
            }
            if nextPage >= pages.count {
                pages.append([updatedOverflowItem])
            } else {
                pages[nextPage].insert(updatedOverflowItem, at: 0)
                handlePageOverflow(pageIndex: nextPage)
            }
        }
    }
}
