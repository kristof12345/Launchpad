import SwiftUI

struct ActionsSettings: View {
   private let settingsManager = SettingsManager.shared
   private let appManager = AppManager.shared
   private let categoryManager = CategoryManager.shared

   @State private var showingClearConfirmation = false
   @State private var showingImportAlert = false
   @State private var showingExportAlert = false
   @State private var alertTitle = ""
   @State private var alertMessage = ""

   var body: some View {
      VStack(alignment: .leading, spacing: 20) {
         VStack(alignment: .leading, spacing: 12) {
            Text(L10n.layoutManagement)
               .font(.headline)
               .foregroundColor(.primary)

            Button(action: exportLayout) {
               HStack {
                  Image(systemName: "square.and.arrow.up")
                  Text(L10n.exportLayout)
                  Spacer()
               }
               .padding(.horizontal, 16)
               .padding(.vertical, 10)
               .background(Color.blue.opacity(0.1))
               .foregroundColor(.blue)
               .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .glassEffect()

            Button(action: importLayout) {
               HStack {
                  Image(systemName: "square.and.arrow.down")
                  Text(L10n.importLayout)
                  Spacer()
               }
               .padding(.horizontal, 16)
               .padding(.vertical, 10)
               .background(Color.green.opacity(0.1))
               .foregroundColor(.green)
               .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .glassEffect()

            Button(action: importFromOldLaunchpad) {
               HStack {
                  Image(systemName: "arrow.down.doc")
                  Text(L10n.importFromOldLaunchpad)
                  Spacer()
               }
               .padding(.horizontal, 16)
               .padding(.vertical, 10)
               .background(Color.purple.opacity(0.1))
               .foregroundColor(.purple)
               .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .glassEffect()

            Button(action: { showingClearConfirmation = true }) {
               HStack {
                  Image(systemName: "trash")
                  Text(L10n.clearAllApps)
                  Spacer()
               }
               .padding(.horizontal, 16)
               .padding(.vertical, 10)
               .background(Color.red.opacity(0.1))
               .foregroundColor(.red)
               .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .glassEffect()
         }

         VStack(alignment: .leading, spacing: 12) {
            Text(L10n.applicationControl)
               .font(.headline)
               .foregroundColor(.primary)

            Button(action: forceQuitApp) {
               HStack {
                  Image(systemName: "power")
                  Text(L10n.forceQuit)
                  Spacer()
               }
               .padding(.horizontal, 16)
               .padding(.vertical, 10)
               .background(Color.orange.opacity(0.1))
               .foregroundColor(.orange)
               .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .glassEffect()
         }
      }
      .alert(L10n.clearAllAppsTitle, isPresented: $showingClearConfirmation) {
         Button(L10n.cancel, role: .cancel) { }
         Button(L10n.clear, role: .destructive) {
            clearGridItems()
         }
      } message: {
         Text(L10n.clearAllAppsMessage)
      }
      .alert(alertTitle, isPresented: $showingImportAlert) {
         Button(L10n.ok) { }
      } message: {
         Text(alertMessage)
      }
      .alert(alertTitle, isPresented: $showingExportAlert) {
         Button(L10n.ok) { }
      } message: {
         Text(alertMessage)
      }
      .padding(.horizontal, 8)
   }

   private func exportLayout() {
      _ = categoryManager.exportCategories()
      let result = appManager.exportLayout()
      alertTitle = result.success ? L10n.exportSuccess : L10n.exportFailed;
      alertMessage = result.message
      showingExportAlert = true
   }

   private func importLayout() {
      _ = categoryManager.exportCategories()
      let result = appManager.importLayout(appsPerPage: settingsManager.settings.appsPerPage)
      alertTitle = result.success ? L10n.importSuccess : L10n.importFailed
      alertMessage = result.message
      showingImportAlert = true
   }

   private func clearGridItems() {
      appManager.clearGridItems(appsPerPage: settingsManager.settings.appsPerPage)
   }

   private func forceQuitApp() {
      NSApplication.shared.terminate(nil)
   }

   private func importFromOldLaunchpad() {
      let success = appManager.importFromOldLaunchpad(appsPerPage: settingsManager.settings.appsPerPage)
      if success {
         alertTitle = L10n.importSuccess
         alertMessage = L10n.importSuccessMessage
      } else {
         alertTitle = L10n.importFailed
         alertMessage = L10n.importFailedMessage
      }
      showingImportAlert = true
   }
}
