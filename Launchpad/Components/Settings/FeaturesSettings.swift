import SwiftUI

struct FeaturesSettings: View {
   @Binding var settings: LaunchpadSettings

   var body: some View {
      VStack(alignment: .center, spacing: 20) {
         VStack(alignment: .leading, spacing: 12) {

            SettingsToggle(
               title: L10n.showDock,
               isOn: $settings.showDock
            )

            SettingsToggle(
               title: L10n.showMenuBar,
               isOn: $settings.showMenuBar
            )

            SettingsToggle(
               title: L10n.startAtLogin,
               isOn: Binding(
                  get: { settings.startAtLogin },
                  set: { newValue in
                     settings.startAtLogin = newValue
                     if newValue {
                        LoginItemManager.shared.enableLoginItem()
                     } else {
                        LoginItemManager.shared.disableLoginItem()
                     }
                  }
               )
            )

            SettingsSlider(
               title: L10n.dropAnimationDelay,
               value: $settings.dropDelay,
               range: 0.0...3.0,
               step: 0.1,
               minLabel: L10n.time00s,
               maxLabel: L10n.time30s
            )

            SettingsSlider(
               title: L10n.pageScrollDebounce,
               value: $settings.scrollDebounceInterval,
               range: 0.0...3.0,
               step: 0.1,
               minLabel: L10n.time00s,
               maxLabel: L10n.time30s
            )

            SettingsSlider(
               title: L10n.pageScrollThreshold,
               value: $settings.scrollActivationThreshold,
               range: 10...200,
               step: 10,
               minLabel: L10n.number10,
               maxLabel: L10n.number200
            )
         }

         VStack(alignment: .center) {
            HStack {
               Image(systemName: "info.circle")
                  .foregroundColor(.orange)
               Text(L10n.restartRequired)
                  .font(.subheadline)
                  .fontWeight(.medium)
                  .foregroundColor(.orange)
            }

            Text(L10n.restartWarningMessage)
               .font(.caption)
               .foregroundColor(.secondary)
         }
         .padding(.horizontal, 12)
         .padding(.vertical, 8)
         .background(
            RoundedRectangle(cornerRadius: 8)
               .fill(Color.orange.opacity(0.1))
               .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange.opacity(0.3), lineWidth: 1))
         )
      }
      .padding(.horizontal, 8)
   }
}
