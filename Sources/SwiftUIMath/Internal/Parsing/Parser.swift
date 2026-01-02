import Foundation

extension Math {
  struct ParserError: Error {
    enum Code: Int {
      case mismatchedBraces = 1
      case invalidCommand
      case characterNotFound
      case missingDelimiter
      case invalidDelimiter
      case missingRight
      case missingLeft
      case invalidEnvironment
      case missingEnvironment
      case missingBegin
      case missingEnd
      case invalidNumberOfColumns
      case internalError
      case invalidLimits
    }

    let code: Code
    let message: String
  }
}

extension Math {
  struct Parser {
    struct Environment {
      var name: String?
      var ended: Bool
      var numberOfRows: Int
      var alignment: Table.ColumnAlignment?  // Optional alignment for starred matrix environments

      init(name: String?, alignment: Table.ColumnAlignment? = nil) {
        self.name = name
        self.numberOfRows = 0
        self.ended = false
        self.alignment = alignment
      }
    }

    enum Mode {
      case display
      case inline
    }

    var string: String
    var currentCharIndex: String.Index
    var currentInnerAtom: Inner?
    var currentEnvironment: Environment?
    var currentFontStyle: Atom.FontStyle
    var spacesAllowed: Bool
    var mode: Mode = .display

    var error: ParserError?

    // MARK: - Character-handling routines

    var hasCharacters: Bool { currentCharIndex < string.endIndex }

    // gets the next character and increments the index
    mutating func nextCharacter() -> Character {
      assert(
        self.hasCharacters,
        "Retrieving character at index \(self.currentCharIndex) beyond length \(self.string.count)"
      )
      let ch = string[currentCharIndex]
      currentCharIndex = string.index(after: currentCharIndex)
      return ch
    }

    mutating func unlookCharacter() {
      assert(currentCharIndex > string.startIndex, "Unlooking when at the first character.")
      if currentCharIndex > string.startIndex {
        currentCharIndex = string.index(before: currentCharIndex)
      }
    }

    // Peek at next command without consuming it (for \not lookahead)
    mutating func peekNextCommand() -> String {
      let savedIndex = currentCharIndex
      skipSpaces()

      guard hasCharacters else {
        currentCharIndex = savedIndex
        return ""
      }

      let char = nextCharacter()
      let command: String

      if char == "\\" {
        command = readCommand()
      } else {
        command = ""
      }

      // Restore position
      currentCharIndex = savedIndex
      return command
    }

    // Consume the next command (after peeking)
    mutating func consumeNextCommand() {
      skipSpaces()

      guard hasCharacters else { return }

      let char = nextCharacter()
      if char == "\\" {
        _ = readCommand()
      }
    }

    mutating func expectCharacter(_ ch: Character) -> Bool {
      assertNotSpace(ch)
      self.skipSpaces()

      if self.hasCharacters {
        let nextChar = self.nextCharacter()
        assertNotSpace(nextChar)
        if nextChar == ch {
          return true
        } else {
          self.unlookCharacter()
          return false
        }
      }
      return false
    }

    static let spaceToCommands: [CGFloat: String] = [
      3: ",",
      4: ">",
      5: ";",
      (-3): "!",
      18: "quad",
      36: "qquad",
    ]

    static let styleToCommands: [Style.Level: String] = [
      .display: "displaystyle",
      .text: "textstyle",
      .script: "scriptstyle",
      .scriptOfScript: "scriptscriptstyle",
    ]

    // Comprehensive mapping of \not command combinations to Unicode negated symbols
    static let notCombinations: [String: String] = [
      // Primary targets (user requested)
      "equiv": "\u{2262}",  // ≢ Not equivalent
      "subset": "\u{2284}",  // ⊄ Not subset
      "in": "\u{2209}",  // ∉ Not element of

      // Additional standard negations
      "sim": "\u{2241}",  // ≁ Not similar
      "approx": "\u{2249}",  // ≉ Not approximately equal
      "cong": "\u{2247}",  // ≇ Not congruent
      "parallel": "\u{2226}",  // ∦ Not parallel
      "subseteq": "\u{2288}",  // ⊈ Not subset or equal
      "supset": "\u{2285}",  // ⊅ Not superset
      "supseteq": "\u{2289}",  // ⊉ Not superset or equal
      "=": "\u{2260}",  // ≠ Not equal (alternative to \neq)
    ]

    init(string: String) {
      self.error = nil
      self.string = string
      self.currentCharIndex = string.startIndex
      self.currentFontStyle = .default
      self.spacesAllowed = false
    }

    // MARK: - Delimiter Detection

    func detectAndStripDelimiters(from str: String) -> (String, Mode) {
      let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)

      // Check display delimiters first (more specific patterns)

      // \[...\] - LaTeX display math
      if trimmed.hasPrefix("\\[") && trimmed.hasSuffix("\\]") && trimmed.count > 4 {
        let content = String(trimmed.dropFirst(2).dropLast(2))
        return (content, .display)
      }

      // $$...$$ - TeX display math (check before single $)
      if trimmed.hasPrefix("$$") && trimmed.hasSuffix("$$") && trimmed.count > 4 {
        let content = String(trimmed.dropFirst(2).dropLast(2))
        return (content, .display)
      }

