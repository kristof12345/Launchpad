import SwiftUI

extension AppGridItem {
   var path: String {
      switch self {
      case .app(let app): return app.path
      case .folder: return ""
      case .category: return ""
      case .widget: return ""
      }
   }
   
   var lastOpenedDate: Date? {
      switch self {
      case .app(let app): return app.lastOpenedDate
      case .folder(let folder): return folder.apps.compactMap(\.lastOpenedDate).max()
      case .category: return nil
      case .widget: return nil
      }
   }
   
   var installDate: Date? {
      switch self {
      case .app(let app): return app.installDate
      case .folder(let folder): return folder.apps.compactMap(\.installDate).max()
      case .category: return nil
      case .widget: return nil
      }
   }
   
   var appPaths: Set<String> {
      switch self {
      case .app(let app): return [app.path]
      case .folder(let folder): return Set(folder.apps.map(\.path))
      case .category: return []
      case .widget: return []
      }
   }
   
   func serialize() -> [String: Any] {
      switch self {
      case .app(let app): return serialize(app)
      case .folder(let folder): return serialize(folder)
      case .category: return [:]
      case .widget(let widget): return serialize(widget)
      }
   }
   
   func serialize(_ folder: Folder) -> [String : Any] {
      return [
         "type": "folder",
         "id": folder.id.uuidString,
         "name": folder.name,
         "page": folder.page,
         "apps": folder.apps.map(serialize)
      ]
   }
   
   func serialize(_ app: AppInfo) -> [String: Any] {
      [
         "type": "app",
         "id": app.id.uuidString,
         "name": app.name,
         "page": app.page,
         "path": app.path
      ]
   }
   
   func serialize(_ widget: Widget) -> [String: Any] {
      [
         "type": "widget",
         "id": widget.id.uuidString,
         "name": widget.name,
         "widgetType": widget.type.rawValue,
         "size": widget.size.rawValue,
         "page": widget.page,
         "configuration": widget.configuration
      ]
   }
   
   func withUpdatedPage(_ newPage: Int) -> AppGridItem {
      switch self {
      case .app(let app):
         return .app(AppInfo(name: app.name, icon: app.icon, path: app.path, bundleId: app.bundleId, lastOpenedDate: app.lastOpenedDate, installDate: app.installDate, page: newPage))
      case .folder(let folder):
         return .folder(Folder(name: folder.name, page: newPage, apps: folder.apps))
      case .category(let category):
         return .category(category)
      case .widget(let widget):
         return .widget(Widget(id: widget.id, name: widget.name, type: widget.type, size: widget.size, page: newPage, configuration: widget.configuration))
      }
   }
}
