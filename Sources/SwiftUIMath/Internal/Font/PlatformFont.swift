@preconcurrency import CoreGraphics
@preconcurrency import CoreText
import Foundation

extension Math {
  final class PlatformFont: Sendable {
    let font: Font
    let cgFont: CGFont
    let ctFont: CTFont
    let metrics: FontMetrics

    init?(font: Font) {
      guard
        let cgFont = FontRegistry.shared.graphicsFont(named: font.name),
        let ctFont = FontRegistry.shared.font(named: font.name, size: font.size),
        let table = FontRegistry.shared.table(named: font.name)
      else {
        return nil
      }

      self.font = font
      self.cgFont = cgFont
      self.ctFont = ctFont
      self.metrics = FontMetrics(
        font: font,
        unitsPerEm: UInt(CTFontGetUnitsPerEm(ctFont)),
        table: table
      )
    }

    func withSize(_ size: CGFloat) -> PlatformFont {
      PlatformFont(font: .init(name: font.name, size: size))!
    }
  }
}
