import AppKit
import Foundation

@MainActor
final class AppManager: ObservableObject {
   private let userDefaults = UserDefaults.standard
   private let gridItemsKey = "LaunchpadGridItems"
   private let hiddenAppsKey = "LaunchpadHiddenApps"

   static let shared = AppManager()

   private init() {
      self.pages = [[]]
      self.hiddenAppPaths = Set(userDefaults.stringArray(forKey: hiddenAppsKey) ?? [])
   }

   @Published var pages: [[AppGridItem]]
   @Published var hiddenAppPaths: Set<String> {
      didSet {
         saveHiddenApps()
      }
   }

   func loadGridItems(appsPerPage: Int) {
      print("Load grid items.")
      let apps = discoverApps()
      let gridItems = loadLayoutFromUserDefaults(for: apps)
      let visibleItems = gridItems.filter { item in !isItemHidden(item) }

      pages = groupItemsByPage(items: visibleItems, appsPerPage: appsPerPage)
   }

   func saveGridItems() {
      print("Save grid items.")
      let itemsData = pages.flatMap { $0 }.map { $0.serialize() }
      userDefaults.set(itemsData, forKey: gridItemsKey)
   }

   func importLayout(appsPerPage: Int) -> (success: Bool, message: String) {
      let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("LaunchpadLayout.json")
      let result = importLayoutFromJSON(filePath: filePath, appsPerPage: appsPerPage)
      saveGridItems()
      return result
   }

   func exportLayout() -> (success: Bool, message: String) {
      let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("LaunchpadLayout.json")
      return exportLayoutToJSON(filePath: filePath)
   }

   func clearGridItems(appsPerPage: Int) {
      print("Clear grid items.")
      userDefaults.removeObject(forKey: gridItemsKey)
      userDefaults.synchronize()
      loadGridItems(appsPerPage: appsPerPage)
   }

   func importFromOldLaunchpad(appsPerPage: Int) -> Bool {
      print("Import from old Launchpad database.")
      let apps = discoverApps()

      guard DatabaseImportManager.shared.oldLaunchpadDatabaseExists() else {
         print("Old Launchpad database not found")
         return false
      }

      var gridItems = DatabaseImportManager.shared.readOldLaunchpadLayout(currentApps: apps)

      addRemainingApps(items: &gridItems, apps: apps)

      pages = groupItemsByPage(items: gridItems, appsPerPage: appsPerPage)
      saveGridItems()

      print("Successfully imported layout from old Launchpad")
      return true
   }

   func recalculatePages(appsPerPage: Int) {
      print("Recalculate pages.")
      let allItems = pages.flatMap { $0 }
      pages = groupItemsByPage(items: allItems, appsPerPage: appsPerPage)
   }

   func sortItems(by sortOrder: SortOrder, appsPerPage: Int) {
      print("Sort order changed to: \(sortOrder.rawValue)")
      var allItems = pages.flatMap { $0 }

      switch sortOrder {
      case .name:
         sortByName(&allItems)
      case .itemType:
         sortByType(&allItems)
      case .lastOpened:
         sortByLastOpened(&allItems)
      case .installDate:
         sortByInstallDate(&allItems)
      case .defaultLayout:
         // Load the saved layout from UserDefaults
         let apps = discoverApps()
         allItems = loadLayoutFromUserDefaults(for: apps)
      }

      pages = groupItemsByPage(items: allItems, appsPerPage: appsPerPage)
   }

   fileprivate func sortByName(_ items: inout [AppGridItem]) {
      items.sort { $0.name < $1.name }
   }

   fileprivate func sortByType(_ items: inout [AppGridItem]) {
      items.sort { $0.isFolder != $1.isFolder ? $0.isFolder : $0.name < $1.name }
   }

   fileprivate func sortByLastOpened(_ items: inout [AppGridItem]) {
      // Sort by last opened date (most recent first), with nil dates at the end
      items.sort { item1, item2 in
         let date1 = item1.lastOpenedDate
         let date2 = item2.lastOpenedDate

         // If both have dates, compare them (newer first)
         if let d1 = date1, let d2 = date2 {
            return d1 > d2
         }
         // If only first has date, it comes first
         if date1 != nil { return true }
         // If only second has date, it comes first
         if date2 != nil { return false }
         // If neither has date, sort by name
         return item1.name < item2.name
      }
   }

