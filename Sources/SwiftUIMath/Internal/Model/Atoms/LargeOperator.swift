import Foundation

extension Math {
  final class LargeOperator: Atom {
    var limits: Bool

    init(_ largeOperator: LargeOperator) {
      self.limits = largeOperator.limits
      super.init(largeOperator)
    }

    init(limits: Bool = false) {
      self.limits = limits
      super.init(type: .largeOperator)
    }
  }
}
