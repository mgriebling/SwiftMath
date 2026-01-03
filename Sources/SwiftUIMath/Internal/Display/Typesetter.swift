import CoreText
import Foundation

// MARK: - Inter Element Spacing

private enum InterElementSpaceType: Int {
  case invalid = -1
  case none = 0
  case thin
  case nsThin  // Thin but not in script mode
  case nsMedium
  case nsThick
}

private let interElementSpaceArray: [[InterElementSpaceType]] =
  //   ordinary   operator   binary     relation  open       close     punct     fraction
  [
    [.none, .thin, .nsMedium, .nsThick, .none, .none, .none, .nsThin],  // ordinary
    [.thin, .thin, .invalid, .nsThick, .none, .none, .none, .nsThin],  // operator
    [.nsMedium, .nsMedium, .invalid, .invalid, .nsMedium, .invalid, .invalid, .nsMedium],  // binary
    [.nsThick, .nsThick, .invalid, .none, .nsThick, .none, .none, .nsThick],  // relation
    [.none, .none, .invalid, .none, .none, .none, .none, .none],  // open
    [.none, .thin, .nsMedium, .nsThick, .none, .none, .none, .nsThin],  // close
    [.nsThin, .nsThin, .invalid, .nsThin, .nsThin, .nsThin, .nsThin, .nsThin],  // punct
    [.nsThin, .thin, .nsMedium, .nsThick, .nsThin, .none, .nsThin, .nsThin],  // fraction
    [.nsMedium, .nsThin, .nsMedium, .nsThick, .none, .none, .none, .nsThin],
  ]  // radical

private func getInterElementSpaces() -> [[InterElementSpaceType]] {
  return interElementSpaceArray
}

// Get's the index for the given type. If row is true, the index is for the row (i.e. left element) otherwise it is for the column (right element)
func getInterElementSpaceArrayIndexForType(_ type: Math.AtomType, row: Bool) -> Int {
  switch type {
  case .color, .textColor, .colorBox, .ordinary, .placeholder:  // A placeholder is treated as ordinary
    return 0
  case .largeOperator:
    return 1
  case .binaryOperator:
    return 2
  case .relation:
    return 3
  case .open:
    return 4
  case .close:
    return 5
  case .punctuation:
    return 6
  case .fraction,  // Fraction and inner are treated the same.
    .inner:
    return 7
  case .radical:
    if row {
      // Radicals have inter element spaces only when on the left side.
      // Note: This is a departure from latex but we don't want \sqrt{4}4 to look weird so we put a space in between.
      // They have the same spacing as ordinary except with ordinary.
      return 8
    } else {
      // Treat radical as ordinary on the right side
      return 0
    }
  // Numbers, variables, and unary operators are treated as ordinary
  case .number, .variable, .unaryOperator:
    return 0
  // Decorative types (accent, underline, overline) are treated as ordinary
  case .accent, .underline, .overline:
    return 0
  // Special types that don't typically participate in spacing are treated as ordinary
  case .boundary, .space, .style, .table:
    return 0
  }
}

// MARK: - Italics
// mathit
func getItalicized(_ ch: Character) -> UTF32Char {
  var unicode = ch.utf32

  // Special cases for italics
  if ch == "h" { return UTF32Char.planksConstant }

  if ch.isUpperEnglish {
    unicode = UTF32Char.capitalItalicStart + (ch.utf32 - Character("A").utf32)
  } else if ch.isLowerEnglish {
    unicode = UTF32Char.lowerItalicStart + (ch.utf32 - Character("a").utf32)
  } else if ch.isCapitalGreek {
    // Capital Greek characters
    unicode = UTF32Char.greekCapitalItalicStart + (ch.utf32 - UTF32Char.capitalGreekStart)
  } else if ch.isLowerGreek {
    // Greek characters
    unicode = UTF32Char.greekLowerItalicStart + (ch.utf32 - UTF32Char.lowerGreekStart)
  } else if ch.isGreekSymbol {
    return UTF32Char.greekSymbolItalicStart + ch.greekSymbolOrder!
  }
  // Note there are no italicized numbers in unicode so we don't support italicizing numbers.
  return unicode
}

// mathbf
func getBold(_ ch: Character) -> UTF32Char {
  var unicode = ch.utf32
  if ch.isUpperEnglish {
    unicode = UTF32Char.mathCapitalBoldStart + (ch.utf32 - Character("A").utf32)
  } else if ch.isLowerEnglish {
    unicode = UTF32Char.mathLowerBoldStart + (ch.utf32 - Character("a").utf32)
  } else if ch.isCapitalGreek {
    // Capital Greek characters
    unicode = UTF32Char.greekCapitalBoldStart + (ch.utf32 - UTF32Char.capitalGreekStart)
  } else if ch.isLowerGreek {
    // Greek characters
    unicode = UTF32Char.greekLowerBoldStart + (ch.utf32 - UTF32Char.lowerGreekStart)
  } else if ch.isGreekSymbol {
    return UTF32Char.greekSymbolBoldStart + ch.greekSymbolOrder!
  } else if ch.isNumber {
    unicode = UTF32Char.numberBoldStart + (ch.utf32 - Character("0").utf32)
  }
  return unicode
}

// mathbfit
func getBoldItalic(_ ch: Character) -> UTF32Char {
  var unicode = ch.utf32
  if ch.isUpperEnglish {
    unicode = UTF32Char.mathCapitalBoldItalicStart + (ch.utf32 - Character("A").utf32)
  } else if ch.isLowerEnglish {
    unicode = UTF32Char.mathLowerBoldItalicStart + (ch.utf32 - Character("a").utf32)
  } else if ch.isCapitalGreek {
    // Capital Greek characters
    unicode = UTF32Char.greekCapitalBoldItalicStart + (ch.utf32 - UTF32Char.capitalGreekStart)
  } else if ch.isLowerGreek {
    // Greek characters
    unicode = UTF32Char.greekLowerBoldItalicStart + (ch.utf32 - UTF32Char.lowerGreekStart)
  } else if ch.isGreekSymbol {
    return UTF32Char.greekSymbolBoldItalicStart + ch.greekSymbolOrder!
  } else if ch.isNumber {
    // No bold italic for numbers so we just bold them.
    unicode = getBold(ch)
  }
  return unicode
}

// LaTeX default
func getDefaultStyle(_ ch: Character) -> UTF32Char {
  if ch.isLowerEnglish || ch.isUpperEnglish || ch.isLowerGreek || ch.isGreekSymbol {
    return getItalicized(ch)
  } else if ch.isNumber || ch.isCapitalGreek {
    // In the default style numbers and capital greek is roman
    return ch.utf32
  } else if ch == "." {
    // . is treated as a number in our code, but it doesn't change fonts.
    return ch.utf32
  } else {
    NSException(
      name: NSExceptionName("IllegalCharacter"),
      reason: "Unknown character \(ch) for default style."
    ).raise()
  }
  return ch.utf32
}

// mathcal/mathscr (caligraphic or script)
func getCaligraphic(_ ch: Character) -> UTF32Char {
  // Caligraphic has lots of exceptions:
  switch ch {
  case "B":
    return 0x212C  // Script B (bernoulli)
  case "E":
    return 0x2130  // Script E (emf)
  case "F":
    return 0x2131  // Script F (fourier)
  case "H":
    return 0x210B  // Script H (hamiltonian)
  case "I":
    return 0x2110  // Script I
  case "L":
    return 0x2112  // Script L (laplace)
  case "M":
    return 0x2133  // Script M (M-matrix)
  case "R":
    return 0x211B  // Script R (Riemann integral)
  case "e":
    return 0x212F  // Script e (Natural exponent)
  case "g":
    return 0x210A  // Script g (real number)
  case "o":
    return 0x2134  // Script o (order)
  default:
    break
  }
  var unicode: UTF32Char
  if ch.isUpperEnglish {
    unicode = UTF32Char.mathCapitalScriptStart + (ch.utf32 - Character("A").utf32)
  } else if ch.isLowerEnglish {
    // Latin Modern Math does not have lower case caligraphic characters, so we use
    // the default style instead of showing a ?
    unicode = getDefaultStyle(ch)
  } else {
    // Caligraphic characters don't exist for greek or numbers, we give them the
    // default treatment.
    unicode = getDefaultStyle(ch)
  }
  return unicode
}

// mathtt (monospace)
func getTypewriter(_ ch: Character) -> UTF32Char {
  if ch.isUpperEnglish {
    return UTF32Char.mathCapitalTTStart + (ch.utf32 - Character("A").utf32)
  } else if ch.isLowerEnglish {
    return UTF32Char.mathLowerTTStart + (ch.utf32 - Character("a").utf32)
  } else if ch.isNumber {
    return UTF32Char.numberTTStart + (ch.utf32 - Character("0").utf32)
  }
  // Monospace characters don't exist for greek, we give them the
  // default treatment.
  return getDefaultStyle(ch)
}

// mathsf
func getSansSerif(_ ch: Character) -> UTF32Char {
  if ch.isUpperEnglish {
    return UTF32Char.mathCapitalSansSerifStart + (ch.utf32 - Character("A").utf32)
  } else if ch.isLowerEnglish {
    return UTF32Char.mathLowerSansSerifStart + (ch.utf32 - Character("a").utf32)
  } else if ch.isNumber {
    return UTF32Char.numberSansSerifStart + (ch.utf32 - Character("0").utf32)
  }
  // Sans-serif characters don't exist for greek, we give them the
  // default treatment.
  return getDefaultStyle(ch)
}

// mathfrak
func getFraktur(_ ch: Character) -> UTF32Char {
  // Fraktur has exceptions:
  switch ch {
  case "C":
    return 0x212D  // C Fraktur
  case "H":
    return 0x210C  // Hilbert space
  case "I":
    return 0x2111  // Imaginary
  case "R":
    return 0x211C  // Real
  case "Z":
    return 0x2128  // Z Fraktur
  default:
    break
  }
  if ch.isUpperEnglish {
    return UTF32Char.mathCapitalFrakturStart + (ch.utf32 - Character("A").utf32)
  } else if ch.isLowerEnglish {
    return UTF32Char.mathLowerFrakturStart + (ch.utf32 - Character("a").utf32)
  }
  // Fraktur characters don't exist for greek & numbers, we give them the
  // default treatment.
  return getDefaultStyle(ch)
}

// mathbb (double struck)
func getBlackboard(_ ch: Character) -> UTF32Char {
  // Blackboard has lots of exceptions:
  switch ch {
  case "C":
    return 0x2102  // Complex numbers
  case "H":
    return 0x210D  // Quarternions
  case "N":
    return 0x2115  // Natural numbers
  case "P":
    return 0x2119  // Primes
  case "Q":
    return 0x211A  // Rationals
  case "R":
    return 0x211D  // Reals
  case "Z":
    return 0x2124  // Integers
  default:
    break
  }
  if ch.isUpperEnglish {
    return UTF32Char.mathCapitalBlackboardStart + (ch.utf32 - Character("A").utf32)
  } else if ch.isLowerEnglish {
    return UTF32Char.mathLowerBlackboardStart + (ch.utf32 - Character("a").utf32)
  } else if ch.isNumber {
    return UTF32Char.numberBlackboardStart + (ch.utf32 - Character("0").utf32)
  }
  // Blackboard characters don't exist for greek, we give them the
  // default treatment.
  return getDefaultStyle(ch)
}

func styleCharacter(_ ch: Character, fontStyle: Math.Atom.FontStyle) -> UTF32Char {
  switch fontStyle {
  case .default:
    return getDefaultStyle(ch)
  case .roman:
    return ch.utf32
  case .bold:
    return getBold(ch)
  case .italic:
    return getItalicized(ch)
  case .boldItalic:
    return getBoldItalic(ch)
  case .caligraphic:
    return getCaligraphic(ch)
  case .typewriter:
    return getTypewriter(ch)
  case .sansSerif:
    return getSansSerif(ch)
  case .fraktur:
    return getFraktur(ch)
  case .blackboard:
    return getBlackboard(ch)
  }
}

func changeFont(_ str: String, fontStyle: Math.Atom.FontStyle) -> String {
  var retval = ""
  let codes = Array(str)
  for i in 0..<str.count {
    let ch = codes[i]
    var unicode = styleCharacter(ch, fontStyle: fontStyle)
    unicode = NSSwapHostIntToLittle(unicode)
    let charStr = String(UnicodeScalar(unicode)!)
    retval.append(charStr)
  }
  return retval
}

func getBboxDetails(_ bbox: CGRect, ascent: inout CGFloat, descent: inout CGFloat) {
  ascent = max(0, CGRectGetMaxY(bbox) - 0)

  // Descent is how much the line goes below the origin. However if the line is all above the origin, then descent can't be negative.
  descent = max(0, 0 - CGRectGetMinY(bbox))
}

// MARK: - Typesetter

extension Math {
  final class Typesetter {
    var font: PlatformFont!
    var displayAtoms = [DisplayNode]()
    var currentPosition = CGPoint.zero
    var currentLine: NSMutableAttributedString!
    var currentAtoms = [Atom]()  // List of atoms that make the line
    var currentLineIndexRange = NSMakeRange(0, 0)
    var style: Style.Level { didSet { _styleFont = nil } }
    private var _styleFont: PlatformFont?
    var styleFont: PlatformFont {
      if _styleFont == nil {
        _styleFont = font.withSize(Self.getStyleSize(style, font: font))
      }
      return _styleFont!
    }
    var cramped = false
    var spaced = false
    var maxWidth: CGFloat = 0  // Maximum width for line breaking, 0 means no constraint
    var currentLineStartIndex: Int = 0  // Index in displayAtoms where current line starts
    var minimumLineSpacing: CGFloat = 0  // Minimum spacing between lines (will be set based on fontSize)