   fileprivate func sortByInstallDate(_ items: inout [AppGridItem]) {
      // Sort by install date (most recent first), with nil dates at the end
      items.sort { item1, item2 in
         let date1 = item1.installDate
         let date2 = item2.installDate

         // If both have dates, compare them (newer first)
         if let d1 = date1, let d2 = date2 {
            return d1 > d2
         }
         // If only first has date, it comes first
         if date1 != nil { return true }
         // If only second has date, it comes first
         if date2 != nil { return false }
         // If neither has date, sort by name
         return item1.name < item2.name
      }
   }

   private func discoverApps() -> [AppInfo] {
      print("Discover apps.")
      let defaultPaths = ["/Applications", "/System/Applications"]
      let customPaths = SettingsManager.shared.settings.customAppLocations
      let allPaths = defaultPaths + customPaths
      return allPaths.flatMap { discoverAppsRecursively(directory: $0) }.sorted { $0.name.lowercased() < $1.name.lowercased() }
   }

   private func discoverAppsRecursively(directory: String, maxDepth: Int = 3, currentDepth: Int = 0) -> [AppInfo] {
      guard currentDepth < maxDepth, let contents = try? FileManager.default.contentsOfDirectory(atPath: directory)
      else { return [] }
      var foundApps: [AppInfo] = []
      for item in contents {
         let path = "\(directory)/\(item)"
         if item.hasSuffix(".app") {
            let name = getLocalizedAppName(for: URL(fileURLWithPath: path), fallbackName: item.replacingOccurrences(of: ".app", with: ""))
            let icon = IconCache.shared.icon(forPath: path)
            let bundleId = Bundle(path: path)?.bundleIdentifier ?? "unknown.bundle.\(name)"

            let installDate = try? FileManager.default.attributesOfItem(atPath: path)[.creationDate] as? Date
            let lastOpenedDate = try? URL(fileURLWithPath: path).resourceValues(forKeys: [.contentAccessDateKey]).contentAccessDate

            foundApps.append(AppInfo(name: name, icon: icon, path: path, bundleId: bundleId, lastOpenedDate: lastOpenedDate, installDate: installDate))
         } else if shouldSearchDirectory(item: item, at: path) {
            foundApps.append(contentsOf: discoverAppsRecursively(directory: path, maxDepth: maxDepth, currentDepth: currentDepth + 1))
         }
      }
      return foundApps
   }

   private func shouldSearchDirectory(item: String, at path: String) -> Bool {
      let skipDirectories = [".Trash", ".DS_Store", ".localized"]
      var isDirectory: ObjCBool = false
      return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
      && isDirectory.boolValue && !skipDirectories.contains(item) && !item.hasPrefix(".")
   }

   private func loadLayoutFromUserDefaults(for apps: [AppInfo]) -> [AppGridItem] {
      print("Load layout.")
      guard let savedData = userDefaults.array(forKey: gridItemsKey) as? [[String: Any]] else { return apps.map{.app($0)} }

      let appsByPath = Dictionary(uniqueKeysWithValues: apps.map { ($0.path, $0) })
      var gridItems: [AppGridItem] = []

      for itemData in savedData {
         guard let type = itemData["type"] as? String else { continue }
         switch type {
         case "app":
            if let gridItem = loadAppItem(from: itemData, appsByPath: appsByPath) {
               gridItems.append(gridItem)
            }
         case "folder":
            if let gridItem = loadFolderItem(from: itemData, appsByPath: appsByPath) {
               gridItems.append(gridItem)
            }
         case "widget":
            if let gridItem = loadWidgetItem(from: itemData) {
               gridItems.append(gridItem)
            }
         default:
            break
         }
      }

      addRemainingApps(items: &gridItems, apps: apps)

      return gridItems
   }

