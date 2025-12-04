import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
   private var isCurrentlyHidden = false
   static var onExitRequested: (() -> Void)?
   
   func applicationDidHide(_ notification: Notification) {
      print("Hiding Launchpad.")
      isCurrentlyHidden = true
   }
   
   func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
      print("Reopening Launchpad.")
      if isCurrentlyHidden {
         isCurrentlyHidden = false
      } else {
         // Request exit animation instead of immediately hiding
         if let onExitRequested = AppDelegate.onExitRequested {
            onExitRequested()
         } else {
            NSApp.hide(nil)
         }
      }
      
      return true
   }
}
