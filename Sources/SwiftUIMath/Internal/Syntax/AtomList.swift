import Foundation

extension Math {
  enum AtomType: Int {
    // A number or text in ordinary format - Ord in TeX
    case ordinary = 1
    // A number - Does not exist in TeX
    case number
    // A variable (i.e. text in italic format) - Does not exist in TeX
    case variable
    // A large operator such as (sin/cos, integral etc.) - Op in TeX
    case largeOperator
    // A binary operator - Bin in TeX
    case binaryOperator
    // A unary operator - Does not exist in TeX.
    case unaryOperator
    // A relation, e.g. = > < etc. - Rel in TeX
    case relation
    // Open brackets - Open in TeX
    case open
    // Close brackets - Close in TeX
    case close
    // A fraction e.g 1/2 - generalized fraction node in TeX
    case fraction
    // A radical operator e.g. sqrt(2)
    case radical
    // Punctuation such as , - Punct in TeX
    case punctuation
    // A placeholder square for future input. Does not exist in TeX
    case placeholder
    // An inner atom, i.e. an embedded math list - Inner in TeX
    case inner
    // An underlined atom - Under in TeX
    case underline
    // An overlined atom - Over in TeX
    case overline
    // An accented atom - Accent in TeX
    case accent

    // Atoms after this point do not support subscripts or superscripts

    // A left atom - Left & Right in TeX. We don't need two since we track boundaries separately.
    case boundary = 101

    // Atoms after this are non-math TeX nodes that are still useful in math mode. They do not have
    // the usual structure.

    // Spacing between math atoms. This denotes both glue and kern for TeX. We do not
    // distinguish between glue and kern.
    case space = 201

    // Denotes style changes during rendering.
    case style
    case color
    case textColor
    case colorBox

    // Atoms after this point are not part of TeX and do not have the usual structure.

    // An table atom. This atom does not exist in TeX. It is equivalent to the TeX command
    // halign which is handled outside of the TeX math rendering engine. We bring it into our
    // math typesetting to handle matrices and other tables.
    case table = 1001
  }
}

extension Math.AtomType {
  var disallowsFollowingBinaryOperator: Bool {
    switch self {
    case .binaryOperator, .relation, .open, .punctuation, .largeOperator:
      return true
    default:
      return false
    }
  }

  var allowsScripts: Bool {
    self < .boundary
  }
}

extension Math.AtomType: Comparable {
  static func < (lhs: Math.AtomType, rhs: Math.AtomType) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

extension Math.AtomType: CustomStringConvertible {
  var description: String {
    switch self {
    case .ordinary: return "Ordinary"
    case .number: return "Number"
    case .variable: return "Variable"
    case .largeOperator: return "Large Operator"
    case .binaryOperator: return "Binary Operator"
    case .unaryOperator: return "Unary Operator"
    case .relation: return "Relation"
    case .open: return "Open"
    case .close: return "Close"
    case .fraction: return "Fraction"
    case .radical: return "Radical"
    case .punctuation: return "Punctuation"
    case .placeholder: return "Placeholder"
    case .inner: return "Inner"
    case .underline: return "Underline"
    case .overline: return "Overline"
    case .accent: return "Accent"
    case .boundary: return "Boundary"
    case .space: return "Space"
    case .style: return "Style"
    case .color: return "Color"
    case .textColor: return "TextColor"
    case .colorBox: return "Colorbox"
    case .table: return "Table"
    }
  }
}

extension Math {
  class Atom: CustomStringConvertible {
    enum FontStyle: Int {
      case `default` = 0
      case roman
      case bold
      case caligraphic
      case typewriter
      case italic
      case sansSerif
      case fraktur
      case blackboard
      case boldItalic
    }

    var description: String {
      [
        nucleus,
        superscript.map { "^{\($0)}" },
        `subscript`.map { "_{\($0)}" },
      ]
      .compactMap(\.self)
      .joined()
    }

    var type: AtomType
    var nucleus: String
    var indexRange: NSRange
    var fontStyle: FontStyle
    var fusedAtoms: [Atom]

    var `subscript`: AtomList? {
      didSet {
        if `subscript` != nil, !allowsScripts {
          assertionFailure("Subscripts are not allowed for \(type)")
          `subscript` = nil
        }
      }
    }

    var superscript: AtomList? {
      didSet {
        if superscript != nil, !allowsScripts {
          assertionFailure("Superscripts are not allowed for \(type)")
          superscript = nil
        }
      }
    }

    var finalized: Atom {
      let finalized = copy()
      finalized.superscript = finalized.superscript?.finalized
      finalized.subscript = finalized.subscript?.finalized
      return finalized
    }

    var string: String {
      description
    }

    var allowsScripts: Bool {
      type.allowsScripts
    }

    var disallowsFollowingBinaryOperator: Bool {
      type.disallowsFollowingBinaryOperator
    }

    init(
      type: AtomType = .ordinary,
      nucleus: String = "",
      indexRange: NSRange = NSRange(),
      fontStyle: FontStyle = .default,
      fusedAtoms: [Atom] = [],
      subscript: AtomList? = nil,
      superscript: AtomList? = nil
    ) {
      self.type = type
      self.nucleus = nucleus
      self.indexRange = indexRange
      self.fontStyle = fontStyle
      self.fusedAtoms = fusedAtoms
      self.subscript = `subscript`
      self.superscript = superscript
    }