    // Performance optimization: skip line breaking checks if we know all remaining content fits
    private var remainingContentFits = false

    static func createLineForMathList(
      _ mathList: AtomList?, font: PlatformFont?, style: Style.Level
    ) -> DisplayList? {
      let finalizedList = mathList?.finalized
      // default is not cramped, no width constraint
      return self.createLineForMathList(
        finalizedList, font: font, style: style, cramped: false, maxWidth: 0)
    }

    static func createLineForMathList(
      _ mathList: AtomList?, font: PlatformFont?, style: Style.Level, maxWidth: CGFloat
    ) -> DisplayList? {
      let finalizedList = mathList?.finalized
      // default is not cramped
      return self.createLineForMathList(
        finalizedList, font: font, style: style, cramped: false, maxWidth: maxWidth)
    }

    // Internal
    static func createLineForMathList(
      _ mathList: AtomList?, font: PlatformFont?, style: Style.Level, cramped: Bool
    ) -> DisplayList? {
      return self.createLineForMathList(
        mathList, font: font, style: style, cramped: cramped, spaced: false, maxWidth: 0)
    }

    // Internal
    static func createLineForMathList(
      _ mathList: AtomList?, font: PlatformFont?, style: Style.Level, cramped: Bool,
      maxWidth: CGFloat
    ) -> DisplayList? {
      return self.createLineForMathList(
        mathList, font: font, style: style, cramped: cramped, spaced: false, maxWidth: maxWidth)
    }

    // Internal
    static func createLineForMathList(
      _ mathList: AtomList?, font: PlatformFont?, style: Style.Level, cramped: Bool, spaced: Bool
    ) -> DisplayList? {
      return self.createLineForMathList(
        mathList, font: font, style: style, cramped: cramped, spaced: spaced, maxWidth: 0)
    }

    // Internal
    static func createLineForMathList(
      _ mathList: AtomList?, font: PlatformFont?, style: Style.Level, cramped: Bool, spaced: Bool,
      maxWidth: CGFloat
    ) -> DisplayList? {
      assert(font != nil)
      let preprocessedAtoms = self.preprocessMathList(mathList)
      let typesetter = Typesetter(
        withFont: font, style: style, cramped: cramped, spaced: spaced, maxWidth: maxWidth)
      typesetter.createDisplayAtoms(preprocessedAtoms)
      let lastAtom = mathList!.atoms.last
      let last = lastAtom?.indexRange ?? NSMakeRange(0, 0)
      let line = DisplayList(
        children: typesetter.displayAtoms, range: NSMakeRange(0, NSMaxRange(last)))
      return line
    }

    static var placeholderColor: PlatformColor { PlatformColor.blue }

    init(
      withFont font: PlatformFont?, style: Style.Level, cramped: Bool, spaced: Bool,
      maxWidth: CGFloat = 0
    ) {
      self.font = font
      self.displayAtoms = [DisplayNode]()
      self.currentPosition = CGPoint.zero
      self.cramped = cramped
      self.spaced = spaced
      self.maxWidth = maxWidth
      self.currentLine = NSMutableAttributedString()
      self.currentAtoms = [Atom]()
      self.style = style
      self.currentLineIndexRange = NSMakeRange(NSNotFound, NSNotFound)
      self.currentLineStartIndex = 0
      // Set minimum line spacing to 20% of fontSize for some breathing room
      self.minimumLineSpacing = (font?.font.size ?? 0) * 0.2
    }

    static func preprocessMathList(_ ml: AtomList?) -> [Atom] {
      // Note: Some of the preprocessing described by the TeX algorithm is done in the finalize method of AtomList.
      // Specifically rules 5 & 6 in Appendix G are handled by finalize.
      // This function does not do a complete preprocessing as specified by TeX either. It removes any special atom types
      // that are not included in TeX and applies Rule 14 to merge ordinary characters.
      var preprocessed = [Atom]()  //  arrayWithCapacity:ml.atoms.count)
      var prevNode: Atom! = nil
      preprocessed.reserveCapacity(ml!.atoms.count)
      for atom in ml!.atoms {
        if atom.type == .variable || atom.type == .number {
          // This is not a TeX type node. TeX does this during parsing the input.
          // switch to using the italic math font
          // We convert it to ordinary
          let newFont = changeFont(atom.nucleus, fontStyle: atom.fontStyle)  // mathItalicize(atom.nucleus)
          atom.type = .ordinary
          atom.nucleus = newFont
        } else if atom.type == .unaryOperator {
          // Neither of these are TeX nodes. TeX treats these as Ordinary. So will we.
          atom.type = .ordinary
        }

        if atom.type == .ordinary {
          // This is Rule 14 to merge ordinary characters.
          // combine ordinary atoms together
          if prevNode != nil && prevNode.type == .ordinary && prevNode.`subscript` == nil
            && prevNode.superscript == nil
          {
            prevNode.fuse(with: atom)
            // skip the current node, we are done here.
            continue
          }
        }

        // TODO: add italic correction here or in second pass?
        prevNode = atom
        preprocessed.append(atom)
      }
      return preprocessed
    }

    // returns the size of the font in this style
    static func getStyleSize(_ style: Style.Level, font: PlatformFont?) -> CGFloat {
      let original = font!.font.size
      switch style {
      case .display, .text:
        return original
      case .script:
        return original * font!.metrics.scriptScaleDown
      case .scriptOfScript:
        return original * font!.metrics.scriptScriptScaleDown
      }
    }

    func addInterElementSpace(_ prevNode: Atom?, currentType type: AtomType) {
      var interElementSpace = CGFloat(0)
      if prevNode != nil {
        interElementSpace = getInterElementSpace(prevNode!.type, right: type)
      } else if self.spaced {
        // For the first atom of a spaced list, treat it as if it is preceded by an open.
        interElementSpace = getInterElementSpace(.open, right: type)
      }
      self.currentPosition.x += interElementSpace
    }

    // MARK: - Interatom Line Breaking

    // Calculate the width that would result from adding this atom to the current line
    // Returns the approximate width including inter-element spacing
    func calculateAtomWidth(_ atom: Atom, prevNode: Atom?) -> CGFloat {
      // Skip atoms that don't participate in normal width calculation
      // These are handled specially in the rendering code
      if atom.type == .space || atom.type == .style {
        return 0
      }

      // Calculate inter-element spacing (only for types that have defined spacing)
      var interElementSpace: CGFloat = 0
      if prevNode != nil && prevNode!.type != .space && prevNode!.type != .style {
        interElementSpace = getInterElementSpace(prevNode!.type, right: atom.type)
      } else if self.spaced && prevNode?.type != .space {
        interElementSpace = getInterElementSpace(.open, right: atom.type)
      }

      // Calculate the width of the atom's nucleus
      let atomString = NSAttributedString(
        string: atom.nucleus,
        attributes: [
          kCTFontAttributeName as NSAttributedString.Key: styleFont.ctFont as Any
        ])
      let ctLine = CTLineCreateWithAttributedString(atomString as CFAttributedString)
      let atomWidth = CGFloat(CTLineGetTypographicBounds(ctLine, nil, nil, nil))

      return interElementSpace + atomWidth
    }

    // Calculate the current line width
    func getCurrentLineWidth() -> CGFloat {
      if currentLine.length == 0 {
        return 0
      }
      let attrString = currentLine.mutableCopy() as! NSMutableAttributedString
      attrString.addAttribute(
        kCTFontAttributeName as NSAttributedString.Key, value: styleFont.ctFont as Any,
        range: NSMakeRange(0, attrString.length))
      let ctLine = CTLineCreateWithAttributedString(attrString)
      return CGFloat(CTLineGetTypographicBounds(ctLine, nil, nil, nil))
    }

    // Check if we should break to a new line before adding this atom
    // Uses look-ahead to find better break points aesthetically
    // Returns true if a line break was performed
    @discardableResult
    func checkAndPerformInteratomLineBreak(_ atom: Atom, prevNode: Atom?, nextAtoms: [Atom] = [])
      -> Bool
    {
      // Only perform interatom breaking when maxWidth is set
      guard maxWidth > 0 else { return false }

      // Don't break if current line is empty
      guard currentLine.length > 0 else { return false }

      // Performance optimization: if we've determined remaining content fits, skip breaking checks
      if remainingContentFits {
        return false
      }

      // CRITICAL: Don't break in the middle of words
      // When "équivaut" is decomposed as "é" (accent) + "quivaut" (ordinary),
      // we must not break between them even if the line exceeds maxWidth.
      // Check if currentLine ends with a letter and next atom starts with a letter
      // This prevents breaking mid-word (like "é|quivaut")
      if atom.type == .ordinary && !atom.nucleus.isEmpty {
        let lineText = currentLine.string
        if !lineText.isEmpty {
          let lastChar = lineText.last!
          let firstChar = atom.nucleus.first!

          // If line ends with a letter (no trailing space/punctuation) and next atom
          // starts with a letter, they're part of the same word - don't break!
          // Example: "...é" + "quivaut" should not break
          // But "...km " + "équivaut" can break (has space)
          // IMPORTANT: Only apply this to multi-character atoms (text words), not single
          // letters (math variables). In math "4ac" splits as "4","a","c" - these are
          // separate and CAN be broken between.
          if lastChar.isLetter && firstChar.isLetter && atom.nucleus.count > 1 {
            // Don't break - this would split a word
            return false
          }
        }
      }

      // Calculate what the width would be if we add this atom
      // IMPORTANT: Use currentPosition.x instead of getCurrentLineWidth()
      // because currentLine only measures the current text segment, but after
      // superscripts/subscripts, the line may be split into multiple segments.
      // currentPosition.x tracks the actual visual horizontal position.
      let currentLineWidth = getCurrentLineWidth()
      let visualLineWidth = currentPosition.x + currentLineWidth
      let atomWidth = calculateAtomWidth(atom, prevNode: prevNode)
      let projectedWidth = visualLineWidth + atomWidth

      // If we're well within the limit, no need to break
      if projectedWidth <= maxWidth {
        // Performance optimization: if we have plenty of space left and limited atoms remaining,
        // we can skip all future line breaking checks for this line
        if !remainingContentFits && !nextAtoms.isEmpty {
          // Conservative estimate: if we're using less than 60% of available width
          // and have only a few atoms left, assume remaining content will fit
          let usageRatio = projectedWidth / maxWidth
          if usageRatio < 0.6 && nextAtoms.count <= 5 {
            remainingContentFits = true
          } else if usageRatio < 0.75 {
            // For moderate usage, estimate remaining content width
            let estimatedRemainingWidth = estimateRemainingAtomsWidth(nextAtoms)
            if projectedWidth + estimatedRemainingWidth <= maxWidth {
              remainingContentFits = true
            }
          }
        }
        return false
      }

      // We've exceeded the width. Now use break quality scoring to find the best break point.

      // If we're far over the limit (>20% excess), break immediately regardless of quality
      if projectedWidth > maxWidth * 1.2 {
        performInteratomLineBreak()
        return true
      }

      // We're slightly over the limit. Look ahead to see if there's a better break point coming soon.
      let currentPenalty = calculateBreakPenalty(afterAtom: prevNode, beforeAtom: atom)

      // Look ahead up to 3 atoms to find better break points
      var bestBreakOffset = 0  // 0 = break now (before current atom)
      var bestPenalty = currentPenalty

      var cumulativeWidth = projectedWidth
      var lookAheadPrev = atom

      for (offset, nextAtom) in nextAtoms.prefix(3).enumerated() {
        // Calculate width if we continue to this atom
        let nextAtomWidth = calculateAtomWidth(nextAtom, prevNode: lookAheadPrev)
        cumulativeWidth += nextAtomWidth

        // If we'd be way over the limit, stop looking ahead
        if cumulativeWidth > maxWidth * 1.3 {
          break
        }

        // Calculate penalty for breaking before this next atom
        let penalty = calculateBreakPenalty(afterAtom: lookAheadPrev, beforeAtom: nextAtom)

        // If this is a better break point (lower penalty), remember it
        if penalty < bestPenalty {
          bestPenalty = penalty
          bestBreakOffset = offset + 1  // +1 because we want to break before nextAtom
        }

        // If we found a perfect break point (penalty = 0), use it
        if penalty == 0 {
          break
        }

        lookAheadPrev = nextAtom
      }

      // If best break point is not at current position, defer the break
      if bestBreakOffset > 0 {
        // Don't break yet - continue adding atoms to find the better break point
        return false
      }

      // Break at current position (best option available)
      performInteratomLineBreak()
      return true
    }

    // Estimate the approximate width of remaining atoms
    // Returns a conservative (upper bound) estimate
    private func estimateRemainingAtomsWidth(_ atoms: [Atom]) -> CGFloat {
      // Use a simple heuristic: average character width * character count
      let avgCharWidth = styleFont.metrics.mathUnit
      var totalChars = 0

      for atom in atoms {
        // Count nucleus characters
        totalChars += atom.nucleus.count

        // Add extra for subscripts/superscripts (rough estimate)
        if atom.`subscript` != nil {
          totalChars += 3
        }
        if atom.superscript != nil {
          totalChars += 3
        }
      }

      // Return conservative estimate (multiply by 1.5 for safety margin)
      return CGFloat(totalChars) * avgCharWidth * 1.5
    }

    // Perform the actual line break operation
    private func performInteratomLineBreak() {
      // Reset optimization flag - after breaking, we need to check again
      remainingContentFits = false

      // Flush the current line
      self.addDisplayLine()

      // Calculate dynamic line height based on actual content
      let lineHeight = calculateCurrentLineHeight()

      // Move down for new line using dynamic height
      currentPosition.y -= lineHeight
      currentPosition.x = 0

      // Update line start index for next line
      currentLineStartIndex = displayAtoms.count

      // Reset for new line
      currentLine = NSMutableAttributedString()
      currentAtoms = []
      currentLineIndexRange = NSMakeRange(NSNotFound, NSNotFound)
    }