      // Check inline delimiters

      // \(...\) - LaTeX inline math
      if trimmed.hasPrefix("\\(") && trimmed.hasSuffix("\\)") && trimmed.count > 4 {
        let content = String(trimmed.dropFirst(2).dropLast(2))
        return (content, .inline)
      }

      // $...$ - TeX inline math (must check after $$)
      if trimmed.hasPrefix("$") && trimmed.hasSuffix("$") && trimmed.count > 2
        && !trimmed.hasPrefix("$$")
      {
        let content = String(trimmed.dropFirst(1).dropLast(1))
        return (content, .inline)
      }

      // Check if it's an environment (\begin{...}\end{...})
      // These are handled by existing logic and are display mode by default
      if trimmed.hasPrefix("\\begin{") {
        return (str, .display)
      }

      // No delimiters found - default to display mode (current behavior for backward compatibility)
      return (str, .display)
    }

    // MARK: - AtomList builder functions

    mutating func build() -> AtomList? {
      // Detect and strip delimiters, updating the string and mode
      let (cleanedString, mode) = detectAndStripDelimiters(from: self.string)
      self.string = cleanedString
      self.currentCharIndex = cleanedString.startIndex
      self.mode = mode

      // If inline mode, we could optionally prepend a \textstyle command
      // to force inline rendering of operators. For now, just track the mode.

      let list = self.buildInternal(false)
      if self.hasCharacters && error == nil {
        self.setError(.mismatchedBraces, message: "Mismatched braces: \(self.string)")
        return nil
      }
      if error != nil {
        return nil
      }

      // Note: For inline mode, we insert \textstyle to match LaTeX behavior.
      // However, fractionStyle() has been modified to keep fractions at the
      // same font size in both display and text modes (not one level smaller).
      // Large operators show limits above/below in text style due to the updated
      // condition in makeLargeOp() that checks both .display and .text styles.
      if mode == .inline && list != nil && !list!.atoms.isEmpty {
        // Prepend \textstyle to force inline rendering
        let styleAtom = Style(level: .text)
        list!.atoms.insert(styleAtom, at: 0)
      }

      return list
    }

    static func build(fromString string: String) -> AtomList? {
      var builder = Parser(string: string)
      return builder.build()
    }

    static func build(fromString string: String, error: inout ParserError?) -> AtomList? {
      var builder = Parser(string: string)
      let output = builder.build()
      if builder.error != nil {
        error = builder.error
        return nil
      }
      return output
    }

    mutating func buildInternal(_ oneCharOnly: Bool) -> AtomList? {
      self.buildInternal(oneCharOnly, stopChar: nil)
    }

