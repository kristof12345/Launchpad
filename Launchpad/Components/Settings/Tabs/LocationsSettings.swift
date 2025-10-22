import SwiftUI

struct LocationsSettings: View {
   @Binding var settings: LaunchpadSettings
   private let settingsManager = SettingsManager.shared
   private let appManager = AppManager.shared
   @State private var newLocation: String = ""
   @State private var showingAlert = false
   @State private var alertMessage = ""
   @State private var customLocations: [String] = []
   
   var body: some View {
      VStack(alignment: .leading, spacing: 20) {
         VStack(alignment: .leading, spacing: 12) {
            Text(L10n.customAppLocations)
               .font(.headline)
               .foregroundColor(.primary)
            
            Text(L10n.locationsDescription)
               .font(.subheadline)
               .foregroundColor(.secondary)
            
            Text(L10n.addLocation)
               .font(.headline)
               .foregroundColor(.primary)
            
            HStack(spacing: 8) {
               TextField(L10n.locationPlaceholder, text: $newLocation)
                  .textFieldStyle(.roundedBorder)
               
               Button(action: selectFolder) {
                  Image(systemName: "folder")
               }
               .buttonStyle(.bordered)
               
               Button(action: addLocation) {
                  Image(systemName: "plus.circle.fill")
               }
               .buttonStyle(.borderedProminent)
               .disabled(newLocation.isEmpty)
            }
         }
         
         VStack(alignment: .leading, spacing: 12) {
            Text(L10n.customLocations)
               .font(.headline)
               .foregroundColor(.primary)
            
            if customLocations.isEmpty {
               Text(L10n.noCustomLocations)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                  .italic()
                  .padding(.vertical, 8)
            } else {
               ScrollView {
                  VStack(spacing: 8) {
                     ForEach(Array(customLocations.enumerated()), id: \.offset) { index, location in
                        HStack {
                           Image(systemName: "folder.fill")
                              .foregroundColor(.blue)
                           Text(location)
   .font(.body)
                              .lineLimit(1)
                              .truncationMode(.middle)
                           Spacer()
                           Button(action: {
                              removeLocation(at: index)
                           }) {
                              Image(systemName: "trash")
                                 .foregroundColor(.red)
                           }
                           .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                           RoundedRectangle(cornerRadius: 6)
                              .fill(Color.primary.opacity(0.05))
                        )
                        .glassEffect()
                     }
                  }
               }
            }
         }
      }
      .padding(.horizontal, 8)
      .onAppear {
         refreshLocations()
      }
      .alert(L10n.invalidLocation, isPresented: $showingAlert) {
         Button(L10n.ok, role: .cancel) { }
      } message: {
         Text(alertMessage)
      }
   }
   
   private func refreshLocations() {
      customLocations = settingsManager.settings.customAppLocations
   }
   
   private func addLocation() {
      let trimmedLocation = newLocation.trimmingCharacters(in: .whitespaces)
      guard !trimmedLocation.isEmpty else { return }
      
      var isDirectory: ObjCBool = false
      let exists = FileManager.default.fileExists(atPath: trimmedLocation, isDirectory: &isDirectory)
      
      if !exists {
         alertMessage = L10n.locationDoesNotExist
         showingAlert = true
         return
      }
      
      if !isDirectory.boolValue {
         alertMessage = L10n.locationNotDirectory
         showingAlert = true
         return
      }
      
      if customLocations.contains(trimmedLocation) {
         alertMessage = L10n.locationAlreadyAdded
         showingAlert = true
         return
      }
      
      // Save directly to settings manager
      var updatedSettings = settingsManager.settings
      updatedSettings.customAppLocations.append(trimmedLocation)
      settingsManager.saveSettings(newSettings: updatedSettings)
      
      // Update local state and binding
      customLocations.append(trimmedLocation)
      settings.customAppLocations.append(trimmedLocation)
      
      // Reload apps to include new location
      appManager.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
      
      newLocation = ""
   }
   
   private func removeLocation(at index: Int) {
      // Save directly to settings manager
      var updatedSettings = settingsManager.settings
      updatedSettings.customAppLocations.remove(at: index)
      settingsManager.saveSettings(newSettings: updatedSettings)
      
      // Update local state and binding
      customLocations.remove(at: index)
      settings.customAppLocations.remove(at: index)
      
      // Reload apps to reflect removed location
      appManager.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
   }
   
   private func selectFolder() {
      let panel = NSOpenPanel()
      panel.canChooseFiles = false
      panel.canChooseDirectories = true
      panel.allowsMultipleSelection = false
      panel.message = L10n.selectFolderMessage
      
      if panel.runModal() == .OK, let url = panel.url {
         newLocation = url.path
      }
   }
}
