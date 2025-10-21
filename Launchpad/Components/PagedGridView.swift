import AppKit
import SwiftUI

struct PagedGridView: View {
   @Binding var pages: [[AppGridItem]]
   @Binding var showSettings: Bool
   var settings: LaunchpadSettings

   @State private var currentPage = 0
   @State private var lastScrollTime = Date.distantPast
   @State private var accumulatedScrollX: CGFloat = 0
   @State private var eventMonitor: Any?
   @State private var searchText = ""
   @State private var selectedSearchIndex = 0
   @State private var draggedItem: AppGridItem?
   @State private var selectedFolder: Folder?
   @State private var sortOrder: SortOrder = SortOrder.defaultLayout
   @State private var selectedCategory: Category?

   var body: some View {
      VStack(spacing: 0) {
         SearchBarView(
            searchText: $searchText,
            sortOrder: $sortOrder,
            onSortChange: handleSort,
            onSettingsOpen: { showSettings = true },
            transparency: settings.transparency,
            showIcons: settings.showIconsInSearch
         )

         CategoryBar(
            selectedCategory: $selectedCategory,
            transparency: settings.transparency
         )

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
                        onItemTap: handleTap
                     )
                     .frame(width: geo.size.width, height: geo.size.height)
                  }
               }
               .offset(x: -CGFloat(currentPage) * geo.size.width)
               .animation(LaunchPadConstants.springAnimation, value: currentPage)
            } else {
               SearchResultsView(
                  apps: filteredApps(),
                  settings: settings,
                  selectedIndex: selectedSearchIndex,
                  onItemTap: handleTap
               )
               .frame(width: geo.size.width, height: geo.size.height)
            }
         }
         PageIndicatorView(
            currentPage: $currentPage,
            pageCount: pages.count,
            isFolderOpen: selectedFolder != nil,
            searchText: searchText,
            settings: settings
         )
      }
      .onAppear(perform: setupEventMonitoring)
      .onDisappear(perform: cleanupEventMonitoring)
      .onChange(of: searchText) {
         selectedSearchIndex = 0
      }

      FolderDetailView(
         pages: $pages,
         folder: $selectedFolder,
         settings: settings,
         onItemTap: handleTap
      )

      CategoryDetailView(
         category: $selectedCategory,
         allApps: allApps(),
         settings: settings,
         onItemTap: handleTap
      )

      PageDropZonesView(
         currentPage: currentPage,
         totalPages: pages.count,
         draggedItem: draggedItem,
         onNavigateLeft: navigateToPreviousPage,
         onNavigateRight: navigateToNextPage,
         transparency: settings.transparency
      )
   }

   private func filteredApps() -> [AppInfo] {
      guard !searchText.isEmpty else { return [] }

      let searchTerm = searchText.lowercased()
      return pages.flatMap { $0 }.flatMap { item -> [AppInfo] in
         switch item {
         case .app(let app):
            return app.name.lowercased().contains(searchTerm) ? [app] : []
         case .folder(let folder):
            if folder.name.lowercased().contains(searchTerm) {
               return folder.apps
            } else {
               return folder.apps.filter { $0.name.lowercased().contains(searchTerm) }
            }
         case .category:
            return []
         case .widget:
            return []
         }
      }
   }

   private func allApps() -> [AppInfo] {
      pages.flatMap { $0 }.compactMap { item in
         if case .app(let app) = item {
            return app
         }
         return nil
      }
   }

   private func handleTap(item: AppGridItem) {
      switch item {
      case .app(let app):
         AppLauncher.launch(path: app.path)
      case .folder(let folder):
         selectedFolder = folder
      case .category(let category):
         selectedCategory = category
      case .widget:
         // Widgets don't have tap actions
         break
      }
   }

   private func setupEventMonitoring() {
      eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel, .keyDown]) { event in
         switch event.type {
         case .scrollWheel:
            return handleScrollEvent(event: event)
         case .keyDown:
            return handleKeyEvent(event: event)
         default:
            return event
         }
      }

      NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { notification in
         guard let activatedApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }

         Task { @MainActor in
            if activatedApp.bundleIdentifier == Bundle.main.bundleIdentifier {
               handleAppActivation()
            } else {
               AppLauncher.exit()
            }
         }
      }
   }

   private func cleanupEventMonitoring() {
      if let monitor = eventMonitor {
         NSEvent.removeMonitor(monitor)
         eventMonitor = nil
      }
   }

   private func handleScrollEvent(event: NSEvent) -> NSEvent? {
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

   private func handleKeyEvent(event: NSEvent) -> NSEvent? {
      print(event.keyCode)
      // Handle special keys
      switch event.keyCode {
      case 53:  // ESC
         if !searchText.isEmpty {
            searchText = ""
            selectedSearchIndex = 0

         } else if selectedFolder == nil && selectedCategory == nil {
            AppLauncher.exit()
         } else {
            selectedFolder = nil
            selectedCategory = nil
         }
      case 123:  // Left arrow
         if !searchText.isEmpty {
            navigateSearchLeft()
            return nil
         } else if selectedFolder == nil && selectedCategory == nil {
            navigateToPreviousPage()
         }
      case 124:  // Right arrow
         if !searchText.isEmpty {
            navigateSearchRight()
            return nil
         } else if selectedFolder == nil && selectedCategory == nil {
            navigateToNextPage()
         }
      case 125:  // Down arrow
         if !searchText.isEmpty {
            navigateSearchDown()
            return nil
         }
      case 126:  // Up arrow
         if !searchText.isEmpty {
            navigateSearchUp()
            return nil
         }
      case 43:  // CMD + Comma
         showSettings = true
      case 36:  // Enter
         if selectedCategory != nil {
            launchAllAppsInCategory()
         } else {
            launchSelectedSearchResult()
         }
      default:
         break
      }

      return event
   }

   private func navigateToPreviousPage() {
      guard currentPage > 0 else { return }

      withAnimation(LaunchPadConstants.springAnimation) {
         currentPage = currentPage - 1
      }
   }

   private func navigateToNextPage() {
      if currentPage < pages.count - 1 {
         withAnimation(LaunchPadConstants.springAnimation) {
            currentPage += 1
         }
      } else {
         createNewPage()
      }
   }

   private func createNewPage() {
      pages.append([])
      withAnimation(LaunchPadConstants.springAnimation) {
         currentPage = pages.count - 1
      }
   }

   private func launchSelectedSearchResult() {
      guard !searchText.isEmpty else { return }
      let apps = filteredApps()
      guard selectedSearchIndex >= 0 && selectedSearchIndex < apps.count else { return }

      AppLauncher.launch(path: apps[selectedSearchIndex].path)
   }

   private func launchAllAppsInCategory() {
      guard selectedCategory != nil else { return }
      let categoryApps = CategoryManager.shared.getAppsForCategory(category: selectedCategory!, from: allApps())
      for app in categoryApps {
         AppLauncher.launch(path: app.path)
      }
   }

   private func handleSort(sortOrder: SortOrder) {
      AppManager.shared.sortItems(by: sortOrder, appsPerPage: settings.appsPerPage)
   }

   private func navigateSearchLeft() {
      let apps = filteredApps()
      guard !apps.isEmpty else { return }

      if selectedSearchIndex > 0 {
         selectedSearchIndex -= 1
      } else {
         selectedSearchIndex = apps.count - 1
      }
   }

   private func navigateSearchRight() {
      let apps = filteredApps()
      guard !apps.isEmpty else { return }

      if selectedSearchIndex < apps.count - 1 {
         selectedSearchIndex += 1
      } else {
         selectedSearchIndex = 0
      }
   }

   private func navigateSearchUp() {
      let apps = filteredApps()
      guard !apps.isEmpty else { return }

      let newIndex = selectedSearchIndex - settings.columns
      if newIndex >= 0 {
         selectedSearchIndex = newIndex
      } else {
         // Wrap to bottom row
         let lastRowStartIndex = (apps.count - 1) / settings.columns * settings.columns
         let columnOffset = selectedSearchIndex % settings.columns
         selectedSearchIndex = min(lastRowStartIndex + columnOffset, apps.count - 1)
      }
   }

   private func navigateSearchDown() {
      let apps = filteredApps()
      guard !apps.isEmpty else { return }

      let newIndex = selectedSearchIndex + settings.columns
      if newIndex < apps.count {
         selectedSearchIndex = newIndex
      } else {
         // Wrap to top row
         let columnOffset = selectedSearchIndex % settings.columns
         selectedSearchIndex = min(columnOffset, apps.count - 1)
      }
   }

   private func handleAppActivation() {
      if settings.resetOnRelaunch {
         currentPage = 0
         selectedFolder = nil
         selectedCategory = nil
         searchText = ""
      }

      if !settings.isActivated {
         showSettings = true
      }
   }
}