    mutating func buildInternal(_ oneCharOnly: Bool, stopChar stop: Character?) -> AtomList? {
      let list = AtomList()
      assert(!(oneCharOnly && stop != nil), "Cannot set both oneCharOnly and stopChar.")
      var prevAtom: Atom? = nil
      while self.hasCharacters {
        if error != nil { return nil }  // If there is an error thus far then bail out.

        var atom: Atom? = nil
        let char = self.nextCharacter()

        if oneCharOnly {
          if char == "^" || char == "}" || char == "_" || char == "&" {
            // this is not the character we are looking for.
            // They are meant for the caller to look at.
            self.unlookCharacter()
            return list
          }
        }
        // If there is a stop character, keep scanning 'til we find it
        if stop != nil && char == stop! {
          return list
        }

        if char == "^" {
          assert(!oneCharOnly, "This should have been handled before")
          if prevAtom == nil || prevAtom!.superscript != nil || !prevAtom!.allowsScripts {
            // If there is no previous atom, or if it already has a superscript
            // or if scripts are not allowed for it, then add an empty node.
            prevAtom = Atom(type: .ordinary, nucleus: "")
            list.append(prevAtom!)
          }
          // this is a superscript for the previous atom
          // note: if the next char is the stopChar it will be consumed by the ^ and so it doesn't count as stop
          prevAtom!.superscript = self.buildInternal(true)
          continue
        } else if char == "_" {
          assert(!oneCharOnly, "This should have been handled before")
          if prevAtom == nil || prevAtom!.`subscript` != nil || !prevAtom!.allowsScripts {
            // If there is no previous atom, or if it already has a subcript
            // or if scripts are not allowed for it, then add an empty node.
            prevAtom = Atom(type: .ordinary, nucleus: "")
            list.append(prevAtom!)
          }
          // this is a subscript for the previous atom
          // note: if the next char is the stopChar it will be consumed by the _ and so it doesn't count as stop
          prevAtom!.`subscript` = self.buildInternal(true)
          continue
        } else if char == "{" {
          // this puts us in a recursive routine, and sets oneCharOnly to false and no stop character
          if let subList = self.buildInternal(false, stopChar: "}") {
            prevAtom = subList.atoms.last
            list.append(contentsOf: subList)
            if oneCharOnly {
              return list
            }
          }
          continue
        } else if char == "}" {
          // \ means a command
          assert(!oneCharOnly, "This should have been handled before")
          assert(stop == nil, "This should have been handled before")
          // Special case: } terminates implicit table (name == nil) created by \\
          // This happens when \\ is used inside braces: \substack{a \\ b}
          if self.currentEnvironment != nil && self.currentEnvironment!.name == nil {
            // Mark environment as ended, don't consume the }
            self.currentEnvironment!.ended = true
            return list
          }
          // We encountered a closing brace when there is no stop set, that means there was no
          // corresponding opening brace.
          self.setError(.mismatchedBraces, message: "Mismatched braces.")
          return nil
        } else if char == "\\" {
          let command = readCommand()
          let done = stopCommand(command, list: list, stopChar: stop)
          if done != nil {
            return done
          } else if error != nil {
            return nil
          }
          if self.applyModifier(command, atom: prevAtom) {
            continue
          }

          if let fontStyle = AtomFactory.fontStyle(named: command) {
            let oldSpacesAllowed = spacesAllowed
            // Text has special consideration where it allows spaces without escaping.
            spacesAllowed = command == "text"
            let oldFontStyle = currentFontStyle
            currentFontStyle = fontStyle
            if let sublist = self.buildInternal(true) {
              // Restore the font style.
              currentFontStyle = oldFontStyle
              spacesAllowed = oldSpacesAllowed

              prevAtom = sublist.atoms.last
              list.append(contentsOf: sublist)
              if oneCharOnly {
                return list
              }
            }
            continue
          }
          atom = self.atomForCommand(command)
          if atom == nil {
            // this was an unknown command,
            // we flag an error and return
            // (note setError will not set the error if there is already one, so we flag internal error
            // in the odd case that an _error is not set.
            self.setError(.internalError, message: "Internal error")
            return nil
          }
        } else if char == "&" {
          // used for column separation in tables
          assert(!oneCharOnly, "This should have been handled before")
          if self.currentEnvironment != nil {
            return list
          } else {
            // Create a new table with the current list and a default env
            if let table = self.buildTable(environment: nil, firstList: list, isRow: false) {
              return AtomList(atom: table)
            } else {
              return nil
            }
          }
        } else if spacesAllowed && char == " " {
          // If spaces are allowed then spaces do not need escaping with a \ before being used.
          atom = AtomFactory.atom(forLatexSymbol: " ")
        } else {
          atom = AtomFactory.atom(forCharacter: char)
          if atom == nil {
            // Not a recognized character in standard math mode
            // In text mode (spacesAllowed && roman style), accept any Unicode character for fallback font support
            // This enables Chinese, Japanese, Korean, emoji, etc. in \text{} commands
            if spacesAllowed && currentFontStyle == .roman {
              atom = Atom(type: .ordinary, nucleus: String(char))
            } else {
              // In math mode or non-text commands, skip unrecognized characters
              continue
            }
          }
        }

        guard let atom else {
          assertionFailure("Atom shouldn't be nil")
          continue
        }
        atom.fontStyle = currentFontStyle
        list.append(atom)
        prevAtom = atom

        if oneCharOnly {
          return list
        }
      }
      if stop != nil {
        if stop == "}" {
          // We did not find a corresponding closing brace.
          self.setError(.mismatchedBraces, message: "Missing closing brace")
        } else {
          // we never found our stop character
          let errorMessage = "Expected character not found: \(stop!)"
          self.setError(.characterNotFound, message: errorMessage)
        }
      }
      return list
    }

    // MARK: - AtomList to LaTeX conversion

