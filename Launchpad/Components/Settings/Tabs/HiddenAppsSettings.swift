import SwiftUI

struct HiddenAppsSettings: View {
   private let appManager = AppManager.shared
   private let settingsManager = SettingsManager.shared

   @State private var hiddenApps: [AppInfo] = []
   @State private var showingUnhideAllConfirmation = false

   var body: some View {
      VStack(alignment: .leading, spacing: 20) {
         VStack(alignment: .leading, spacing: 12) {
            Text(L10n.hiddenApps)
               .font(.headline)
               .foregroundColor(.primary)

            Text(L10n.hiddenAppsDescription)
               .font(.subheadline)
               .foregroundColor(.secondary)

            if hiddenApps.isEmpty {
               VStack(spacing: 12) {
                  Image(systemName: "eye.slash")
                     .font(.system(size: 48))
                     .foregroundColor(.secondary.opacity(0.5))
                  Text(L10n.noHiddenApps)
                     .font(.headline)
                     .foregroundColor(.secondary)
               }
               .frame(maxWidth: .infinity)
               .padding(.vertical, 40)
            } else {
               ScrollView {
                  VStack(spacing: 8) {
                     ForEach(hiddenApps) { app in
                        HiddenAppRow(app: app, onUnhide: {
                           unhideApp(app)
                        })
                     }
                  }
               }
               .frame(maxHeight: 300)

               Button(action: { showingUnhideAllConfirmation = true }) {
                  HStack {
                     Image(systemName: "eye")
                     Text(L10n.unhideAllApps)
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

            }
         }
         .onAppear {
            refreshHiddenApps()
         }
         .alert(L10n.unhideAllApps, isPresented: $showingUnhideAllConfirmation) {
            Button(L10n.cancel, role: .cancel) { }
            Button(L10n.unhideAllApps, role: .destructive) {
               unhideAllApps()
            }
         } message: {
            Text("This will restore all hidden apps to the grid.")
         }
         .padding(.horizontal, 8)
      }
   }

   private func refreshHiddenApps() {
      hiddenApps = appManager.getHiddenApps()
   }

   private func unhideApp(_ app: AppInfo) {
      appManager.unhideApp(path: app.path, appsPerPage: settingsManager.settings.appsPerPage)
      refreshHiddenApps()
   }

   private func unhideAllApps() {
      for app in hiddenApps {
         appManager.unhideApp(path: app.path, appsPerPage: settingsManager.settings.appsPerPage)
      }
      refreshHiddenApps()
   }
}

struct HiddenAppRow: View {
   let app: AppInfo
   let onUnhide: () -> Void

   var body: some View {
      HStack(spacing: 12) {
         Image(nsImage: app.icon)
            .resizable()
            .frame(width: 32, height: 32)
            .cornerRadius(6)

         Text(app.name)
            .font(.body)
            .foregroundColor(.primary)

         Spacer()

         Button(action: onUnhide) {
            Image(systemName: "eye")
               .foregroundColor(.blue)
         }
         .buttonStyle(.plain)
         .help(L10n.unhideApp)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(Color.secondary.opacity(0.1))
      .cornerRadius(8)
      .glassEffect()
   }
}
