import CoreGraphics
import Foundation

extension Math {
  final class DisplayAccent: DisplayNode {
    var accentee: DisplayList?
    var accent: DisplayGlyph?

    init(accent: DisplayGlyph?, accentee: DisplayList?, range: NSRange) {
      self.accent = accent
      self.accentee = accentee
      super.init()
      self.range = range
    }

    override var position: CGPoint {
      didSet { updateAccenteePosition() }
    }

    private func updateAccenteePosition() {
      accentee?.position = CGPoint(x: position.x, y: position.y)
    }
  }
}