    static func atomListToString(_ atomList: AtomList?) -> String {
      var str = ""
      var currentFontStyle = Atom.FontStyle.default
      if let atomList {
        for atom in atomList.atoms {
          if currentFontStyle != atom.fontStyle {
            if currentFontStyle != .default {
              str += "}"
            }
            if atom.fontStyle != .default {
              let fontStyleName = AtomFactory.fontName(for: atom.fontStyle)
              str += "\\\(fontStyleName){"
            }
            currentFontStyle = atom.fontStyle
          }
          if atom.type == .fraction {
            if let frac = atom as? Fraction {
              if frac.isContinuedFraction {
                // Generate \cfrac with optional alignment
                if frac.alignment != "c" {
                  str +=
                    "\\cfrac[\(frac.alignment)]{\(atomListToString(frac.numerator!))}{\(atomListToString(frac.denominator!))}"
                } else {
                  str +=
                    "\\cfrac{\(atomListToString(frac.numerator!))}{\(atomListToString(frac.denominator!))}"
                }
              } else if frac.hasRule {
                str +=
                  "\\frac{\(atomListToString(frac.numerator!))}{\(atomListToString(frac.denominator!))}"
              } else {
                let command: String
                if frac.leftDelimiter.isEmpty && frac.rightDelimiter.isEmpty {
                  command = "atop"
                } else if frac.leftDelimiter == "(" && frac.rightDelimiter == ")" {
                  command = "choose"
                } else if frac.leftDelimiter == "{" && frac.rightDelimiter == "}" {
                  command = "brace"
                } else if frac.leftDelimiter == "[" && frac.rightDelimiter == "]" {
                  command = "brack"
                } else {
                  command = "atopwithdelims\(frac.leftDelimiter)\(frac.rightDelimiter)"
                }
                str +=
                  "{\(atomListToString(frac.numerator!)) \\\(command) \(atomListToString(frac.denominator!))}"
              }
            }
          } else if atom.type == .radical {
            str += "\\sqrt"
            if let rad = atom as? Radical {
              if rad.degree != nil {
                str += "[\(atomListToString(rad.degree!))]"
              }
              str += "{\(atomListToString(rad.radicand!))}"
            }
          } else if atom.type == .inner {
            if let inner = atom as? Inner {
              if inner.leftBoundary != nil || inner.rightBoundary != nil {
                if inner.leftBoundary != nil {
                  str += "\\left\(delimiterToString(inner.leftBoundary!)) "
                } else {
                  str += "\\left. "
                }

                str += atomListToString(inner.innerList!)

                if inner.rightBoundary != nil {
                  str += "\\right\(delimiterToString(inner.rightBoundary!)) "
                } else {
                  str += "\\right. "
                }
              } else {
                str += "{\(atomListToString(inner.innerList!))}"
              }
            }
          } else if atom.type == .table {
            if let table = atom as? Table {
              if !table.environment.isEmpty {
                str += "\\begin{\(table.environment)}"
              }

              for i in 0..<table.numberOfRows {
                let row = table.cells[i]
                for j in 0..<row.count {
                  let cell = row[j]
                  if table.environment == "matrix" {
                    if cell.atoms.count >= 1 && cell.atoms[0].type == Math.AtomType.style {
                      // remove first atom
                      cell.atoms.removeFirst()
                    }
                  }
                  if table.environment == "eqalign" || table.environment == "aligned"
                    || table.environment == "split"
                  {
                    if j == 1 && cell.atoms.count >= 1
                      && cell.atoms[0].type == Math.AtomType.ordinary
                      && cell.atoms[0].nucleus.count == 0
                    {
                      // remove empty nucleus added for spacing
                      cell.atoms.removeFirst()
                    }
                  }
                  str += atomListToString(cell)
                  if j < row.count - 1 {
                    str += "&"
                  }
                }
                if i < table.numberOfRows - 1 {
                  str += "\\\\ "
                }
              }
              if !table.environment.isEmpty {
                str += "\\end{\(table.environment)}"
              }
            }
          } else if atom.type == .overline {
            if let overline = atom as? Overline {
              str += "\\overline"
              str += "{\(atomListToString(overline.innerList!))}"
            }
          } else if atom.type == .underline {
            if let underline = atom as? Underline {
              str += "\\underline"
              str += "{\(atomListToString(underline.innerList!))}"
            }
          } else if atom.type == .accent {
            if let accent = atom as? Accent {
              str += "\\\(AtomFactory.accentName(accent)!){\(atomListToString(accent.innerList!))}"
            }
          } else if atom.type == .largeOperator {
            let op = atom as! LargeOperator
            let command = AtomFactory.latexSymbolName(for: atom)
            let originalOp = AtomFactory.atom(forLatexSymbol: command!) as! LargeOperator
            str += "\\\(command!) "
            if originalOp.limits != op.limits {
              if op.limits {
                str += "\\limits "
              } else {
                str += "\\nolimits "
              }
            }
          } else if atom.type == .space {
            if let space = atom as? Space {
              if let command = Self.spaceToCommands[space.amount] {
                str += "\\\(command) "
              } else {
                str += String(format: "\\mkern%.1fmu", space.amount)
              }
            }
          } else if atom.type == .style {
            if let style = atom as? Style {
              if let command = Self.styleToCommands[style.level] {
                str += "\\\(command) "
              }
            }
          } else if atom.nucleus.isEmpty {
            str += "{}"
          } else if atom.nucleus == "\u{2236}" {
            // math colon
            str += ":"
          } else if atom.nucleus == "\u{2212}" {
            // math minus
            str += "-"
          } else {
            if let command = AtomFactory.latexSymbolName(for: atom) {
              str += "\\\(command) "
            } else {
              str += "\(atom.nucleus)"
            }
          }

          if atom.superscript != nil {
            str += "^{\(atomListToString(atom.superscript!))}"
          }

          if atom.`subscript` != nil {
            str += "_{\(atomListToString(atom.`subscript`!))}"
          }
        }
      }
      if currentFontStyle != .default {
        str += "}"
      }
      return str
    }

    static func delimiterToString(_ delimiter: Atom) -> String {
      if let command = AtomFactory.delimiterName(of: delimiter) {
        let singleChars = ["(", ")", "[", "]", "<", ">", "|", ".", "/"]
        if singleChars.contains(command) {
          return command
        } else if command == "||" {
          return "\\|"
        } else {
          return "\\\(command)"
        }
      }
      return ""
    }

