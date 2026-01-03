import CoreGraphics
import Foundation

extension Math {
  class DisplayNode {
    var ascent: CGFloat = 0
    var descent: CGFloat = 0
    var width: CGFloat = 0
    var position: CGPoint = .zero
    var range: NSRange = NSRange(location: 0, length: 0)
    var hasScript: Bool = false

    func bounds() -> CGRect {
      CGRect(x: position.x, y: position.y - descent, width: width, height: ascent + descent)
    }
  }
}
