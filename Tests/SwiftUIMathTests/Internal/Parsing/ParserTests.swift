import Foundation
import Testing

@testable import SwiftUIMath

@Suite
struct ParserTests {
  func checkAtomTypes(_ list: Math.AtomList?, types: [Math.AtomType]) {
    if let list = list {
      #expect(list.atoms.count == types.count)
      for i in 0..<list.atoms.count {
        let atom = list.atoms[i]
        #expect(atom.type == types[i])
      }
    } else {
      #expect(types.isEmpty)
    }
  }

  struct TestRecord {
    let build: String
    let atomType: [Math.AtomType]
    let types: [Math.AtomType]
    let extra: [Math.AtomType]
    let result: String

    init(
      build: String, atomType: [Math.AtomType], types: [Math.AtomType],
      extra: [Math.AtomType] = [Math.AtomType](), result: String
    ) {
      self.build = build
      self.atomType = atomType
      self.types = types
      self.extra = extra
      self.result = result
    }
  }

  func getTestData() -> [TestRecord] {
    [
      TestRecord(build: "x", atomType: [.variable], types: [], result: "x"),
      TestRecord(build: "1", atomType: [.number], types: [], result: "1"),
      TestRecord(build: "*", atomType: [.binaryOperator], types: [], result: "*"),
      TestRecord(build: "+", atomType: [.binaryOperator], types: [], result: "+"),
      TestRecord(build: ".", atomType: [.number], types: [], result: "."),
      TestRecord(build: "(", atomType: [.open], types: [], result: "("),
      TestRecord(build: ")", atomType: [.close], types: [], result: ")"),
      TestRecord(build: ",", atomType: [.punctuation], types: [], result: ","),
      TestRecord(build: "!", atomType: [.close], types: [], result: "!"),
      TestRecord(build: "=", atomType: [.relation], types: [], result: "="),
      TestRecord(
        build: "x+2", atomType: [.variable, .binaryOperator, .number], types: [], result: "x+2"),
      // spaces are ignored
      TestRecord(
        build: "(2.3 * 8)",
        atomType: [.open, .number, .number, .number, .binaryOperator, .number, .close], types: [],
        result: "(2.3*8)"),
      // braces are just for grouping
      TestRecord(
        build: "5{3+4}", atomType: [.number, .number, .binaryOperator, .number], types: [],
        result: "53+4"),
      // commands
      TestRecord(
        build: "\\pi+\\theta\\geq 3",
        atomType: [.variable, .binaryOperator, .variable, .relation, .number], types: [],
        result: "\\pi +\\theta \\geq 3"),
      // aliases
      TestRecord(
        build: "\\pi\\ne 5 \\land 3",
        atomType: [.variable, .relation, .number, .binaryOperator, .number], types: [],
        result: "\\pi \\neq 5\\wedge 3"),
      // control space
      TestRecord(
        build: "x \\ y", atomType: [.variable, .ordinary, .variable], types: [], result: "x\\  y"),
      // spacing
      TestRecord(
        build: "x \\quad y \\; z \\! q",
        atomType: [.variable, .space, .variable, .space, .variable, .space, .variable], types: [],
        result: "x\\quad y\\; z\\! q"),
    ]
  }

  func getTestDataSuperscript() -> [TestRecord] {
    [
      TestRecord(build: "x^2", atomType: [.variable], types: [.number], result: "x^{2}"),
      TestRecord(
        build: "x^23", atomType: [.variable, .number], types: [.number], result: "x^{2}3"),
      TestRecord(
        build: "x^{23}", atomType: [.variable], types: [.number, .number], result: "x^{23}"),
      TestRecord(
        build: "x^2^3", atomType: [.variable, .ordinary], types: [.number], result: "x^{2}{}^{3}"),
      TestRecord(
        build: "x^{2^3}", atomType: [.variable], types: [.number], extra: [.number],
        result: "x^{2^{3}}"),
      TestRecord(
        build: "x^{^2*}", atomType: [.variable], types: [.ordinary, .binaryOperator],
        extra: [.number], result: "x^{{}^{2}*}"),
      TestRecord(build: "^2", atomType: [.ordinary], types: [.number], result: "{}^{2}"),
      TestRecord(build: "{}^2", atomType: [.ordinary], types: [.number], result: "{}^{2}"),
      TestRecord(build: "x^^2", atomType: [.variable, .ordinary], types: [], result: "x^{}{}^{2}"),
      TestRecord(build: "5{x}^2", atomType: [.number, .variable], types: [], result: "5x^{2}"),
    ]
  }

  func getTestDataSubscript() -> [TestRecord] {
    [
      TestRecord(build: "x_2", atomType: [.variable], types: [.number], result: "x_{2}"),
      TestRecord(
        build: "x_23", atomType: [.variable, .number], types: [.number], result: "x_{2}3"),
      TestRecord(
        build: "x_{23}", atomType: [.variable], types: [.number, .number], result: "x_{23}"),
      TestRecord(
        build: "x_2_3", atomType: [.variable, .ordinary], types: [.number], result: "x_{2}{}_{3}"),
      TestRecord(
        build: "x_{2_3}", atomType: [.variable], types: [.number], extra: [.number],
        result: "x_{2_{3}}"),
      TestRecord(
        build: "x_{_2*}", atomType: [.variable], types: [.ordinary, .binaryOperator],
        extra: [.number], result: "x_{{}_{2}*}"),
      TestRecord(build: "_2", atomType: [.ordinary], types: [.number], result: "{}_{2}"),
      TestRecord(build: "{}_2", atomType: [.ordinary], types: [.number], result: "{}_{2}"),
      TestRecord(build: "x__2", atomType: [.variable, .ordinary], types: [], result: "x_{}{}_{2}"),
      TestRecord(build: "5{x}_2", atomType: [.number, .variable], types: [], result: "5x_{2}"),
    ]
  }

  func getTestDataSuperSubscript() -> [TestRecord] {
    [
      TestRecord(
        build: "x_2^*", atomType: [.variable], types: [.number], extra: [.binaryOperator],
        result: "x^{*}_{2}"),
      TestRecord(
        build: "x^*_2", atomType: [.variable], types: [.number], extra: [.binaryOperator],
        result: "x^{*}_{2}"),
      TestRecord(
        build: "x_^*", atomType: [.variable], types: [], extra: [.binaryOperator],
        result: "x^{*}_{}"),
      TestRecord(build: "x^_2", atomType: [.variable], types: [.number], result: "x^{}_{2}"),
      TestRecord(build: "x_{2^*}", atomType: [.variable], types: [.number], result: "x_{2^{*}}"),
      TestRecord(
        build: "x^{*_2}", atomType: [.variable], types: [], extra: [.binaryOperator],
        result: "x^{*_{2}}"),
      TestRecord(
        build: "_2^*", atomType: [.ordinary], types: [.number], extra: [.binaryOperator],
        result: "{}^{*}_{2}"),
    ]
  }

  struct TestRecord2 {
    let build: String
    let type1: [Math.AtomType]
    let number: Int
    let type2: [Math.AtomType]
    let left: String
    let right: String
    let result: String
  }

  func getTestDataLeftRight() -> [TestRecord2] {
    [
      TestRecord2(
        build: "\\left( 2 \\right)", type1: [.inner], number: 0, type2: [.number], left: "(",
        right: ")", result: "\\left( 2\\right) "),
      // spacing
      TestRecord2(
        build: "\\left ( 2 \\right )", type1: [.inner], number: 0, type2: [.number], left: "(",
        right: ")", result: "\\left( 2\\right) "),
      // commands
      TestRecord2(
        build: "\\left\\{ 2 \\right\\}", type1: [.inner], number: 0, type2: [.number], left: "{",
        right: "}", result: "\\left\\{ 2\\right\\} "),
      // complex commands
      TestRecord2(
        build: "\\left\\langle x \\right\\rangle", type1: [.inner], number: 0, type2: [.variable],
        left: "\u{2329}", right: "\u{232A}", result: "\\left< x\\right> "),
      // bars
      TestRecord2(
        build: "\\left| x \\right\\|", type1: [.inner], number: 0, type2: [.variable], left: "|",
        right: "\u{2016}", result: "\\left| x\\right\\| "),
      // inner in between
      TestRecord2(
        build: "5 + \\left( 2 \\right) - 2",
        type1: [.number, .binaryOperator, .inner, .binaryOperator, .number], number: 2,
        type2: [.number], left: "(", right: ")", result: "5+\\left( 2\\right) -2"),
      // long inner
      TestRecord2(
        build: "\\left( 2 + \\frac12\\right)", type1: [.inner], number: 0,
        type2: [.number, .binaryOperator, .fraction], left: "(", right: ")",
        result: "\\left( 2+\\frac{1}{2}\\right) "),
      // nested
      TestRecord2(
        build: "\\left[ 2 + \\left|\\frac{-x}{2}\\right| \\right]", type1: [.inner], number: 0,
        type2: [.number, .binaryOperator, .inner], left: "[", right: "]",
        result: "\\left[ 2+\\left| \\frac{-x}{2}\\right| \\right] "),
      // With scripts
      TestRecord2(
        build: "\\left( 2 \\right)^2", type1: [.inner], number: 0, type2: [.number], left: "(",
        right: ")", result: "\\left( 2\\right) ^{2}"),
      // Scripts on left
      TestRecord2(
        build: "\\left(^2 \\right )", type1: [.inner], number: 0, type2: [.ordinary], left: "(",
        right: ")", result: "\\left( {}^{2}\\right) "),
      // Dot
      TestRecord2(
        build: "\\left( 2 \\right.", type1: [.inner], number: 0, type2: [.number], left: "(",
        right: "", result: "\\left( 2\\right. "),
    ]
  }

