import CoreGraphics
import Foundation

extension Math {
  final class DisplayFraction: DisplayNode {
    var numerator: DisplayList?
    var denominator: DisplayList?

    var numeratorUp: CGFloat = 0 { didSet { updateNumeratorPosition() } }
    var denominatorDown: CGFloat = 0 { didSet { updateDenominatorPosition() } }
    var linePosition: CGFloat = 0
    var lineThickness: CGFloat = 0

    init(numerator: DisplayList?, denominator: DisplayList?, position: CGPoint, range: NSRange) {
      self.numerator = numerator
      self.denominator = denominator
      super.init()
      self.position = position
      self.range = range
    }

    override var ascent: CGFloat {
      get { (numerator?.ascent ?? 0) + numeratorUp }
      set { super.ascent = newValue }
    }

    override var descent: CGFloat {
      get { (denominator?.descent ?? 0) + denominatorDown }
      set { super.descent = newValue }
    }

    override var width: CGFloat {
      get { max(numerator?.width ?? 0, denominator?.width ?? 0) }
      set { super.width = newValue }
    }

    override var position: CGPoint {
      didSet {
        updateDenominatorPosition()
        updateNumeratorPosition()
      }
    }

    private func updateDenominatorPosition() {
      guard let denominator else { return }
      denominator.position = CGPoint(
        x: position.x + (width - denominator.width) / 2,
        y: position.y - denominatorDown
      )
    }

    private func updateNumeratorPosition() {
      guard let numerator else { return }
      numerator.position = CGPoint(
        x: position.x + (width - numerator.width) / 2,
        y: position.y + numeratorUp
      )
    }
  }
}