    // Check if we should break before adding a complex display (fraction, radical, etc.)
    // Returns true if breaking is needed
    func shouldBreakBeforeDisplay(
      _ display: DisplayNode, prevNode: Atom?, displayType: AtomType = .ordinary
    ) -> Bool {
      // No breaking if no width constraint
      guard maxWidth > 0 else { return false }

      // No breaking if line is empty
      guard currentLine.length > 0 else { return false }

      // Calculate spacing between current content and new display
      var interElementSpace: CGFloat = 0
      if prevNode != nil {
        interElementSpace = getInterElementSpace(prevNode!.type, right: displayType)
      }

      // Calculate projected width
      let currentWidth = getCurrentLineWidth()
      let projectedWidth = currentWidth + interElementSpace + display.width

      // Break only if it would exceed max width
      return projectedWidth > maxWidth
    }

    // Adjust the current position to avoid overlap between the new display and previous line's displays
    // This is called when adding displays to a line below the first line
    //
    // Coordinate formulas (from test expectations):
    // - Bottom of display = position.y + descent
    // - Top of display = position.y - ascent
    // - No overlap when: prevBottom <= currTop + spacing
    // - Which means: prevBottom <= (currPosition - currAscent) + spacing
    // - Rearranging: currPosition >= prevBottom + currAscent - spacing
    //
    // Recursively adjust positions of a display and all its nested sub-displays
    // Note: For DisplayRadical and DisplayFraction, their position setters automatically
    // update child positions (radicand/degree, numerator/denominator), so we don't need
    // to manually adjust those. We only need to adjust subdisplays within DisplayList.
    private func adjustDisplayPosition(_ display: DisplayNode, by delta: CGFloat) {
      display.position.y += delta

      // If it's a DisplayList, adjust all its subdisplays too
      if let mathListDisplay = display as? DisplayList {
        for subDisplay in mathListDisplay.children {
          adjustDisplayPosition(subDisplay, by: delta)
        }
      }

      // Note: No special handling needed for DisplayRadical or DisplayFraction
      // Their position setters handle updating child positions automatically
    }

    // Adjust position to avoid overlap with previous line
    // In CoreText's Y-up coordinate system:
    // - Positive Y = upward, Negative Y = downward
    // - Top of display = position + ascent (higher Y)
    // - Bottom of display = position - descent (lower Y)
    // - No overlap when: prevBottom >= currTop (with spacing)
    private func adjustPositionToAvoidOverlap(_ display: DisplayNode) {
      // Find all displays on previous lines and calculate their minimum bottom edge
      // In Y-up: Bottom = position - descent (lower Y value)
      var minBottomEdge: CGFloat = CGFloat.greatestFiniteMagnitude

      for i in 0..<currentLineStartIndex {
        let prevDisplay = displayAtoms[i]
        let bottomEdge = prevDisplay.position.y - prevDisplay.descent
        minBottomEdge = min(minBottomEdge, bottomEdge)
      }

      // Calculate where current top would be
      // In Y-up: Top = position + ascent (higher Y value)
      let currentTop = currentPosition.y + display.ascent

      // Check for overlap: prevBottom should be <= currTop (with spacing)
      // We need prevBottom - spacing >= currTop for no overlap
      let tolerance: CGFloat = 0.5
      let maxAllowedTop = minBottomEdge - tolerance

      if currentTop > maxAllowedTop {
        // Current top is too high, adjust position downward (more negative)
        // We need: position + ascent = maxAllowedTop
        // So: position = maxAllowedTop - ascent
        let requiredPosition = maxAllowedTop - display.ascent
        let delta = requiredPosition - currentPosition.y

        currentPosition.y = requiredPosition

        // Update all displays on this line, including nested subdisplays
        for i in currentLineStartIndex..<displayAtoms.count {
          adjustDisplayPosition(displayAtoms[i], by: delta)
        }
      }
    }

    // Perform line break for complex displays
    func performLineBreak() {
      if currentLine.length > 0 {
        self.addDisplayLine()
      }

      // Calculate dynamic line height based on actual content
      let lineHeight = calculateCurrentLineHeight()

      // Move down for new line using dynamic height
      currentPosition.y -= lineHeight
      currentPosition.x = 0

      // Update line start index for next line
      currentLineStartIndex = displayAtoms.count
    }

    // Calculate the height of the current line based on actual display heights
    // Returns the total height (max ascent + max descent) plus minimum spacing
    func calculateCurrentLineHeight() -> CGFloat {
      // If no displays added for current line, use default spacing
      guard currentLineStartIndex < displayAtoms.count else {
        return styleFont.font.size * 1.5
      }

      var maxAscent: CGFloat = 0
      var maxDescent: CGFloat = 0

      // Iterate through all displays added for the current line
      for i in currentLineStartIndex..<displayAtoms.count {
        let display = displayAtoms[i]
        maxAscent = max(maxAscent, display.ascent)
        maxDescent = max(maxDescent, display.descent)
      }

      // Total line height = max ascent + max descent + minimum spacing
      let lineHeight = maxAscent + maxDescent + minimumLineSpacing

      // Ensure we have at least the baseline fontSize spacing for readability
      return max(lineHeight, styleFont.font.size * 1.2)
    }

    // Estimate the width of an atom including its scripts (without actually creating the displays)
    // This is used for width-checking decisions for atoms with super/subscripts
    func estimateAtomWidthWithScripts(_ atom: Atom) -> CGFloat {
      // Estimate base atom width
      var atomWidth = CGFloat(atom.nucleus.count) * styleFont.font.size * 0.5  // rough estimate

      // If atom has scripts, estimate their contribution
      if atom.superscript != nil || atom.`subscript` != nil {
        let scriptFontSize = Self.getStyleSize(self.scriptStyle(), font: font)

        var scriptWidth: CGFloat = 0
        if let superscript = atom.superscript {
          // Estimate superscript width
          let superScriptAtomCount = superscript.atoms.count
          scriptWidth = max(scriptWidth, CGFloat(superScriptAtomCount) * scriptFontSize * 0.5)
        }

        if let `subscript` = atom.`subscript` {
          // Estimate subscript width
          let subScriptAtomCount = `subscript`.atoms.count
          scriptWidth = max(scriptWidth, CGFloat(subScriptAtomCount) * scriptFontSize * 0.5)
        }

        // Add script width plus space after script
        atomWidth += scriptWidth + styleFont.metrics.spaceAfterScript
      }

      return atomWidth
    }

    // Calculate break penalty score for breaking after a given atom type
    // Lower scores indicate better break points (0 = best, higher = worse)
    func calculateBreakPenalty(afterAtom: Atom?, beforeAtom: Atom?) -> Int {
      // No atom context - neutral penalty
      guard let after = afterAtom else { return 50 }

      let afterType = after.type
      let beforeType = beforeAtom?.type

      // Best break points (penalty = 0): After binary operators, relations, punctuation
      if afterType == .binaryOperator {
        return 0  // Great: break after +, -, ×, ÷
      }
      if afterType == .relation {
        return 0  // Great: break after =, <, >, ≤, ≥
      }
      if afterType == .punctuation {
        return 0  // Great: break after commas, semicolons
      }

      // Good break points (penalty = 10): After ordinary atoms (variables, numbers)
      if afterType == .ordinary {
        return 10  // Good: break after variables like a, b, c
      }

      // Bad break points (penalty = 100): After open brackets or before close brackets
      if afterType == .open {
        return 100  // Bad: don't break immediately after (
      }
      if beforeType == .close {
        return 100  // Bad: don't break immediately before )
      }

      // Worse break points (penalty = 150): Would break operator-operand pairing
      if afterType == .unaryOperator || afterType == .largeOperator {
        return 150  // Worse: don't break after operators like ∑, ∫
      }

      // Neutral default
      return 50
    }