    mutating func atomForCommand(_ command: String) -> Atom? {
      if let atom = AtomFactory.atom(forLatexSymbol: command) {
        return atom
      }
      if let accent = AtomFactory.accent(withName: command) {
        // The command is an accent
        accent.innerList = self.buildInternal(true)
        return accent
      } else if command == "frac" {
        // A fraction command has 2 arguments
        let frac = Fraction()
        frac.numerator = self.buildInternal(true)
        frac.denominator = self.buildInternal(true)
        return frac
      } else if command == "cfrac" {
        // A continued fraction command with optional alignment and 2 arguments
        let frac = Fraction()
        frac.isContinuedFraction = true

        // Parse optional alignment parameter [l], [r], [c]
        skipSpaces()
        if hasCharacters && string[currentCharIndex] == "[" {
          _ = nextCharacter()  // consume '['
          let alignmentChar = nextCharacter()
          if alignmentChar == "l" || alignmentChar == "r" || alignmentChar == "c" {
            frac.alignment = String(alignmentChar)
          }
          // Consume closing ']'
          if hasCharacters && string[currentCharIndex] == "]" {
            _ = nextCharacter()
          }
        }

        frac.numerator = self.buildInternal(true)
        frac.denominator = self.buildInternal(true)
        return frac
      } else if command == "dfrac" {
        // Display-style fraction command has 2 arguments
        let frac = Fraction()
        let numerator = self.buildInternal(true)
        let denominator = self.buildInternal(true)

        // Prepend \displaystyle to force display mode rendering
        let displayStyle = Style(level: .display)
        numerator?.insert(displayStyle, at: 0)
        denominator?.insert(displayStyle, at: 0)

        frac.numerator = numerator
        frac.denominator = denominator
        return frac
      } else if command == "tfrac" {
        // Text-style fraction command has 2 arguments
        let frac = Fraction()
        let numerator = self.buildInternal(true)
        let denominator = self.buildInternal(true)

        // Prepend \textstyle to force text mode rendering
        let textStyle = Style(level: .text)
        numerator?.insert(textStyle, at: 0)
        denominator?.insert(textStyle, at: 0)

        frac.numerator = numerator
        frac.denominator = denominator
        return frac
      } else if command == "binom" {
        // A binom command has 2 arguments
        let frac = Fraction(hasRule: false)
        frac.numerator = self.buildInternal(true)
        frac.denominator = self.buildInternal(true)
        frac.leftDelimiter = "("
        frac.rightDelimiter = ")"
        return frac
      } else if command == "sqrt" {
        // A sqrt command with one argument
        let rad = Radical()
        guard self.hasCharacters else {
          rad.radicand = self.buildInternal(true)
          return rad
        }
        let ch = self.nextCharacter()
        if ch == "[" {
          // special handling for sqrt[degree]{radicand}
          rad.degree = self.buildInternal(false, stopChar: "]")
          rad.radicand = self.buildInternal(true)
        } else {
          self.unlookCharacter()
          rad.radicand = self.buildInternal(true)
        }
        return rad
      } else if command == "left" {
        // Save the current inner while a new one gets built.
        let oldInner = currentInnerAtom
        currentInnerAtom = Inner()
        currentInnerAtom!.leftBoundary = self.getBoundaryAtom("left")
        if currentInnerAtom!.leftBoundary == nil {
          return nil
        }
        currentInnerAtom!.innerList = self.buildInternal(false)
        if currentInnerAtom!.rightBoundary == nil {
          // A right node would have set the right boundary so we must be missing the right node.
          let errorMessage = "Missing \\right"
          self.setError(.missingRight, message: errorMessage)
          return nil
        }
        // reinstate the old inner atom.
        let newInner = currentInnerAtom
        currentInnerAtom = oldInner
        return newInner
      } else if command == "overline" {
        // The overline command has 1 arguments
        let over = Overline()
        over.innerList = self.buildInternal(true)
        return over
      } else if command == "underline" {
        // The underline command has 1 arguments
        let under = Underline()
        under.innerList = self.buildInternal(true)
        return under
      } else if command == "substack" {
        // \substack reads ONE braced argument containing rows separated by \\
        // Similar to how \frac reads {numerator}{denominator}

        // Read the braced content using standard pattern
        let content = self.buildInternal(true)

        if content == nil {
          return nil
        }

        // The content may already be a table if \\ was encountered
        // Check if we got a table from the \\ parsing
        if content!.atoms.count == 1, let tableAtom = content!.atoms.first as? Table {
          return tableAtom
        }

        // Otherwise, single row - wrap in table
        var rows = [[AtomList]]()
        rows.append([content!])

        var error: ParserError? = self.error
        let table = AtomFactory.table(withEnvironment: nil, rows: rows, error: &error)
        if table == nil && self.error == nil {
          self.error = error
          return nil
        }

        return table
      } else if command == "begin" {
        let env = self.readEnvironment()
        if env == nil {
          return nil
        }
        let table = self.buildTable(environment: env, firstList: nil, isRow: false)
        return table
      } else if command == "color" {
        // A color command has 2 arguments
        let mathColor = Color()
        let color = self.readColor()
        if color == nil {
          return nil
        }
        mathColor.colorString = color!
        mathColor.innerList = self.buildInternal(true)
        return mathColor
      } else if command == "textcolor" {
        // A textcolor command has 2 arguments
        let mathColor = TextColor()
        let color = self.readColor()
        if color == nil {
          return nil
        }
        mathColor.colorString = color!
        mathColor.innerList = self.buildInternal(true)
        return mathColor
      } else if command == "colorbox" {
        // A color command has 2 arguments
        let mathColorbox = ColorBox()
        let color = self.readColor()
        if color == nil {
          return nil
        }
        mathColorbox.colorString = color!
        mathColorbox.innerList = self.buildInternal(true)
        return mathColorbox
      } else if command == "pmod" {
        // A pmod command has 1 argument - creates (mod n)
        let inner = Inner()
        inner.leftBoundary = AtomFactory.boundary(forDelimiter: "(")
        inner.rightBoundary = AtomFactory.boundary(forDelimiter: ")")

        let innerList = AtomList()

        // Add the "mod" operator (upright text)
        let modOperator = AtomFactory.atom(forLatexSymbol: "mod")!
        innerList.append(modOperator)

        // Add medium space between "mod" and argument (6mu)
        let space = Space(amount: 6.0)
        innerList.append(space)

        // Parse the argument from braces
        let argument = self.buildInternal(true)
        if let argList = argument {
          innerList.append(contentsOf: argList)
        }

        inner.innerList = innerList
        return inner
      } else if command == "not" {
        // Handle \not command with lookahead for comprehensive negation support
        let nextCommand = self.peekNextCommand()

        if let negatedUnicode = Self.notCombinations[nextCommand] {
          self.consumeNextCommand()  // Remove base symbol from stream
          return Atom(type: .relation, nucleus: negatedUnicode)
        } else {
          let errorMessage = "Unsupported \\not\\\(nextCommand) combination"
          self.setError(.invalidCommand, message: errorMessage)
          return nil
        }
      } else {
        let errorMessage = "Invalid command \\\(command)"
        self.setError(.invalidCommand, message: errorMessage)
        return nil
      }
    }

