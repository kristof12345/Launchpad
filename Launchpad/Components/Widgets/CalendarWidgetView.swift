import SwiftUI

struct CalendarWidgetView: View {
   let widget: Widget
   let layout: LayoutMetrics
   
   @State private var currentDate = Date()
   
   let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
   
   var body: some View {
      VStack(spacing: widget.size == .small ? 2 : 8) {
         // Day of week
         Text(dayOfWeek)
            .font(.system(size: layout.iconSize * (widget.size == .small ? 0.15 : 0.18), weight: .medium))
            .foregroundColor(.white.opacity(0.9))
            .textCase(.uppercase)
         
         // Day number
         Text(dayNumber)
            .font(.system(size: layout.iconSize * (widget.size == .small ? 0.4 : 0.5), weight: .bold, design: .rounded))
            .foregroundColor(.white)
         
         if widget.size != .small {
            // Month and year
            Text(monthYear)
               .font(.system(size: layout.iconSize * 0.15, weight: .regular))
               .foregroundColor(.white.opacity(0.8))
         }
      }
      .onReceive(timer) { input in
         currentDate = input
      }
   }
   
   private var dayOfWeek: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "EEE"
      return formatter.string(from: currentDate)
   }
   
   private var dayNumber: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "d"
      return formatter.string(from: currentDate)
   }
   
   private var monthYear: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "MMMM yyyy"
      return formatter.string(from: currentDate)
   }
}
