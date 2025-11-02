import XCTest
import AppKit
@testable import LaunchpadPlus

/// Base test case class providing common setup/teardown for AppManager tests
/// This improves test isolation by ensuring consistent cleanup between tests
@MainActor
class BaseTestCase: XCTestCase {
   
   var appManager: AppManager!
   
   override func setUp() {
      super.setUp()
      appManager = AppManager.shared
      clearAllTestData()
   }
   
   override func tearDown() {
      clearAllTestData()
      super.tearDown()
   }
   
   /// Clears all test-related data from UserDefaults and resets manager state
   func clearAllTestData() {
      UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.gridItems)
      UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.hiddenApps)
      UserDefaults.standard.synchronize()
      
      // Reset AppManager state
      appManager.pages = [[]]
      appManager.hiddenAppPaths = Set<String>()
   }
   
   /// Creates a single mock app for testing
   func createMockApp(name: String, path: String, bundleId: String = "com.test.app", page: Int) -> AppInfo {
      let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
      return AppInfo(
         name: name,
         icon: mockIcon,
         path: path,
         bundleId: bundleId,
         lastOpenedDate: nil,
         installDate: nil,
         page: page
      )
   }
   
   /// Creates mock apps for testing
   func createMockApps(count: Int, startingPage: Int = 0) -> [AppGridItem] {
      let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
      return (0..<count).map { i in
         let app = AppInfo(
            name: "Test App \(i)",
            icon: mockIcon,
            path: "/Applications/TestApp\(i).app",
            bundleId: "com.test.app\(i)",
            lastOpenedDate: nil,
            installDate: nil,
            page: startingPage
         )
         return AppGridItem.app(app)
      }
   }
   
   /// Creates a mock folder for testing
   func createMockFolder(name: String, page: Int, appCount: Int = 3) -> Folder {
      let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
      let apps = (0..<appCount).map { i in
         AppInfo(
            name: "\(name) App \(i)",
            icon: mockIcon,
            path: "/Applications/\(name)App\(i).app",
            bundleId: "com.test.\(name.lowercased()).\(i)",
            lastOpenedDate: nil,
            installDate: nil,
            page: 0
         )
      }
      return Folder(name: name, page: page, apps: apps)
   }
   
   /// Waits for async operations to complete
   func waitForAsync(_ nanoseconds: UInt64 = 100_000_000) async {
      try? await Task.sleep(nanoseconds: nanoseconds)
   }
}
