import CoreGraphics
import Foundation

extension Math {
  final class DisplayList: DisplayNode {
    enum LinePosition: Int {
      case regular
      case `subscript`
      case superscript
    }

    var linePosition: LinePosition = .regular
    var children: [DisplayNode] = []
    var index: Int = NSNotFound

    init(children: [DisplayNode], range: NSRange) {
      super.init()
      self.children = children
      self.position = .zero
      self.index = NSNotFound
      self.range = range
      recomputeDimensions()
    }

    func recomputeDimensions() {
      var maxAscent: CGFloat = 0
      var maxDescent: CGFloat = 0
      var maxWidth: CGFloat = 0
      for node in children {
        let ascent = max(0, node.position.y + node.ascent)
        maxAscent = max(maxAscent, ascent)

        let descent = max(0, 0 - (node.position.y - node.descent))
        maxDescent = max(maxDescent, descent)

        let width = node.width + node.position.x
        maxWidth = max(maxWidth, width)
      }
      self.ascent = maxAscent
      self.descent = maxDescent
      self.width = maxWidth
    }
  }
}
