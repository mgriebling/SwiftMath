import SwiftUI

public struct Math: View {
  @Environment(\.mathFont) private var font
  @Environment(\.mathTypesettingStyle) private var typesettingStyle
  @Environment(\.mathRenderingMode) private var renderingMode

  private let latex: String

  public init(_ latex: String) {
    self.latex = latex
  }

  public var body: some View {
    Layout(latex: latex, font: font, style: typesettingStyle) {
      Canvas { context, size in
        guard
          let displayNode = DisplayProvider.shared.display(
            for: latex,
            font: font,
            style: typesettingStyle,
            proposedWidth: size.width
          )
        else {
          return
        }

        switch renderingMode {
        case .monochrome:
          // Monochrome rendering with foreground style
          context.draw(displayNode, size: size, with: .foreground)
        case .multicolor(let base):
          // Multicolor rendering with base color for uncolored elements
          context.draw(displayNode, size: size, foregroundColor: base)
        }
      }
    }
  }
}

extension Math {
  @_spi(Textual)
  public struct TypographicBounds: Sendable {
    @_spi(Textual)
    public var origin: CGPoint

    @_spi(Textual)
    public var width: CGFloat

    @_spi(Textual)
    public var ascent: CGFloat

    @_spi(Textual)
    public var descent: CGFloat

    @_spi(Textual)
    public var size: CGSize {
      .init(width: self.width, height: self.ascent + self.descent)
    }

    static let zero = TypographicBounds(origin: .zero, width: 0, ascent: 0, descent: 0)
  }

  @_spi(Textual)
  public func typographicBounds(
    fitting proposal: ProposedViewSize,
    font: Font,
    style: TypesettingStyle
  ) -> TypographicBounds {
    if let width = proposal.width, width <= 0 {
      return .zero
    }

    return DisplayProvider.shared
      .display(
        for: self.latex,
        font: font,
        style: style,
        proposedWidth: proposal.width ?? 0
      )
      .map {
        TypographicBounds(
          origin: $0.position,
          width: $0.width,
          ascent: $0.ascent,
          descent: $0.descent
        )
      } ?? .zero
  }
}

extension Math {
  private struct Layout: SwiftUI.Layout {
    let latex: String
    let font: Font
    let style: TypesettingStyle

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
      if let width = proposal.width, width <= 0 {
        return .zero
      }

      return DisplayProvider.shared.sizeThatFits(
        proposedWidth: proposal.width ?? 0,
        latex: latex,
        font: font,
        style: style
      )
    }

    func placeSubviews(
      in bounds: CGRect,
      proposal: ProposedViewSize,
      subviews: Subviews,
      cache: inout ()
    ) {
      if let view = subviews.first {
        view.place(at: bounds.origin, proposal: .init(bounds.size))
      }
    }
  }
}

#Preview("Display Style") {
  Math("\\frac{1}{2}+\\sqrt{2}+\\sum_{i=1}^{n}x_i")
    .mathFont(Math.Font(name: .latinModern, size: 24))
    .foregroundStyle(
      .linearGradient(
        colors: [.red, .blue],
        startPoint: .top,
        endPoint: .bottom
      )
    )
    .padding()
}

#Preview("Text Style") {
  Math("\\int_0^1 x^2\\,dx = \\frac{1}{3}")
    .mathTypesettingStyle(.text)
    .mathFont(Math.Font(name: .libertinus, size: 20))
    .padding()
}

#Preview("Large Operators") {
  Math("\\lim_{n\\to\\infty}\\sum_{k=1}^{n}\\frac{1}{k^2}=\\frac{\\pi^2}{6}")
    .mathTypesettingStyle(.display)
    .mathFont(Math.Font(name: .xits, size: 22))
    .padding()
}

#Preview("Matrix") {
  Math("A=\\begin{pmatrix}1&2\\\\3&4\\end{pmatrix}")
    .mathTypesettingStyle(.display)
    .mathFont(Math.Font(name: .asana, size: 22))
    .padding()
}

#Preview("Cases") {
  Math("\\begin{cases} x + y = 5 \\\\ 2x - y = 1 \\end{cases}")
    .mathTypesettingStyle(.display)
    .mathFont(Math.Font(name: .termes, size: 22))
    .padding()
}

#Preview("Accents And Scripts") {
  Math("\\hat{x}+\\bar{y}+\\vec{z}+a_{i}^{2}")
    .mathTypesettingStyle(.text)
    .mathFont(Math.Font(name: .euler, size: 22))
    .padding()
}

#Preview("Multicolor") {
  Math("\\color{#cc0000}{a}+\\color{#00aa00}{b}+\\color{#0000cc}{c}")
    .mathTypesettingStyle(.text)
    .mathRenderingMode(.multicolor)
    .mathFont(Math.Font(name: .latinModern, size: 22))
    .padding()
}

#Preview("Multicolor 2") {
  Math("\\textcolor{#ff8800}{\\int_0^1 x^2\\,dx}=\\textcolor{#0088ff}{\\frac{1}{3}}")
    .mathRenderingMode(.multicolor)
    .mathFont(Math.Font(name: .libertinus, size: 20))
    .padding()
}
