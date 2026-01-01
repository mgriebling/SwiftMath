import Foundation

extension Math {
  final class Radical: Atom {
    var radicand: AtomList?
    var degree: AtomList?

    override var description: String {
      [
        "\\sqrt",
        degree.map { "[\($0)]" },
        "{\(radicand?.description ?? "placeholder")}",
        superscript.map { "^{\($0)}" },
        `subscript`.map { "_{\($0)}" },
      ]
      .compactMap(\.self)
      .joined()
    }

    override var finalized: Math.Atom {
      let finalized = super.finalized

      if let radical = finalized as? Radical {
        radical.radicand = radical.radicand?.finalized
        radical.degree = radical.degree?.finalized
      }

      return finalized
    }

    init(_ radical: Radical) {
      self.radicand = radical.radicand.map { AtomList($0) }
      self.degree = radical.degree.map { AtomList($0) }

      super.init(radical)
    }

    init(radicand: AtomList? = nil, degree: AtomList? = nil) {
      self.radicand = radicand
      self.degree = degree

      super.init(type: .radical)
    }
  }
}
