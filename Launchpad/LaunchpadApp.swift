import SwiftUI

/// Main application entry point for Launchpad
/// Uses liquid glass effects (macOS 26+) for modern, translucent UI
@main
struct LaunchpadApp: App {
   @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
   @StateObject private var settingsManager = SettingsManager.shared
   @StateObject private var appManager = AppManager.shared
   @State private var showSettings = false
   @State private var isInitialized = false

   var body: some Scene {
      WindowGroup {
         ZStack {
            WindowAccessor()
            PagedGridView(
               pages: $appManager.pages,
               showSettings: $showSettings,
               settings: settingsManager.settings
            )
            .opacity(showSettings ? 0.3 : 1.0)
            .animation(LaunchPadConstants.fadeAnimation, value: showSettings)
            .onTapGesture(perform: AppLauncher.exit)

            if showSettings {
               SettingsView(onDismiss: { showSettings = false }, initialTab: settingsManager.settings.isActivated ? 0 : 6)
            }
         }
         .onAppear(perform: initialize)
      }
   }

   private func initialize() {
      guard !isInitialized else { return }
      isInitialized = true
      
      appManager.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
      
      NSMenu.setMenuBarVisible(settingsManager.settings.showDock)
   }
}
