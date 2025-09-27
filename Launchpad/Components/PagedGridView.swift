import AppKit
import SwiftUI

struct PagedGridView: View {
    @Binding var pages: [[AppGridItem]]
    let settings: LaunchpadSettings
    let showSettings: () -> Void
    
    @GestureState private var dragOffset: CGFloat = 0
    @State private var currentPage = 0
    @State private var draggedPage = 0
    @State private var lastScrollTime = Date.distantPast
    @State private var accumulatedScrollX: CGFloat = 0
    @State private var eventMonitor: Any?
    @State private var searchText = ""
    @State private var draggedItem: AppGridItem?
    @State private var selectedFolder: Folder?

    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(searchText: $searchText)
            GeometryReader { geo in
                if searchText.isEmpty {
                    HStack(spacing: 0) {
                        ForEach(pages.indices, id: \.self) { pageIndex in
                            SinglePageView(
                                pages: $pages,
                                draggedItem: $draggedItem,
                                pageIndex: pageIndex,
                                settings: settings,
                                isFolderOpen: selectedFolder != nil,
                                onItemTap: handleItemTap
                            )
                            .frame(width: geo.size.width, height: geo.size.height)
                        }
                    }
                    .offset(x: -CGFloat(currentPage) * geo.size.width + dragOffset)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2), value: currentPage)
                    .onAppear(perform: setupEventMonitoring)
                    .onDisappear(perform: cleanupEventMonitoring)
                } else {
                    SearchResultsView(apps: filteredApps(), settings: settings)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            
            if searchText.isEmpty {
                PageIndicatorView(
                    currentPage: $currentPage,
                    pageCount: pages.count,
                    isFolderOpen: selectedFolder != nil,
                    searchText: searchText
                )
            }
        }
        
        FolderDetailView(
            pages: $pages,
            folder: $selectedFolder,
            settings: settings
        )
        
        PageDropZonesView(
            currentPage: currentPage,
            totalPages: pages.count,
            draggedItem: draggedItem,
            onNavigateLeft: navigateToPreviousPage,
            onNavigateRight: navigateToNextPage
        )
    }

    private func handleItemTap(_ item: AppGridItem) {
        switch item {
        case .app(let app):
            AppLauncher.launch(path: app.path)
        case .folder(let folder):
            selectedFolder = folder
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.1)) {}
        }
    }
    
    private func filteredApps() -> [AppInfo] {
        let searchTextLowercased = searchText.lowercased()
        let allItems = pages.flatMap { $0 }
        var matchingApps: [AppInfo] = []
        
        for item in allItems {
            switch item {
            case .app(let app):
                if app.name.lowercased().contains(searchTextLowercased) {
                    matchingApps.append(app)
                }
            case .folder(let folder):
                if folder.name.lowercased().contains(searchTextLowercased) {
                    matchingApps.append(contentsOf: folder.apps)
                } else {
                    let matchingFolderApps = folder.apps.filter { app in
                        app.name.lowercased().contains(searchTextLowercased)
                    }
                    matchingApps.append(contentsOf: matchingFolderApps)
                }
            }
        }
        
        return matchingApps
    }

    private func setupEventMonitoring() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel, .keyDown]) { event in
            switch event.type {
            case .scrollWheel:
                return handleScrollEvent(event)
            case .keyDown:
                return handleKeyEvent(event)
            default:
                return event
            }
        }
    }
    
    private func cleanupEventMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private func handleScrollEvent(_ event: NSEvent) -> NSEvent? {
        guard searchText.isEmpty && selectedFolder == nil else { return event }
        
        let absX = abs(event.scrollingDeltaX)
        let absY = abs(event.scrollingDeltaY)
        guard absX > absY && absX > 0 else { return event }
        
        let now = Date()
        guard now.timeIntervalSince(lastScrollTime) >= settings.scrollDebounceInterval else { return event }
        
        accumulatedScrollX += event.scrollingDeltaX
        
        if accumulatedScrollX <= -settings.scrollActivationThreshold {
            currentPage = min(currentPage + 1, pages.count - 1)
            resetScrollState(at: now)
            return nil
        } else if accumulatedScrollX >= settings.scrollActivationThreshold {
            currentPage = max(currentPage - 1, 0)
            resetScrollState(at: now)
            return nil
        }
        
        return event
    }
    
    private func resetScrollState(at time: Date) {
        lastScrollTime = time
        accumulatedScrollX = 0
    }
    
    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        switch event.keyCode {
        case 53:  // ESC key
            AppLauncher.exit()
        case 123:  // Left arrow key
            navigateToPreviousPage()
        case 124:  // Right arrow key
            navigateToNextPage()
        case 43:  // Comma key
            if event.modifierFlags.contains(.command) {
                showSettings()
            }
        default:
            break
        }
        return event
    }
    
    private func navigateToPreviousPage() {
        guard currentPage > 0 else { return }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
            currentPage -= 1
        }
    }
    
    private func navigateToNextPage() {
        guard currentPage < pages.count - 1 else { return }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
            currentPage += 1
        }
    }
}
