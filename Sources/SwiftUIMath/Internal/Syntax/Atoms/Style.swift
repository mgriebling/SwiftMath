import Foundation

extension Math {
  final class Style: Atom {
    enum Level: Int {
      case display
      case text
      case script
      case scriptOfScript

      var isScript: Bool {
        switch self {
        case .script, .scriptOfScript:
          return true
        default:
          return false
        }
      }

      var isNotScript: Bool {
        !isScript
      }

      func next() -> Level {
        Level(rawValue: rawValue + 1) ?? .display
      }
    }

    var level: Level

    init(_ style: Style) {
      self.level = style.level
      super.init(style)
    }

    init(level: Level = .display) {
      self.level = level
      super.init(type: .style)
    }
  }
}