   private func loadAppItem(from itemData: [String: Any], appsByPath: [String: AppInfo]) -> AppGridItem? {
      let path = itemData["path"] as! String
      let page = itemData["page"] as! Int
      guard let baseApp = appsByPath[path] else { return nil }
      return .app(AppInfo(name: baseApp.name, icon: baseApp.icon, path: baseApp.path, bundleId: baseApp.bundleId,lastOpenedDate: baseApp.lastOpenedDate, installDate: baseApp.installDate, page: page))

   }

   private func loadFolderItem(from itemData: [String: Any], appsByPath: [String: AppInfo]) -> AppGridItem? {
      guard let folderName = itemData["name"] as? String,
            let appsData = itemData["apps"] as? [[String: Any]] else { return nil }
      let folderApps = appsData.compactMap { appData -> AppInfo? in
         guard let path = appData["path"] as? String,
               let app = appsByPath[path] else { return nil }
         let savedPage = appData["page"] as? Int ?? 0
         return AppInfo(name: app.name, icon: app.icon, path: app.path, bundleId: app.bundleId, lastOpenedDate: app.lastOpenedDate, installDate: app.installDate,  page: savedPage)
      }
      guard !folderApps.isEmpty else { return nil }
      let savedPage = itemData["page"] as? Int ?? 0
      let folder = Folder(name: folderName, page: savedPage, apps: folderApps)
      return .folder(folder)
   }
   
   private func loadWidgetItem(from itemData: [String: Any]) -> AppGridItem? {
      guard let name = itemData["name"] as? String,
            let widgetTypeString = itemData["widgetType"] as? String,
            let widgetType = WidgetType(rawValue: widgetTypeString),
            let sizeString = itemData["size"] as? String,
            let size = WidgetSize(rawValue: sizeString) else { return nil }
      
      let page = itemData["page"] as? Int ?? 0
      let configuration = itemData["configuration"] as? [String: String] ?? [:]
      
      let widget = Widget(name: name, type: widgetType, size: size, page: page, configuration: configuration)
      return .widget(widget)
   }

   private func getLocalizedAppName(for url: URL, fallbackName: String) -> String {
      if let rawValue = NSMetadataItem(url: url)?.value(forAttribute: kMDItemDisplayName as String) as? String {
         var trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
         if trimmed.lowercased().hasSuffix(".app") {
            trimmed = String(trimmed.dropLast(4))
         }
         return trimmed
      }
      return fallbackName
   }

   private func groupItemsByPage(items: [AppGridItem], appsPerPage: Int) -> [[AppGridItem]] {
      print("App count: \(items.count)")
      let groupedByPage = Dictionary(grouping: items) { $0.page }
      let pageCount = max(groupedByPage.keys.max() ?? 1, 1)
      var pages: [[AppGridItem]] = []
      var currentPage = 0

      print("Page count: \(pageCount)")

      for pageNum in currentPage...pageCount {
         currentPage = pageNum
         var currentPageItems: [AppGridItem] = []
         let pageItems = groupedByPage[pageNum] ?? []
         print("Current page: \(currentPage), page num: \(pageNum), items: \(pageItems.count)")
         for item in pageItems {
            if currentPageItems.count >= appsPerPage {
               pages.append(currentPageItems)
               currentPage += 1
               currentPageItems = []
            }

            let updatedItem = currentPage > item.page ? updateItemPage(item: item, to: currentPage) : item
            currentPageItems.append(updatedItem)
         }

         if !currentPageItems.isEmpty {
            pages.append(currentPageItems)
         }
      }
      return pages.isEmpty ? [[]] : pages
   }

   private func updateItemPage(item: AppGridItem, to page: Int) -> AppGridItem {
      return item.withUpdatedPage(page)
   }

