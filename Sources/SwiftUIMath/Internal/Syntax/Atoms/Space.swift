import Foundation

extension Math {
  final class Space: Atom {
    var amount: CGFloat

    init(_ space: Space) {
      self.amount = space.amount
      super.init(space)
    }

    init(amount: CGFloat = 0) {
      self.amount = amount
      super.init(type: .space)
    }
  }
}
