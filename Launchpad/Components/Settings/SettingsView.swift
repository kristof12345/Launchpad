import SwiftUI

struct SettingsView: View {
   private let settingsManager = SettingsManager.shared
   private let appManager = AppManager.shared
   let onDismiss: () -> Void
   
   @State private var selectedTab: Int
   @State private var settings: LaunchpadSettings = SettingsManager.shared.settings
   
   init(onDismiss: @escaping () -> Void, initialTab: Int = 0) {
      self.onDismiss = onDismiss;
      _selectedTab = State(initialValue: initialTab)
   }
   
   var body: some View {
      ZStack {
         Color.black.opacity(0.4)
            .ignoresSafeArea()
            .onTapGesture(perform: onDismiss)
         
         // GlassEffectContainer groups related glass effects for optimal performance
         // This is part of macOS 26's Liquid Glass API
         GlassEffectContainer {
            VStack(spacing: 0) {
               HStack {
                  Text(L10n.launchpadSettings)
                     .font(.title2)
                     .fontWeight(.semibold)
                  Spacer()
                  Button("✕", action: onDismiss)
                     .buttonStyle(.plain)
                     .foregroundColor(.secondary)
                     .font(.title3)
                     .hoverEffect()
               }
               .padding(.bottom, 16)
               
               HStack(spacing: 0) {
                  // Sidebar with vertical tabs
                  VStack(alignment: .leading, spacing: 4) {
                     SidebarTabButton(
                        icon: "grid",
                        label: L10n.layout,
                        isSelected: selectedTab == 0,
                        action: { selectedTab = 0 }
                     )
                     SidebarTabButton(
                        icon: "sparkles",
                        label: L10n.features,
                        isSelected: selectedTab == 1,
                        action: { selectedTab = 1 }
                     )
                     SidebarTabButton(
                        icon: "bolt",
                        label: L10n.actions,
                        isSelected: selectedTab == 2,
                        action: { selectedTab = 2 }
                     )
                     SidebarTabButton(
                        icon: "eye.slash",
                        label: L10n.hiddenApps,
                        isSelected: selectedTab == 3,
                        action: { selectedTab = 3 }
                     )
                     SidebarTabButton(
                        icon: "tag.fill",
                        label: L10n.categories,
                        isSelected: selectedTab == 4,
                        action: { selectedTab = 4 }
                     )
                     SidebarTabButton(
                        icon: "folder",
                        label: L10n.locations,
                        isSelected: selectedTab == 5,
                        action: { selectedTab = 5 }
                     )
                     SidebarTabButton(
                        icon: "key.fill",
                        label: L10n.activation,
                        isSelected: selectedTab == 6,
                        action: { selectedTab = 6 }
                     )
                     Spacer()
                  }
                  .frame(width: 200)
                  .padding(.trailing, 16)
                  
                  Divider()
                     .padding(.trailing, 16)
                  
                  // Content area
                  VStack {
                     Group {
                        if selectedTab == 0 {
                           LayoutSettings(settings: $settings)
                        } else if selectedTab == 1 {
                           FeaturesSettings(settings: $settings)
                        } else if selectedTab == 2 {
                           ActionsSettings()
                        } else if selectedTab == 3 {
                           HiddenAppsSettings()
                        } else if selectedTab == 4 {
                           CategorySettings()
                        } else if selectedTab == 5 {
                           LocationsSettings(settings: $settings)
                        } else {
                           ActivationSettings(settings: $settings)
                        }
                     }
                     
                     Spacer()
                     
                     HStack(spacing: 16) {
                        Button(L10n.resetToDefaults, action: reset)
                           .buttonStyle(.bordered)
                           .hoverEffect()
                        Spacer()
                        Button(L10n.cancel, action: onDismiss)
                           .buttonStyle(.bordered)
                           .hoverEffect()
                        Button(L10n.apply, action: apply)
                           .buttonStyle(.borderedProminent)
                           .hoverEffect()
                     }
                  }
               }
            }
            .padding(24)
            .frame(width: 720, height: 460)
         }
         // Apply liquid glass effect to the entire settings container
         // This provides a modern, translucent appearance
         .glassEffect()
         .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
      }
   }
   
   private func apply() {
      updateSettings()
      onDismiss()
   }
   
   private func reset() {
      settings = LaunchpadSettings()
      updateSettings()
   }
   
   private func updateSettings() {
      let oldAppsPerPage = settingsManager.settings.appsPerPage
      let newAppsPerPage = settings.appsPerPage
      let oldLocations = settingsManager.settings.customAppLocations
      let newLocations = settings.customAppLocations
      
      settingsManager.saveSettings(newSettings: settings)
      
      if(settings.showDock) {
         NSMenu.setMenuBarVisible(true)
      } else {
         NSMenu.setMenuBarVisible(false)
      }
      
      // Recalculate pages if the number of apps per page changed
      if oldAppsPerPage != newAppsPerPage {
         appManager.recalculatePages(appsPerPage: newAppsPerPage)
      }
      
      // Reload apps if custom locations changed
      if oldLocations != newLocations {
         appManager.loadGridItems(appsPerPage: settings.appsPerPage)
      }
   }
}
