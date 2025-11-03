import Foundation
import ServiceManagement

@MainActor
final class LoginItemManager {
   static let shared = LoginItemManager()
   
   @discardableResult
   func enableLoginItem() -> Bool {
      do {
         try SMAppService.mainApp.register()
         print("Login item enabled successfully")
         return true
      } catch {
         print("Failed to enable login item: \(error.localizedDescription)")
         return false
      }
   }
   
   @discardableResult
   func disableLoginItem() -> Bool {
      do {
         try SMAppService.mainApp.unregister()
         print("Login item disabled successfully")
         return true
      } catch {
         print("Failed to disable login item: \(error.localizedDescription)")
         return false
      }
   }
   
   func isLoginItemEnabled() -> Bool {
      return SMAppService.mainApp.status == .enabled
   }
   
   func getLoginItemStatus() -> String {
      switch SMAppService.mainApp.status {
      case .enabled:
         return "Enabled"
      case .notRegistered:
         return "Not Registered"
      case .notFound:
         return "Not Found"
      case .requiresApproval:
         return "Requires Approval"
      @unknown default:
         return "Unknown"
      }
   }
}
