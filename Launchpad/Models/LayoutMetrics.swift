import AppKit
import SwiftUI

struct LayoutMetrics {
    let size: CGSize
    let hPadding: CGFloat
    let vPadding: CGFloat
    let hSpacing: CGFloat
    let vSpacing: CGFloat
    let cellWidth: CGFloat
    let iconSize: CGFloat
    let fontSize: CGFloat
    
    init(size: CGSize, columns: Int, rows: Int, iconSize: Double) {
        self.size = size
        self.iconSize = iconSize

        hPadding = size.width * 0.06
        vPadding = size.height * 0.08
        hSpacing = size.height < 800 ? size.height * 0.04 : size.height * 0.03

        // Calculate vSpacing so all rows and icons fill the available height
        let availableHeight = size.height - (vPadding * 2)
        let totalIconHeight = CGFloat(rows) * CGFloat(iconSize)
        let totalSpacing = max(CGFloat(rows - 1), 1)
        vSpacing = totalSpacing > 0 ? max((availableHeight - totalIconHeight) / totalSpacing, 0) : 0

        let totalHSpacing = CGFloat(columns - 1) * hSpacing
        cellWidth = (size.width - (hPadding * 2) - totalHSpacing) / CGFloat(columns)
        fontSize = max(10, cellWidth * 0.04)
    }
}
