import CoreGraphics
import Foundation

extension Math {
  final class DisplayTextRun: DisplayNode {
    var attributedString: NSAttributedString
    var font: Math.Font
    var atoms: [Math.Atom]
    var text: String { attributedString.string }

    init(
      attributedString: NSAttributedString,
      font: Math.Font,
      position: CGPoint = .zero,
      range: NSRange,
      atoms: [Math.Atom]
    ) {
      self.attributedString = attributedString
      self.font = font
      self.atoms = atoms
      super.init()
      self.position = position
      self.range = range
    }
  }
}
