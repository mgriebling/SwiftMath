import Foundation

extension Math {
  final class TextColor: Atom {
    var colorString: String
    var innerList: AtomList?

    override var description: String {
      [
        "\\textcolor",
        "{\(colorString)}",
        innerList.map { "{\($0)}" },
      ]
      .compactMap(\.self)
      .joined()
    }

    override var finalized: Math.Atom {
      let finalized = super.finalized

      if let textColor = finalized as? TextColor {
        textColor.innerList = textColor.innerList?.finalized
      }

      return finalized
    }

    init(_ textColor: TextColor) {
      self.colorString = textColor.colorString
      self.innerList = textColor.innerList.map { AtomList($0) }

      super.init(textColor)
    }

    init(colorString: String = "", innerList: AtomList? = nil) {
      self.colorString = colorString
      self.innerList = innerList
      super.init(type: .textColor)
    }
  }
}
