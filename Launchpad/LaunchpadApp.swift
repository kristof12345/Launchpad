import SwiftUI

@main
struct LaunchpadApp: App {
   @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
   @StateObject private var settingsManager = SettingsManager.shared
   @StateObject private var appManager = AppManager.shared
   @State private var showSettings = false
   @State private var isInitialized = false

   var body: some Scene {
      Window("Launchpad", id: "main") {
         ZStack {
            PagedGridView(
               pages: $appManager.pages,
               showSettings: $showSettings,
               settings: settingsManager.settings
            )
            .opacity(showSettings ? 0.3 : 1.0)
            .animation(LaunchPadConstants.fadeAnimation, value: showSettings)
            .onTapGesture(perform: AppLauncher.exit)

            if showSettings {
               SettingsView(onDismiss: { showSettings = false }, initialTab: settingsManager.settings.isActivated ? 0 : 5)
            }
         }
         .background(VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow))
         .onAppear(perform: initialize)
         .ignoresSafeArea()
      }
      .windowStyle(.hiddenTitleBar)
      .windowResizability(.contentSize)
      .defaultSize(width: NSScreen.main?.frame.width ?? 1920, height: NSScreen.main?.frame.height ?? 1080)
   }

   private func initialize() {
      guard !isInitialized else { return }
      isInitialized = true
      
      appManager.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
      
      NSMenu.setMenuBarVisible(settingsManager.settings.showDock)
   }
}
