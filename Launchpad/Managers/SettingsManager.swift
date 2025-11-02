import Foundation

@MainActor
final class SettingsManager: ObservableObject {
   static let shared = SettingsManager()

   @Published var settings: LaunchpadSettings

   private let userDefaults = UserDefaults.standard

   private init() {
      self.settings = Self.loadSettings()
   }

   func saveSettings(newSettings: LaunchpadSettings) {
      settings = newSettings

      guard let data = try? JSONEncoder().encode(settings) else { return }
      print("Save settings.")
      userDefaults.set(data, forKey: UserDefaultsKeys.settings)
   }

   private static func loadSettings() -> LaunchpadSettings {
      guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.settings),
            let settings = try? JSONDecoder().decode(LaunchpadSettings.self, from: data)
      else {
         return LaunchpadSettings()
      }
      return settings
   }

   func resetToDefaults() {
      settings = LaunchpadSettings()
   }
}