    func createDisplayAtoms(_ preprocessed: [Atom]) {
      // items should contain all the nodes that need to be layed out.
      // convert to a list of DisplayAtoms
      var prevNode: Atom? = nil
      var lastType: AtomType!
      for (index, atom) in preprocessed.enumerated() {
        // Get next atoms for look-ahead (up to 3 atoms ahead)
        let nextAtoms = Array(
          preprocessed.suffix(from: min(index + 1, preprocessed.count)).prefix(3))
        switch atom.type {
        case .number, .variable, .unaryOperator:
          // These should never appear as they should have been removed by preprocessing
          assertionFailure(
            "These types should never show here as they are removed by preprocessing.")

        case .boundary:
          assertionFailure("A boundary atom should never be inside a mathlist.")

        case .space:
          // stash the existing layout
          if currentLine.length > 0 {
            self.addDisplayLine()
          }
          let space = atom as! Space
          // add the desired space
          currentPosition.x += space.amount * styleFont.metrics.mathUnit
          // Since this is extra space, the desired interelement space between the prevAtom
          // and the next node is still preserved. To avoid resetting the prevAtom and lastType
          // we skip to the next node.
          continue

        case .style:
          // stash the existing layout
          if currentLine.length > 0 {
            self.addDisplayLine()
          }
          let style = atom as! Style
          self.style = style.level
          // We need to preserve the prevNode for any interelement space changes.
          // so we skip to the next node.
          continue

        case .color:
          // Create the colored display first (pass maxWidth for inner breaking)
          let colorAtom = atom as! Color
          let display = Typesetter.createLineForMathList(
            colorAtom.innerList, font: font, style: style, maxWidth: maxWidth)
          display!.localTextColor = PlatformColor(fromHexString: colorAtom.colorString)

          // Check if we need to break before adding this colored content
          let shouldBreak = shouldBreakBeforeDisplay(
            display!, prevNode: prevNode, displayType: .ordinary)

          // Flush current line to convert accumulated text to displays
          if currentLine.length > 0 {
            self.addDisplayLine()
          }

          // Perform line break if needed
          if shouldBreak {
            performLineBreak()
          } else {
            self.addInterElementSpace(prevNode, currentType: .ordinary)
          }

          display!.position = currentPosition
          currentPosition.x += display!.width
          displayAtoms.append(display!)

        case .textColor:
          // Create the text colored display first (pass maxWidth for inner breaking)
          let colorAtom = atom as! TextColor
          let display = Typesetter.createLineForMathList(
            colorAtom.innerList, font: font, style: style, maxWidth: maxWidth)
          display!.localTextColor = PlatformColor(fromHexString: colorAtom.colorString)

          // Check if we need to break before adding this colored content
          let shouldBreak = shouldBreakBeforeDisplay(
            display!, prevNode: prevNode, displayType: .ordinary)

          // Flush current line to convert accumulated text to displays
          if currentLine.length > 0 {
            self.addDisplayLine()
          }

          // Perform line break if needed
          if shouldBreak {
            performLineBreak()
          } else if prevNode != nil && display!.children.count > 0 {
            // Handle inter-element spacing if not breaking
            if let subDisplay = display!.children.first,
              let ctLineDisplay = subDisplay as? DisplayTextRun,
              !ctLineDisplay.atoms.isEmpty
            {
              let subDisplayAtom = ctLineDisplay.atoms[0]
              let interElementSpace = self.getInterElementSpace(
                prevNode!.type, right: subDisplayAtom.type)
              // Since we already flushed currentLine, it's empty now, so use x positioning
              currentPosition.x += interElementSpace
            }
          }

          display!.position = currentPosition
          currentPosition.x += display!.width
          displayAtoms.append(display!)

        case .colorBox:
          // Create the colorbox display first (pass maxWidth for inner breaking)
          let colorboxAtom = atom as! ColorBox
          let display = Typesetter.createLineForMathList(
            colorboxAtom.innerList, font: font, style: style, maxWidth: maxWidth)

          display!.localBackgroundColor = PlatformColor(fromHexString: colorboxAtom.colorString)

          // Check if we need to break before adding this colorbox
          let shouldBreak = shouldBreakBeforeDisplay(
            display!, prevNode: prevNode, displayType: .ordinary)

          // Flush current line to convert accumulated text to displays
          if currentLine.length > 0 {
            self.addDisplayLine()
          }

          // Perform line break if needed
          if shouldBreak {
            performLineBreak()
          } else {
            self.addInterElementSpace(prevNode, currentType: .ordinary)
          }

          display!.position = currentPosition
          currentPosition.x += display!.width
          displayAtoms.append(display!)

        case .radical:
          // Create the radical display first
          let rad = atom as! Radical
          let displayRad = self.makeRadical(rad.radicand, range: rad.indexRange)
          if rad.degree != nil {
            // add the degree to the radical
            let degree = Typesetter.createLineForMathList(
              rad.degree, font: font, style: .scriptOfScript)
            displayRad!.setDegree(degree, fontMetrics: styleFont.metrics)
          }

          // Check if we need to break before adding this radical
          // Radicals are considered as Ord in rule 16.
          let shouldBreak = shouldBreakBeforeDisplay(
            displayRad!, prevNode: prevNode, displayType: .ordinary)

          // Flush current line to convert accumulated text to displays
          if currentLine.length > 0 {
            self.addDisplayLine()
          }

          // Perform line break if needed
          if shouldBreak {
            performLineBreak()
          } else {
            self.addInterElementSpace(prevNode, currentType: .ordinary)
          }

          // Position and add the radical display
          displayRad!.position = currentPosition
          displayAtoms.append(displayRad!)

          // Check for overlap if we're not on the first line
          if currentLineStartIndex > 0 {
            adjustPositionToAvoidOverlap(displayRad!)
          }

          currentPosition.x += displayRad!.width

          // add super scripts || subscripts
          if atom.`subscript` != nil || atom.superscript != nil {
            self.makeScripts(
              atom, display: displayRad, index: UInt(rad.indexRange.location), delta: 0)
          }
        // change type to ordinary
        //atom.type = .ordinary;

        case .fraction:
          // Create the fraction display first
          let frac = atom as! Fraction?
          let display = self.makeFraction(frac)

          // Check if we need to break before adding this fraction
          let shouldBreak = shouldBreakBeforeDisplay(
            display!, prevNode: prevNode, displayType: atom.type)

          // Flush current line to convert accumulated text to displays
          if currentLine.length > 0 {
            self.addDisplayLine()
          }

          // Perform line break if needed
          if shouldBreak {
            performLineBreak()
          } else {
            self.addInterElementSpace(prevNode, currentType: atom.type)
          }

          // Position and add the fraction display
          display!.position = currentPosition
          displayAtoms.append(display!)

          // Check for overlap if we're not on the first line
          if currentLineStartIndex > 0 {
            adjustPositionToAvoidOverlap(display!)
          }

          currentPosition.x += display!.width

          // add super scripts || subscripts
          if atom.`subscript` != nil || atom.superscript != nil {
            self.makeScripts(
              atom, display: display, index: UInt(frac!.indexRange.location), delta: 0)
          }

        case .largeOperator:
          // Flush current line to convert accumulated text to displays
          if currentLine.length > 0 {
            self.addDisplayLine()
          }

          // Add inter-element spacing before operator
          self.addInterElementSpace(prevNode, currentType: atom.type)

          // Create and position the large operator display
          // makeLargeOp sets position, advances currentPosition.x, and adds scripts
          let op = atom as! LargeOperator?
          let display = self.makeLargeOp(op)
          displayAtoms.append(display!)

        case .inner:
          // Create the inner display first
          let inner = atom as! Inner?
          var display: DisplayNode? = nil
          if inner!.leftBoundary != nil || inner!.rightBoundary != nil {
            // Pass maxWidth to delimited content so it can also break
            display = self.makeLeftRight(inner, maxWidth: maxWidth)
          } else {
            // Pass maxWidth to inner content so it can also break
            display = Typesetter.createLineForMathList(
              inner!.innerList, font: font, style: style, cramped: cramped, maxWidth: maxWidth)
          }

          // Check if we need to break before adding this inner content
          let shouldBreak = shouldBreakBeforeDisplay(
            display!, prevNode: prevNode, displayType: .inner)

          // Flush current line to convert accumulated text to displays
          if currentLine.length > 0 {
            self.addDisplayLine()
          }

          // Perform line break if needed
          if shouldBreak {
            performLineBreak()
          } else {
            self.addInterElementSpace(prevNode, currentType: atom.type)
          }

          // Position and add the inner display
          display!.position = currentPosition
          currentPosition.x += display!.width
          displayAtoms.append(display!)

          // add super scripts || subscripts
          if atom.`subscript` != nil || atom.superscript != nil {
            self.makeScripts(
              atom, display: display, index: UInt(atom.indexRange.location), delta: 0)
          }

        case .underline:
          // stash the existing layout
          if currentLine.length > 0 {
            self.addDisplayLine()
          }
          // Underline is considered as Ord in rule 16.
          self.addInterElementSpace(prevNode, currentType: .ordinary)
          atom.type = .ordinary

          let under = atom as! Underline?
          let display = self.makeUnderline(under)
          displayAtoms.append(display!)
          currentPosition.x += display!.width
          // add super scripts || subscripts
          if atom.`subscript` != nil || atom.superscript != nil {
            self.makeScripts(
              atom, display: display, index: UInt(atom.indexRange.location), delta: 0)
          }

        case .overline:
          // stash the existing layout
          if currentLine.length > 0 {
            self.addDisplayLine()
          }
          // Overline is considered as Ord in rule 16.
          self.addInterElementSpace(prevNode, currentType: .ordinary)
          atom.type = .ordinary

          let over = atom as! Overline?
          let display = self.makeOverline(over)
          displayAtoms.append(display!)
          currentPosition.x += display!.width
          // add super scripts || subscripts
          if atom.`subscript` != nil || atom.superscript != nil {
            self.makeScripts(
              atom, display: display, index: UInt(atom.indexRange.location), delta: 0)
          }

        case .accent:
          if maxWidth > 0 {
            // When line wrapping is enabled, render the accent properly but inline
            // to avoid premature line flushing

            let accent = atom as! Accent

            // Get the base character from innerList
            var baseChar = ""
            if let innerList = accent.innerList, !innerList.atoms.isEmpty {
              // Convert innerList to string
              baseChar = Math.Parser.atomListToString(innerList)
            }

            // Combine base character with accent to create proper composed character
            let accentChar = atom.nucleus
            let composedString = baseChar + accentChar

            // Normalize to composed form (NFC) to get proper accented character
            let normalizedString = composedString.precomposedStringWithCanonicalMapping

            // Add inter-element spacing
            if prevNode != nil {
              let interElementSpace = self.getInterElementSpace(prevNode!.type, right: .ordinary)
              if currentLine.length > 0 {
                if interElementSpace > 0 {
                  currentLine.addAttribute(
                    kCTKernAttributeName as NSAttributedString.Key,
                    value: NSNumber(floatLiteral: interElementSpace),
                    range: currentLine.mutableString.rangeOfComposedCharacterSequence(
                      at: currentLine.length - 1))
                }
              } else {
                currentPosition.x += interElementSpace
              }
            }

            // Add the properly composed accented character
            let current = NSAttributedString(string: normalizedString)
            currentLine.append(current)

            // Don't check for line breaks here - accented characters are part of words
            // and breaking after each one would split words like "équivaut" into "é" + "quivaut"
            // Line breaking is handled in the regular .ordinary case below

            // Add to atom list
            if currentLineIndexRange.location == NSNotFound {
              currentLineIndexRange = atom.indexRange
            } else {
              currentLineIndexRange.length += atom.indexRange.length
            }
            currentAtoms.append(atom)

            // Treat accent as ordinary for spacing purposes
            atom.type = .ordinary
          } else {
            // Original behavior when no width constraint
            // Check if we need to break the line due to width constraints
            self.checkAndBreakLine()
            // stash the existing layout
            if currentLine.length > 0 {
              self.addDisplayLine()
            }
            // Accent is considered as Ord in rule 16.
            self.addInterElementSpace(prevNode, currentType: .ordinary)
            atom.type = .ordinary

            let accent = atom as! Accent?
            let display = self.makeAccent(accent)
            displayAtoms.append(display!)
            currentPosition.x += display!.width

            // add super scripts || subscripts
            if atom.`subscript` != nil || atom.superscript != nil {
              self.makeScripts(
                atom, display: display, index: UInt(atom.indexRange.location), delta: 0)
            }
          }

        case .table:
          // Create the table display first
          let table = atom as! Table?
          let display = self.makeTable(table)

          // Check if we need to break before adding this table
          // We will consider tables as inner
          let shouldBreak = shouldBreakBeforeDisplay(
            display!, prevNode: prevNode, displayType: .inner)

          // Flush current line to convert accumulated text to displays
          if currentLine.length > 0 {
            self.addDisplayLine()
          }

          // Perform line break if needed
          if shouldBreak {
            performLineBreak()
          } else {
            self.addInterElementSpace(prevNode, currentType: .inner)
          }
          atom.type = .inner

          display!.position = currentPosition
          displayAtoms.append(display!)
          currentPosition.x += display!.width
        // A table doesn't have subscripts or superscripts

        case .ordinary, .binaryOperator, .relation, .open, .close, .placeholder, .punctuation:
          // the rendering for all the rest is pretty similar
          // All we need is render the character and set the interelement space.

          // INTERATOM LINE BREAKING: Check if we need to break before adding this atom
          // Pass nextAtoms for look-ahead to find better break points
          checkAndPerformInteratomLineBreak(atom, prevNode: prevNode, nextAtoms: nextAtoms)

          if prevNode != nil {
            let interElementSpace = self.getInterElementSpace(prevNode!.type, right: atom.type)
            if currentLine.length > 0 {
              if interElementSpace > 0 {
                // add a kerning of that space to the previous character
                currentLine.addAttribute(
                  kCTKernAttributeName as NSAttributedString.Key,
                  value: NSNumber(floatLiteral: interElementSpace),
                  range: currentLine.mutableString.rangeOfComposedCharacterSequence(
                    at: currentLine.length - 1))
              }
            } else {
              // increase the space
              currentPosition.x += interElementSpace
            }
          }
          var current: NSAttributedString? = nil
          if atom.type == .placeholder {
            let color = Typesetter.placeholderColor
            current = NSAttributedString(
              string: atom.nucleus,
              attributes: [kCTForegroundColorAttributeName as NSAttributedString.Key: color.cgColor]
            )
          } else {
            current = NSAttributedString(string: atom.nucleus)
          }

          currentLine.append(current!)

          // Universal line breaking: only for simple atoms (no scripts)
          // This works for text, mixed text+math, and simple equations
          let isSimpleAtom = (atom.`subscript` == nil && atom.superscript == nil)

          if isSimpleAtom && maxWidth > 0 {
            // Measure the current line width
            let attrString = currentLine.mutableCopy() as! NSMutableAttributedString
            attrString.addAttribute(
              kCTFontAttributeName as NSAttributedString.Key, value: styleFont.ctFont as Any,
              range: NSMakeRange(0, attrString.length))
            let ctLine = CTLineCreateWithAttributedString(attrString)
            let segmentWidth = CGFloat(CTLineGetTypographicBounds(ctLine, nil, nil, nil))

            // IMPORTANT: Account for currentPosition.x to get the true visual line width
            // After superscripts/subscripts, currentPosition.x > 0 because previous segments
            // have been rendered and flushed
            let visualLineWidth = currentPosition.x + segmentWidth

            if visualLineWidth > maxWidth {
              // Line is too wide - need to find a break point
              let currentText = currentLine.string

              // Use Unicode-aware line breaking with number protection
              // IMPORTANT: Use remaining width, not full maxWidth, because currentPosition.x
              // may be > 0 if we've already rendered segments on this visual line
              let remainingWidth = max(0, maxWidth - currentPosition.x)
              if let breakIndex = findBestBreakPoint(
                in: currentText, font: styleFont.ctFont, maxWidth: remainingWidth)
              {
                // Split the line at the suggested break point
                let breakOffset = currentText.distance(from: currentText.startIndex, to: breakIndex)

                // Create attributed string for the first line
                let firstLine = NSMutableAttributedString(
                  string: String(currentText.prefix(breakOffset)))
                firstLine.addAttribute(
                  kCTFontAttributeName as NSAttributedString.Key, value: styleFont.ctFont as Any,
                  range: NSMakeRange(0, firstLine.length))

                // Check if first line still exceeds remaining width - need to find earlier break point
                let firstLineCT = CTLineCreateWithAttributedString(firstLine)
                let firstLineWidth = CGFloat(CTLineGetTypographicBounds(firstLineCT, nil, nil, nil))

                if firstLineWidth > remainingWidth {
                  // Need to break earlier - find previous break point
                  let firstLineText = firstLine.string
                  if let earlierBreakIndex = findBestBreakPoint(
                    in: firstLineText, font: styleFont.ctFont, maxWidth: remainingWidth)
                  {
                    let earlierOffset = firstLineText.distance(
                      from: firstLineText.startIndex, to: earlierBreakIndex)
                    let earlierLine = NSMutableAttributedString(
                      string: String(firstLineText.prefix(earlierOffset)))
                    earlierLine.addAttribute(
                      kCTFontAttributeName as NSAttributedString.Key,
                      value: styleFont.ctFont as Any, range: NSMakeRange(0, earlierLine.length))

                    // Flush the earlier line
                    currentLine = earlierLine
                    currentAtoms = []  // Approximate - we're splitting
                    self.addDisplayLine()

                    // Reset optimization flag after line break
                    remainingContentFits = false

                    // Calculate dynamic line height and move down for new line
                    let lineHeight = calculateCurrentLineHeight()
                    currentPosition.y -= lineHeight
                    currentPosition.x = 0
                    currentLineStartIndex = displayAtoms.count

                    // Remaining text includes everything after the earlier break
                    let remainingText =
                      String(firstLineText.suffix(from: earlierBreakIndex))
                      + String(currentText.suffix(from: breakIndex))
                    currentLine = NSMutableAttributedString(string: remainingText)
                    currentAtoms = []
                    currentLineIndexRange = NSMakeRange(NSNotFound, NSNotFound)
                  }
                } else {
                  // First line fits - proceed with normal wrapping
                  // Keep track of atoms that belong to the first line
                  let firstLineAtoms = currentAtoms

                  // Flush the first line
                  currentLine = firstLine
                  currentAtoms = firstLineAtoms
                  self.addDisplayLine()

                  // Reset optimization flag after line break
                  remainingContentFits = false

                  // Calculate dynamic line height and move down for new line
                  let lineHeight = calculateCurrentLineHeight()
                  currentPosition.y -= lineHeight
                  currentPosition.x = 0
                  currentLineStartIndex = displayAtoms.count

                  // Start the new line with the content after the break
                  let remainingText = String(currentText.suffix(from: breakIndex))
                  currentLine = NSMutableAttributedString(string: remainingText)

                  // Reset atom list for new line
                  currentAtoms = []
                  currentLineIndexRange = NSMakeRange(NSNotFound, NSNotFound)
                }
              }
              // If no break point found, let it overflow (better than breaking mid-word)
            }
          }

          // Check if atom with scripts would exceed width constraint (improved script handling)
          if maxWidth > 0 && (atom.`subscript` != nil || atom.superscript != nil)
            && currentLine.length > 0
          {
            // Estimate width including scripts
            let atomWidthWithScripts = estimateAtomWidthWithScripts(atom)
            let interElementSpace = self.getInterElementSpace(
              prevNode?.type ?? .ordinary, right: atom.type)
            let currentWidth = getCurrentLineWidth()
            let projectedWidth = currentWidth + interElementSpace + atomWidthWithScripts

            // If adding this scripted atom would exceed width, break line first
            if projectedWidth > maxWidth {
              self.addDisplayLine()
              let lineHeight = calculateCurrentLineHeight()
              currentPosition.y -= lineHeight
              currentPosition.x = 0
              currentLineStartIndex = displayAtoms.count
            }
          }

          // add the atom to the current range
          if currentLineIndexRange.location == NSNotFound {
            currentLineIndexRange = atom.indexRange
          } else {
            currentLineIndexRange.length += atom.indexRange.length
          }
          // add the fused atoms
          if !atom.fusedAtoms.isEmpty {
            currentAtoms.append(contentsOf: atom.fusedAtoms)  //.addObjectsFromArray:atom.fusedAtoms)
          } else {
            currentAtoms.append(atom)
          }

          // add super scripts || subscripts
          if atom.`subscript` != nil || atom.superscript != nil {
            // stash the existing line
            // We don't check currentLine.length here since we want to allow empty lines with super/sub scripts.
            let line = self.addDisplayLine()
            var delta = CGFloat(0)
            if !atom.nucleus.isEmpty {
              // Use the italic correction of the last character.
              let index = atom.nucleus.index(before: atom.nucleus.endIndex)
              let glyph = self.findGlyphForCharacterAtIndex(index, inString: atom.nucleus)
              delta = styleFont.metrics.italicCorrection(forGlyph: glyph)
            }
            if delta > 0 && atom.`subscript` == nil {
              // Add a kern of delta
              currentPosition.x += delta
            }
            self.makeScripts(
              atom, display: line, index: UInt(NSMaxRange(atom.indexRange) - 1), delta: delta)
          }
        }  // switch
        lastType = atom.type
        prevNode = atom
      }  // node loop
      if currentLine.length > 0 {
        self.addDisplayLine()
      }
      if spaced && lastType != nil {
        // If spaced then add an interelement space between the last type and close
        let display = displayAtoms.last
        let interElementSpace = self.getInterElementSpace(lastType, right: .close)
        display?.width += interElementSpace
      }
    }

