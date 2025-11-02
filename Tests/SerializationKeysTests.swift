import XCTest
@testable import LaunchpadPlus

final class SerializationKeysTests: XCTestCase {
   
   // MARK: - SerializationKeys Tests
   
   func testSerializationKeysValues() {
      XCTAssertEqual(SerializationKeys.type, "type", "Type key should be 'type'")
      XCTAssertEqual(SerializationKeys.id, "id", "ID key should be 'id'")
      XCTAssertEqual(SerializationKeys.name, "name", "Name key should be 'name'")
      XCTAssertEqual(SerializationKeys.page, "page", "Page key should be 'page'")
      XCTAssertEqual(SerializationKeys.path, "path", "Path key should be 'path'")
      XCTAssertEqual(SerializationKeys.apps, "apps", "Apps key should be 'apps'")
   }
   
   func testSerializationKeysAreUnique() {
      let keys: Set<String> = [
         SerializationKeys.type,
         SerializationKeys.id,
         SerializationKeys.name,
         SerializationKeys.page,
         SerializationKeys.path,
         SerializationKeys.apps
      ]
      
      XCTAssertEqual(keys.count, 6, "All serialization keys should be unique")
   }
   
   func testSerializationKeysAreNotEmpty() {
      XCTAssertFalse(SerializationKeys.type.isEmpty, "Type key should not be empty")
      XCTAssertFalse(SerializationKeys.id.isEmpty, "ID key should not be empty")
      XCTAssertFalse(SerializationKeys.name.isEmpty, "Name key should not be empty")
      XCTAssertFalse(SerializationKeys.page.isEmpty, "Page key should not be empty")
      XCTAssertFalse(SerializationKeys.path.isEmpty, "Path key should not be empty")
      XCTAssertFalse(SerializationKeys.apps.isEmpty, "Apps key should not be empty")
   }
   
   // MARK: - SerializationTypes Tests
   
   func testSerializationTypesValues() {
      XCTAssertEqual(SerializationTypes.app, "app", "App type should be 'app'")
      XCTAssertEqual(SerializationTypes.folder, "folder", "Folder type should be 'folder'")
      XCTAssertEqual(SerializationTypes.category, "category", "Category type should be 'category'")
   }
   
   func testSerializationTypesAreUnique() {
      let types: Set<String> = [
         SerializationTypes.app,
         SerializationTypes.folder,
         SerializationTypes.category
      ]
      
      XCTAssertEqual(types.count, 3, "All serialization types should be unique")
   }
   
   func testSerializationTypesAreNotEmpty() {
      XCTAssertFalse(SerializationTypes.app.isEmpty, "App type should not be empty")
      XCTAssertFalse(SerializationTypes.folder.isEmpty, "Folder type should not be empty")
      XCTAssertFalse(SerializationTypes.category.isEmpty, "Category type should not be empty")
   }
   
   // MARK: - Integration Tests
   
   func testSerializationKeysMatchExpectedFormat() {
      // Verify keys match the format used in actual serialization
      let mockAppData: [String: Any] = [
         SerializationKeys.type: SerializationTypes.app,
         SerializationKeys.id: "test-id",
         SerializationKeys.name: "Test App",
         SerializationKeys.page: 0,
         SerializationKeys.path: "/Applications/Test.app"
      ]
      
      XCTAssertEqual(mockAppData[SerializationKeys.type] as? String, "app")
      XCTAssertEqual(mockAppData[SerializationKeys.id] as? String, "test-id")
      XCTAssertEqual(mockAppData[SerializationKeys.name] as? String, "Test App")
      XCTAssertEqual(mockAppData[SerializationKeys.page] as? Int, 0)
      XCTAssertEqual(mockAppData[SerializationKeys.path] as? String, "/Applications/Test.app")
   }
   
   func testFolderSerializationFormat() {
      let mockFolderData: [String: Any] = [
         SerializationKeys.type: SerializationTypes.folder,
         SerializationKeys.id: "folder-id",
         SerializationKeys.name: "Test Folder",
         SerializationKeys.page: 1,
         SerializationKeys.apps: []
      ]
      
      XCTAssertEqual(mockFolderData[SerializationKeys.type] as? String, "folder")
      XCTAssertNotNil(mockFolderData[SerializationKeys.apps] as? [Any])
   }
}
