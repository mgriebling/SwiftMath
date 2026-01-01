import Foundation

extension Math {
  final class Color: Atom {
    var colorString: String
    var innerList: AtomList?

    override var description: String {
      [
        "\\color",
        "{\(colorString)}",
        innerList.map { "{\($0)}" },
      ]
      .compactMap(\.self)
      .joined()
    }

    override var finalized: Math.Atom {
      let finalized = super.finalized

      if let color = finalized as? Color {
        color.innerList = color.innerList?.finalized
      }

      return finalized
    }

    init(_ color: Color) {
      self.colorString = color.colorString
      self.innerList = color.innerList.map { AtomList($0) }

      super.init(color)
    }

    init(colorString: String = "", innerList: AtomList? = nil) {
      self.colorString = colorString
      self.innerList = innerList
      super.init(type: .color)
    }
  }
}
