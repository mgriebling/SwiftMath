import Foundation

extension Math {
  final class Accent: Atom {
    var innerList: AtomList?

    override var finalized: Math.Atom {
      let finalized = super.finalized

      if let accent = finalized as? Accent {
        accent.innerList = accent.innerList?.finalized
      }

      return finalized
    }

    init(_ accent: Accent) {
      self.innerList = accent.innerList.map { AtomList($0) }
      super.init(accent)
    }

    init(value: String = "", innerList: AtomList? = nil) {
      self.innerList = innerList
      super.init(type: .accent, nucleus: value)
    }
  }
}