    // MARK: - Unicode-aware Line Breaking

    // Find the best break point using Core Text, with conservative number protection
    func findBestBreakPoint(in text: String, font: CTFont, maxWidth: CGFloat) -> String.Index? {
      let attributes: [NSAttributedString.Key: Any] = [
        kCTFontAttributeName as NSAttributedString.Key: font
      ]
      let attrString = NSAttributedString(string: text, attributes: attributes)
      let typesetter = CTTypesetterCreateWithAttributedString(attrString as CFAttributedString)
      let suggestedBreak = CTTypesetterSuggestLineBreak(typesetter, 0, Double(maxWidth))

      guard suggestedBreak > 0 else {
        return nil
      }

      // IMPORTANT: CTTypesetterSuggestLineBreak returns a UTF-16 code unit offset,
      // but Swift String.Index works with Unicode extended grapheme clusters.
      // We must convert from UTF-16 space to String.Index properly to avoid
      // breaking in the middle of Unicode characters (like "é" in "équivaut").

      // Convert UTF-16 offset to String.Index
      guard
        let utf16Index = text.utf16.index(
          text.utf16.startIndex, offsetBy: suggestedBreak, limitedBy: text.utf16.endIndex),
        let breakIndex = String.Index(utf16Index, within: text)
      else {
        return nil
      }

      // Conservative check: verify we're not breaking within a number
      if isBreakingSafeForNumbers(text: text, breakIndex: breakIndex) {
        return breakIndex
      }

      // If the suggested break would split a number, find the previous safe break point
      return findPreviousSafeBreak(in: text, before: breakIndex)
    }

    // Check if breaking at this index would split a number
    func isBreakingSafeForNumbers(text: String, breakIndex: String.Index) -> Bool {
      guard breakIndex > text.startIndex && breakIndex < text.endIndex else {
        return true
      }

      // Check a small window around the break point
      let beforeIndex = text.index(before: breakIndex)
      let charBefore = text[beforeIndex]
      let charAfter = text[breakIndex]

      // Number separators in various locales
      let numberSeparators: Set<Character> = [
        ".", ",",  // Decimal/thousands (EN/FR)
        "'",  // Thousands (CH)
        "\u{00A0}",  // Non-breaking space (FR thousands)
        "\u{2009}",  // Thin space (sometimes used)
        "\u{202F}",  // Narrow no-break space (FR)
      ]

      // Pattern 1: digit + separator + digit (e.g., "3.14" or "3,14")
      if charBefore.isNumber && numberSeparators.contains(charAfter) {
        // Check if there's a digit after the separator
        let nextIndex = text.index(after: breakIndex)
        if nextIndex < text.endIndex && text[nextIndex].isNumber {
          return false  // Don't break: this looks like "3.|14"
        }
      }

      // Pattern 2: separator + digit, check if previous is digit
      if numberSeparators.contains(charBefore) && charAfter.isNumber {
        // Check if there's a digit before the separator
        if beforeIndex > text.startIndex {
          let prevIndex = text.index(before: beforeIndex)
          if text[prevIndex].isNumber {
            return false  // Don't break: this looks like "3,|14"
          }
        }
      }

      // Pattern 3: digit + digit (shouldn't happen with CTTypesetter, but be safe)
      if charBefore.isNumber && charAfter.isNumber {
        return false  // Don't break within consecutive digits
      }

      // Pattern 4: digit + space + digit (French: "1 000 000")
      if charBefore.isNumber && charAfter.isWhitespace {
        let nextIndex = text.index(after: breakIndex)
        if nextIndex < text.endIndex && text[nextIndex].isNumber {
          return false  // Don't break: this looks like "1 |000"
        }
      }

      return true  // Safe to break
    }

    // Find previous safe break point before the given index
    func findPreviousSafeBreak(in text: String, before breakIndex: String.Index) -> String.Index? {
      var currentIndex = breakIndex

      // Walk backwards to find a space or safe break
      while currentIndex > text.startIndex {
        currentIndex = text.index(before: currentIndex)

        // Prefer breaking at whitespace (safest option)
        if text[currentIndex].isWhitespace {
          return text.index(after: currentIndex)  // Break after the space
        }

        // Check if this would be safe
        if isBreakingSafeForNumbers(text: text, breakIndex: currentIndex) {
          return currentIndex
        }
      }

      return nil
    }

    // Check if the current line exceeds maxWidth and break if needed
    func checkAndBreakLine() {
      guard maxWidth > 0 && currentLine.length > 0 else { return }

      // Measure the current line width
      let attrString = currentLine.mutableCopy() as! NSMutableAttributedString
      attrString.addAttribute(
        kCTFontAttributeName as NSAttributedString.Key, value: styleFont.ctFont as Any,
        range: NSMakeRange(0, attrString.length))
      let ctLine = CTLineCreateWithAttributedString(attrString)
      let lineWidth = CGFloat(CTLineGetTypographicBounds(ctLine, nil, nil, nil))

      guard lineWidth > maxWidth else { return }

      // Line is too wide - need to find a break point
      let currentText = currentLine.string

      // Use Unicode-aware line breaking with number protection
      if let breakIndex = findBestBreakPoint(
        in: currentText, font: styleFont.ctFont, maxWidth: maxWidth)
      {
        // Split the line at the suggested break point
        let breakOffset = currentText.distance(from: currentText.startIndex, to: breakIndex)

        // Create attributed string for the first line
        let firstLine = NSMutableAttributedString(string: String(currentText.prefix(breakOffset)))
        firstLine.addAttribute(
          kCTFontAttributeName as NSAttributedString.Key, value: styleFont.ctFont as Any,
          range: NSMakeRange(0, firstLine.length))

        // Check if first line still exceeds maxWidth - need to find earlier break point
        let firstLineCT = CTLineCreateWithAttributedString(firstLine)
        let firstLineWidth = CGFloat(CTLineGetTypographicBounds(firstLineCT, nil, nil, nil))

        if firstLineWidth > maxWidth {
          // Need to break earlier - find previous break point
          let firstLineText = firstLine.string
          if let earlierBreakIndex = findBestBreakPoint(
            in: firstLineText, font: styleFont.ctFont, maxWidth: maxWidth)
          {
            let earlierOffset = firstLineText.distance(
              from: firstLineText.startIndex, to: earlierBreakIndex)
            let earlierLine = NSMutableAttributedString(
              string: String(firstLineText.prefix(earlierOffset)))
            earlierLine.addAttribute(
              kCTFontAttributeName as NSAttributedString.Key, value: styleFont.ctFont as Any,
              range: NSMakeRange(0, earlierLine.length))

            // Flush the earlier line
            currentLine = earlierLine
            currentAtoms = []
            self.addDisplayLine()

            // Calculate dynamic line height and move down for new line
            let lineHeight = calculateCurrentLineHeight()
            currentPosition.y -= lineHeight
            currentPosition.x = 0
            currentLineStartIndex = displayAtoms.count

            // Remaining text includes everything after the earlier break
            let remainingText =
              String(firstLineText.suffix(from: earlierBreakIndex))
              + String(currentText.suffix(from: breakIndex))
            currentLine = NSMutableAttributedString(string: remainingText)
            currentAtoms = []
            currentLineIndexRange = NSMakeRange(NSNotFound, NSNotFound)
            return
          }
        }

        // Keep track of atoms that belong to the first line
        let firstLineAtoms = currentAtoms

        // Flush the first line
        currentLine = firstLine
        currentAtoms = firstLineAtoms
        self.addDisplayLine()

        // Calculate dynamic line height and move down for new line
        let lineHeight = calculateCurrentLineHeight()
        currentPosition.y -= lineHeight
        currentPosition.x = 0
        currentLineStartIndex = displayAtoms.count

        // Start the new line with the content after the break
        let remainingText = String(currentText.suffix(from: breakIndex))
        currentLine = NSMutableAttributedString(string: remainingText)

        // Reset atom list for new line
        currentAtoms = []
        currentLineIndexRange = NSMakeRange(NSNotFound, NSNotFound)
      }
    }

    @discardableResult
    func addDisplayLine() -> DisplayTextRun? {
      // add the font
      currentLine.addAttribute(
        kCTFontAttributeName as NSAttributedString.Key, value: styleFont.ctFont as Any,
        range: NSMakeRange(0, currentLine.length))
      /*assert(currentLineIndexRange.length == numCodePoints(currentLine.string),
       "The length of the current line: %@ does not match the length of the range (%d, %d)",
       currentLine, currentLineIndexRange.location, currentLineIndexRange.length);*/

      let line = CTLineCreateWithAttributedString(currentLine)
      let displayAtom = DisplayTextRun(
        text: currentLine.string,
        font: styleFont.font,
        position: currentPosition,
        range: currentLineIndexRange,
        atoms: currentAtoms
      )
      let width = CTLineGetTypographicBounds(line, nil, nil, nil)
      let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
      displayAtom.width = width
      displayAtom.ascent = max(0, bounds.maxY)
      displayAtom.descent = max(0, 0 - bounds.minY)
      self.displayAtoms.append(displayAtom)
      // update the position
      currentPosition.x += displayAtom.width
      // clear the string and the range
      currentLine = NSMutableAttributedString()
      currentAtoms = [Atom]()
      currentLineIndexRange = NSMakeRange(NSNotFound, NSNotFound)
      return displayAtom
    }

    // MARK: - Spacing

    // Returned in units of mu = 1/18 em.
    private func getSpacingInMu(_ type: InterElementSpaceType) -> Int {
      // let valid = [Style.Level.display, .text]
      switch type {
      case .invalid: return -1
      case .none: return 0
      case .thin: return 3
      case .nsThin: return style.isNotScript ? 3 : 0
      case .nsMedium: return style.isNotScript ? 4 : 0
      case .nsThick: return style.isNotScript ? 5 : 0
      }
    }

    func getInterElementSpace(_ left: AtomType, right: AtomType) -> CGFloat {
      let leftIndex = getInterElementSpaceArrayIndexForType(left, row: true)
      let rightIndex = getInterElementSpaceArrayIndexForType(right, row: false)
      let spaceArray = getInterElementSpaces()[Int(leftIndex)]
      let spaceTypeObj = spaceArray[Int(rightIndex)]
      let spaceType = spaceTypeObj
      assert(spaceType != .invalid, "Invalid space between \(left) and \(right)")

      let spaceMultipler = self.getSpacingInMu(spaceType)
      if spaceMultipler > 0 {
        // 1 em = size of font in pt. space multipler is in multiples mu or 1/18 em
        return CGFloat(spaceMultipler) * styleFont.metrics.mathUnit
      }
      return 0
    }

    // MARK: - Subscript/Superscript

    func scriptStyle() -> Style.Level {
      switch style {
      case .display, .text: return .script
      case .script, .scriptOfScript: return .scriptOfScript
      }
    }

    // subscript is always cramped
    func subscriptCramped() -> Bool { true }

    // superscript is cramped only if the current style is cramped
    func superScriptCramped() -> Bool { cramped }

    func superScriptShiftUp() -> CGFloat {
      if cramped {
        return styleFont.metrics.superscriptShiftUpCramped
      } else {
        return styleFont.metrics.superscriptShiftUp
      }
    }

