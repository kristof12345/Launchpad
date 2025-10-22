import SwiftUI

struct WidgetView: View {
   let widget: Widget
   let layout: LayoutMetrics
   let isDragged: Bool
   
   var body: some View {
      ZStack {
         RoundedRectangle(cornerRadius: layout.iconSize / 4)
            .fill(Color.white.opacity(0.1))
            .overlay(
               RoundedRectangle(cornerRadius: layout.iconSize / 4)
                  .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
         
         widgetContent
      }
      .frame(width: widgetWidth, height: widgetHeight)
      .scaleEffect(isDragged ? LaunchPadConstants.draggedItemScale : 1)
      .opacity(isDragged ? LaunchPadConstants.draggedItemOpacity : 1)
   }
   
   @ViewBuilder
   private var widgetContent: some View {
      switch widget.type {
      case .clock:
         ClockWidgetView(widget: widget, layout: layout)
      case .calendar:
         CalendarWidgetView(widget: widget, layout: layout)
      case .weather:
         WeatherWidgetView(widget: widget, layout: layout)
      case .battery:
         BatteryWidgetView(widget: widget, layout: layout)
      case .stocks:
         StocksWidgetView(widget: widget, layout: layout)
      case .notes:
         Text("📝")
            .font(.system(size: layout.iconSize * 0.6))
      }
   }
   
   private var widgetWidth: CGFloat {
      let cellWidth = layout.cellWidth
      let spacing = layout.hSpacing
      let span = CGFloat(widget.size.gridSpan)
      return cellWidth * span + spacing * (span - 1)
   }
   
   private var widgetHeight: CGFloat {
      let cellHeight = layout.cellWidth  // Using cellWidth to keep cells square
      let spacing = layout.hSpacing
      let span = CGFloat(widget.size.gridSpan)
      return cellHeight * span + spacing * (span - 1)
   }
}
