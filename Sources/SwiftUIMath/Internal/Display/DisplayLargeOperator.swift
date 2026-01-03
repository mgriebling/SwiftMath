import CoreGraphics
import Foundation

extension Math {
  final class DisplayLargeOperator: DisplayNode {
    var upperLimit: DisplayList?
    var lowerLimit: DisplayList?
    var nucleus: DisplayNode?

    var limitShift: CGFloat = 0
    var upperLimitGap: CGFloat = 0 { didSet { updateUpperLimitPosition() } }
    var lowerLimitGap: CGFloat = 0 { didSet { updateLowerLimitPosition() } }
    var extraPadding: CGFloat = 0

    init(
      nucleus: DisplayNode?, upperLimit: DisplayList?, lowerLimit: DisplayList?,
      limitShift: CGFloat, extraPadding: CGFloat
    ) {
      self.upperLimit = upperLimit
      self.lowerLimit = lowerLimit
      self.nucleus = nucleus
      self.limitShift = limitShift
      self.extraPadding = extraPadding
      super.init()

      var maxWidth = max(nucleus?.width ?? 0, upperLimit?.width ?? 0)
      maxWidth = max(maxWidth, lowerLimit?.width ?? 0)
      width = maxWidth
    }

    override var ascent: CGFloat {
      get {
        guard let nucleus else { return 0 }
        if let upperLimit {
          return nucleus.ascent + extraPadding + upperLimit.ascent + upperLimitGap
            + upperLimit.descent
        }
        return nucleus.ascent
      }
      set { super.ascent = newValue }
    }

    override var descent: CGFloat {
      get {
        guard let nucleus else { return 0 }
        if let lowerLimit {
          return nucleus.descent + extraPadding + lowerLimitGap + lowerLimit.descent
            + lowerLimit.ascent
        }
        return nucleus.descent
      }
      set { super.descent = newValue }
    }

    override var position: CGPoint {
      didSet {
        updateLowerLimitPosition()
        updateUpperLimitPosition()
        updateNucleusPosition()
      }
    }

    private func updateLowerLimitPosition() {
      guard let lowerLimit, let nucleus else { return }
      lowerLimit.position = CGPoint(
        x: position.x - limitShift + (width - lowerLimit.width) / 2,
        y: position.y - nucleus.descent - lowerLimitGap - lowerLimit.ascent
      )
    }

    private func updateUpperLimitPosition() {
      guard let upperLimit, let nucleus else { return }
      upperLimit.position = CGPoint(
        x: position.x + limitShift + (width - upperLimit.width) / 2,
        y: position.y + nucleus.ascent + upperLimitGap + upperLimit.descent
      )
    }

    private func updateNucleusPosition() {
      guard let nucleus else { return }
      nucleus.position = CGPoint(x: position.x + (width - nucleus.width) / 2, y: position.y)
    }
  }
}
