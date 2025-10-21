import SwiftUI

struct ClockWidgetView: View {
   let widget: Widget
   let layout: LayoutMetrics
   
   @State private var currentTime = Date()
   
   let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
   
   var body: some View {
      VStack(spacing: 4) {
         Text(currentTime, style: .time)
            .font(.system(size: layout.iconSize * 0.3, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
         
         if widget.size != .small {
            Text(currentTime, style: .date)
               .font(.system(size: layout.iconSize * 0.15, weight: .regular))
               .foregroundColor(.white.opacity(0.8))
         }
      }
      .onReceive(timer) { input in
         currentTime = input
      }
   }
}
