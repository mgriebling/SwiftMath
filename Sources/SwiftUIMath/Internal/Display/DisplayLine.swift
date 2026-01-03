import CoreGraphics
import Foundation

extension Math {
  final class DisplayLine: DisplayNode {
    var inner: DisplayList?
    var lineShiftUp: CGFloat = 0
    var lineThickness: CGFloat = 0

    init(inner: DisplayList?, position: CGPoint, range: NSRange) {
      self.inner = inner
      super.init()
      self.position = position
      self.range = range
    }

    override var position: CGPoint {
      didSet { updateInnerPosition() }
    }

    private func updateInnerPosition() {
      inner?.position = CGPoint(x: position.x, y: position.y)
    }
  }
}
