import SwiftUI

struct WidgetSettings: View {
   @ObservedObject var settingsManager: SettingsManager
   @State private var selectedWidgetType: WidgetType = .clock
   @State private var selectedWidgetSize: WidgetSize = .medium
   @State private var showAlert = false
   
   var body: some View {
      VStack(alignment: .leading, spacing: 16) {
         Text(L10n.widgets)
            .font(.headline)
         
         Text(L10n.widgetsDescription)
            .font(.caption)
            .foregroundColor(.secondary)
         
         Divider()
         
         HStack(spacing: 12) {
            Text(L10n.widgetType)
               .frame(width: 100, alignment: .leading)
            
            Picker("", selection: $selectedWidgetType) {
               Text(L10n.widgetClock).tag(WidgetType.clock)
               Text(L10n.widgetCalendar).tag(WidgetType.calendar)
               Text(L10n.widgetWeather).tag(WidgetType.weather)
               Text(L10n.widgetBattery).tag(WidgetType.battery)
               Text(L10n.widgetStocks).tag(WidgetType.stocks)
               Text(L10n.widgetNotes).tag(WidgetType.notes)
            }
            .pickerStyle(.segmented)
         }
         
         HStack(spacing: 12) {
            Text(L10n.widgetSize)
               .frame(width: 100, alignment: .leading)
            
            Picker("", selection: $selectedWidgetSize) {
               Text(L10n.widgetSizeSmall).tag(WidgetSize.small)
               Text(L10n.widgetSizeMedium).tag(WidgetSize.medium)
               Text(L10n.widgetSizeLarge).tag(WidgetSize.large)
            }
            .pickerStyle(.segmented)
         }
         
         Button(action: {
            addWidget()
         }) {
            Label(L10n.addWidget, systemImage: "plus.square")
         }
         .alert(isPresented: $showAlert) {
            Alert(
               title: Text(L10n.addWidget),
               message: Text("Widget added to the first page"),
               dismissButton: .default(Text(L10n.ok))
            )
         }
      }
      .padding()
   }
   
   private func addWidget() {
      let appsPerPage = settingsManager.settings.appsPerPage
      AppManager.shared.addWidget(type: selectedWidgetType, size: selectedWidgetSize, page: 0, appsPerPage: appsPerPage)
      showAlert = true
   }
}
