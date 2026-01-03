import CoreGraphics
import Foundation

extension Math {
  final class DisplayTextRun: DisplayNode {
    var text: String
    var font: Math.Font
    var atoms: [Math.Atom]

    init(
      text: String, font: Math.Font, position: CGPoint = .zero, range: NSRange, atoms: [Math.Atom]
    ) {
      self.text = text
      self.font = font
      self.atoms = atoms
      super.init()
      self.position = position
      self.range = range
    }
  }
}