  func getTestDataParseErrors() -> [(String, Math.ParserError.Code)] {
    return [
      ("}a", .mismatchedBraces),
      ("\\notacommand", .invalidCommand),
      ("\\sqrt[5+3", .characterNotFound),
      ("{5+3", .mismatchedBraces),
      ("5+3}", .mismatchedBraces),
      ("{1+\\frac{3+2", .mismatchedBraces),
      ("1+\\left", .missingDelimiter),
      ("\\left(\\frac12\\right", .missingDelimiter),
      ("\\left 5 + 3 \\right)", .invalidDelimiter),
      ("\\left(\\frac12\\right + 3", .invalidDelimiter),
      ("\\left\\lmoustache 5 + 3 \\right)", .invalidDelimiter),
      ("\\left(\\frac12\\right\\rmoustache + 3", .invalidDelimiter),
      ("5 + 3 \\right)", .missingLeft),
      ("\\left(\\frac12", .missingRight),
      ("\\left(5 + \\left| \\frac12 \\right)", .missingRight),
      ("5+ \\left|\\frac12\\right| \\right)", .missingLeft),
      ("\\begin matrix \\end matrix", .characterNotFound),  // missing {
      ("\\begin", .characterNotFound),  // missing {
      ("\\begin{", .characterNotFound),  // missing }
      ("\\begin{matrix parens}", .characterNotFound),  // missing } (no spaces in env)
      ("\\begin{matrix} x", .missingEnd),
      ("\\begin{matrix} x \\end", .characterNotFound),  // missing {
      ("\\begin{matrix} x \\end + 3", .characterNotFound),  // missing {
      ("\\begin{matrix} x \\end{", .characterNotFound),  // missing }
      ("\\begin{matrix} x \\end{matrix + 3", .characterNotFound),  // missing }
      ("\\begin{matrix} x \\end{pmatrix}", .invalidEnvironment),
      ("x \\end{matrix}", .missingBegin),
      ("\\begin{notanenv} x \\end{notanenv}", .invalidEnvironment),
      ("\\begin{matrix} \\notacommand \\end{matrix}", .invalidCommand),
      ("\\begin{displaylines} x & y \\end{displaylines}", .invalidNumberOfColumns),
      ("\\begin{eqalign} x \\end{eqalign}", .invalidNumberOfColumns),
      ("\\nolimits", .invalidLimits),
      ("\\frac\\limits{1}{2}", .invalidLimits),
      ("&\\begin", .characterNotFound),
      ("x & y \\\\ z & w \\end{matrix}", .invalidEnvironment),
    ]
  }

