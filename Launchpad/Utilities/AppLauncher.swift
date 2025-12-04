import AppKit

@MainActor
final class AppLauncher {
   static var onExitRequested: (() -> Void)?
   
   static func launch(path: String) {
      AppManager.shared.incrementOpenCount(forPath: path)
      NSWorkspace.shared.open(URL(fileURLWithPath: path))
      exit()
   }
   
   static func exit() {
      print("Exiting Launchpad.")
      // Try to use the exit callback for animation, otherwise hide immediately
      if let onExitRequested = onExitRequested {
         onExitRequested()
      } else {
         NSApp.hide(nil)
      }
   }
   
   static func hideImmediately() {
      NSApp.hide(nil)
   }
}
