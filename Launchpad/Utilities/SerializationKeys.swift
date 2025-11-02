import Foundation

/// Centralized constants for serialization keys used when saving/loading app grid items
enum SerializationKeys {
   /// Key for the type of grid item (app, folder, category)
   static let type = "type"
   
   /// Key for the unique identifier
   static let id = "id"
   
   /// Key for the display name
   static let name = "name"
   
   /// Key for the page number
   static let page = "page"
   
   /// Key for the file system path
   static let path = "path"
   
   /// Key for the array of apps within a folder
   static let apps = "apps"
}

/// Type identifiers for different grid item types
enum SerializationTypes {
   /// Identifier for an application item
   static let app = "app"
   
   /// Identifier for a folder item
   static let folder = "folder"
   
   /// Identifier for a category item
   static let category = "category"
}
