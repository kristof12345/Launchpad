import SwiftUI

extension AppGridItem {
   var path: String {
      switch self {
      case .app(let app): return app.path
      case .folder: return ""
      case .category: return ""
      }
   }

   var lastOpenedDate: Date? {
      switch self {
      case .app(let app): return app.lastOpenedDate
      case .folder(let folder): return folder.apps.compactMap(\.lastOpenedDate).max()
      case .category: return nil
      }
   }

   var installDate: Date? {
      switch self {
      case .app(let app): return app.installDate
      case .folder(let folder): return folder.apps.compactMap(\.installDate).max()
      case .category: return nil
      }
   }

   var appPaths: Set<String> {
      switch self {
      case .app(let app): return [app.path]
      case .folder(let folder): return Set(folder.apps.map(\.path))
      case .category: return []
      }
   }

   func serialize() -> [String: Any] {
      switch self {
      case .app(let app): return serialize(app)
      case .folder(let folder): return serialize(folder)
      case .category: return [:]
      }
   }

   func serialize(_ folder: Folder) -> [String : Any] {
      return [
         SerializationKeys.type: SerializationTypes.folder,
         SerializationKeys.id: folder.id.uuidString,
         SerializationKeys.name: folder.name,
         SerializationKeys.page: folder.page,
         SerializationKeys.apps: folder.apps.map(serialize)
      ]
   }

   func serialize(_ app: AppInfo) -> [String: Any] {
      [
         SerializationKeys.type: SerializationTypes.app,
         SerializationKeys.id: app.id.uuidString,
         SerializationKeys.name: app.name,
         SerializationKeys.page: app.page,
         SerializationKeys.path: app.path
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
      }
   }
}
