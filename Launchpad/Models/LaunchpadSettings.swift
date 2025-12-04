import Foundation

struct LaunchpadSettings: Codable, Equatable {
   // MARK: - Grid Layout
   var columns: Int
   var rows: Int
   var iconSize: Double
   var margin: Double
   var folderColumns: Int
   var folderRows: Int
   var categoryColumns: Int
   var categoryRows: Int

   // MARK: - Interaction & Animation
   var dropDelay: Double
   var scrollDebounceInterval: TimeInterval
   var scrollActivationThreshold: Double
   var enableIconAnimation: Bool
   var enableFadeAnimation: Bool

   // MARK: - Display & Appearance
   var showDock: Bool
   var transparency: Double
   var showIconsInSearch: Bool
   var backgroundType: BackgroundType
   var customBackgroundPath: String
   var backgroundBlur: Double
   var labelFontColor: String?

   // MARK: - Behavior
   var startAtLogin: Bool
   var resetOnRelaunch: Bool

   // MARK: - Advanced
   var productKey: String
   var customAppLocations: [String]

   // MARK: - Defaults
   static let defaultColumns = 7
   static let defaultRows = 5
   static let defaultIconSize: Double = 100.0
   static let defaultMargin: Double = 20.0
   static let defaultFolderColumns = 5
   static let defaultFolderRows = 3
   static let defaultCategoryColumns = 3
   static let defaultCategoryRows = 2
   static let defaultDropDelay: Double = 0.5
   static let defaultScrollDebounceInterval: TimeInterval = 0.8
   static let defaultScrollActivationThreshold: Double = 80.0
   static let defaultTransparency: Double = 1.0
   static let defaultEnableIconAnimation = true
   static let defaultEnableFadeAnimation = true
   static let defaultStartAtLogin = false
   static let defaultResetOnRelaunch = true
   static let defaultShowDock = true
   static let defaultShowIconsInSearch = true
   static let defaultBackgroundType: BackgroundType = .default
   static let defaultBackgroundBlur: Double = 10.0



   // MARK: - Initializer
   init(
      columns: Int = defaultColumns,
      rows: Int = defaultRows,
      iconSize: Double = defaultIconSize,
      margin: Double = defaultMargin,
      folderColumns: Int = defaultFolderColumns,
      folderRows: Int = defaultFolderRows,
      categoryColumns: Int = defaultCategoryColumns,
      categoryRows: Int = defaultCategoryRows,
      dropDelay: Double = defaultDropDelay,
      scrollDebounceInterval: TimeInterval = defaultScrollDebounceInterval,
      scrollActivationThreshold: Double = defaultScrollActivationThreshold,
      enableIconAnimation: Bool = defaultEnableIconAnimation,
      enableFadeAnimation: Bool = defaultEnableFadeAnimation,
      showDock: Bool = defaultShowDock,
      transparency: Double = defaultTransparency,
      showIconsInSearch: Bool = defaultShowIconsInSearch,
      backgroundType: BackgroundType = defaultBackgroundType,
      customBackgroundPath: String = "",
      backgroundBlur: Double = defaultBackgroundBlur,
      labelFontColor: String? = nil,
      startAtLogin: Bool = defaultStartAtLogin,
      resetOnRelaunch: Bool = defaultResetOnRelaunch,
      productKey: String = "",
      customAppLocations: [String] = []
   ) {
      // Layout
      self.columns = max(4, min(12, columns))
      self.rows = max(3, min(10, rows))
      self.iconSize = max(20, min(200, iconSize))
      self.margin = max(0, min(300, margin))
      self.folderColumns = max(3, min(10, folderColumns))
      self.folderRows = max(3, min(8, folderRows))
      self.categoryColumns = max(2, min(4, categoryColumns))
      self.categoryRows = max(2, min(4, categoryRows))

      // Interaction
      self.dropDelay = max(0.0, min(3.0, dropDelay))
      self.scrollDebounceInterval = scrollDebounceInterval
      self.scrollActivationThreshold = scrollActivationThreshold
      self.enableIconAnimation = enableIconAnimation
      self.enableFadeAnimation = enableFadeAnimation

      // Appearance
      self.transparency = max(0.0, min(2.0, transparency))
      self.backgroundType = backgroundType
      self.customBackgroundPath = customBackgroundPath
      self.backgroundBlur = max(0.0, min(30.0, backgroundBlur))
      self.labelFontColor = labelFontColor

      // Behavior
      self.showDock = showDock
      self.showIconsInSearch = showIconsInSearch
      self.startAtLogin = startAtLogin
      self.resetOnRelaunch = resetOnRelaunch

      // Advanced
      self.productKey = productKey
      self.customAppLocations = customAppLocations
   }
}