    // make scripts for the last atom
    // index is the index of the element which is getting the sub/super scripts.
    func makeScripts(_ atom: Atom?, display: DisplayNode?, index: UInt, delta: CGFloat) {
      assert(atom!.`subscript` != nil || atom!.superscript != nil)

      var superScriptShiftUp = 0.0
      var subscriptShiftDown = 0.0

      display?.hasScript = true
      if !(display is DisplayTextRun) {
        // get the font in script style
        let scriptFontSize = Self.getStyleSize(self.scriptStyle(), font: font)
        let scriptFont = font.withSize(scriptFontSize)
        let scriptFontMetrics = scriptFont.metrics

        // if it is not a simple line then
        superScriptShiftUp = display!.ascent - scriptFontMetrics.superscriptBaselineDropMax
        subscriptShiftDown = display!.descent + scriptFontMetrics.subscriptBaselineDropMin
      }

      if atom!.superscript == nil {
        assert(atom!.`subscript` != nil)
        let _subscript = Typesetter.createLineForMathList(
          atom!.`subscript`, font: font, style: self.scriptStyle(), cramped: self.subscriptCramped()
        )
        _subscript?.linePosition = .`subscript`
        _subscript?.index = Int(index)

        subscriptShiftDown = fmax(subscriptShiftDown, styleFont.metrics.subscriptShiftDown)
        subscriptShiftDown = fmax(
          subscriptShiftDown, _subscript!.ascent - styleFont.metrics.subscriptTopMax)
        // add the subscript
        _subscript?.position = CGPointMake(
          currentPosition.x, currentPosition.y - subscriptShiftDown)
        displayAtoms.append(_subscript!)
        // update the position
        currentPosition.x += _subscript!.width + styleFont.metrics.spaceAfterScript
        return
      }

      let superscript = Typesetter.createLineForMathList(
        atom!.superscript, font: font, style: self.scriptStyle(), cramped: self.superScriptCramped()
      )
      superscript!.linePosition = .superscript
      superscript!.index = Int(index)
      superScriptShiftUp = fmax(superScriptShiftUp, self.superScriptShiftUp())
      superScriptShiftUp = fmax(
        superScriptShiftUp, superscript!.descent + styleFont.metrics.superscriptBottomMin)

      if atom!.`subscript` == nil {
        superscript!.position = CGPointMake(
          currentPosition.x, currentPosition.y + superScriptShiftUp)
        displayAtoms.append(superscript!)
        // update the position
        currentPosition.x += superscript!.width + styleFont.metrics.spaceAfterScript
        return
      }
      let ssubscript = Typesetter.createLineForMathList(
        atom!.`subscript`, font: font, style: self.scriptStyle(), cramped: self.subscriptCramped())
      ssubscript!.linePosition = .`subscript`
      ssubscript!.index = Int(index)
      subscriptShiftDown = fmax(subscriptShiftDown, styleFont.metrics.subscriptShiftDown)

      // joint positioning of subscript & superscript
      let subSuperScriptGap =
        (superScriptShiftUp - superscript!.descent) + (subscriptShiftDown - ssubscript!.ascent)
      if subSuperScriptGap < styleFont.metrics.subSuperscriptGapMin {
        // Set the gap to atleast as much
        subscriptShiftDown += styleFont.metrics.subSuperscriptGapMin - subSuperScriptGap
        let superscriptBottomDelta =
          styleFont.metrics.superscriptBottomMaxWithSubscript
          - (superScriptShiftUp - superscript!.descent)
        if superscriptBottomDelta > 0 {
          // superscript is lower than the max allowed by the font with a subscript.
          superScriptShiftUp += superscriptBottomDelta
          subscriptShiftDown -= superscriptBottomDelta
        }
      }
      // The delta is the italic correction above that shift superscript position
      superscript?.position = CGPointMake(
        currentPosition.x + delta, currentPosition.y + superScriptShiftUp)
      displayAtoms.append(superscript!)
      ssubscript?.position = CGPointMake(currentPosition.x, currentPosition.y - subscriptShiftDown)
      displayAtoms.append(ssubscript!)
      currentPosition.x +=
        max(superscript!.width + delta, ssubscript!.width) + styleFont.metrics.spaceAfterScript
    }

    // MARK: - Fractions

    func numeratorShiftUp(_ hasRule: Bool) -> CGFloat {
      if hasRule {
        if style == .display {
          return styleFont.metrics.fractionNumeratorDisplayStyleShiftUp
        } else {
          return styleFont.metrics.fractionNumeratorShiftUp
        }
      } else {
        if style == .display {
          return styleFont.metrics.stackTopDisplayStyleShiftUp
        } else {
          return styleFont.metrics.stackTopShiftUp
        }
      }
    }

    func numeratorGapMin() -> CGFloat {
      if style == .display {
        return styleFont.metrics.fractionNumeratorDisplayStyleGapMin
      } else {
        return styleFont.metrics.fractionNumeratorGapMin
      }
    }

    func denominatorShiftDown(_ hasRule: Bool) -> CGFloat {
      if hasRule {
        if style == .display {
          return styleFont.metrics.fractionDenominatorDisplayStyleShiftDown
        } else {
          return styleFont.metrics.fractionDenominatorShiftDown
        }
      } else {
        if style == .display {
          return styleFont.metrics.stackBottomDisplayStyleShiftDown
        } else {
          return styleFont.metrics.stackBottomShiftDown
        }
      }
    }

    func denominatorGapMin() -> CGFloat {
      if style == .display {
        return styleFont.metrics.fractionDenominatorDisplayStyleGapMin
      } else {
        return styleFont.metrics.fractionDenominatorGapMin
      }
    }

    func stackGapMin() -> CGFloat {
      if style == .display {
        return styleFont.metrics.stackDisplayStyleGapMin
      } else {
        return styleFont.metrics.stackGapMin
      }
    }

    func fractionDelimiterHeight() -> CGFloat {
      if style == .display {
        return styleFont.metrics.fractionDelimiterDisplayStyleSize
      } else {
        return styleFont.metrics.fractionDelimiterSize
      }
    }

    func fractionStyle() -> Style.Level {
      // Keep fractions at the same style level instead of incrementing.
      // This ensures that fraction numerators/denominators have the same
      // font size as regular text, preventing them from appearing too small
      // in inline mode or when nested.
      return style
    }

    func makeFraction(_ frac: Fraction?) -> DisplayNode? {
      // lay out the parts of the fraction
      let numeratorStyle: Style.Level
      let denominatorStyle: Style.Level

      if frac!.isContinuedFraction {
        // Continued fractions always use display style
        numeratorStyle = .display
        denominatorStyle = .display
      } else {
        // Regular fractions use adaptive style
        let fractionStyle = self.fractionStyle
        numeratorStyle = fractionStyle()
        denominatorStyle = fractionStyle()
      }

      let numeratorDisplay = Typesetter.createLineForMathList(
        frac!.numerator, font: font, style: numeratorStyle, cramped: false)
      let denominatorDisplay = Typesetter.createLineForMathList(
        frac!.denominator, font: font, style: denominatorStyle, cramped: true)

      // determine the location of the numerator
      var numeratorShiftUp = self.numeratorShiftUp(frac!.hasRule)
      var denominatorShiftDown = self.denominatorShiftDown(frac!.hasRule)
      let barLocation = styleFont.metrics.axisHeight
      let barThickness = frac!.hasRule ? styleFont.metrics.fractionRuleThickness : 0

      if frac!.hasRule {
        // This is the difference between the lowest edge of the numerator and the top edge of the fraction bar
        let distanceFromNumeratorToBar =
          (numeratorShiftUp - numeratorDisplay!.descent) - (barLocation + barThickness / 2)
        // The distance should at least be displayGap
        let minNumeratorGap = self.numeratorGapMin
        if distanceFromNumeratorToBar < minNumeratorGap() {
          // This makes the distance between the bottom of the numerator and the top edge of the fraction bar
          // at least minNumeratorGap.
          numeratorShiftUp += (minNumeratorGap() - distanceFromNumeratorToBar)
        }

        // Do the same for the denominator
        // This is the difference between the top edge of the denominator and the bottom edge of the fraction bar
        let distanceFromDenominatorToBar =
          (barLocation - barThickness / 2) - (denominatorDisplay!.ascent - denominatorShiftDown)
        // The distance should at least be denominator gap
        let minDenominatorGap = self.denominatorGapMin
        if distanceFromDenominatorToBar < minDenominatorGap() {
          // This makes the distance between the top of the denominator and the bottom of the fraction bar to be exactly
          // minDenominatorGap
          denominatorShiftDown += (minDenominatorGap() - distanceFromDenominatorToBar)
        }
      } else {
        // This is the distance between the numerator and the denominator
        let clearance =
          (numeratorShiftUp - numeratorDisplay!.descent)
          - (denominatorDisplay!.ascent - denominatorShiftDown)
        // This is the minimum clearance between the numerator and denominator.
        let minGap = self.stackGapMin()
        if clearance < minGap {
          numeratorShiftUp += (minGap - clearance) / 2
          denominatorShiftDown += (minGap - clearance) / 2
        }
      }

      let display = DisplayFraction(
        numerator: numeratorDisplay, denominator: denominatorDisplay, position: currentPosition,
        range: frac!.indexRange)

      display.numeratorUp = numeratorShiftUp
      display.denominatorDown = denominatorShiftDown
      display.lineThickness = barThickness
      display.linePosition = barLocation
      if frac!.leftDelimiter.isEmpty && frac!.rightDelimiter.isEmpty {
        return display
      } else {
        return self.addDelimitersToFractionDisplay(display, forFraction: frac)
      }
    }

    func addDelimitersToFractionDisplay(_ display: DisplayFraction?, forFraction frac: Fraction?)
      -> DisplayNode?
    {
      assert(
        !frac!.leftDelimiter.isEmpty || !frac!.rightDelimiter.isEmpty,
        "Fraction should have a delimiters to call this function")

      var innerElements = [DisplayNode]()
      let glyphHeight = self.fractionDelimiterHeight
      var position = CGPoint.zero
      if !frac!.leftDelimiter.isEmpty {
        let leftGlyph = self.findGlyphForBoundary(frac!.leftDelimiter, withHeight: glyphHeight())
        leftGlyph!.position = position
        position.x += leftGlyph!.width
        innerElements.append(leftGlyph!)
      }

      display!.position = position
      position.x += display!.width
      innerElements.append(display!)

      if !frac!.rightDelimiter.isEmpty {
        let rightGlyph = self.findGlyphForBoundary(frac!.rightDelimiter, withHeight: glyphHeight())
        rightGlyph!.position = position
        position.x += rightGlyph!.width
        innerElements.append(rightGlyph!)
      }
      let innerDisplay = DisplayList(children: innerElements, range: frac!.indexRange)
      innerDisplay.position = currentPosition
      return innerDisplay
    }

    // MARK: - Radicals

    func radicalVerticalGap() -> CGFloat {
      if style == .display {
        return styleFont.metrics.radicalDisplayStyleVerticalGap
      } else {
        return styleFont.metrics.radicalVerticalGap
      }
    }

    func getRadicalGlyphWithHeight(_ radicalHeight: CGFloat) -> DisplayShiftedNode? {
      var glyphAscent = CGFloat(0)
      var glyphDescent = CGFloat(0)
      var glyphWidth = CGFloat(0)

      let radicalGlyph = self.findGlyphForCharacterAtIndex(
        "\u{221A}".startIndex, inString: "\u{221A}")
      let glyph = self.findGlyph(
        radicalGlyph, withHeight: radicalHeight, glyphAscent: &glyphAscent,
        glyphDescent: &glyphDescent, glyphWidth: &glyphWidth)

      var glyphDisplay: DisplayShiftedNode?
      if glyphAscent + glyphDescent < radicalHeight {
        // the glyphs is not as large as required. A glyph needs to be constructed using the extenders.
        glyphDisplay = self.constructGlyph(radicalGlyph, withHeight: radicalHeight)
      }

      if glyphDisplay == nil {
        // No constructed display so use the glyph we got.
        glyphDisplay = DisplayGlyph(
          glyph: glyph, font: styleFont.font, range: NSMakeRange(NSNotFound, 0))
        glyphDisplay!.ascent = glyphAscent
        glyphDisplay!.descent = glyphDescent
        glyphDisplay!.width = glyphWidth
      }
      return glyphDisplay
    }

    func makeRadical(_ radicand: AtomList?, range: NSRange) -> DisplayRadical? {
      let innerDisplay = Typesetter.createLineForMathList(
        radicand, font: font, style: style, cramped: true)!
      var clearance = self.radicalVerticalGap()
      let radicalRuleThickness = styleFont.metrics.radicalRuleThickness
      let radicalHeight =
        innerDisplay.ascent + innerDisplay.descent + clearance + radicalRuleThickness

      let glyph = self.getRadicalGlyphWithHeight(radicalHeight)!

      // Note this is a departure from Latex. Latex assumes that glyphAscent == thickness.
      // Open type math makes no such assumption, and ascent and descent are independent of the thickness.
      // Latex computes delta as descent - (h(inner) + d(inner) + clearance)
      // but since we may not have ascent == thickness, we modify the delta calculation slightly.
      // If the font designer followes Latex conventions, it will be identical.
      let delta =
        (glyph.descent + glyph.ascent)
        - (innerDisplay.ascent + innerDisplay.descent + clearance + radicalRuleThickness)
      if delta > 0 {
        clearance += delta / 2  // increase the clearance to center the radicand inside the sign.
      }

      // we need to shift the radical glyph up, to coincide with the baseline of inner.
      // The new ascent of the radical glyph should be thickness + adjusted clearance + h(inner)
      let radicalAscent = radicalRuleThickness + clearance + innerDisplay.ascent
      let shiftUp = radicalAscent - glyph.ascent  // Note: if the font designer followed latex conventions, this is the same as glyphAscent == thickness.
      glyph.shiftDown = -shiftUp

      let radical = DisplayRadical(
        radicand: innerDisplay, glyph: glyph, position: currentPosition, range: range)
      radical.ascent = radicalAscent + styleFont.metrics.radicalExtraAscender
      radical.topKern = styleFont.metrics.radicalExtraAscender
      radical.lineThickness = radicalRuleThickness
      // Note: Until we have radical construction from parts, it is possible that glyphAscent+glyphDescent is less
      // than the requested height of the glyph (i.e. radicalHeight), so in the case the innerDisplay has a larger
      // descent we use the innerDisplay's descent.
      radical.descent = max(glyph.ascent + glyph.descent - radicalAscent, innerDisplay.descent)
      radical.width = glyph.width + innerDisplay.width
      return radical
    }

