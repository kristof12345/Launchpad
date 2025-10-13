import SwiftUI

@main
struct LaunchpadApp: App {
   @StateObject private var settingsManager = SettingsManager.shared
   @StateObject private var appManager = AppManager.shared
   @State private var showSettings = false
   @State private var isInitialized = false
   @State private var wasAlreadyActive = false
   @State private var windowRefreshTrigger = false

   var body: some Scene {
      WindowGroup {
         ZStack {
            WindowAccessor()
               .id(windowRefreshTrigger) // Force refresh when modals close
            PagedGridView(
               pages: $appManager.pages,
               settings: settingsManager.settings,
               showSettings: { showSettings = true }
            )
            .opacity(showSettings ? 0.3 : 1.0)
            .animation(LaunchPadConstants.fadeAnimation, value: showSettings)
            .allowsHitTesting(!showSettings) // Disable hit testing when settings are shown
            .contentShape(Rectangle()) // Ensure entire area is tappable
            .onTapGesture(perform: AppLauncher.exit)

            if showSettings {
               SettingsView(onDismiss: {
                  showSettings = false
                  restoreWindowFocus()
               }, initialTab: settingsManager.settings.isActivated ? 1 : 3)
            }
         }
         .background(VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow))
         .onAppear(perform: initialize)
      }
      .windowStyle(.hiddenTitleBar)
   }

   private func initialize() {
      guard !isInitialized else { return }
      appManager.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
      isInitialized = true

      if(settingsManager.settings.showDock) {
         subscribeToSystemEvents()
         NSMenu.setMenuBarVisible(true)
      } else {
         NSMenu.setMenuBarVisible(false)
      }

      if !settingsManager.settings.isActivated {
         showSettings = true
      }
   }

   private func subscribeToSystemEvents() {
      NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { notification in
         guard let activatedApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }

         let isSelf = activatedApp.bundleIdentifier == Bundle.main.bundleIdentifier
         Task { @MainActor in
            if (isSelf) {
               // If the app was already active when clicked in dock, hide it
               if self.wasAlreadyActive {
                  print("Launchpad was already active, hiding.")
                  AppLauncher.exit()
               } else {
                  print("Entering Launchpad.")
               }
               self.wasAlreadyActive = true
            } else {
               print("Exiting Launchpad.")
               self.wasAlreadyActive = false
               AppLauncher.exit()
            }
         }
      }
   }
   
   private func restoreWindowFocus() {
      // Force window to become key and restore event handling
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
         if let window = NSApp.windows.first(where: { $0.isVisible && $0.level == .statusBar }) {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
         }
         // Toggle state to force WindowAccessor refresh
         windowRefreshTrigger.toggle()
      }
   }
}
