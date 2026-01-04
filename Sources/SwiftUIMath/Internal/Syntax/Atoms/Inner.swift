import Foundation

extension Math {
  final class Inner: Atom {
    var innerList: AtomList?

    var leftBoundary: Atom? {
      didSet {
        if let leftBoundary, leftBoundary.type != .boundary {
          assertionFailure("Left boundary must be of type 'boundary'")
          self.leftBoundary = nil
        }
      }
    }

    var rightBoundary: Atom? {
      didSet {
        if let rightBoundary, rightBoundary.type != .boundary {
          assertionFailure("Right boundary must be of type 'boundary'")
          self.rightBoundary = nil
        }
      }
    }

    override var description: String {
      [
        "\\inner",
        leftBoundary.map { "[\($0.nucleus)]" },
        innerList.map { "{\($0)}" },
        rightBoundary.map { "[\($0.nucleus)]" },
        superscript.map { "^{\($0)}" },
        `subscript`.map { "_{\($0)}" },
      ]
      .compactMap(\.self)
      .joined()
    }

    override var finalized: Math.Atom {
      let finalized = super.finalized

      if let inner = finalized as? Inner {
        inner.innerList = inner.innerList?.finalized
      }

      return finalized
    }

    init(_ inner: Inner) {
      self.innerList = inner.innerList.map { AtomList($0) }
      self.leftBoundary = inner.leftBoundary.map { $0.copy() }
      self.rightBoundary = inner.rightBoundary.map { $0.copy() }

      super.init(inner)
    }

    init(
      innerList: AtomList? = nil,
      leftBoundary: Atom? = nil,
      rightBoundary: Atom? = nil
    ) {
      self.innerList = innerList
      self.leftBoundary = leftBoundary
      self.rightBoundary = rightBoundary

      super.init(type: .inner)
    }
  }
}
