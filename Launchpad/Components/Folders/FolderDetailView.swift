import Foundation
import SwiftUI

struct FolderDetailView: View {
    @Binding var pages: [[AppGridItem]]
    @Binding var folder: Folder?
    let settings: LaunchpadSettings
    
    @State private var editingName = false
    @State private var draggedApp: AppInfo?
    @State private var isAnimatingIn = false
    @State private var isAnimatingOut = false
    @State private var dragHoverPosition: CGPoint?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if folder != nil {
            ZStack {
                // Enhanced backdrop with liquid glass
                Color.black.opacity(0.15)
                    .background(.ultraThinMaterial, in: Rectangle())
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onDrop(
                        of: [.text],
                        delegate: FolderRemoveDropDelegate(
                            folder: Binding(get: { folder! }, set: { folder = $0 }), 
                            draggedApp: $draggedApp, 
                            onRemoveApp: addAppToPage
                        )
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2)) {
                            saveFolder()
                        }
                    }

                VStack(spacing: 28) {
                    // Enhanced header with liquid glass styling
                    HStack {
                        Spacer()
                        if editingName {
                            TextField(L10n.folderNamePlaceholder, text: Binding(get: { folder!.name }, set: { folder!.name = $0 }))
                                .textFieldStyle(.plain)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.thickMaterial)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        }
                                }
                                .onSubmit { 
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        editingName = false 
                                    }
                                }
                        } else {
                            Text(folder!.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.thinMaterial)
                                        .opacity(0.8)
                                }
                                .onTapGesture { 
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        editingName = true 
                                    }
                                }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 32)
                    
                    GeometryReader { geo in
                        let layout = LayoutMetrics(size: geo.size, columns: settings.folderColumns, iconSize: settings.iconSize)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVGrid(
                                columns: GridLayoutUtility.createGridColumns(count: settings.folderColumns, cellWidth: layout.cellWidth, spacing: layout.spacing),
                                spacing: layout.spacing
                            ) {
                                ForEach(folder!.apps.indices, id: \.self) { index in
                                    let app = folder!.apps[index]
                                    AppIconView(app: app, layout: layout, isDragged: draggedApp?.id == app.id)
                                        .scaleEffect(draggedApp?.id == app.id ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: draggedApp?.id == app.id)
                                        .onDrag {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                draggedApp = app
                                            }
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
                                        .transition(.asymmetric(
                                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                                            removal: .scale(scale: 1.2).combined(with: .opacity)
                                        ))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.thinMaterial)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(.white.opacity(0.1), lineWidth: 0.5)
                                }
                        }
                    }
                }
                .frame(width: 1240, height: 840)
                .background {
                    // Enhanced liquid glass container
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.thickMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(.white.opacity(0.1))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.2), radius: 40, x: 0, y: 20)
                        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                }
                .scaleEffect(isAnimatingOut ? 0.85 : (isAnimatingIn ? 1.0 : 0.8))
                .opacity(isAnimatingOut ? 0.0 : (isAnimatingIn ? 1.0 : 0.0))
                .blur(radius: isAnimatingOut ? 4 : 0)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.2)) { 
                        isAnimatingIn = true 
                    }
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
        
        // Animate out before saving
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1)) {
            isAnimatingOut = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let newFolder = Folder(name: folder!.name, page: folder!.page, apps: folder!.apps)
            pages[pageIndex][itemIndex] = .folder(newFolder)
            folder = nil
        }
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