    mutating func readColor() -> String? {
      if !self.expectCharacter("{") {
        // We didn't find an opening brace, so no env found.
        self.setError(.characterNotFound, message: "Missing {")
        return nil
      }

      // Ignore spaces and nonascii.
      self.skipSpaces()

      // a string of all upper and lower case characters.
      var mutable = ""
      while self.hasCharacters {
        let ch = self.nextCharacter()
        if ch == "#" || (ch >= "A" && ch <= "Z") || (ch >= "a" && ch <= "z")
          || (ch >= "0" && ch <= "9")
        {
          mutable.append(ch)  // appendString:[NSString stringWithCharacters:&ch length:1]];
        } else {
          // we went too far
          self.unlookCharacter()
          break
        }
      }

      if !self.expectCharacter("}") {
        // We didn't find an closing brace, so invalid format.
        self.setError(.characterNotFound, message: "Missing }")
        return nil
      }
      return mutable
    }

    mutating func skipSpaces() {
      while self.hasCharacters {
        let ch = self.nextCharacter().utf32
        if ch < 0x21 || ch > 0x7E {
          // skip non ascii characters and spaces
          continue
        } else {
          self.unlookCharacter()
          return
        }
      }
    }

    static var fractionCommands: [String: [Character]] {
      [
        "over": [],
        "atop": [],
        "choose": ["(", ")"],
        "brack": ["[", "]"],
        "brace": ["{", "}"],
      ]
    }

    mutating func stopCommand(_ command: String, list: AtomList, stopChar: Character?) -> AtomList?
    {
      if command == "right" {
        if currentInnerAtom == nil {
          let errorMessage = "Missing \\left"
          self.setError(.missingLeft, message: errorMessage)
          return nil
        }
        currentInnerAtom!.rightBoundary = self.getBoundaryAtom("right")
        if currentInnerAtom!.rightBoundary == nil {
          return nil
        }
        // return the list read so far.
        return list
      } else if let delims = Self.fractionCommands[command] {
        var frac: Fraction! = nil
        if command == "over" {
          frac = Fraction()
        } else {
          frac = Fraction(hasRule: false)
        }
        if delims.count == 2 {
          frac.leftDelimiter = String(delims[0])
          frac.rightDelimiter = String(delims[1])
        }
        frac.numerator = list
        frac.denominator = self.buildInternal(false, stopChar: stopChar)
        if error != nil {
          return nil
        }
        let fracList = AtomList()
        fracList.append(frac)
        return fracList
      } else if command == "\\" || command == "cr" {
        if currentEnvironment != nil {
          // Stop the current list and increment the row count
          currentEnvironment!.numberOfRows += 1
          return list
        } else {
          // Create a new table with the current list and a default env
          if let table = self.buildTable(environment: nil, firstList: list, isRow: true) {
            return AtomList(atom: table)
          }
        }
      } else if command == "end" {
        if currentEnvironment == nil {
          let errorMessage = "Missing \\begin"
          self.setError(.missingBegin, message: errorMessage)
          return nil
        }
        let env = self.readEnvironment()
        if env == nil {
          return nil
        }
        if env! != currentEnvironment!.name {
          let errorMessage =
            "Begin environment name \(currentEnvironment!.name ?? "(none)") does not match end name: \(env!)"
          self.setError(.invalidEnvironment, message: errorMessage)
          return nil
        }
        // Finish the current environment.
        currentEnvironment!.ended = true
        return list
      }
      return nil
    }

