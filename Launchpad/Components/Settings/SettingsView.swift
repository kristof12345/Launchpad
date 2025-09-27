import SwiftUI

struct SettingsView: View {
   private let settingsManager = SettingsManager.shared
   private let appManager = AppManager.shared
   let onDismiss: () -> Void

   @State private var selectedTab = 0
   @State private var settings: LaunchpadSettings = SettingsManager.shared.settings

   var body: some View {
      ZStack {
         // Liquid glass backdrop
         Color.black.opacity(0.2)
            .background(.ultraThinMaterial, in: Rectangle())
            .ignoresSafeArea()
            .onTapGesture {
               withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
                  onDismiss()
               }
            }
         
         VStack(spacing: 0) {
            // Header with liquid glass styling
            HStack {
               Text(L10n.launchpadSettings)
                  .font(.title2)
                  .fontWeight(.semibold)
                  .foregroundStyle(.primary)
               Spacer()
               Button(action: {
                  withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.1)) {
                     onDismiss()
                  }
               }) {
                  Image(systemName: "xmark.circle.fill")
                     .font(.title3)
                     .foregroundStyle(.secondary, .quaternary)
                     .symbolRenderingMode(.hierarchical)
               }
               .buttonStyle(.plain)
               .scaleEffect(1.0)
               .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedTab)
            }
            .padding(.bottom, 20)

            // Enhanced segmented picker with liquid glass
            Picker("", selection: $selectedTab) {
               Label(L10n.layout, systemImage: "grid").tag(0)
               Label(L10n.actions, systemImage: "bolt").tag(1)
            }
            .pickerStyle(.segmented)
            .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .padding(.bottom, 20)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)

            // Content area with smooth transitions
            Group {
               if selectedTab == 0 {
                  LayoutSettings(settings: $settings)
                     .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                     ))
               } else {
                  ActionsSettings()
                     .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                     ))
               }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2), value: selectedTab)

            Spacer()

            // Enhanced action buttons with liquid glass styling
            HStack(spacing: 12) {
               Button(L10n.resetToDefaults) {
                  withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                     reset()
                  }
               }
               .buttonStyle(.bordered)
               .controlSize(.regular)
               
               Spacer()
               
               Button(L10n.cancel) {
                  withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                     onDismiss()
                  }
               }
               .buttonStyle(.bordered)
               .controlSize(.regular)
               
               Button(L10n.apply) {
                  withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                     apply()
                  }
               }
               .buttonStyle(.borderedProminent)
               .controlSize(.regular)
            }
         }
         .padding(28)
         .frame(width: 500, height: 540)
         .background {
            // Multi-layer liquid glass effect
            RoundedRectangle(cornerRadius: 20, style: .continuous)
               .fill(.thickMaterial)
               .overlay {
                  RoundedRectangle(cornerRadius: 20, style: .continuous)
                     .fill(.white.opacity(0.1))
               }
               .overlay {
                  RoundedRectangle(cornerRadius: 20, style: .continuous)
                     .stroke(.white.opacity(0.2), lineWidth: 1)
               }
               .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 15)
               .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
         }
         .scaleEffect(1.0)
         .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2), value: selectedTab)
         .onTapGesture(perform: {})
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

      settingsManager.updateSettings(
         columns: settings.columns,
         rows: settings.rows,
         iconSize: settings.iconSize,
         dropDelay: settings.dropDelay,
         folderColumns: settings.folderColumns,
         folderRows: settings.folderRows,
         scrollDebounceInterval: settings.scrollDebounceInterval,
         scrollActivationThreshold: CGFloat(settings.scrollActivationThreshold)
      )

      // Recalculate pages if the number of apps per page changed
      if oldAppsPerPage != newAppsPerPage {
         appManager.recalculatePages(appsPerPage: newAppsPerPage)
      }
   }
}
