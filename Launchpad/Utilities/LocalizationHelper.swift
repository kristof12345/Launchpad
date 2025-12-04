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
   static let cancel = "cancel".localized
   static let apply = "apply".localized
   static let ok = "ok".localized

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
   static let categoryColumns = "category_columns".localized
   static let categoryRows = "category_rows".localized
   static let iconSize = "icon_size".localized
   static let margin = "margin".localized
   static let dropAnimationDelay = "drop_animation_delay".localized
   static let pageScrollDebounce = "page_scroll_debounce".localized
   static let pageScrollThreshold = "page_scroll_threshold".localized
   static let showDock = "show_dock".localized
   static let startAtLogin = "start_at_login".localized
   static let resetOnRelaunch = "reset_on_relaunch".localized
   static let showIconsInSearch = "show_icons_in_search".localized
   static let enableIconAnimation = "enable_icon_animation".localized
   static let enableFadeAnimation = "enable_fade_animation".localized
   static let transparency = "transparency".localized
   static let labelFontColor = "label_font_color".localized
   
   // MARK: - Actions Settings
   static let actions = "actions".localized
   static let layoutManagement = "layout_management".localized
   static let exportLayout = "export_layout".localized
   static let importLayout = "import_layout".localized
   static let importFromOldLaunchpad = "import_from_old_launchpad".localized
   static let clearAllApps = "clear_all_apps".localized
   static let refreshApps = "refresh_apps".localized
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
   static let exportSuccess = "export_success".localized
   static let exportFailed = "export_failed".localized
   
   // MARK: - Search
   static let searchPlaceholder = "search_placeholder".localized
   static let noAppsFound = "no_apps_found".localized
   static let sortBy = "sort_by".localized
   static let sortByDefault = "sort_by_default".localized
   static let sortByName = "sort_by_name".localized
   static let sortByType = "sort_by_type".localized
   static let sortByLastOpened = "sort_by_last_opened".localized
   static let sortByInstallDate = "sort_by_install_date".localized
   static let sortByMostOpened = "sort_by_most_opened".localized
   
   // MARK: - Folder Management
   static let untitledFolder = "untitled_folder".localized
   static let newFolder = "new_folder".localized
   
   // MARK: - Category Management
   static let categories = "categories".localized
   static let untitledCategory = "untitled_category".localized
   static let manageCategories = "manage_categories".localized
   static let deleteCategory = "delete_category".localized
   static let deleteCategoryTitle = "delete_category_title".localized
   static let deleteCategoryMessage = "delete_category_message".localized
   static let openAllApps = "open_all_apps".localized
   static let noCategories = "no_categories".localized
   static let noCategoriesTitle = "no_categories_title".localized
   static let noCategoriesSubtitle = "no_categories_subtitle".localized
   static let categoriesDescription = "categories_description".localized
   static let createCategory = "create_category".localized
   static let categoryName = "category_name".localized
   static let allApps = "all_apps".localized
   
   // MARK: - Numbers
   static let number10 = "number_10".localized
   static let number200 = "number_200".localized
   static let time00s = "time_0_0s".localized
   static let time30s = "time_3_0s".localized
   
   // MARK: - Activation Settings
   static let activation = "activation".localized
   static let productKey = "product_key".localized
   static let enterProductKey = "enter_product_key".localized
   static let activate = "activate".localized
   static let activated = "activated".localized
   static let notActivated = "not_activated".localized
   static let invalidProductKey = "invalid_product_key".localized
   static let activationSuccessful = "activation_successful".localized
   static let purchasePrompt = "purchase_prompt".localized
   static let purchaseLicense = "purchase_license".localized
   
   // MARK: - Locations Settings
   static let locations = "locations".localized
   static let locationsDescription = "locations_description".localized
   static let customLocations = "custom_locations".localized
   static let customAppLocations = "custom_app_locations".localized
   static let noCustomLocations = "no_custom_locations".localized
   static let addLocation = "add_location".localized
   static let locationPlaceholder = "location_placeholder".localized
   static let browseFolder = "browse_folder".localized
   static let invalidLocation = "invalid_location".localized
   static let locationDoesNotExist = "location_does_not_exist".localized
   static let locationNotDirectory = "location_not_directory".localized
   static let locationAlreadyAdded = "location_already_added".localized
   static let selectFolderMessage = "select_folder_message".localized
   
   // MARK: - Hidden Apps
   static let hiddenApps = "hidden_apps".localized
   static let hideApp = "hide_app".localized
   static let unhideApp = "unhide_app".localized
   static let noHiddenApps = "no_hidden_apps".localized
   static let hiddenAppsDescription = "hidden_apps_description".localized
   static let unhideAllApps = "unhide_all_apps".localized
   
   // MARK: - Background Settings
   static let background = "background".localized
   static let backgroundType = "background_type".localized
   static let backgroundDefault = "background_default".localized
   static let backgroundWallpaper = "background_wallpaper".localized
   static let backgroundCustom = "background_custom".localized
   static let backgroundBlur = "background_blur".localized
   static let customImagePath = "custom_image_path".localized
   static let browseImage = "browse_image".localized
   static let selectImageMessage = "select_image_message".localized
   static let imageNotFound = "image_not_found".localized
}
