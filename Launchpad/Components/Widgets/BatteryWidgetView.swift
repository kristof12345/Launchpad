import SwiftUI
import IOKit.ps

struct BatteryWidgetView: View {
   let widget: Widget
   let layout: LayoutMetrics
   
   @State private var batteryLevel: Int = 100
   @State private var isCharging: Bool = false
   
   let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
   
   var body: some View {
      VStack(spacing: widget.size == .small ? 2 : 8) {
         batteryIcon
            .font(.system(size: layout.iconSize * (widget.size == .small ? 0.4 : 0.5)))
            .foregroundColor(batteryColor)
         
         Text("\(batteryLevel)%")
            .font(.system(size: layout.iconSize * (widget.size == .small ? 0.25 : 0.3), weight: .semibold, design: .rounded))
            .foregroundColor(.white)
         
         if widget.size != .small && isCharging {
            Text("Charging")
               .font(.system(size: layout.iconSize * 0.12, weight: .regular))
               .foregroundColor(.white.opacity(0.8))
         }
      }
      .onAppear {
         updateBatteryInfo()
      }
      .onReceive(timer) { _ in
         updateBatteryInfo()
      }
   }
   
   private var batteryIcon: Image {
      if isCharging {
         return Image(systemName: "bolt.fill")
      } else if batteryLevel > 80 {
         return Image(systemName: "battery.100")
      } else if batteryLevel > 50 {
         return Image(systemName: "battery.75")
      } else if batteryLevel > 25 {
         return Image(systemName: "battery.50")
      } else if batteryLevel > 10 {
         return Image(systemName: "battery.25")
      } else {
         return Image(systemName: "battery.0")
      }
   }
   
   private var batteryColor: Color {
      if isCharging {
         return .green
      } else if batteryLevel > 20 {
         return .white
      } else {
         return .red
      }
   }
   
   private func updateBatteryInfo() {
      // Get battery information from macOS
      let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
      if let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] {
         for source in sources {
            if let info = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] {
               if let currentCapacity = info[kIOPSCurrentCapacityKey] as? Int,
                  let maxCapacity = info[kIOPSMaxCapacityKey] as? Int,
                  maxCapacity > 0 {
                  batteryLevel = (currentCapacity * 100) / maxCapacity
               }
               
               if let isChargingValue = info[kIOPSIsChargingKey] as? Bool {
                  isCharging = isChargingValue
               }
            }
         }
      }
   }
}
