import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
   private var isCurrentlyHidden = true

   func applicationDidFinishLaunching(_ notification: Notification) {
      // Replace the default window with our custom ResponsiveWindow
      if let window = NSApplication.shared.windows.first {
         let responsiveWindow = ResponsiveWindow(
            contentRect: window.frame,
            styleMask: window.styleMask,
            backing: .buffered,
            defer: false
         )
         
         responsiveWindow.contentView = window.contentView
         responsiveWindow.makeKeyAndOrderFront(nil)
         
         window.close()
      }
   }

   func applicationDidHide(_ notification: Notification) {
      isCurrentlyHidden = true
   }

   func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
      if isCurrentlyHidden {
         isCurrentlyHidden = false
         return true
      } else {
         AppLauncher.exit()
         return false
      }
   }
}

