import SwiftUI

@main
struct LaunchpadApp: App {
   @StateObject private var settingsManager = SettingsManager.shared
   @StateObject private var appManager = AppManager.shared
   @State private var showSettings = false
   @State private var isInitialized = false
   @State private var wasAlreadyActive = false

   var body: some Scene {
      WindowGroup {
         ZStack {
            WindowAccessor()
            PagedGridView(
               pages: $appManager.pages,
               settings: settingsManager.settings,
               showSettings: { showSettings = true }
            )
            .opacity(showSettings ? 0.3 : 1.0)
            .animation(LaunchPadConstants.fadeAnimation, value: showSettings)
            .onTapGesture(perform: AppLauncher.exit)

            if showSettings {
               SettingsView(onDismiss: { showSettings = false }, initialTab: settingsManager.settings.isActivated ? 1 : 3)
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

      // Handle menu bar visibility separately from dock
      NSMenu.setMenuBarVisible(settingsManager.settings.showMenuBar)

      // Subscribe to system events if dock is shown
      if(settingsManager.settings.showDock) {
         subscribeToSystemEvents()
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
}
