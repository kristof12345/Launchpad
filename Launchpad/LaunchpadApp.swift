import SwiftUI

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
            PagedGridView(pages: $appManager.pages, showSettings: $showSettings)
               .environmentObject(settingsManager)
               .opacity(showSettings ? LaunchpadConstants.overlayOpacity : 1.0)
               .animation(LaunchpadConstants.fadeAnimation, value: showSettings)
               .onTapGesture(perform: AppLauncher.exit)

            if showSettings {
               SettingsView(onDismiss: { showSettings = false }, initialTab: 0)
            }
         }
         .background(BackgroundView())
         .environmentObject(settingsManager)
         .onAppear(perform: initialize)
      }
   }

   private func initialize() {
      guard !isInitialized else { return }

      isInitialized = true
      appManager.loadAppGridItems(appsPerPage: settingsManager.settings.appsPerPage)
      NSMenu.setMenuBarVisible(settingsManager.settings.showDock)
   }
}
