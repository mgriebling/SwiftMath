import Foundation

extension Math {
  final class Overline: Atom {
    var innerList: AtomList?

    override var finalized: Math.Atom {
      let finalized = super.finalized

      if let overline = finalized as? Overline {
        overline.innerList = overline.innerList?.finalized
      }

      return finalized
    }

    init(_ overline: Overline) {
      self.innerList = overline.innerList.map { AtomList($0) }
      super.init(overline)
    }

    init(innerList: AtomList? = nil) {
      self.innerList = innerList
      super.init(type: .overline)
    }
  }
}
