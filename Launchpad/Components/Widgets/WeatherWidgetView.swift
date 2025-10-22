import SwiftUI

struct WeatherWidgetView: View {
   let widget: Widget
   let layout: LayoutMetrics
   
   // Mock weather data - in a real implementation, this would fetch from a weather API
   @State private var temperature: Int = 72
   @State private var condition: String = "Partly Cloudy"
   @State private var icon: String = "cloud.sun.fill"
   
   var body: some View {
      VStack(spacing: widget.size == .small ? 2 : 8) {
         Image(systemName: icon)
            .font(.system(size: layout.iconSize * (widget.size == .small ? 0.4 : 0.5)))
            .foregroundColor(.white)
            .symbolRenderingMode(.multicolor)
         
         Text("\(temperature)°")
            .font(.system(size: layout.iconSize * (widget.size == .small ? 0.3 : 0.35), weight: .semibold, design: .rounded))
            .foregroundColor(.white)
         
         if widget.size != .small {
            Text(condition)
               .font(.system(size: layout.iconSize * 0.12, weight: .regular))
               .foregroundColor(.white.opacity(0.8))
               .lineLimit(1)
         }
      }
   }
}
