import Foundation

extension Math {
  final class ColorBox: Atom {
    var colorString: String
    var innerList: AtomList?

    override var description: String {
      [
        "\\colorbox",
        "{\(colorString)}",
        innerList.map { "{\($0)}" },
      ]
      .compactMap(\.self)
      .joined()
    }

    override var finalized: Math.Atom {
      let finalized = super.finalized

      if let colorBox = finalized as? ColorBox {
        colorBox.innerList = colorBox.innerList?.finalized
      }

      return finalized
    }

    init(_ colorBox: ColorBox) {
      self.colorString = colorBox.colorString
      self.innerList = colorBox.innerList.map { AtomList($0) }

      super.init(colorBox)
    }

    init(colorString: String = "", innerList: AtomList? = nil) {
      self.colorString = colorString
      self.innerList = innerList
      super.init(type: .colorBox)
    }
  }
}
