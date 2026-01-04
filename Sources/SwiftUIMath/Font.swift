import SwiftUI

extension Math {
  public struct Font: Hashable, Sendable {
    public struct Name: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
      public let rawValue: String

      public init(rawValue: String) {
        self.rawValue = rawValue
      }

      public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
      }
    }

    public let name: Name
    public let size: CGFloat
  }
}

extension Math.Font.Name {
  public static let latinModern: Self = "latinmodern-math"
  public static let kpMathLight: Self = "KpMath-Light"
  public static let kpMathSans: Self = "KpMath-Sans"
  public static let xits: Self = "xits-math"
  public static let termes: Self = "texgyretermes-math"
  public static let asana: Self = "Asana-Math"
  public static let euler: Self = "Euler-Math"
  public static let fira: Self = "FiraMath-Regular"
  public static let notoSans: Self = "NotoSansMath-Regular"
  public static let libertinus: Self = "LibertinusMath-Regular"
  public static let garamond: Self = "Garamond-Math"
  public static let leteSans: Self = "LeteSansMath"
}

extension View {
  public func mathFont(_ font: Math.Font) -> some View {
    environment(\.mathFont, font)
  }
}

extension EnvironmentValues {
  @Entry var mathFont = Math.Font(name: .latinModern, size: 20)
}