    init(_ other: Atom) {
      self.type = other.type
      self.nucleus = other.nucleus
      self.indexRange = other.indexRange
      self.fontStyle = other.fontStyle
      self.fusedAtoms = other.fusedAtoms
      self.subscript = other.`subscript`.map { AtomList($0) }
      self.superscript = other.superscript.map { AtomList($0) }
    }

    convenience init(type: AtomType, value: String) {
      self.init(type: type, nucleus: type == .radical ? "" : value)
    }

    func copy() -> Atom {
      switch type {
      case .fraction:
        return (self as? Fraction).map {
          Fraction($0)
        } ?? Fraction()
      case .radical:
        return (self as? Radical).map {
          Radical($0)
        } ?? Radical()
      case .largeOperator:
        return (self as? LargeOperator).map {
          LargeOperator($0)
        } ?? LargeOperator()
      case .inner:
        return (self as? Inner).map {
          Inner($0)
        } ?? Inner()
      case .overline:
        return (self as? Overline).map {
          Overline($0)
        } ?? Overline()
      case .underline:
        return (self as? Underline).map {
          Underline($0)
        } ?? Underline()
      case .accent:
        return (self as? Accent).map {
          Accent($0)
        } ?? Accent()
      case .space:
        return (self as? Space).map {
          Space($0)
        } ?? Space()
      case .style:
        return (self as? Style).map {
          Style($0)
        } ?? Style()
      case .color:
        return (self as? Color).map {
          Color($0)
        } ?? Color()
      case .textColor:
        return (self as? TextColor).map {
          TextColor($0)
        } ?? TextColor()
      case .colorBox:
        return (self as? ColorBox).map {
          ColorBox($0)
        } ?? ColorBox()
      case .table:
        return (self as? Table).map {
          Table($0)
        } ?? Table()
      default:
        return Atom(self)
      }
    }

    func fuse(with atom: Atom) {
      guard `subscript` == nil, superscript == nil, type == atom.type else {
        assertionFailure("Cannot fuse \(self) with \(atom)")
        return
      }

      if fusedAtoms.isEmpty {
        fusedAtoms.append(.init(self))
      }

      if atom.fusedAtoms.isEmpty {
        fusedAtoms.append(atom)
      } else {
        fusedAtoms.append(contentsOf: atom.fusedAtoms)
      }

      nucleus += atom.nucleus
      indexRange.length += atom.indexRange.length

      self.superscript = atom.superscript
      self.`subscript` = atom.`subscript`
    }
  }
}

extension Math {
  final class AtomList {
    var atoms: [Atom]

    var finalized: AtomList {
      let finalizedList = AtomList()

      var previousAtom: Atom?

      for atom in atoms {
        let finalizedAtom = atom.finalized

        if atom.indexRange == NSRange() {
          let location = (previousAtom?.indexRange).map {
            $0.location + $0.length
          }
          finalizedAtom.indexRange = NSRange(location: location ?? 0, length: 1)
        }

        switch finalizedAtom.type {
        case .binaryOperator where previousAtom.disallowsFollowingBinaryOperator:
          finalizedAtom.type = .unaryOperator
        case .relation, .punctuation, .close:
          if case .binaryOperator = previousAtom?.type {
            previousAtom?.type = .unaryOperator
          }
        case .number:
          if let previousAtom,
            case .number = previousAtom.type,
            previousAtom.`subscript` == nil,
            previousAtom.superscript == nil
          {
            previousAtom.fuse(with: finalizedAtom)
            continue  // skip the current node, we are done here
          }
        default:
          break
        }

        finalizedList.append(finalizedAtom)
        previousAtom = finalizedAtom
      }

      if let previousAtom, case .binaryOperator = previousAtom.type {
        previousAtom.type = .unaryOperator
      }

      return finalizedList
    }

    init(_ list: AtomList) {
      self.atoms = list.atoms.map {
        $0.copy()
      }
    }

    convenience init(atom: Atom) {
      self.init(atoms: [atom])
    }

    init(atoms: [Atom] = []) {
      self.atoms = atoms
    }

    func append(_ atom: Atom) {
      guard canAdd(atom) else {
        assertionFailure("Can't append atom of type \(atom.type)")
        return
      }
      atoms.append(atom)
    }

    func insert(_ atom: Atom, at index: Int) {
      guard atoms.indices.contains(index) || index == atoms.endIndex else {
        return
      }
      guard canAdd(atom) else {
        assertionFailure("Can't insert atom of type \(atom.type)")
        return
      }
      atoms.insert(atom, at: index)
    }

    func append(contentsOf list: AtomList) {
      atoms.append(contentsOf: list.atoms)
    }
  }
}

extension Math.AtomList: CustomStringConvertible {
  var description: String {
    atoms.description
  }
}

extension Math.AtomList {
  private func canAdd(_ atom: Math.Atom) -> Bool {
    atom.type != .boundary
  }
}

extension Optional where Wrapped: Math.Atom {
  var disallowsFollowingBinaryOperator: Bool {
    guard case .some(let wrapped) = self else {
      return true
    }
    return wrapped.disallowsFollowingBinaryOperator
  }
}
