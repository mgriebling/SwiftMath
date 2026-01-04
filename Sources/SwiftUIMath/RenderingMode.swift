import SwiftUI

extension Math {
  public enum RenderingMode: Sendable {
    case monochrome
    case multicolor(base: SwiftUI.Color)

    static var multicolor: Self {
      .multicolor(base: .primary)
    }
  }
}

extension View {
  public func mathRenderingMode(_ mathRenderingMode: Math.RenderingMode) -> some View {
    environment(\.mathRenderingMode, mathRenderingMode)
  }
}

extension EnvironmentValues {
  @Entry var mathRenderingMode: Math.RenderingMode = .monochrome
}
