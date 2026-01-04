import SwiftUI

extension Math {
  public enum TypesettingStyle: Sendable {
    case display
    case text
  }
}

extension View {
  public func mathTypesettingStyle(_ typesettingStyle: Math.TypesettingStyle) -> some View {
    environment(\.mathTypesettingStyle, typesettingStyle)
  }
}

extension EnvironmentValues {
  @Entry var mathTypesettingStyle: Math.TypesettingStyle = .display
}