    // MARK: - Glyphs

    func findGlyph(
      _ glyph: CGGlyph, withHeight height: CGFloat, glyphAscent: inout CGFloat,
      glyphDescent: inout CGFloat, glyphWidth: inout CGFloat
    ) -> CGGlyph {
      let variants = styleFont.metrics.verticalVariants(forGlyph: glyph)
      let numVariants = variants.count
      var glyphs = [CGGlyph]()  // numVariants)
      glyphs.reserveCapacity(numVariants)
      for i in 0..<numVariants {
        glyphs.append(variants[i])
      }

      var bboxes = [CGRect](repeating: CGRect.zero, count: numVariants)
      var advances = [CGSize](repeating: CGSize.zero, count: numVariants)

      // Get the bounds for these glyphs
      CTFontGetBoundingRectsForGlyphs(styleFont.ctFont, .horizontal, glyphs, &bboxes, numVariants)
      CTFontGetAdvancesForGlyphs(styleFont.ctFont, .horizontal, glyphs, &advances, numVariants)
      var ascent = CGFloat(0)
      var descent = CGFloat(0)
      var width = CGFloat(0)
      for i in 0..<numVariants {
        let bounds = bboxes[i]
        width = advances[i].width
        getBboxDetails(bounds, ascent: &ascent, descent: &descent)

        if ascent + descent >= height {
          glyphAscent = ascent
          glyphDescent = descent
          glyphWidth = width
          return glyphs[i]
        }
      }
      glyphAscent = ascent
      glyphDescent = descent
      glyphWidth = width
      return glyphs[numVariants - 1]
    }

    func constructGlyph(_ glyph: CGGlyph, withHeight glyphHeight: CGFloat) -> DisplayGlyphRun? {
      let parts = styleFont.metrics.verticalAssembly(forGlyph: glyph)
      if parts.count == 0 {
        return nil
      }
      var glyphs = [UInt16]()
      var offsets = [CGFloat]()
      var height: CGFloat = 0
      self.constructGlyphWithParts(
        parts, glyphHeight: glyphHeight, glyphs: &glyphs, offsets: &offsets, height: &height)
      var first = glyphs[0]
      let width = CTFontGetAdvancesForGlyphs(styleFont.ctFont, .horizontal, &first, nil, 1)
      let display = DisplayGlyphRun(glyphs: glyphs, offsets: offsets, font: styleFont.font)
      display.width = width
      display.ascent = height
      display.descent = 0  // it's upto the rendering to adjust the display up or down.
      return display
    }

    func constructGlyphWithParts(
      _ parts: [FontMetrics.GlyphPart], glyphHeight: CGFloat, glyphs: inout [UInt16],
      offsets: inout [CGFloat], height: inout CGFloat
    ) {
      // Loop forever until the glyph height is valid
      for numExtenders in 0..<Int.max {
        var glyphsRv = [UInt16]()
        var offsetsRv = [CGFloat]()

        var prev: FontMetrics.GlyphPart? = nil
        let minDistance = styleFont.metrics.minConnectorOverlap
        var minOffset = CGFloat(0)
        var maxDelta = CGFloat.greatestFiniteMagnitude  // the maximum amount we can increase the offsets by

        for part in parts {
          var repeats = 1
          if part.isExtender {
            repeats = numExtenders
          }
          // add the extender num extender times
          for _ in 0..<repeats {
            glyphsRv.append(part.glyph)
            if prev != nil {
              let maxOverlap = min(prev!.endConnectorLength, part.startConnectorLength)
              // the minimum amount we can add to the offset
              let minOffsetDelta = prev!.fullAdvance - maxOverlap
              // The maximum amount we can add to the offset.
              let maxOffsetDelta = prev!.fullAdvance - minDistance
              // we can increase the offsets by at most max - min.
              maxDelta = min(maxDelta, maxOffsetDelta - minOffsetDelta)
              minOffset += minOffsetDelta
            }
            offsetsRv.append(minOffset)
            prev = part
          }
        }

        assert(glyphsRv.count == offsetsRv.count, "Offsets should match the glyphs")
        if prev == nil {
          continue  // maybe only extenders
        }
        let minHeight = minOffset + prev!.fullAdvance
        let maxHeight = minHeight + maxDelta * CGFloat(glyphsRv.count - 1)
        if minHeight >= glyphHeight {
          // we are done
          glyphs = glyphsRv
          offsets = offsetsRv
          height = minHeight
          return
        } else if glyphHeight <= maxHeight {
          // spread the delta equally between all the connectors
          let delta = glyphHeight - minHeight
          let deltaIncrease = delta / CGFloat(glyphsRv.count - 1)
          var lastOffset = CGFloat(0)
          for i in 0..<offsetsRv.count {
            let offset = offsetsRv[i] + CGFloat(i) * deltaIncrease
            offsetsRv[i] = offset
            lastOffset = offset
          }
          // we are done
          glyphs = glyphsRv
          offsets = offsetsRv
          height = lastOffset + prev!.fullAdvance
          return
        }
      }
    }

    func findGlyphForCharacterAtIndex(_ index: String.Index, inString str: String) -> CGGlyph {
      // Get the character at index taking into account UTF-32 characters
      var chars = Array(str[index].utf16)

      // Get the glyph from the font
      var glyph = [CGGlyph](repeating: CGGlyph.zero, count: chars.count)
      let found = CTFontGetGlyphsForCharacters(styleFont.ctFont, &chars, &glyph, chars.count)
      if !found {
        // the font did not contain a glyph for our character, so we just return 0 (notdef)
        return 0
      }
      return glyph[0]
    }

    // MARK: - Large Operators

    func makeLargeOp(_ op: LargeOperator!) -> DisplayNode? {
      // Show limits above/below in both display and text (inline) modes
      // Only show limits to the side in script modes to keep them compact
      let limits = op.limits && (style == .display || style == .text)
      var delta = CGFloat(0)
      if op.nucleus.count == 1 {
        var glyph = self.findGlyphForCharacterAtIndex(op.nucleus.startIndex, inString: op.nucleus)
        if style == .display && glyph != 0 {
          // Enlarge the character in display style.
          glyph = styleFont.metrics.largerGlyph(forGlyph: glyph)
        }
        // This is be the italic correction of the character.
        delta = styleFont.metrics.italicCorrection(forGlyph: glyph)

        // vertically center
        let bbox = CTFontGetBoundingRectsForGlyphs(styleFont.ctFont, .horizontal, &glyph, nil, 1)
        let width = CTFontGetAdvancesForGlyphs(styleFont.ctFont, .horizontal, &glyph, nil, 1)
        var ascent = CGFloat(0)
        var descent = CGFloat(0)
        getBboxDetails(bbox, ascent: &ascent, descent: &descent)
        let shiftDown = 0.5 * (ascent - descent) - styleFont.metrics.axisHeight
        let glyphDisplay = DisplayGlyph(glyph: glyph, font: styleFont.font, range: op.indexRange)
        glyphDisplay.ascent = ascent
        glyphDisplay.descent = descent
        glyphDisplay.width = width
        if (op.`subscript` != nil) && !limits {
          // Remove italic correction from the width of the glyph if
          // there is a subscript and limits is not set.
          glyphDisplay.width -= delta
        }
        glyphDisplay.shiftDown = shiftDown
        glyphDisplay.position = currentPosition
        return self.addLimitsToDisplay(glyphDisplay, forOperator: op, delta: delta)
      } else {
        // Create a regular node
        let line = NSMutableAttributedString(string: op.nucleus)
        // add the font
        line.addAttribute(
          kCTFontAttributeName as NSAttributedString.Key, value: styleFont.ctFont,
          range: NSMakeRange(0, line.length))
        let ctLine = CTLineCreateWithAttributedString(line)
        let displayAtom = DisplayTextRun(
          text: line.string,
          font: styleFont.font,
          position: currentPosition,
          range: op.indexRange,
          atoms: [op]
        )
        let width = CTLineGetTypographicBounds(ctLine, nil, nil, nil)
        let bounds = CTLineGetBoundsWithOptions(ctLine, .useGlyphPathBounds)
        displayAtom.width = width
        displayAtom.ascent = max(0, bounds.maxY)
        displayAtom.descent = max(0, 0 - bounds.minY)
        return self.addLimitsToDisplay(displayAtom, forOperator: op, delta: 0)
      }
    }

    func addLimitsToDisplay(_ display: DisplayNode?, forOperator op: LargeOperator, delta: CGFloat)
      -> DisplayNode?
    {
      // If there is no subscript or superscript, just return the current display
      if op.`subscript` == nil && op.superscript == nil {
        currentPosition.x += display!.width
        return display
      }
      // Show limits above/below in both display and text (inline) modes
      if op.limits && (style == .display || style == .text) {
        // make limits
        var superscript: DisplayList? = nil
        var `subscript`: DisplayList? = nil
        if op.superscript != nil {
          superscript = Typesetter.createLineForMathList(
            op.superscript, font: font, style: self.scriptStyle(),
            cramped: self.superScriptCramped())
        }
        if op.`subscript` != nil {
          `subscript` = Typesetter.createLineForMathList(
            op.`subscript`, font: font, style: self.scriptStyle(), cramped: self.subscriptCramped())
        }
        assert(
          (superscript != nil) || (`subscript` != nil),
          "At least one of superscript or subscript should have been present.")
        let opsDisplay = DisplayLargeOperator(
          nucleus: display, upperLimit: superscript, lowerLimit: `subscript`, limitShift: delta / 2,
          extraPadding: 0)
        if superscript != nil {
          let upperLimitGap = max(
            styleFont.metrics.upperLimitGapMin,
            styleFont.metrics.upperLimitBaselineRiseMin - superscript!.descent)
          opsDisplay.upperLimitGap = upperLimitGap
        }
        if `subscript` != nil {
          let lowerLimitGap = max(
            styleFont.metrics.lowerLimitGapMin,
            styleFont.metrics.lowerLimitBaselineDropMin - `subscript`!.ascent)
          opsDisplay.lowerLimitGap = lowerLimitGap
        }
        opsDisplay.position = currentPosition
        opsDisplay.range = op.indexRange
        currentPosition.x += opsDisplay.width
        return opsDisplay
      } else {
        currentPosition.x += display!.width
        self.makeScripts(op, display: display, index: UInt(op.indexRange.location), delta: delta)
        return display
      }
    }

    // MARK: - Large delimiters

    // Delimiter shortfall from plain.tex
    static let kDelimiterFactor = CGFloat(901)
    static let kDelimiterShortfallPoints = CGFloat(5)

    func makeLeftRight(_ inner: Inner?, maxWidth: CGFloat = 0) -> DisplayNode? {
      assert(
        inner!.leftBoundary != nil || inner!.rightBoundary != nil,
        "Inner should have a boundary to call this function")

      let innerListDisplay = Typesetter.createLineForMathList(
        inner!.innerList, font: font, style: style, cramped: cramped, spaced: true,
        maxWidth: maxWidth)
      let axisHeight = styleFont.metrics.axisHeight
      // delta is the max distance from the axis
      let delta = max(innerListDisplay!.ascent - axisHeight, innerListDisplay!.descent + axisHeight)
      let d1 = (delta / 500) * Typesetter.kDelimiterFactor  // This represents atleast 90% of the formula
      let d2 = 2 * delta - Typesetter.kDelimiterShortfallPoints  // This represents a shortfall of 5pt
      // The size of the delimiter glyph should cover at least 90% of the formula or
      // be at most 5pt short.
      let glyphHeight = max(d1, d2)

      var innerElements = [DisplayNode]()
      var position = CGPoint.zero
      if inner!.leftBoundary != nil && !inner!.leftBoundary!.nucleus.isEmpty {
        let leftGlyph = self.findGlyphForBoundary(
          inner!.leftBoundary!.nucleus, withHeight: glyphHeight)
        leftGlyph!.position = position
        position.x += leftGlyph!.width
        innerElements.append(leftGlyph!)
      }

      innerListDisplay!.position = position
      position.x += innerListDisplay!.width
      innerElements.append(innerListDisplay!)

      if inner!.rightBoundary != nil && !inner!.rightBoundary!.nucleus.isEmpty {
        let rightGlyph = self.findGlyphForBoundary(
          inner!.rightBoundary!.nucleus, withHeight: glyphHeight)
        rightGlyph!.position = position
        position.x += rightGlyph!.width
        innerElements.append(rightGlyph!)
      }
      let innerDisplay = DisplayList(children: innerElements, range: inner!.indexRange)
      return innerDisplay
    }