   private func importLayoutFromJSON(filePath: URL, appsPerPage: Int) -> (success: Bool, message: String) {
      guard FileManager.default.fileExists(atPath: filePath.path) else {
         print("Layout file not found at \(filePath.path)")
         return (false, "Layout file not found at \n\(filePath.path)")
      }

      do {
         let jsonData = try Data(contentsOf: filePath)
         let itemsArray = try JSONSerialization.jsonObject(with: jsonData) as! [[String: Any]]
         let allApps = discoverApps()
         let appsByPath = Dictionary(uniqueKeysWithValues: allApps.map { ($0.path, $0) })
         var gridItems: [AppGridItem] = []
         for itemData in itemsArray {
            let type = itemData["type"] as! String
            switch type {
            case "app":
               if let gridItem = loadAppItem(from: itemData, appsByPath: appsByPath) {
                  gridItems.append(gridItem)
               }
            case "folder":
               if let gridItem = loadFolderItem(from: itemData, appsByPath: appsByPath) {
                  gridItems.append(gridItem)
               }
            case "widget":
               if let gridItem = loadWidgetItem(from: itemData) {
                  gridItems.append(gridItem)
               }
            default:
               break
            }
         }
         let newPages = groupItemsByPage(items: gridItems, appsPerPage: appsPerPage)
         self.pages = newPages
         print("Successfully imported layout from \(filePath.path)")
         return (true, "Successfully imported layout from \n\(filePath.path)")
      } catch {
         print("Failed to import layout \(error)")
         return (false, "Failed to import layout \n\(error.localizedDescription)")
      }
   }

   private func exportLayoutToJSON(filePath: URL) -> (success: Bool, message: String) {
      do {
         let itemsData = pages.flatMap { $0 }.map { $0.serialize() }
         let jsonData = try JSONSerialization.data(withJSONObject: itemsData, options: .prettyPrinted)
         try jsonData.write(to: filePath)
         print("Layout export finished successfully to \(filePath.path)")
         return (true, "Layout export finished successfully to \n\(filePath.path)")
      } catch {
         print("Failed to export layout \(error)")
         return (false, "Failed to export layout \n\(error.localizedDescription)")
      }
   }

   private func addRemainingApps(items: inout [AppGridItem], apps: [AppInfo]) {
      var usedApps = Set<String>()
      for gridItem in items {
         usedApps.formUnion(gridItem.appPaths)
      }

      let maxPage = items.map(\.page).max() ?? 0
      for app in apps where !usedApps.contains(app.path) {
         items.append(.app(AppInfo(name: app.name, icon: app.icon, path: app.path, bundleId: app.bundleId, lastOpenedDate: app.lastOpenedDate, installDate: app.installDate,  page: maxPage)))
      }
   }

   private func saveHiddenApps() {
      print("Save hidden apps.")
      userDefaults.set(Array(hiddenAppPaths), forKey: hiddenAppsKey)
      userDefaults.synchronize()
   }

   func hideApp(path: String, appsPerPage: Int) {
      print("Hide app: \(path)")
      hiddenAppPaths.insert(path)
      loadGridItems(appsPerPage: appsPerPage)
   }

   func unhideApp(path: String, appsPerPage: Int) {
      print("Unhide app: \(path)")
      hiddenAppPaths.remove(path)
      loadGridItems(appsPerPage: appsPerPage)
   }

   func getHiddenApps() -> [AppInfo] {
      let allApps = discoverApps()
      return allApps.filter { hiddenAppPaths.contains($0.path) }
   }

   private func isItemHidden(_ item: AppGridItem) -> Bool {
      switch item {
      case .app(let app):
         return hiddenAppPaths.contains(app.path)
      case .folder(_):
         return false
      case .category:
         return false
      case .widget:
         return false
      }
   }
   
   func addWidget(type: WidgetType, size: WidgetSize, page: Int, appsPerPage: Int) {
      let widget = Widget(name: type.rawValue.capitalized, type: type, size: size, page: page)
      let widgetItem = AppGridItem.widget(widget)
      
      // Add the widget to the specified page
      if page < pages.count {
         pages[page].append(widgetItem)
      } else {
         // Create new page if needed
         while pages.count <= page {
            pages.append([])
         }
         pages[page].append(widgetItem)
      }
      
      // Recalculate pages to ensure proper layout
      recalculatePages(appsPerPage: appsPerPage)
      saveGridItems()
   }
   
   func removeWidget(id: UUID, appsPerPage: Int) {
      for pageIndex in 0..<pages.count {
         pages[pageIndex].removeAll { item in
            if case .widget(let widget) = item {
               return widget.id == id
            }
            return false
         }
      }
      
      recalculatePages(appsPerPage: appsPerPage)
      saveGridItems()
   }
}
