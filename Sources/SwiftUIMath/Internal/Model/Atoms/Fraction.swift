import Foundation

extension Math {
  final class Fraction: Atom {
    var hasRule: Bool
    var leftDelimiter: String
    var rightDelimiter: String
    var numerator: AtomList?
    var denominator: AtomList?

    var isContinuedFraction: Bool = false
    var alignment: String  // "l", "r", "c" for left, right, center

    override var description: String {
      [
        hasRule ? "\\frac" : "\\atop",
        leftDelimiter.isEmpty ? nil : "[\(leftDelimiter)]",
        rightDelimiter.isEmpty ? nil : "[\(rightDelimiter)]",
        "{\(numerator?.description ?? "placeholder")}",
        "{\(denominator?.description ?? "placeholder")}",
        superscript.map { "^{\($0)}" },
        `subscript`.map { "_{\($0)}" },
      ]
      .compactMap(\.self)
      .joined()
    }

    override var finalized: Math.Atom {
      let finalized = super.finalized

      if let fraction = finalized as? Fraction {
        fraction.numerator = fraction.numerator?.finalized
        fraction.denominator = fraction.denominator?.finalized
      }

      return finalized
    }

    init(_ fraction: Fraction) {
      self.hasRule = fraction.hasRule
      self.leftDelimiter = fraction.leftDelimiter
      self.rightDelimiter = fraction.rightDelimiter
      self.numerator = fraction.numerator.map { AtomList($0) }
      self.denominator = fraction.denominator.map { AtomList($0) }
      self.isContinuedFraction = fraction.isContinuedFraction
      self.alignment = fraction.alignment

      super.init(fraction)
    }

    init(
      hasRule: Bool = true,
      leftDelimiter: String = "",
      rightDelimiter: String = "",
      numerator: AtomList? = nil,
      denominator: AtomList? = nil,
      isContinuedFraction: Bool = false,
      alignment: String = "c"
    ) {
      self.hasRule = hasRule
      self.leftDelimiter = leftDelimiter
      self.rightDelimiter = rightDelimiter
      self.numerator = numerator
      self.denominator = denominator
      self.isContinuedFraction = isContinuedFraction
      self.alignment = alignment

      super.init(type: .fraction)
    }
  }
}