    func findGlyphForBoundary(_ delimiter: String, withHeight glyphHeight: CGFloat) -> DisplayNode?
    {
      var glyphAscent = CGFloat(0)
      var glyphDescent = CGFloat(0)
      var glyphWidth = CGFloat(0)
      let leftGlyph = self.findGlyphForCharacterAtIndex(delimiter.startIndex, inString: delimiter)
      let glyph = self.findGlyph(
        leftGlyph, withHeight: glyphHeight, glyphAscent: &glyphAscent, glyphDescent: &glyphDescent,
        glyphWidth: &glyphWidth)

      var glyphDisplay: DisplayShiftedNode?
      if glyphAscent + glyphDescent < glyphHeight {
        // we didn't find a pre-built glyph that is large enough
        glyphDisplay = self.constructGlyph(leftGlyph, withHeight: glyphHeight)
      }

      if glyphDisplay == nil {
        // Create a glyph display
        glyphDisplay = DisplayGlyph(
          glyph: glyph, font: styleFont.font, range: NSMakeRange(NSNotFound, 0))
        glyphDisplay!.ascent = glyphAscent
        glyphDisplay!.descent = glyphDescent
        glyphDisplay!.width = glyphWidth
      }
      // Center the glyph on the axis
      let shiftDown =
        0.5 * (glyphDisplay!.ascent - glyphDisplay!.descent) - styleFont.metrics.axisHeight
      glyphDisplay!.shiftDown = shiftDown
      return glyphDisplay
    }

    // MARK: - Underline/Overline

    func makeUnderline(_ under: Underline?) -> DisplayNode? {
      let innerListDisplay = Typesetter.createLineForMathList(
        under!.innerList, font: font, style: style, cramped: cramped)
      let underDisplay = DisplayLine(
        inner: innerListDisplay, position: currentPosition, range: under!.indexRange)
      // Move the line down by the vertical gap.
      underDisplay.lineShiftUp =
        -(innerListDisplay!.descent + styleFont.metrics.underbarVerticalGap)
      underDisplay.lineThickness = styleFont.metrics.underbarRuleThickness
      underDisplay.ascent = innerListDisplay!.ascent
      underDisplay.descent =
        innerListDisplay!.descent + styleFont.metrics.underbarVerticalGap
        + styleFont.metrics.underbarRuleThickness + styleFont.metrics.underbarExtraDescender
      underDisplay.width = innerListDisplay!.width
      return underDisplay
    }

    func makeOverline(_ over: Overline?) -> DisplayNode? {
      let innerListDisplay = Typesetter.createLineForMathList(
        over!.innerList, font: font, style: style, cramped: true)
      let overDisplay = DisplayLine(
        inner: innerListDisplay, position: currentPosition, range: over!.indexRange)
      overDisplay.lineShiftUp = innerListDisplay!.ascent + styleFont.metrics.overbarVerticalGap
      overDisplay.lineThickness = styleFont.metrics.underbarRuleThickness
      overDisplay.ascent =
        innerListDisplay!.ascent + styleFont.metrics.overbarVerticalGap
        + styleFont.metrics.overbarRuleThickness + styleFont.metrics.overbarExtraAscender
      overDisplay.descent = innerListDisplay!.descent
      overDisplay.width = innerListDisplay!.width
      return overDisplay
    }

    // MARK: - Accents

    func isSingleCharAccentee(_ accent: Accent?) -> Bool {
      guard let accent = accent else { return false }
      if accent.innerList!.atoms.count != 1 {
        // Not a single char list.
        return false
      }
      let innerAtom = accent.innerList!.atoms[0]
      if innerAtom.nucleus.count != 1 {
        // A complex atom, not a simple char.
        return false
      }
      if innerAtom.`subscript` != nil || innerAtom.superscript != nil {
        return false
      }
      return true
    }

    // The distance the accent must be moved from the beginning.
    func getSkew(_ accent: Accent?, accenteeWidth width: CGFloat, accentGlyph: CGGlyph) -> CGFloat {
      guard let accent = accent else { return 0 }
      if accent.nucleus.isEmpty {
        // No accent
        return 0
      }
      let accentAdjustment = styleFont.metrics.topAccentAdjustment(forGlyph: accentGlyph)
      var accenteeAdjustment = CGFloat(0)
      if !self.isSingleCharAccentee(accent) {
        // use the center of the accentee
        accenteeAdjustment = width / 2
      } else {
        let innerAtom = accent.innerList!.atoms[0]
        let accenteeGlyph = self.findGlyphForCharacterAtIndex(
          innerAtom.nucleus.index(innerAtom.nucleus.endIndex, offsetBy: -1),
          inString: innerAtom.nucleus)
        accenteeAdjustment = styleFont.metrics.topAccentAdjustment(forGlyph: accenteeGlyph)
      }
      // The adjustments need to aligned, so skew is just the difference.
      return (accenteeAdjustment - accentAdjustment)
    }

    // Find the largest horizontal variant if exists, with width less than max width.
    func findVariantGlyph(
      _ glyph: CGGlyph, withMaxWidth maxWidth: CGFloat, maxWidth glyphAscent: inout CGFloat,
      glyphDescent: inout CGFloat, glyphWidth: inout CGFloat
    ) -> CGGlyph {
      let variants = styleFont.metrics.horizontalVariants(forGlyph: glyph)
      let numVariants = variants.count
      assert(
        numVariants > 0, "A glyph is always it's own variant, so number of variants should be > 0")
      var glyphs = [CGGlyph]()
      glyphs.reserveCapacity(numVariants)
      for i in 0..<numVariants {
        glyphs.append(variants[i])
      }

      var curGlyph = glyphs[0]  // if no other glyph is found, we'll return the first one.
      var bboxes = [CGRect](repeating: CGRect.zero, count: numVariants)  // [numVariants)
      var advances = [CGSize](repeating: CGSize.zero, count: numVariants)
      // Get the bounds for these glyphs
      CTFontGetBoundingRectsForGlyphs(styleFont.ctFont, .horizontal, &glyphs, &bboxes, numVariants)
      CTFontGetAdvancesForGlyphs(styleFont.ctFont, .horizontal, &glyphs, &advances, numVariants)
      for i in 0..<numVariants {
        let bounds = bboxes[i]
        var ascent = CGFloat(0)
        var descent = CGFloat(0)
        let width = CGRectGetMaxX(bounds)
        getBboxDetails(bounds, ascent: &ascent, descent: &descent)

        if width > maxWidth {
          if i == 0 {
            // glyph dimensions are not yet set
            glyphWidth = advances[i].width
            glyphAscent = ascent
            glyphDescent = descent
          }
          return curGlyph
        } else {
          curGlyph = glyphs[i]
          glyphWidth = advances[i].width
          glyphAscent = ascent
          glyphDescent = descent
        }
      }
      // We exhausted all the variants and none was larger than the width, so we return the largest
      return curGlyph
    }

    func makeAccent(_ accent: Accent?) -> DisplayNode? {
      var accentee = Typesetter.createLineForMathList(
        accent!.innerList, font: font, style: style, cramped: true)
      if accent!.nucleus.isEmpty {
        // no accent!
        return accentee
      }
      let end = accent!.nucleus.index(before: accent!.nucleus.endIndex)
      var accentGlyph = self.findGlyphForCharacterAtIndex(end, inString: accent!.nucleus)
      let accenteeWidth = accentee!.width
      var glyphAscent = CGFloat(0)
      var glyphDescent = CGFloat(0)
      var glyphWidth = CGFloat(0)
      accentGlyph = self.findVariantGlyph(
        accentGlyph, withMaxWidth: accenteeWidth, maxWidth: &glyphAscent,
        glyphDescent: &glyphDescent, glyphWidth: &glyphWidth)
      let delta = min(accentee!.ascent, styleFont.metrics.accentBaseHeight)
      let skew = self.getSkew(accent, accenteeWidth: accenteeWidth, accentGlyph: accentGlyph)
      let height = accentee!.ascent - delta  // This is always positive since delta <= height.
      let accentPosition = CGPointMake(skew, height)
      let accentGlyphDisplay = DisplayGlyph(
        glyph: accentGlyph, font: styleFont.font, range: accent!.indexRange)
      accentGlyphDisplay.ascent = glyphAscent
      accentGlyphDisplay.descent = glyphDescent
      accentGlyphDisplay.width = glyphWidth
      accentGlyphDisplay.position = accentPosition

      if self.isSingleCharAccentee(accent)
        && (accent!.`subscript` != nil || accent!.superscript != nil)
      {
        // Attach the super/subscripts to the accentee instead of the accent.
        let innerAtom = accent!.innerList!.atoms[0]
        innerAtom.superscript = accent!.superscript
        innerAtom.`subscript` = accent!.`subscript`
        accent?.superscript = nil
        accent?.`subscript` = nil
        // Remake the accentee (now with sub/superscripts)
        // Note: Latex adjusts the heights in case the height of the char is different in non-cramped mode. However this shouldn't be the case since cramping
        // only affects fractions and superscripts. We skip adjusting the heights.
        accentee = Typesetter.createLineForMathList(
          accent!.innerList, font: font, style: style, cramped: cramped)
      }

      let display = DisplayAccent(
        accent: accentGlyphDisplay, accentee: accentee, range: accent!.indexRange)
      display.width = accentee!.width
      display.descent = accentee!.descent
      let ascent = accentee!.ascent - delta + glyphAscent
      display.ascent = max(accentee!.ascent, ascent)
      display.position = currentPosition

      return display
    }

    // MARK: - Table

    let kBaseLineSkipMultiplier = CGFloat(1.2)  // default base line stretch is 12 pt for 10pt font.
    let kLineSkipMultiplier = CGFloat(0.1)  // default is 1pt for 10pt font.
    let kLineSkipLimitMultiplier = CGFloat(0)
    let kJotMultiplier = CGFloat(0.3)  // A jot is 3pt for a 10pt font.

    func makeTable(_ table: Table?) -> DisplayNode? {
      let numColumns = table!.numberOfColumns
      if numColumns == 0 || table!.numberOfRows == 0 {
        // Empty table
        return DisplayList(children: [DisplayNode](), range: table!.indexRange)
      }

      var columnWidths = [CGFloat](repeating: 0, count: numColumns)
      let displays = self.typesetCells(table, columnWidths: &columnWidths)

      // Position all the columns in each row
      var rowDisplays = [DisplayNode]()
      for row in displays {
        let rowDisplay = self.makeRowWithColumns(row, forTable: table, columnWidths: columnWidths)
        rowDisplays.append(rowDisplay!)
      }

      // Position all the rows
      self.positionRows(rowDisplays, forTable: table)
      let tableDisplay = DisplayList(children: rowDisplays, range: table!.indexRange)
      tableDisplay.position = currentPosition
      return tableDisplay
    }

    // Typeset every cell in the table. As a side-effect calculate the max column width of each column.
    func typesetCells(_ table: Table?, columnWidths: inout [CGFloat]) -> [[DisplayNode]] {
      var displays = [[DisplayNode]]()
      for row in table!.cells {
        var colDisplays = [DisplayNode]()
        for i in 0..<row.count {
          let disp = Typesetter.createLineForMathList(row[i], font: font, style: style)
          columnWidths[i] = max(disp!.width, columnWidths[i])
          colDisplays.append(disp!)
        }
        displays.append(colDisplays)
      }
      return displays
    }

    func makeRowWithColumns(_ cols: [DisplayNode], forTable table: Table?, columnWidths: [CGFloat])
      -> DisplayList?
    {
      var columnStart = CGFloat(0)
      var rowRange = NSMakeRange(NSNotFound, 0)
      for i in 0..<cols.count {
        let col = cols[i]
        let colWidth = columnWidths[i]
        let alignment = table?.alignment(forColumn: i)
        var cellPos = columnStart
        switch alignment {
        case .right:
          cellPos += colWidth - col.width
        case .center:
          cellPos += (colWidth - col.width) / 2
        case .left, .none:
          // No changes if left aligned
          cellPos += 0  // no op
        }
        if rowRange.location != NSNotFound {
          rowRange = NSUnionRange(rowRange, col.range)
        } else {
          rowRange = col.range
        }

        col.position = CGPointMake(cellPos, 0)
        columnStart += colWidth + table!.interColumnSpacing * styleFont.metrics.mathUnit
      }
      // Create a display for the row
      let rowDisplay = DisplayList(children: cols, range: rowRange)
      return rowDisplay
    }

    func positionRows(_ rows: [DisplayNode], forTable table: Table?) {
      // Position the rows
      // We will first position the rows starting from 0 and then in the second pass center the whole table vertically.
      var currPos = CGFloat(0)
      let openup = table!.interRowAdditionalSpacing * kJotMultiplier * styleFont.font.size
      let baselineSkip = openup + kBaseLineSkipMultiplier * styleFont.font.size
      let lineSkip = openup + kLineSkipMultiplier * styleFont.font.size
      let lineSkipLimit = openup + kLineSkipLimitMultiplier * styleFont.font.size
      var prevRowDescent = CGFloat(0)
      var ascent = CGFloat(0)
      var first = true
      for row in rows {
        if first {
          row.position = CGPointZero
          ascent += row.ascent
          first = false
        } else {
          var skip = baselineSkip
          if skip - (prevRowDescent + row.ascent) < lineSkipLimit {
            // rows are too close to each other. Space them apart further
            skip = prevRowDescent + row.ascent + lineSkip
          }
          // We are going down so we decrease the y value.
          currPos -= skip
          row.position = CGPointMake(0, currPos)
        }
        prevRowDescent = row.descent
      }

      // Vertically center the whole structure around the axis
      // The descent of the structure is the position of the last row
      // plus the descent of the last row.
      let descent = -currPos + prevRowDescent
      let shiftDown = 0.5 * (ascent - descent) - styleFont.metrics.axisHeight

      for row in rows {
        row.position = CGPointMake(row.position.x, row.position.y - shiftDown)
      }
    }
  }
}
