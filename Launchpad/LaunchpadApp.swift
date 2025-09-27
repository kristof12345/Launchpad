import SwiftUI

@main
struct LaunchpadApp: App {
   @StateObject private var settingsManager = SettingsManager.shared
   @StateObject private var appManager = AppManager.shared
   @State private var showSettings = false
   
   var body: some Scene {
      WindowGroup {
         ZStack {
            WindowAccessor()
            PagedGridView(
               pages: $appManager.pages,
               settings: settingsManager.settings,
               showSettings: { 
                  withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
                     showSettings = true 
                  }
               }
            )
            .opacity(showSettings ? 0.2 : 1.0)
            .scaleEffect(showSettings ? 0.95 : 1.0)
            .blur(radius: showSettings ? 8 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2), value: showSettings)
            
            if showSettings {
               SettingsView(onDismiss: { 
                  withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
                     showSettings = false 
                  }
               })
               .transition(.asymmetric(
                  insertion: .scale(scale: 0.8).combined(with: .opacity),
                  removal: .scale(scale: 0.9).combined(with: .opacity)
               ))
            }
         }
         .background(VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow))
         .onAppear(perform: initialize)
         .onTapGesture(perform: AppLauncher.exit)
      }
      .windowStyle(.hiddenTitleBar)
   }
   
   private func initialize() {
      NSMenu.setMenuBarVisible(false)
      appManager.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
   }
}
