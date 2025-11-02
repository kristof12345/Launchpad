import Foundation

/// Centralized constants for keyboard key codes used in event handling
enum KeyCodeConstants {
   /// Escape key - used to close modals or exit the application
   static let escape: UInt16 = 53
   
   /// Left arrow key - used for navigation
   static let leftArrow: UInt16 = 123
   
   /// Right arrow key - used for navigation
   static let rightArrow: UInt16 = 124
   
   /// Down arrow key - used for navigation
   static let downArrow: UInt16 = 125
   
   /// Up arrow key - used for navigation
   static let upArrow: UInt16 = 126
   
   /// Enter/Return key - used to confirm actions
   static let enter: UInt16 = 36
   
   /// Comma key - used with CMD for settings (CMD+,)
   static let comma: UInt16 = 43
}
