import SwiftUI

@main
struct LaunchpadApp: App {
   @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
   @StateObject private var settingsManager = SettingsManager.shared
   @StateObject private var appManager = AppManager.shared
   @State private var showSettings = false
   @State private var isInitialized = false
   @State private var windowOpacity: Double = 0.0

   var body: some Scene {
      WindowGroup {
         ZStack {
            WindowAccessor()
            PagedGridView(pages: $appManager.pages, showSettings: $showSettings)
               .environmentObject(settingsManager)
               .opacity(showSettings ? LaunchpadConstants.overlayOpacity : 1.0)
               .animation(LaunchpadConstants.fadeAnimation, value: showSettings)
               .onTapGesture(perform: handleExitRequest)

            if showSettings {
               SettingsView(onDismiss: { showSettings = false }, initialTab: settingsManager.settings.isActivated ? 0 : 7)
            }
         }
         .background(BackgroundView())
         .environmentObject(settingsManager)
         .opacity(windowOpacity)
         .animation(
            settingsManager.settings.enableFadeAnimation ? LaunchpadConstants.fadeAnimation : nil,
            value: windowOpacity
         )
         .onAppear(perform: initialize)
      }
   }

   private func initialize() {
      guard !isInitialized else { return }

      isInitialized = true
      appManager.loadAppGridItems(appsPerPage: settingsManager.settings.appsPerPage)
      NSMenu.setMenuBarVisible(settingsManager.settings.showDock)
      
      // Set up exit callback
      AppLauncher.onExitRequested = handleExitRequest
      AppDelegate.onExitRequested = handleExitRequest
      
      // Fade in animation
      if settingsManager.settings.enableFadeAnimation {
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            windowOpacity = 1.0
         }
      } else {
         windowOpacity = 1.0
      }
      
      // Listen for app activation to fade in
      NotificationCenter.default.addObserver(
         forName: NSApplication.didBecomeActiveNotification,
         object: nil,
         queue: .main
      ) { [weak self] _ in
         guard let self = self else { return }
         // Fade in when app becomes active
         if self.windowOpacity < 1.0 {
            if self.settingsManager.settings.enableFadeAnimation {
               DispatchQueue.main.async {
                  self.windowOpacity = 1.0
               }
            } else {
               self.windowOpacity = 1.0
            }
         }
      }
   }
   
   private func handleExitRequest() {
      if settingsManager.settings.enableFadeAnimation && windowOpacity > 0 {
         // Fade out before hiding
         windowOpacity = 0.0
         DispatchQueue.main.asyncAfter(deadline: .now() + LaunchpadConstants.fadeAnimationDuration) {
            AppLauncher.hideImmediately()
         }
      } else {
         AppLauncher.hideImmediately()
      }
   }
}
