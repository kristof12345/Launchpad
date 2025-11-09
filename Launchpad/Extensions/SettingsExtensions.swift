import Foundation

extension LaunchpadSettings {
   var appsPerPage: Int {
      return columns * rows
   }

   var isActivated: Bool {
      return true
   }

   var isPro: Bool {
      return true
   }

   var isPremium: Bool {
      return true
   }
}
