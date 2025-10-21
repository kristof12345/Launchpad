import Foundation

enum WidgetType: String, Codable {
   case clock
   case calendar
   case weather
   case notes
   
   var defaultSize: WidgetSize {
      switch self {
      case .clock:
         return .medium
      case .calendar:
         return .medium
      case .weather:
         return .small
      case .notes:
         return .large
      }
   }
}

enum WidgetSize: String, Codable {
   case small   // 1x1
   case medium  // 2x2
   case large   // 3x3
   
   var gridSpan: Int {
      switch self {
      case .small:
         return 1
      case .medium:
         return 2
      case .large:
         return 3
      }
   }
}

struct Widget: Identifiable, Equatable, Codable {
   let id: UUID
   var name: String
   var type: WidgetType
   var size: WidgetSize
   var page: Int
   var configuration: [String: String]
   
   init(id: UUID = UUID(), name: String, type: WidgetType, size: WidgetSize, page: Int = 0, configuration: [String: String] = [:]) {
      self.id = id
      self.name = name
      self.type = type
      self.size = size
      self.page = page
      self.configuration = configuration
   }
}
