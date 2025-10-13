import Foundation

extension String {
    /// Returns the localized version of the string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Returns the localized version of the string with arguments
    func localized(_ arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

/// Localization helper for common strings
struct L10n {
    // MARK: - General
    static let appName = "app_name".localized
    static let settings = "settings".localized
    static let cancel = "cancel".localized
    static let apply = "apply".localized
    static let ok = "ok".localized
    static let close = "close".localized
    
    // MARK: - Settings View
    static let launchpadSettings = "launchpad_settings".localized
    static let resetToDefaults = "reset_to_defaults".localized
    static let features = "features".localized
    
    // MARK: - Layout Settings
    static let layout = "layout".localized
    static let columns = "columns".localized
    static let rows = "rows".localized
    static let folderColumns = "folder_columns".localized
    static let folderRows = "folder_rows".localized
    static let iconSize = "icon_size".localized
    static let dropAnimationDelay = "drop_animation_delay".localized
    static let pageScrollDebounce = "page_scroll_debounce".localized
    static let pageScrollThreshold = "page_scroll_threshold".localized
    static let showDock = "show_dock".localized
    static let showMenuBar = "show_menu_bar".localized
    static let startAtLogin = "start_at_login".localized
    static let transparency = "transparency".localized
    
    // MARK: - Actions Settings
    static let actions = "actions".localized
    static let layoutManagement = "layout_management".localized
    static let exportLayout = "export_layout".localized
    static let importLayout = "import_layout".localized
    static let importFromOldLaunchpad = "import_from_old_launchpad".localized
    static let resetOptions = "reset_options".localized
    static let clearAllApps = "clear_all_apps".localized
    static let applicationControl = "application_control".localized
    static let forceQuit = "force_quit".localized
    
    // MARK: - Alerts and Confirmations
    static let clearAllAppsTitle = "clear_all_apps_title".localized
    static let clearAllAppsMessage = "clear_all_apps_message".localized
    static let clear = "clear".localized
    static let importSuccess = "import_success".localized
    static let importSuccessMessage = "import_success_message".localized
    static let importFailed = "import_failed".localized
    static let importFailedMessage = "import_failed_message".localized
    
    // MARK: - Search
    static let searchPlaceholder = "search_placeholder".localized
    static let searchAppsPlaceholder = "search_apps_placeholder".localized
    static let noResultsTitle = "no_results_title".localized
    static let noResultsMessage = "no_results_message".localized
    static let noAppsFound = "no_apps_found".localized
    
    // MARK: - Folder Management
    static let folderNamePlaceholder = "folder_name_placeholder".localized
    static let untitledFolder = "untitled_folder".localized
    static let newFolder = "new_folder".localized
    
    // MARK: - Actions Placeholder
    static let actionsPlaceholder = "actions_placeholder".localized
    
    // MARK: - Time Units
    static let secondsShort = "seconds_short".localized
    static let millisecondsShort = "milliseconds_short".localized
    
    // MARK: - Numbers
    static let number10 = "number_10".localized
    static let number200 = "number_200".localized
    static let time00s = "time_0_0s".localized
    static let time30s = "time_3_0s".localized
    
    // MARK: - Restart Warning
    static let restartRequired = "restart_required".localized
    static let restartWarningMessage = "restart_warning_message".localized
    
    // MARK: - Activation Settings
    static let activation = "activation".localized
    static let productKey = "product_key".localized
    static let enterProductKey = "enter_product_key".localized
    static let activate = "activate".localized
    static let activationStatus = "activation_status".localized
    static let activated = "activated".localized
    static let notActivated = "not_activated".localized
    static let invalidProductKey = "invalid_product_key".localized
    static let activationSuccessful = "activation_successful".localized
    static let purchasePrompt = "purchase_prompt".localized
    static let purchaseLicense = "purchase_license".localized
}
