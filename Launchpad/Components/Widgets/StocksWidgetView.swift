import SwiftUI

struct StocksWidgetView: View {
   let widget: Widget
   let layout: LayoutMetrics
   
   // Mock stock data - in a real implementation, this would fetch from a stocks API
   @State private var stockSymbol: String = "AAPL"
   @State private var stockPrice: Double = 173.50
   @State private var priceChange: Double = 2.34
   @State private var percentChange: Double = 1.37
   
   var body: some View {
      VStack(spacing: widget.size == .small ? 2 : 6) {
         // Stock symbol
         Text(stockSymbol)
            .font(.system(size: layout.iconSize * (widget.size == .small ? 0.25 : 0.28), weight: .bold, design: .rounded))
            .foregroundColor(.white)
         
         // Stock price
         Text("$\(stockPrice, specifier: "%.2f")")
            .font(.system(size: layout.iconSize * (widget.size == .small ? 0.2 : 0.25), weight: .semibold, design: .rounded))
            .foregroundColor(.white)
         
         if widget.size != .small {
            // Price change
            HStack(spacing: 4) {
               Image(systemName: priceChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                  .font(.system(size: layout.iconSize * 0.12))
               
               Text("\(abs(priceChange), specifier: "%.2f") (\(abs(percentChange), specifier: "%.2f")%)")
                  .font(.system(size: layout.iconSize * 0.12, weight: .regular))
            }
            .foregroundColor(priceChange >= 0 ? .green : .red)
         } else {
            // Compact change indicator
            HStack(spacing: 2) {
               Image(systemName: priceChange >= 0 ? "arrow.up" : "arrow.down")
                  .font(.system(size: layout.iconSize * 0.15))
               Text("\(abs(percentChange), specifier: "%.1f")%")
                  .font(.system(size: layout.iconSize * 0.15, weight: .medium))
            }
            .foregroundColor(priceChange >= 0 ? .green : .red)
         }
      }
   }
}