    // Applies the modifier to the atom. Returns true if modifier applied.
    mutating func applyModifier(_ modifier: String, atom: Atom?) -> Bool {
      if modifier == "limits" {
        if atom?.type != .largeOperator {
          let errorMessage = "Limits can only be applied to an operator."
          self.setError(.invalidLimits, message: errorMessage)
        } else {
          let op = atom as! LargeOperator
          op.limits = true
        }
        return true
      } else if modifier == "nolimits" {
        if atom?.type != .largeOperator {
          let errorMessage = "No limits can only be applied to an operator."
          self.setError(.invalidLimits, message: errorMessage)
        } else {
          let op = atom as! LargeOperator
          op.limits = false
        }
        return true
      }
      return false
    }

    mutating func setError(_ code: ParserError.Code, message: String) {
      // Only record the first error.
      if error == nil {
        error = ParserError(code: code, message: message)
      }
    }

    mutating func atom(forCommand command: String) -> Atom? {
      if let atom = AtomFactory.atom(forLatexSymbol: command) {
        return atom
      }
      if let accent = AtomFactory.accent(withName: command) {
        accent.innerList = self.buildInternal(true)
        return accent
      } else if command == "frac" {
        let frac = Fraction()
        frac.numerator = self.buildInternal(true)
        frac.denominator = self.buildInternal(true)
        return frac
      } else if command == "cfrac" {
        let frac = Fraction()
        frac.isContinuedFraction = true

        // Parse optional alignment parameter [l], [r], [c]
        skipSpaces()
        if hasCharacters && string[currentCharIndex] == "[" {
          _ = nextCharacter()  // consume '['
          let alignmentChar = nextCharacter()
          if alignmentChar == "l" || alignmentChar == "r" || alignmentChar == "c" {
            frac.alignment = String(alignmentChar)
          }
          // Consume closing ']'
          if hasCharacters && string[currentCharIndex] == "]" {
            _ = nextCharacter()
          }
        }

        frac.numerator = self.buildInternal(true)
        frac.denominator = self.buildInternal(true)
        return frac
      } else if command == "dfrac" {
        // Display-style fraction command has 2 arguments
        let frac = Fraction()
        let numerator = self.buildInternal(true)
        let denominator = self.buildInternal(true)

        // Prepend \displaystyle to force display mode rendering
        let displayStyle = Style(level: .display)
        numerator?.insert(displayStyle, at: 0)
        denominator?.insert(displayStyle, at: 0)

        frac.numerator = numerator
        frac.denominator = denominator
        return frac
      } else if command == "tfrac" {
        // Text-style fraction command has 2 arguments
        let frac = Fraction()
        let numerator = self.buildInternal(true)
        let denominator = self.buildInternal(true)

        // Prepend \textstyle to force text mode rendering
        let textStyle = Style(level: .text)
        numerator?.insert(textStyle, at: 0)
        denominator?.insert(textStyle, at: 0)

        frac.numerator = numerator
        frac.denominator = denominator
        return frac
      } else if command == "binom" {
        let frac = Fraction(hasRule: false)
        frac.numerator = self.buildInternal(true)
        frac.denominator = self.buildInternal(true)
        frac.leftDelimiter = "("
        frac.rightDelimiter = ")"
        return frac
      } else if command == "sqrt" {
        let rad = Radical()
        let char = self.nextCharacter()
        if char == "[" {
          rad.degree = self.buildInternal(false, stopChar: "]")
          rad.radicand = self.buildInternal(true)
        } else {
          self.unlookCharacter()
          rad.radicand = self.buildInternal(true)
        }
        return rad
      } else if command == "left" {
        let oldInner = self.currentInnerAtom
        self.currentInnerAtom = Inner()
        self.currentInnerAtom?.leftBoundary = self.getBoundaryAtom("left")
        if self.currentInnerAtom?.leftBoundary == nil {
          return nil
        }
        self.currentInnerAtom!.innerList = self.buildInternal(false)
        if self.currentInnerAtom?.rightBoundary == nil {
          self.setError(.missingRight, message: "Missing \\right")
          return nil
        }
        let newInner = self.currentInnerAtom
        currentInnerAtom = oldInner
        return newInner
      } else if command == "overline" {
        let over = Overline()
        over.innerList = self.buildInternal(true)

        return over
      } else if command == "underline" {
        let under = Underline()
        under.innerList = self.buildInternal(true)

        return under
      } else if command == "begin" {
        if let env = self.readEnvironment() {
          // Check if this is a starred matrix environment and read optional alignment
          var alignment: Table.ColumnAlignment? = nil
          if env.hasSuffix("*") {
            alignment = self.readOptionalAlignment()
            if self.error != nil {
              return nil
            }
          }

          let table = self.buildTable(environment: env, alignment: alignment, firstList: nil, isRow: false)
          return table
        } else {
          return nil
        }
      } else if command == "color" {
        // A color command has 2 arguments
        let mathColor = Color()
        mathColor.colorString = self.readColor()!
        mathColor.innerList = self.buildInternal(true)
        return mathColor
      } else if command == "colorbox" {
        // A color command has 2 arguments
        let mathColorbox = ColorBox()
        mathColorbox.colorString = self.readColor()!
        mathColorbox.innerList = self.buildInternal(true)
        return mathColorbox
      } else {
        self.setError(.invalidCommand, message: "Invalid command \\\(command)")
        return nil
      }
    }

