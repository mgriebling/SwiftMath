import CoreGraphics
import Foundation

extension Math {
  final class DisplayRadical: DisplayNode {
    var radicand: DisplayList?
    var degree: DisplayList?
    var radicalGlyph: DisplayNode?

    var radicalShift: CGFloat = 0
    var topKern: CGFloat = 0
    var lineThickness: CGFloat = 0

    init(radicand: DisplayList?, glyph: DisplayNode, position: CGPoint, range: NSRange) {
      self.radicand = radicand
      self.radicalGlyph = glyph
      super.init()
      self.position = position
      self.range = range
    }

    override var position: CGPoint {
      didSet { updateRadicandPosition() }
    }

    func updateRadicandPosition() {
      guard let radicand, let radicalGlyph else { return }
      radicand.position = CGPoint(
        x: position.x + radicalShift + radicalGlyph.width,
        y: position.y
      )
    }
  }
}