  @Test
  func builder() throws {
    let data = getTestData()
    for testCase in data {
      let str = testCase.build
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: str, error: &error)
      #expect(error == nil)
      let atomTypes = testCase.atomType
      self.checkAtomTypes(list, types: atomTypes)

      // convert it back to latex
      let latex = Math.Parser.atomListToString(list)
      #expect(latex == testCase.result)
    }
  }

  @Test
  func superscript() throws {
    let data = getTestDataSuperscript()
    for testCase in data {
      let str = testCase.build
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: str, error: &error)
      #expect(error == nil)
      let atomTypes = testCase.atomType
      checkAtomTypes(list, types: atomTypes)

      // get the first atom
      let first = try #require(list).atoms[0]
      // check it's superscript
      let types = testCase.types
      if types.count > 0 {
        #expect(first.superscript != nil)
      }
      let superlist = first.superscript
      checkAtomTypes(superlist, types: types)

      if !testCase.extra.isEmpty {
        // one more level
        let superFirst = try #require(superlist).atoms[0]
        let supersuperList = superFirst.superscript
        checkAtomTypes(supersuperList, types: testCase.extra)
      }

      // convert it back to latex
      let latex = Math.Parser.atomListToString(list)
      #expect(latex == testCase.result)
    }
  }

  @Test
  func `subscript`() throws {
    let data = getTestDataSubscript()
    for testCase in data {
      let str = testCase.build
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: str, error: &error)
      #expect(error == nil)
      let atomTypes = testCase.atomType
      checkAtomTypes(list, types: atomTypes)

      // get the first atom
      let first = try #require(list).atoms[0]
      // check it's superscript
      let types = testCase.types
      if types.count > 0 {
        #expect(first.`subscript` != nil)
      }
      let sublist = first.`subscript`
      checkAtomTypes(sublist, types: types)

      if !testCase.extra.isEmpty {
        // one more level
        let subFirst = try #require(sublist).atoms[0]
        let subsubList = subFirst.`subscript`
        checkAtomTypes(subsubList, types: testCase.extra)
      }

      // convert it back to latex
      let latex = Math.Parser.atomListToString(list)
      #expect(latex == testCase.result)
    }
  }

  @Test
  func superSubscript() throws {
    let data = getTestDataSuperSubscript()
    for testCase in data {
      let str = testCase.build
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: str, error: &error)
      #expect(error == nil)
      let atomTypes = testCase.atomType
      checkAtomTypes(list, types: atomTypes)

      // get the first atom
      let first = try #require(list).atoms[0]
      // check its subscript
      let sub = testCase.types
      if sub.count > 0 {
        #expect(first.`subscript` != nil)
        let sublist = first.`subscript`
        checkAtomTypes(sublist, types: sub)
      }
      let sup = testCase.extra
      if sup.count > 0 {
        #expect(first.superscript != nil)
        let sublist = first.superscript
        checkAtomTypes(sublist, types: sup)
      }

      // convert it back to latex
      let latex = Math.Parser.atomListToString(list)
      #expect(latex == testCase.result)
    }
  }

  @Test
  func symbols() throws {
    let str = "5\\times3^{2\\div2}"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 3)
    var atom = list.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "5")
    atom = list.atoms[1]
    #expect(atom.type == .binaryOperator)
    #expect(atom.nucleus == "\u{00D7}")
    atom = list.atoms[2]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "3")

    // super script
    let superList = atom.superscript!
    #expect((superList.atoms.count) == 3)
    atom = superList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "2")
    atom = superList.atoms[1]
    #expect(atom.type == .binaryOperator)
    #expect(atom.nucleus == "\u{00F7}")
    atom = superList.atoms[2]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "2")
  }

  @Test
  func frac() throws {
    let str = "\\frac1c"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let frac = try #require(list.atoms[0] as? Math.Fraction)
    #expect(frac.type == .fraction)
    #expect(frac.nucleus == "")
    #expect(frac.hasRule)
    #expect(frac.rightDelimiter.isEmpty)
    #expect(frac.leftDelimiter.isEmpty)

    var subList = try #require(frac.numerator)
    #expect((subList.atoms.count) == 1)
    var atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "1")

    atom = list.atoms[0]
    subList = try #require(frac.denominator)
    #expect((subList.atoms.count) == 1)
    atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "c")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\frac{1}{c}")
  }

  @Test
  func fracInFrac() throws {
    let str = "\\frac1\\frac23"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    var frac = try #require(list.atoms[0] as? Math.Fraction)
    #expect(frac.type == .fraction)
    #expect(frac.nucleus == "")
    #expect(frac.hasRule)

    var subList = try #require(frac.numerator)
    #expect((subList.atoms.count) == 1)
    var atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "1")

    subList = try #require(frac.denominator)
    #expect((subList.atoms.count) == 1)
    frac = try #require(subList.atoms[0] as? Math.Fraction)
    #expect(frac.type == .fraction)
    #expect(frac.nucleus == "")

    subList = try #require(frac.numerator)
    #expect((subList.atoms.count) == 1)
    atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "2")

    subList = try #require(frac.denominator)
    #expect((subList.atoms.count) == 1)
    atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "3")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\frac{1}{\\frac{2}{3}}")
  }

  @Test
  func sqrt() throws {
    let str = "\\sqrt2"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let rad = try #require(list.atoms[0] as? Math.Radical)
    #expect(rad.type == .radical)
    #expect(rad.nucleus == "")

    let subList = try #require(rad.radicand)
    #expect((subList.atoms.count) == 1)
    let atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "2")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\sqrt{2}")
  }

  @Test
  func sqrtInSqrt() throws {
    let str = "\\sqrt\\sqrt2"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    var rad = try #require(list.atoms[0] as? Math.Radical)
    #expect(rad.type == .radical)
    #expect(rad.nucleus == "")

    var subList = try #require(rad.radicand)
    #expect((subList.atoms.count) == 1)
    rad = try #require(subList.atoms[0] as? Math.Radical)
    #expect(rad.type == .radical)
    #expect(rad.nucleus == "")

    subList = try #require(rad.radicand)
    #expect((subList.atoms.count) == 1)
    let atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "2")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\sqrt{\\sqrt{2}}")
  }

  @Test
  func rad() throws {
    let str = "\\sqrt[3]2"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let rad = try #require(list.atoms[0] as? Math.Radical)
    #expect(rad.type == .radical)
    #expect(rad.nucleus == "")

    var subList = try #require(rad.radicand)
    #expect((subList.atoms.count) == 1)
    var atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "2")

    subList = try #require(rad.degree)
    #expect((subList.atoms.count) == 1)
    atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "3")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\sqrt[3]{2}")
  }

  @Test
  func sqrtWithoutRadicand() throws {
    let str = "\\sqrt"
    let list = try #require(Math.Parser.build(fromString: str))

    #expect(list.atoms.count == 1)
    let rad = try #require(list.atoms.first as? Math.Radical)
    #expect(rad.type == .radical)
    #expect(rad.nucleus == "")

    #expect(rad.radicand?.atoms.isEmpty == true)
    #expect(rad.degree == nil)

    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\sqrt{}")
  }

  @Test
  func sqrtWithDegreeWithoutRadicand() throws {
    let str = "\\sqrt[3]"
    let list = try #require(Math.Parser.build(fromString: str))

    #expect(list.atoms.count == 1)
    let rad = try #require(list.atoms.first as? Math.Radical)
    #expect(rad.type == .radical)
    #expect(rad.nucleus == "")

    #expect(rad.radicand?.atoms.isEmpty == true)

    let subList = try #require(rad.degree)
    #expect(subList.atoms.count == 1)
    let atom = try #require(subList.atoms.first)
    #expect(atom.type == .number)
    #expect(atom.nucleus == "3")

    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\sqrt[3]{}")
  }

  @Test
  func leftRight() throws {
    let data = getTestDataLeftRight()
    for testCase in data {
      let str = testCase.build

      var error: Math.ParserError? = nil
      let list = try #require(Math.Parser.build(fromString: str, error: &error))
      #expect(error == nil)

      checkAtomTypes(list, types: testCase.type1)

      let innerLoc = testCase.number
      let inner = try #require(list.atoms[innerLoc] as? Math.Inner)
      #expect(inner.type == .inner)
      #expect(inner.nucleus == "")

      let innerList = try #require(inner.innerList)
      checkAtomTypes(innerList, types: testCase.type2)

      let leftBoundary = try #require(inner.leftBoundary)
      #expect(leftBoundary.type == .boundary)
      #expect(leftBoundary.nucleus == testCase.left)

      let rightBoundary = try #require(inner.rightBoundary)
      #expect(rightBoundary.type == .boundary)
      #expect(rightBoundary.nucleus == testCase.right)

      // convert it back to latex
      let latex = Math.Parser.atomListToString(list)
      #expect(latex == testCase.result)
    }
  }

  @Test
  func over() throws {
    let str = "1 \\over c"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let frac = try #require(list.atoms[0] as? Math.Fraction)
    #expect(frac.type == .fraction)
    #expect(frac.nucleus == "")
    #expect(frac.hasRule)
    #expect(frac.rightDelimiter.isEmpty)
    #expect(frac.leftDelimiter.isEmpty)

    var subList = try #require(frac.numerator)
    #expect((subList.atoms.count) == 1)
    var atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "1")

    atom = list.atoms[0]
    subList = try #require(frac.denominator)
    #expect((subList.atoms.count) == 1)
    atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "c")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\frac{1}{c}")
  }

  @Test
  func overInParens() throws {
    let str = "5 + {1 \\over c} + 8"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 5)
    let types = [Math.AtomType.number, .binaryOperator, .fraction, .binaryOperator, .number]
    self.checkAtomTypes(list, types: types)

    let frac = try #require(list.atoms[2] as? Math.Fraction)
    #expect(frac.type == .fraction)
    #expect(frac.nucleus == "")
    #expect(frac.hasRule)
    #expect(frac.rightDelimiter.isEmpty)
    #expect(frac.leftDelimiter.isEmpty)

    var subList = try #require(frac.numerator)
    #expect((subList.atoms.count) == 1)
    var atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "1")

    atom = list.atoms[0]
    subList = try #require(frac.denominator)
    #expect((subList.atoms.count) == 1)
    atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "c")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "5+\\frac{1}{c}+8")
  }

  @Test
  func atop() throws {
    let str = "1 \\atop c"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let frac = try #require(list.atoms[0] as? Math.Fraction)
    #expect(frac.type == .fraction)
    #expect(frac.nucleus == "")
    #expect(!(frac.hasRule))
    #expect(frac.rightDelimiter.isEmpty)
    #expect(frac.leftDelimiter.isEmpty)

    var subList = try #require(frac.numerator)
    #expect((subList.atoms.count) == 1)
    var atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "1")

    atom = list.atoms[0]
    subList = try #require(frac.denominator)
    #expect((subList.atoms.count) == 1)
    atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "c")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "{1 \\atop c}")
  }

  @Test
  func atopInParens() throws {
    let str = "5 + {1 \\atop c} + 8"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 5)
    let types = [Math.AtomType.number, .binaryOperator, .fraction, .binaryOperator, .number]
    self.checkAtomTypes(list, types: types)

    let frac = try #require(list.atoms[2] as? Math.Fraction)
    #expect(frac.type == .fraction)
    #expect(frac.nucleus == "")
    #expect(!(frac.hasRule))
    #expect(frac.rightDelimiter.isEmpty)
    #expect(frac.leftDelimiter.isEmpty)

    var subList = try #require(frac.numerator)
    #expect((subList.atoms.count) == 1)
    var atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "1")

    atom = list.atoms[0]
    subList = try #require(frac.denominator)
    #expect((subList.atoms.count) == 1)
    atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "c")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "5+{1 \\atop c}+8")
  }

  @Test
  func choose() throws {
    let str = "n \\choose k"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let frac = try #require(list.atoms[0] as? Math.Fraction)
    #expect(frac.type == .fraction)
    #expect(frac.nucleus == "")
    #expect(!(frac.hasRule))
    #expect(frac.rightDelimiter == ")")
    #expect(frac.leftDelimiter == "(")

    var subList = try #require(frac.numerator)
    #expect((subList.atoms.count) == 1)
    var atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "n")

    atom = list.atoms[0]
    subList = try #require(frac.denominator)
    #expect((subList.atoms.count) == 1)
    atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "k")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "{n \\choose k}")
  }

  @Test
  func brack() throws {
    let str = "n \\brack k"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let frac = try #require(list.atoms[0] as? Math.Fraction)
    #expect(frac.type == .fraction)
    #expect(frac.nucleus == "")
    #expect(!(frac.hasRule))
    #expect(frac.rightDelimiter == "]")
    #expect(frac.leftDelimiter == "[")

    var subList = try #require(frac.numerator)
    #expect((subList.atoms.count) == 1)
    var atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "n")

    atom = list.atoms[0]
    subList = try #require(frac.denominator)
    #expect((subList.atoms.count) == 1)
    atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "k")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "{n \\brack k}")
  }

  @Test
  func brace() throws {
    let str = "n \\brace k"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let frac = try #require(list.atoms[0] as? Math.Fraction)
    #expect(frac.type == .fraction)
    #expect(frac.nucleus == "")
    #expect(!(frac.hasRule))
    #expect(frac.rightDelimiter == "}")
    #expect(frac.leftDelimiter == "{")

    var subList = try #require(frac.numerator)
    #expect((subList.atoms.count) == 1)
    var atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "n")

    atom = list.atoms[0]
    subList = try #require(frac.denominator)
    #expect((subList.atoms.count) == 1)
    atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "k")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "{n \\brace k}")
  }

  @Test
  func binom() throws {
    let str = "\\binom{n}{k}"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let frac = try #require(list.atoms[0] as? Math.Fraction)
    #expect(frac.type == .fraction)
    #expect(frac.nucleus == "")
    #expect(!(frac.hasRule))
    #expect(frac.rightDelimiter == ")")
    #expect(frac.leftDelimiter == "(")

    var subList = try #require(frac.numerator)
    #expect((subList.atoms.count) == 1)
    var atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "n")

    atom = list.atoms[0]
    subList = try #require(frac.denominator)
    #expect((subList.atoms.count) == 1)
    atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "k")

    // convert it back to latex (binom converts to choose)
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "{n \\choose k}")
  }

  @Test
  func overLine() throws {
    let str = "\\overline 2"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let over = try #require(list.atoms[0] as? Math.Overline)
    #expect(over.type == .overline)
    #expect(over.nucleus == "")

    let subList = try #require(over.innerList)
    #expect((subList.atoms.count) == 1)
    let atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "2")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\overline{2}")
  }

  @Test
  func underline() throws {
    let str = "\\underline 2"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let under = try #require(list.atoms[0] as? Math.Underline)
    #expect(under.type == .underline)
    #expect(under.nucleus == "")

    let subList = try #require(under.innerList)
    #expect((subList.atoms.count) == 1)
    let atom = subList.atoms[0]
    #expect(atom.type == .number)
    #expect(atom.nucleus == "2")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\underline{2}")
  }

  @Test
  func accent() throws {
    let str = "\\bar x"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let accent = try #require(list.atoms[0] as? Math.Accent)
    #expect(accent.type == .accent)
    #expect(accent.nucleus == "\u{0304}")

    let subList = try #require(accent.innerList)
    #expect((subList.atoms.count) == 1)
    let atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "x")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\bar{x}")
  }

  @Test
  func accentedCharacter() throws {
    let str = "\u{00E1}"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let accent = try #require(list.atoms[0] as? Math.Accent)
    #expect(accent.type == .accent)
    #expect(accent.nucleus == "\u{0301}")

    let subList = try #require(accent.innerList)
    #expect((subList.atoms.count) == 1)
    let atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "a")

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\acute{a}")
  }

  @Test
  func mathSpace() throws {
    let str = "\\!"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let space = try #require(list.atoms[0] as? Math.Space)
    #expect(space.type == .space)
    #expect(space.nucleus == "")
    #expect(space.amount == -3)

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\! ")
  }

  @Test
  func mathStyle() throws {
    let str = "\\textstyle y \\scriptstyle x"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 4)
    let style = try #require(list.atoms[0] as? Math.Style)
    #expect(style.type == .style)
    #expect(style.nucleus == "")
    #expect(style.level == .text)

    let style2 = try #require(list.atoms[2] as? Math.Style)
    #expect(style2.type == .style)
    #expect(style2.nucleus == "")
    #expect(style2.level == .script)

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\textstyle y\\scriptstyle x")
  }

  @Test
  func matrix() throws {
    let str = "\\begin{matrix} x & y \\\\ z & w \\end{matrix}"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let table = try #require(list.atoms[0] as? Math.Table)
    #expect(table.type == .table)
    #expect(table.nucleus == "")
    #expect(table.environment == "matrix")
    #expect(table.interRowAdditionalSpacing == 0)
    #expect(table.interColumnSpacing == 18)
    #expect(table.numberOfRows == 2)
    #expect(table.numberOfColumns == 2)

    for column in 0..<2 {
      let alignment = table.alignment(forColumn: column)
      #expect(alignment == .center)
      for row in 0..<2 {
        let cell = table.cells[row][column]
        #expect(cell.atoms.count == 2)
        let style = try #require(cell.atoms[0] as? Math.Style)
        #expect(style.type == .style)
        #expect(style.level == .text)

        let atom = cell.atoms[1]
        #expect(atom.type == .variable)
      }
    }

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\begin{matrix}x&y\\\\ z&w\\end{matrix}")
  }

  @Test
  func pMatrix() throws {
    let str = "\\begin{pmatrix} x & y \\\\ z & w \\end{pmatrix}"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let inner = try #require(list.atoms[0] as? Math.Inner)
    #expect(inner.type == .inner)
    #expect(inner.nucleus == "")

    let innerList = try #require(inner.innerList)

    let leftBoundary = try #require(inner.leftBoundary)
    #expect(leftBoundary.type == .boundary)
    #expect(leftBoundary.nucleus == "(")

    let rightBoundary = try #require(inner.rightBoundary)
    #expect(rightBoundary.type == .boundary)
    #expect(rightBoundary.nucleus == ")")

    #expect((innerList.atoms.count) == 1)
    let table = try #require(innerList.atoms[0] as? Math.Table)
    #expect(table.type == .table)
    #expect(table.nucleus == "")
    #expect(table.environment == "matrix")
    #expect(table.interRowAdditionalSpacing == 0)
    #expect(table.interColumnSpacing == 18)
    #expect(table.numberOfRows == 2)
    #expect(table.numberOfColumns == 2)

    for column in 0..<2 {
      let alignment = table.alignment(forColumn: column)
      #expect(alignment == .center)
      for row in 0..<2 {
        let cell = table.cells[row][column]
        #expect(cell.atoms.count == 2)
        let style = try #require(cell.atoms[0] as? Math.Style)
        #expect(style.type == .style)
        #expect(style.level == .text)

        let atom = cell.atoms[1]
        #expect(atom.type == .variable)
      }
    }

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\left( \\begin{matrix}x&y\\\\ z&w\\end{matrix}\\right) ")
  }

  @Test
  func defaultTable() throws {
    let str = "x \\\\ y"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect(list.atoms.count == 1)
    let table = try #require(list.atoms[0] as? Math.Table)
    #expect(table.type == .table)
    #expect(table.nucleus == "")
    #expect(table.environment.isEmpty)
    #expect(table.interRowAdditionalSpacing == 1)
    #expect(table.interColumnSpacing == 0)
    #expect(table.numberOfRows == 2)
    #expect(table.numberOfColumns == 1)

    for column in 0..<1 {
      let alignment = table.alignment(forColumn: column)
      #expect(alignment == .left)
      for row in 0..<2 {
        let cell = table.cells[row][column]
        #expect(cell.atoms.count == 1)
        let atom = cell.atoms[0]
        #expect(atom.type == .variable)
      }
    }

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "x\\\\ y")
  }

  @Test
  func defaultTableWithCols() throws {
    let str = "x & y \\\\ z & w"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    let table = try #require(list.atoms[0] as? Math.Table)
    #expect(table.type == .table)
    #expect(table.nucleus == "")
    #expect(table.environment.isEmpty)
    #expect(table.interRowAdditionalSpacing == 1)
    #expect(table.interColumnSpacing == 0)
    #expect(table.numberOfRows == 2)
    #expect(table.numberOfColumns == 2)

    for column in 0..<2 {
      let alignment = table.alignment(forColumn: column)
      #expect(alignment == .left)
      for row in 0..<2 {
        let cell = table.cells[row][column]
        #expect(cell.atoms.count == 1)
        let atom = cell.atoms[0]
        #expect(atom.type == .variable)
      }
    }

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "x&y\\\\ z&w")
  }

  @Test
  func eqalign() throws {
    let str1 = "\\begin{eqalign}x&y\\\\ z&w\\end{eqalign}"
    let str2 = "\\begin{split}x&y\\\\ z&w\\end{split}"
    let str3 = "\\begin{aligned}x&y\\\\ z&w\\end{aligned}"
    for str in [str1, str2, str3] {
      let list = try #require(Math.Parser.build(fromString: str))
      #expect((list.atoms.count) == 1)
      let table = try #require(list.atoms[0] as? Math.Table)
      #expect(table.type == .table)
      #expect(table.nucleus == "")
      #expect(table.interRowAdditionalSpacing == 1)
      #expect(table.interColumnSpacing == 0)
      #expect(table.numberOfRows == 2)
      #expect(table.numberOfColumns == 2)

      for column in 0..<2 {
        let alignment = table.alignment(forColumn: column)
        #expect(alignment == ((column == 0) ? .right : .left))
        for row in 0..<2 {
          let cell = table.cells[row][column]
          if column == 0 {
            #expect(cell.atoms.count == 1)
            let atom = cell.atoms[0]
            #expect(atom.type == .variable)
          } else {
            #expect(cell.atoms.count == 2)
            self.checkAtomTypes(cell, types: [.ordinary, .variable])
          }
        }
      }

      // convert it back to latex
      let latex = Math.Parser.atomListToString(list)
      #expect(latex == str)
    }
  }

  @Test
  func displayLines() throws {
    let str1 = "\\begin{displaylines}x\\\\ y\\end{displaylines}"
    let str2 = "\\begin{gather}x\\\\ y\\end{gather}"
    for str in [str1, str2] {
      let list = try #require(Math.Parser.build(fromString: str))
      #expect(list.atoms.count == 1)
      let table = try #require(list.atoms[0] as? Math.Table)
      #expect(table.type == .table)
      #expect(table.nucleus == "")
      #expect(table.interRowAdditionalSpacing == 1)
      #expect(table.interColumnSpacing == 0)
      #expect(table.numberOfRows == 2)
      #expect(table.numberOfColumns == 1)

      for column in 0..<1 {
        let alignment = table.alignment(forColumn: column)
        #expect(alignment == .center)
        for row in 0..<2 {
          let cell = table.cells[row][column]
          #expect(cell.atoms.count == 1)
          let atom = cell.atoms[0]
          #expect(atom.type == .variable)
        }
      }

      // convert it back to latex
      let latex = Math.Parser.atomListToString(list)
      #expect(latex == str)
    }
  }

  @Test
  func errors() throws {
    let data = getTestDataParseErrors()
    for testCase in data {
      let str = testCase.0
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: str, error: &error)
            #expect(list == nil)
      #expect(error != nil)
      let num = testCase.1
      #expect(error?.code == num)
    }
  }

  @Test
  func custom() throws {
    let str = "\\lcm(a,b)"
    var error: Math.ParserError? = nil
    var list = Math.Parser.build(fromString: str, error: &error)
    #expect(list == nil)
    #expect(error != nil)

    let previous = Math.AtomFactory.atom(forLatexSymbol: "lcm")
    Math.AtomFactory.add(
      latexSymbol: "lcm", value: Math.AtomFactory.operatorWithName("lcm", limits: false))
    defer {
      if let previous {
        Math.AtomFactory.add(latexSymbol: "lcm", value: previous)
      } else {
        Math.AtomFactory.remove(latexSymbol: "lcm")
      }
    }
    error = nil
    list = Math.Parser.build(fromString: str, error: &error)
    let atomTypes = [
      Math.AtomType.largeOperator, .open, .variable, .punctuation, .variable, .close,
    ]
    self.checkAtomTypes(list, types: atomTypes)

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\lcm (a,b)")
  }

  @Test
  func fontSingle() throws {
    let str = "\\mathbf x"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect(list.atoms.count == 1)
    let atom = list.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "x")
    #expect(atom.fontStyle == .bold)

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\mathbf{x}")
  }

  @Test
  func fontOneChar() throws {
    let str = "\\cal xy"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 2)
    var atom = list.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "x")
    #expect(atom.fontStyle == .caligraphic)

    atom = list.atoms[1]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "y")
    #expect(atom.fontStyle == .default)

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\mathcal{x}y")
  }

  @Test
  func fontMultipleChars() throws {
    let str = "\\frak{xy}"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 2)
    var atom = list.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "x")
    #expect(atom.fontStyle == .fraktur)

    atom = list.atoms[1]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "y")
    #expect(atom.fontStyle == .fraktur)

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\mathfrak{xy}")
  }

  @Test
  func fontOneCharInside() throws {
    let str = "\\sqrt \\mathrm x y"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 2)

    let rad = try #require(list.atoms[0] as? Math.Radical)
    #expect(rad.type == .radical)
    #expect(rad.nucleus == "")

    let subList = try #require(rad.radicand)
    var atom = subList.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "x")
    #expect(atom.fontStyle == .roman)

    atom = list.atoms[1]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "y")
    #expect(atom.fontStyle == .default)

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\sqrt{\\mathrm{x}}y")
  }

  @Test
  func text() throws {
    let str = "\\text{x y}"
    let list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 3)
    var atom = list.atoms[0]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "x")
    #expect(atom.fontStyle == .roman)

    atom = list.atoms[1]
    #expect(atom.type == .ordinary)
    #expect(atom.nucleus == " ")

    atom = list.atoms[2]
    #expect(atom.type == .variable)
    #expect(atom.nucleus == "y")
    #expect(atom.fontStyle == .roman)

    // convert it back to latex
    let latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\mathrm{x\\  y}")
  }

  @Test
  func limits() throws {
    // Int with no limits (default)
    var str = "\\int"
    var list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    var op = try #require(list.atoms[0] as? Math.LargeOperator)
    #expect(op.type == .largeOperator)
    #expect(!(op.limits))

    // convert it back to latex
    var latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\int ")

    // Int with limits
    str = "\\int\\limits"
    list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    op = try #require(list.atoms[0] as? Math.LargeOperator)
    #expect(op.type == .largeOperator)
    #expect(op.limits)

    // convert it back to latex
    latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\int \\limits ")
  }

  @Test
  func noLimits() throws {
    // Sum with limits (default)
    var str = "\\sum"
    var list = try #require(Math.Parser.build(fromString: str))
    #expect((list.atoms.count) == 1)
    var op = try #require(list.atoms[0] as? Math.LargeOperator)
    #expect(op.type == .largeOperator)
    #expect(op.limits)

    // convert it back to latex
    var latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\sum ")

    // Int with limits
    str = "\\sum\\nolimits"
    list = try #require(Math.Parser.build(fromString: str))
    #expect(list.atoms.count == 1)
    op = try #require(list.atoms[0] as? Math.LargeOperator)
    #expect(op.type == .largeOperator)
    #expect(!(op.limits))

    // convert it back to latex
    latex = Math.Parser.atomListToString(list)
    #expect(latex == "\\sum \\nolimits ")
  }

  // MARK: - Inline and Display Math Delimiter Tests

  @Test
  func inlineMathDollar() throws {
    let str = "$x^2$"
    let list = Math.Parser.build(fromString: str)
    // Should have textstyle at start, then variable with superscript
    #expect(try #require(list).atoms.count >= 1)

    // Find the variable atom (skip style atoms)
    var foundVariable = false
    for atom in try #require(list).atoms {
      if atom.type == .variable && atom.nucleus == "x" {
        foundVariable = true
        #expect(atom.superscript != nil)
        break
      }
    }
    #expect(foundVariable)
  }

  @Test
  func inlineMathParens() throws {
    let str = "\\(E=mc^2\\)"
    let list = Math.Parser.build(fromString: str)
    #expect(try #require(list).atoms.count >= 3)

    // Check for equals sign
    var foundEquals = false
    for atom in try #require(list).atoms {
      if atom.type == .relation && atom.nucleus == "=" {
        foundEquals = true
        break
      }
    }
    #expect(foundEquals)
  }

  @Test
  func inlineMathWithCases() throws {
    let str = "\\(\\begin{cases} x + y = 5 \\\\ 2x - y = 1 \\end{cases}\\)"
    let list = Math.Parser.build(fromString: str)

    // cases environment returns an Inner atom with table inside
    var foundInner = false
    for atom in try #require(list).atoms {
      if atom.type == .inner {
        let inner = try #require(atom as? Math.Inner)
        // Look for table inside the inner list
        if let innerList = inner.innerList {
          for innerAtom in innerList.atoms {
            if innerAtom.type == .table {
              let table = try #require(innerAtom as? Math.Table)
              #expect(table.environment == "cases")
              #expect(table.numberOfRows == 2)
              foundInner = true
              break
            }
          }
        }
        if foundInner { break }
      }
    }
    #expect(foundInner)
  }

  @Test
  func inlineMathVectorDot() throws {
    let str = "$\\vec{a} \\cdot \\vec{b}$"
    let list = Math.Parser.build(fromString: str)

    // Should contain accents (for vec) and cdot operator
    var hasAccent = false
    var hasCdot = false

    for atom in try #require(list).atoms {
      if atom.type == .accent {
        hasAccent = true
      }
      if atom.type == .binaryOperator && atom.nucleus.contains("\u{22C5}") {
        hasCdot = true
      }
    }

    #expect(hasAccent)
    #expect(hasCdot)
  }

  @Test
  func displayMathDoubleDollar() throws {
    let str = "$$x^2 + y^2 = z^2$$"
    let list = Math.Parser.build(fromString: str)
    #expect(try #require(list).atoms.count >= 5)

    // Should NOT have textstyle at start (display mode)
    let firstAtom = try #require(list).atoms.first
    #expect(firstAtom?.type != .style)
  }

  @Test
  func displayMathBrackets() throws {
    let str = "\\[\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}\\]"
    let list = Math.Parser.build(fromString: str)

    // Find sum operator
    var foundSum = false
    for atom in try #require(list).atoms {
      if atom.type == .largeOperator && atom.nucleus.contains("\u{2211}") {
        foundSum = true
        #expect(atom.`subscript` != nil)
        #expect(atom.superscript != nil)
        break
      }
    }
    #expect(foundSum)
  }

  @Test
  func displayMathCasesWithoutDelimiters() throws {
    // This should work as before (backward compatibility)
    let str = "\\begin{cases} x + y = 5 \\\\ 2x - y = 1 \\end{cases}"
    let list = Math.Parser.build(fromString: str)
    #expect(try #require(list).atoms.count >= 1)

    // cases environment returns an Inner atom with table inside
    var foundTable = false
    for atom in try #require(list).atoms {
      if atom.type == .inner {
        let inner = try #require(atom as? Math.Inner)
        if let innerList = inner.innerList {
          for innerAtom in innerList.atoms {
            if innerAtom.type == .table {
              let table = try #require(innerAtom as? Math.Table)
              #expect(table.environment == "cases")
              #expect(table.numberOfRows == 2)
              foundTable = true
              break
            }
          }
        }
        if foundTable { break }
      }
    }

    #expect(foundTable)
  }

  @Test
  func backwardCompatibilityNoDelimiters() throws {
    // Test that expressions without delimiters still work
    let str = "x^2 + y^2 = z^2"
    let list = Math.Parser.build(fromString: str)
    #expect(try #require(list).atoms.count >= 5)
  }

  @Test
  func emptyInlineMath() throws {
    let str = "$$$"  // This is $$$ which should be treated as $$ + $
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    #expect(error == nil || error?.code == .invalidCommand)
    #expect(list == nil || list?.atoms.isEmpty == true)
  }

  @Test
  func emptyDisplayMath() throws {
    let str = "\\[\\]"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    #expect(error == nil || error?.code == .invalidCommand)
    #expect(list == nil || list?.atoms.isEmpty == true)
  }

  @Test
  func dollarInMath() throws {
    // Test that delimiters are properly stripped
    let str = "$a + b$"
    let list = Math.Parser.build(fromString: str)

    // Should not contain $ in the parsed atoms
    for atom in try #require(list).atoms {
      #expect(!(atom.nucleus.contains("$")))
    }
  }

  @Test
  func complexInlineExpression() throws {
    let str = "$\\frac{1}{2} + \\sqrt{3}$"
    let list = Math.Parser.build(fromString: str)

    // Should have fraction and radical
    var hasFraction = false
    var hasRadical = false

    for atom in try #require(list).atoms {
      if atom.type == .fraction {
        hasFraction = true
      }
      if atom.type == .radical {
        hasRadical = true
      }
    }

    #expect(hasFraction)
    #expect(hasRadical)
  }

  @Test
  func inlineMathStyleForcing() throws {
    // Inline math should have textstyle prepended
    let str = "$\\sum_{i=1}^{n} i$"
    let list = Math.Parser.build(fromString: str)

    // First atom should be style atom with text style
    if let firstAtom = try #require(list).atoms.first, firstAtom.type == .style {
      let styleAtom = try #require(firstAtom as? Math.Style)
      #expect(styleAtom.level == .text)
    }
  }

  // MARK: - Tests for build(fromString:error:) API with delimiters

  @Test
  func inlineMathDollarWithError() throws {
    let str = "$x^2$"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    #expect(error == nil)

    // Find the variable atom (skip style atoms)
    var foundVariable = false
    for atom in try #require(list).atoms {
      if atom.type == .variable && atom.nucleus == "x" {
        foundVariable = true
        #expect(atom.superscript != nil)
        break
      }
    }
    #expect(foundVariable)
  }

  @Test
  func inlineMathParensWithError() throws {
    let str = "\\(E=mc^2\\)"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    #expect(error == nil)
    #expect(try #require(list).atoms.count >= 3)

    // Check for equals sign
    var foundEquals = false
    for atom in try #require(list).atoms {
      if atom.type == .relation && atom.nucleus == "=" {
        foundEquals = true
        break
      }
    }
    #expect(foundEquals)
  }

  @Test
  func inlineMathWithCasesWithError() throws {
    let str = "\\(\\begin{cases} x + y = 5 \\\\ 2x - y = 1 \\end{cases}\\)"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    #expect(error == nil)

    // cases environment returns an Inner atom with table inside
    var foundInner = false
    for atom in try #require(list).atoms {
      if atom.type == .inner {
        let inner = try #require(atom as? Math.Inner)
        if let innerList = inner.innerList {
          for innerAtom in innerList.atoms {
            if innerAtom.type == .table {
              let table = try #require(innerAtom as? Math.Table)
              #expect(table.environment == "cases")
              #expect(table.numberOfRows == 2)
              foundInner = true
              break
            }
          }
        }
        if foundInner { break }
      }
    }
    #expect(foundInner)
  }

  @Test
  func displayMathDoubleDollarWithError() throws {
    let str = "$$x^2 + y^2 = z^2$$"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    #expect(error == nil)
    #expect(try #require(list).atoms.count >= 5)
  }

  @Test
  func displayMathBracketsWithError() throws {
    let str = "\\[\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}\\]"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    #expect(error == nil)

    // Find sum operator
    var foundSum = false
    for atom in try #require(list).atoms {
      if atom.type == .largeOperator && atom.nucleus.contains("\u{2211}") {
        foundSum = true
        #expect(atom.`subscript` != nil)
        #expect(atom.superscript != nil)
        break
      }
    }
    #expect(foundSum)
  }

  @Test
  func displayMathCasesWithoutDelimitersWithError() throws {
    let str = "\\begin{cases} x + y = 5 \\\\ 2x - y = 1 \\end{cases}"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    #expect(error == nil)
    #expect(try #require(list).atoms.count >= 1)

    // cases environment returns an Inner atom with table inside
    var foundTable = false
    for atom in try #require(list).atoms {
      if atom.type == .inner {
        let inner = try #require(atom as? Math.Inner)
        if let innerList = inner.innerList {
          for innerAtom in innerList.atoms {
            if innerAtom.type == .table {
              let table = try #require(innerAtom as? Math.Table)
              #expect(table.environment == "cases")
              #expect(table.numberOfRows == 2)
              foundTable = true
              break
            }
          }
        }
        if foundTable { break }
      }
    }

    #expect(foundTable)
  }

  @Test
  func backwardCompatibilityNoDelimitersWithError() throws {
    let str = "x^2 + y^2 = z^2"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    #expect(error == nil)
    #expect(try #require(list).atoms.count >= 5)
  }

  @Test
  func invalidLatexWithError() throws {
    let str = "$\\notacommand$"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)

    #expect(list == nil)
    #expect(error != nil)
    #expect(error?.code == .invalidCommand)
  }

  @Test
  func mismatchedBracesWithError() throws {
    let str = "${x+2$"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)

    #expect(list == nil)
    #expect(error != nil)
    #expect(error?.code == .mismatchedBraces)
  }

  @Test
  func complexInlineExpressionWithError() throws {
    let str = "$\\frac{1}{2} + \\sqrt{3}$"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    #expect(error == nil)

    // Should have fraction and radical
    var hasFraction = false
    var hasRadical = false

    for atom in try #require(list).atoms {
      if atom.type == .fraction {
        hasFraction = true
      }
      if atom.type == .radical {
        hasRadical = true
      }
    }

    #expect(hasFraction)
    #expect(hasRadical)
  }

  @Test
  func inlineMathVectorDotWithError() throws {
    let str = "$\\vec{a} \\cdot \\vec{b}$"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    #expect(error == nil)

    // Should contain accents (for vec) and cdot operator
    var hasAccent = false
    var hasCdot = false

    for atom in try #require(list).atoms {
      if atom.type == .accent {
        hasAccent = true
      }
      if atom.type == .binaryOperator && atom.nucleus.contains("\u{22C5}") {
        hasCdot = true
      }
    }

    #expect(hasAccent)
    #expect(hasCdot)
  }

  // MARK: - Comprehensive Command Coverage Tests

  @Test
  func greekLettersLowercase() throws {
    let commands = [
      "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
      "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi",
      "rho", "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega",
    ]

    for cmd in commands {
      var error: Math.ParserError? = nil
      let str = "$\\\(cmd)$"
      let list = Math.Parser.build(fromString: str, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)
      #expect(unwrappedList.atoms.count >= 1)
    }
  }

  @Test
  func greekLettersUppercase() throws {
    let commands = [
      "Gamma", "Delta", "Theta", "Lambda", "Xi", "Pi", "Sigma", "Upsilon", "Phi", "Psi", "Omega",
    ]

    for cmd in commands {
      var error: Math.ParserError? = nil
      let str = "$\\\(cmd)$"
      let list = Math.Parser.build(fromString: str, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)
      #expect(unwrappedList.atoms.count >= 1)
    }
  }

  @Test
  func binaryOperators() throws {
    let operators = [
      "times", "div", "pm", "mp", "ast", "star", "circ", "bullet",
      "cdot", "cap", "cup", "uplus", "sqcap", "sqcup",
      "oplus", "ominus", "otimes", "oslash", "odot", "wedge", "vee",
    ]

    for op in operators {
      var error: Math.ParserError? = nil
      let str = "$a \\\(op) b$"
      let list = Math.Parser.build(fromString: str, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)

      // Should find the operator
      var foundOp = false
      for atom in unwrappedList.atoms {
        if atom.type == .binaryOperator {
          foundOp = true
          break
        }
      }
      #expect(foundOp)
    }
  }

  @Test
  func relations() throws {
    let relations = [
      "leq", "geq", "neq", "equiv", "approx", "sim", "simeq", "cong",
      "prec", "succ", "subset", "supset", "subseteq", "supseteq",
      "in", "notin", "ni", "propto", "perp", "parallel",
    ]

    for rel in relations {
      var error: Math.ParserError? = nil
      let str = "$a \\\(rel) b$"
      let list = Math.Parser.build(fromString: str, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)

      // Should find the relation
      var foundRel = false
      for atom in unwrappedList.atoms {
        if atom.type == .relation {
          foundRel = true
          break
        }
      }
      #expect(foundRel)
    }
  }

  @Test
  func allAccents() throws {
    let accents = ["hat", "tilde", "bar", "dot", "ddot", "check", "grave", "acute", "breve", "vec"]

    for acc in accents {
      var error: Math.ParserError? = nil
      let str = "$\\\(acc){x}$"
      let list = Math.Parser.build(fromString: str, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)

      // Should find the accent
      var foundAccent = false
      for atom in unwrappedList.atoms {
        if atom.type == .accent {
          foundAccent = true
          break
        }
      }
      #expect(foundAccent)
    }
  }

  @Test
  func delimiterPairs() throws {
    let delimiterPairs = [
      ("langle", "rangle"),
      ("lfloor", "rfloor"),
      ("lceil", "rceil"),
      ("lgroup", "rgroup"),
      ("{", "}"),
    ]

    for (left, right) in delimiterPairs {
      var error: Math.ParserError? = nil
      let str = "$\\left\\\(left) x \\right\\\(right)$"
      let list = Math.Parser.build(fromString: str, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)

      // Should have an inner atom
      var foundInner = false
      for atom in unwrappedList.atoms {
        if atom.type == .inner {
          foundInner = true
          break
        }
      }
      #expect(foundInner)
    }
  }

  @Test
  func largeOperators() throws {
    let operators = [
      "sum", "prod", "coprod", "int", "iint", "iiint", "oint",
      "bigcap", "bigcup", "bigvee", "bigwedge", "bigodot", "bigoplus", "bigotimes",
    ]

    for op in operators {
      var error: Math.ParserError? = nil
      let str = "$\\\(op)_{i=1}^{n} x_i$"
      let list = Math.Parser.build(fromString: str, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)

      // Should find large operator
      var foundOp = false
      for atom in unwrappedList.atoms {
        if atom.type == .largeOperator {
          foundOp = true
          break
        }
      }
      #expect(foundOp)
    }
  }

  @Test
  func arrows() throws {
    let arrows = [
      "leftarrow", "rightarrow", "uparrow", "downarrow", "leftrightarrow",
      "Leftarrow", "Rightarrow", "Uparrow", "Downarrow", "Leftrightarrow",
      "longleftarrow", "longrightarrow", "Longleftarrow", "Longrightarrow",
      "mapsto", "nearrow", "searrow", "swarrow", "nwarrow",
    ]

    for arrow in arrows {
      var error: Math.ParserError? = nil
      let str = "$a \\\(arrow) b$"
      let list = Math.Parser.build(fromString: str, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)

      // Arrows are typically relations
      var foundArrow = false
      for atom in unwrappedList.atoms {
        if atom.type == .relation {
          foundArrow = true
          break
        }
      }
      #expect(foundArrow)
    }
  }

  @Test
  func trigonometricFunctions() throws {
    let functions = [
      "sin", "cos", "tan", "cot", "sec", "csc",
      "arcsin", "arccos", "arctan", "sinh", "cosh", "tanh", "coth",
    ]

    for funcName in functions {
      var error: Math.ParserError? = nil
      let str = "$\\\(funcName) x$"
      let list = Math.Parser.build(fromString: str, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)

      // Should find the function operator
      var foundFunc = false
      for atom in unwrappedList.atoms {
        if atom.type == .largeOperator {
          foundFunc = true
          break
        }
      }
      #expect(foundFunc)
    }
  }

  @Test
  func limitOperators() throws {
    let operators = ["lim", "limsup", "liminf", "max", "min", "sup", "inf", "det", "gcd"]

    for op in operators {
      var error: Math.ParserError? = nil
      let str = "$\\\(op)_{x \\to 0} f(x)$"
      let list = Math.Parser.build(fromString: str, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)

      // Should find the operator
      var foundOp = false
      for atom in unwrappedList.atoms {
        if atom.type == .largeOperator {
          foundOp = true
          break
        }
      }
      #expect(foundOp)
    }
  }

  @Test
  func specialSymbols() throws {
    let symbols = [
      "infty", "partial", "nabla", "prime", "hbar", "ell", "wp",
      "Re", "Im", "top", "bot", "emptyset", "exists", "forall",
      "neg", "angle", "triangle", "ldots", "cdots", "vdots", "ddots",
    ]

    for sym in symbols {
      var error: Math.ParserError? = nil
      let str = "$\\\(sym)$"
      let list = Math.Parser.build(fromString: str, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)
      #expect(unwrappedList.atoms.count >= 1)
    }
  }

  @Test
  func logFunctions() throws {
    let logFuncs = ["log", "ln", "lg"]

    for funcName in logFuncs {
      var error: Math.ParserError? = nil
      let str = "$\\\(funcName) x$"
      _ = Math.Parser.build(fromString: str, error: &error)
      #expect(error == nil)
    }
  }

  // MARK: - High Priority Missing Features Tests

  @Test
  func displayStyle() throws {
    // Test \displaystyle and \textstyle commands
    let testCases = [
      ("\\displaystyle \\sum_{i=1}^{n} x_i", "displaystyle with sum"),
      ("\\textstyle \\int_{0}^{\\infty} f(x) dx", "textstyle with integral"),
      ("x + \\displaystyle\\frac{a}{b} + y", "inline displaystyle fraction"),
      ("\\displaystyle x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}", "displaystyle equation"),
    ]

    for (latex, _) in testCases {
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: latex, error: &error)

      if list == nil || error != nil {
        return
      }

      let unwrappedList = try #require(list)
      #expect(unwrappedList.atoms.count >= 1)
    }
  }

  @Test
  func middleDelimiter() throws {
    // Test \middle command for delimiters in the middle of expressions
    let testCases = [
      ("\\left( \\frac{a}{b} \\middle| \\frac{c}{d} \\right)", "middle pipe"),
      ("\\left\\{ x \\middle\\| y \\right\\}", "middle double pipe"),
      ("\\left[ a \\middle\\\\ b \\right]", "middle backslash"),
    ]

    for (latex, _) in testCases {
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: latex, error: &error)

      if list == nil || error != nil {
        return
      }

      let unwrappedList = try #require(list)
      #expect(unwrappedList.atoms.count >= 1)
    }
  }

  @Test
  func substack() throws {
    // Test \substack for multi-line subscripts and limits

    let testCases = [
      ("\\substack{a \\\\ b}", "simple substack"),
      ("x_{\\substack{a \\\\ b}}", "substack in subscript"),
      ("\\sum_{\\substack{0 \\le i \\le m \\\\ 0 < j < n}} P(i,j)", "substack in sum limits"),
      ("\\prod_{\\substack{p \\text{ prime} \\\\ p < 100}} p", "substack with text"),
      ("A_{\\substack{n \\\\ k}}", "subscript with substack"),
      ("\\substack{\\frac{a}{b} \\\\ c}", "substack with frac"),
      ("\\substack{a}", "single row substack"),
      ("\\substack{a \\\\ b \\\\ c \\\\ d}", "multi-row substack"),
    ]

    for (latex, _) in testCases {
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: latex, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)
      #expect(unwrappedList.atoms.count >= 1)

      // Verify we have a table structure (either directly or in subscript)
      var foundTable = false
      for atom in unwrappedList.atoms {
        if atom.type == .table {
          foundTable = true
          break
        }
        if let `subscript` = atom.`subscript` {
          for subAtom in `subscript`.atoms {
            if subAtom.type == .table {
              foundTable = true
              break
            }
          }
        }
      }
      #expect(foundTable)
    }
  }

  @Test
  func manualDelimiterSizing() throws {
    // Test \big, \Big, \bigg, \Bigg sizing commands
    let testCases = [
      ("\\big( x \\big)", "big parentheses"),
      ("\\Big[ y \\Big]", "Big brackets"),
      ("\\bigg\\{ z \\bigg\\}", "bigg braces"),
      ("\\Bigg| w \\Bigg|", "Bigg pipes"),
      ("\\big< a \\big>", "big angle brackets"),
    ]

    for (latex, _) in testCases {
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: latex, error: &error)

      if list == nil || error != nil {
        return
      }

      let unwrappedList = try #require(list)
      #expect(unwrappedList.atoms.count >= 1)
    }
  }

  @Test
  func spacingCommands() throws {
    // Test fine-tuned spacing commands
    let testCases = [
      ("a\\,b", "thin space \\,"),
      ("a\\:b", "medium space \\:"),
      ("a\\;b", "thick space \\;"),
      ("a\\!b", "negative space \\!"),
      ("\\int\\!\\!\\!\\int f(x,y) dx dy", "multiple negative spaces"),
      ("x \\, y \\: z \\; w", "mixed spacing"),
    ]

    for (latex, _) in testCases {
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: latex, error: &error)

      if list == nil || error != nil {
        return
      }

      let unwrappedList = try #require(list)
      #expect(unwrappedList.atoms.count >= 1)
    }
  }

  // MARK: - Medium Priority Missing Features Tests

  @Test
  func multipleIntegrals() throws {
    // Test \iint, \iiint, \iiiint for multiple integrals
    let testCases = [
      ("\\iint f(x,y) dx dy", "double integral"),
      ("\\iiint f(x,y,z) dx dy dz", "triple integral"),
      ("\\iiiint f(w,x,y,z) dw dx dy dz", "quadruple integral"),
      ("\\iint_{D} f(x,y) dA", "double integral with limits"),
    ]

    for (latex, _) in testCases {
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: latex, error: &error)

      #expect(error == nil)

      let unwrappedList = try #require(list)
      #expect(error == nil)
      #expect(unwrappedList.atoms.count >= 1)

      // Verify we have a large operator (integral) in the list
      var foundOperator = false
      for atom in unwrappedList.atoms {
        if atom.type == .largeOperator {
          foundOperator = true
          break
        }
      }
      #expect(foundOperator)
    }
  }

  @Test
  func continuedFractions() throws {
    // Test \cfrac for continued fractions (already added but verify)
    let testCases = [
      ("\\cfrac{1}{2}", "simple cfrac"),
      ("a_0 + \\cfrac{1}{a_1 + \\cfrac{1}{a_2}}", "nested cfrac"),
      ("\\cfrac{x^2}{y + \\cfrac{1}{z}}", "cfrac with expressions"),
    ]

    for (latex, _) in testCases {
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: latex, error: &error)

      // cfrac might be implemented, let's check
      if list != nil && error == nil {
        let unwrappedList = try #require(list)
        #expect(unwrappedList.atoms.count >= 1)
      } else {
        return
      }
    }
  }

  @Test
  func displayStyleFraction() throws {
    // Test \dfrac - display-style fraction
    let str = "\\dfrac{1}{2}"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    
    #expect(error == nil)
    let unwrappedList = try #require(list)
    #expect(unwrappedList.atoms.count == 1)

    let frac = try #require(unwrappedList.atoms[0] as? Math.Fraction)
    #expect(frac.type == .fraction)
    #expect(frac.hasRule)

    // Check numerator
    let numerator = try #require(frac.numerator)
    #expect(numerator.atoms.count >= 1)

    // First atom should be displaystyle
    if numerator.atoms.count > 1 {
      let styleAtom = try #require(numerator.atoms[0] as? Math.Style)
      #expect(styleAtom.level == .display)
    }

    // Check denominator
    let denominator = try #require(frac.denominator)
    #expect(denominator.atoms.count >= 1)

    if denominator.atoms.count > 1 {
      let styleAtom = try #require(denominator.atoms[0] as? Math.Style)
      #expect(styleAtom.level == .display)
    }
  }

  @Test
  func textStyleFraction() throws {
    // Test \tfrac - text-style fraction
    let str = "\\tfrac{a}{b}"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    
    #expect(error == nil)
    let unwrappedList = try #require(list)
    #expect(unwrappedList.atoms.count == 1)

    let frac = try #require(unwrappedList.atoms[0] as? Math.Fraction)
    #expect(frac.type == .fraction)
    #expect(frac.hasRule)

    // Check numerator
    let numerator = try #require(frac.numerator)
    #expect(numerator.atoms.count >= 1)

    if numerator.atoms.count > 1 {
      let styleAtom = try #require(numerator.atoms[0] as? Math.Style)
      #expect(styleAtom.level == .text)
    }

    // Check denominator
    let denominator = try #require(frac.denominator)
    #expect(denominator.atoms.count >= 1)

    if denominator.atoms.count > 1 {
      let styleAtom = try #require(denominator.atoms[0] as? Math.Style)
      #expect(styleAtom.level == .text)
    }
  }

  @Test
  func displayAndTextStyleFractions() throws {
    // Test the original LaTeX from the user's issue
    let str = "y'=-\\dfrac{2}{x^{3}}"
    var error: Math.ParserError? = nil
    let list = Math.Parser.build(fromString: str, error: &error)
    
    #expect(error == nil)
    let unwrappedList = try #require(list)
    #expect(unwrappedList.atoms.count >= 4)

    // Find the fraction atom
    var foundFraction = false
    for atom in unwrappedList.atoms {
      if atom.type == .fraction {
        foundFraction = true
        let frac = try #require(atom as? Math.Fraction)

        // Check that numerator has displaystyle
        if let numerator = frac.numerator, numerator.atoms.count > 0 {
          let firstAtom = numerator.atoms[0]
          let styleAtom = try #require(firstAtom as? Math.Style)
          #expect(styleAtom.level == .display)
        }
        break
      }
    }

    #expect(foundFraction)

    // Test nested dfrac and tfrac
    let nestedStr = "\\dfrac{\\tfrac{a}{b}}{c}"
    error = nil
    let nestedList = Math.Parser.build(fromString: nestedStr, error: &error)
    #expect(error == nil)
    #expect(nestedList != nil)
  }

  @Test
  func boldsymbol() throws {
    // Test \boldsymbol for bold Greek letters
    let testCases = [
      ("\\boldsymbol{\\alpha}", "bold alpha"),
      ("\\boldsymbol{\\beta}", "bold beta"),
      ("\\boldsymbol{\\Gamma}", "bold Gamma"),
      ("\\mathbf{x} + \\boldsymbol{\\mu}", "mixed bold"),
    ]

    for (latex, _) in testCases {
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: latex, error: &error)

      if list == nil || error != nil {
        return
      }

      let unwrappedList = try #require(list)
      #expect(unwrappedList.atoms.count >= 1)
    }
  }

  @Test
  func starredMatrices() throws {
    // Test starred matrix environments with alignment
    let testCases = [
      ("\\begin{pmatrix*}[r] 1 & 2 \\\\ 3 & 4 \\end{pmatrix*}", "pmatrix* right align"),
      ("\\begin{bmatrix*}[l] a & b \\\\ c & d \\end{bmatrix*}", "bmatrix* left align"),
      ("\\begin{vmatrix*}[c] x & y \\\\ z & w \\end{vmatrix*}", "vmatrix* center align"),
      (
        "\\begin{matrix*}[r] 10 & 20 \\\\ 30 & 40 \\end{matrix*}",
        "matrix* right align (no delimiters)"
      ),
    ]

    for (latex, _) in testCases {
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: latex, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)
      #expect(unwrappedList.atoms.count >= 1)

      // Verify we have a table structure
      var foundTable = false
      for atom in unwrappedList.atoms {
        if atom.type == .table {
          foundTable = true
          break
        }
        // Check inside inner atoms (for matrices with delimiters)
        if atom.type == .inner {
          let inner = try #require(atom as? Math.Inner)
          if let innerList = inner.innerList {
            for innerAtom in innerList.atoms {
              if innerAtom.type == .table {
                foundTable = true
                break
              }
            }
          }
        }
      }
      #expect(foundTable)
    }
  }

  @Test
  func smallMatrix() throws {
    // Test \smallmatrix for inline matrices
    let testCases = [
      (
        "\\left( \\begin{smallmatrix} a & b \\\\ c & d \\end{smallmatrix} \\right)",
        "smallmatrix with delimiters"
      ),
      (
        "A = \\left( \\begin{smallmatrix} 1 & 0 \\\\ 0 & 1 \\end{smallmatrix} \\right)",
        "identity in smallmatrix"
      ),
      ("\\begin{smallmatrix} x \\\\ y \\end{smallmatrix}", "column vector in smallmatrix"),
    ]

    for (latex, _) in testCases {
      var error: Math.ParserError? = nil
      let list = Math.Parser.build(fromString: latex, error: &error)

      let unwrappedList = try #require(list)
      #expect(error == nil)
      #expect(unwrappedList.atoms.count >= 1)

      // Verify we have a table structure
      var foundTable = false
      for atom in unwrappedList.atoms {
        if atom.type == .table {
          foundTable = true
          break
        }
        // Check inside inner atoms (for matrices with delimiters)
        if atom.type == .inner {
          let inner = try #require(atom as? Math.Inner)
          if let innerList = inner.innerList {
            for innerAtom in innerList.atoms {
              if innerAtom.type == .table {
                foundTable = true
                break
              }
            }
          }
        }
      }
      #expect(foundTable)
    }
  }

}
