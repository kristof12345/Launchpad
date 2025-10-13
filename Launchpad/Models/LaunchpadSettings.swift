import Foundation

struct LaunchpadSettings: Codable, Equatable {
   var columns: Int
   var rows: Int
   var iconSize: Double
   var dropDelay: Double
   var folderColumns: Int
   var folderRows: Int
   var scrollDebounceInterval: TimeInterval
   var scrollActivationThreshold: Double
   var showDock: Bool
   var showMenuBar: Bool
   var transparency: Double
   var startAtLogin: Bool
   var productKey: String
   
   static let defaultColumns = 7
   static let defaultRows = 5
   static let defaultIconSize: Double = 100.0
   static let defaultDropDelay: Double = 0.5
   static let defaultFolderColumns = 5
   static let defaultFolderRows = 3
   static let defaultScrollDebounceInterval: TimeInterval = 0.8
   static let defaultScrollActivationThreshold: CGFloat = 80
   static let defaultShowDock = true
   static let defaultShowMenuBar = false
   static let defaultTransparency: Double = 1.0
   static let defaultStartAtLogin = false
   static let defaultProductKey = ""
   
   init(
      columns: Int = defaultColumns,
      rows: Int = defaultRows,
      iconSize: Double = defaultIconSize,
      dropDelay: Double = defaultDropDelay,
      folderColumns: Int = defaultFolderColumns,
      folderRows: Int = defaultFolderRows,
      scrollDebounceInterval: TimeInterval = defaultScrollDebounceInterval,
      scrollActivationThreshold: CGFloat = defaultScrollActivationThreshold,
      showDock: Bool = defaultShowDock,
      showMenuBar: Bool = defaultShowMenuBar,
      transparency: Double = defaultTransparency,
      startAtLogin: Bool = defaultStartAtLogin,
      productKey: String = defaultProductKey
   ) {
      self.columns = max(4, min(12, columns))
      self.rows = max(3, min(10, rows))
      self.iconSize = max(20, min(200, iconSize))
      self.dropDelay = max(0.0, min(3.0, dropDelay))
      self.folderColumns = max(3, min(10, folderColumns))
      self.folderRows = max(3, min(8, folderRows))
      self.scrollDebounceInterval = scrollDebounceInterval
      self.scrollActivationThreshold = scrollActivationThreshold
      self.showDock = showDock
      self.showMenuBar = showMenuBar
      self.transparency = max(0.0, min(2.0, transparency))
      self.startAtLogin = startAtLogin
      self.productKey = productKey
   }
   
   var appsPerPage: Int {
      return columns * rows
   }
   
   var isActivated: Bool {
      return productKey == LaunchPadConstants.productKey
   }
}