    mutating func readEnvironment() -> String? {
      if !self.expectCharacter("{") {
        // We didn't find an opening brace, so no env found.
        self.setError(.characterNotFound, message: "Missing {")
        return nil
      }

      self.skipSpaces()
      let env = self.readString()

      if !self.expectCharacter("}") {
        // We didn"t find an closing brace, so invalid format.
        self.setError(.characterNotFound, message: "Missing }")
        return nil
      }
      return env
    }

    /// Reads optional alignment parameter for starred matrix environments: [r], [l], or [c]
    mutating func readOptionalAlignment() -> Table.ColumnAlignment? {
      self.skipSpaces()

      // Check if there's an opening bracket
      guard hasCharacters && string[currentCharIndex] == "[" else {
        return nil
      }

      _ = nextCharacter()  // consume '['
      self.skipSpaces()

      guard hasCharacters else {
        self.setError(.characterNotFound, message: "Missing alignment specifier after [")
        return nil
      }

      let alignChar = nextCharacter()
      let alignment: Table.ColumnAlignment?

      switch alignChar {
      case "l":
        alignment = .left
      case "c":
        alignment = .center
      case "r":
        alignment = .right
      default:
        self.setError(
          .invalidEnvironment, message: "Invalid alignment specifier: \(alignChar). Must be l, c, or r")
        return nil
      }

      self.skipSpaces()

      if !self.expectCharacter("]") {
        self.setError(.characterNotFound, message: "Missing ] after alignment specifier")
        return nil
      }

      return alignment
    }

    func assertNotSpace(_ ch: Character) {
      assert(ch >= "\u{21}" && ch <= "\u{7E}", "Expected non-space character \(ch)")
    }

    mutating func buildTable(
      environment: String?,
      alignment: Table.ColumnAlignment? = nil,
      firstList: AtomList?,
      isRow: Bool
    ) -> Atom? {
      // Save the current env till an new one gets built.
      let oldEnv = self.currentEnvironment

      currentEnvironment = Environment(name: environment, alignment: alignment)

      var currentRow = 0
      var currentCol = 0

      var rows = [[AtomList]]()
      rows.append([AtomList]())
      if firstList != nil {
        rows[currentRow].append(firstList!)
        if isRow {
          currentEnvironment!.numberOfRows += 1
          currentRow += 1
          rows.append([AtomList]())
        } else {
          currentCol += 1
        }
      }
      while !currentEnvironment!.ended && self.hasCharacters {
        let list = self.buildInternal(false)
        if list == nil {
          // If there is an error building the list, bail out early.
          return nil
        }
        rows[currentRow].append(list!)
        currentCol += 1
        if currentEnvironment!.numberOfRows > currentRow {
          currentRow = currentEnvironment!.numberOfRows
          rows.append([AtomList]())
          currentCol = 0
        }
      }

      if !currentEnvironment!.ended && currentEnvironment!.name != nil {
        self.setError(.missingEnd, message: "Missing \\end")
        return nil
      }

      var error: ParserError? = self.error
      let table = AtomFactory.table(
        withEnvironment: currentEnvironment?.name, alignment: currentEnvironment?.alignment,
        rows: rows, error: &error)
      if table == nil && self.error == nil {
        self.error = error
        return nil
      }
      self.currentEnvironment = oldEnv
      return table
    }

    mutating func getBoundaryAtom(_ delimiterType: String) -> Atom? {
      let delim = self.readDelimiter()
      if delim == nil {
        let errorMessage = "Missing delimiter for \\\(delimiterType)"
        self.setError(.missingDelimiter, message: errorMessage)
        return nil
      }
      let boundary = AtomFactory.boundary(forDelimiter: delim!)
      if boundary == nil {
        let errorMessage = "Invalid delimiter for \(delimiterType): \(delim!)"
        self.setError(.invalidDelimiter, message: errorMessage)
        return nil
      }
      return boundary
    }

    mutating func readDelimiter() -> String? {
      self.skipSpaces()
      while self.hasCharacters {
        let char = self.nextCharacter()
        assertNotSpace(char)
        if char == "\\" {
          let command = self.readCommand()
          if command == "|" {
            return "||"
          }
          return command
        } else {
          return String(char)
        }
      }
      return nil
    }

    mutating func readCommand() -> String {
      let singleChars = "{}$#%_| ,>;!\\"
      if self.hasCharacters {
        let char = self.nextCharacter()
        if singleChars.firstIndex(of: char) != nil {
          return String(char)
        } else {
          self.unlookCharacter()
        }
      }
      return self.readString()
    }

    mutating func readString() -> String {
      // a string of all upper and lower case characters (and asterisks for starred environments)
      var output = ""
      while self.hasCharacters {
        let char = self.nextCharacter()
        if char.isLowercase || char.isUppercase || char == "*" {
          output.append(char)
        } else {
          self.unlookCharacter()
          break
        }
      }
      return output
    }
  }
}
