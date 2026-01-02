import Foundation
import Testing

@testable import SwiftUIMath

@Suite
struct AtomListTests {
  @Test
  func parsesScriptsAndFinalizesAtomList() throws {
    let input = "-52x^{13+y}_{15-} + (-12.3 *)\\frac{-12}{15.2}"
    let list = try parseFinalizedAtomList(from: input)

    try assertFinalizedAtomListContents(list)
    // Re-finalizing should be stable.
    try assertFinalizedAtomListContents(list.finalized)
  }

  @Test
  func appendsAtomsInOrder() {
    let list = Math.AtomList()
    #expect(list.atoms.isEmpty)

    let first = Math.AtomFactory.placeholder()
    list.append(first)
    #expect(list.atoms.count == 1)
    #expect(list.atoms[0] === first)

    let second = Math.AtomFactory.placeholder()
    list.append(second)
    #expect(list.atoms.count == 2)
    #expect(list.atoms[0] === first)
    #expect(list.atoms[1] === second)
  }

  @Test
  func insertsAtomsAtIndices() {
    let list = Math.AtomList()
    let first = Math.AtomFactory.placeholder()
    list.insert(first, at: 0)
    #expect(list.atoms.count == 1)
    #expect(list.atoms[0] === first)

    let second = Math.AtomFactory.placeholder()
    list.insert(second, at: 0)
    #expect(list.atoms.count == 2)
    #expect(list.atoms[0] === second)
    #expect(list.atoms[1] === first)

    let third = Math.AtomFactory.placeholder()
    list.insert(third, at: 2)
    #expect(list.atoms.count == 3)
    #expect(list.atoms[0] === second)
    #expect(list.atoms[1] === first)
    #expect(list.atoms[2] === third)
  }

  @Test
  func appendsListContents() {
    let list1 = Math.AtomList()
    let atom1 = Math.AtomFactory.placeholder()
    let atom2 = Math.AtomFactory.placeholder()
    let atom3 = Math.AtomFactory.placeholder()
    list1.append(atom1)
    list1.append(atom2)
    list1.append(atom3)

    let list2 = Math.AtomList()
    let atom4 = Math.AtomFactory.times()
    let atom5 = Math.AtomFactory.divide()
    list2.append(atom4)
    list2.append(atom5)

    #expect(list1.atoms.count == 3)
    #expect(list2.atoms.count == 2)

    list1.append(contentsOf: list2)
    #expect(list1.atoms.count == 5)
    #expect(list1.atoms[3] === atom4)
    #expect(list1.atoms[4] === atom5)
  }

  @Test
  func removesLastAtom() {
    let list = Math.AtomList()
    let atom = Math.AtomFactory.placeholder()
    list.append(atom)

    #expect(list.atoms.count == 1)
    list.removeLastAtomForTesting()
    #expect(list.atoms.isEmpty)

    list.removeLastAtomForTesting()
    #expect(list.atoms.isEmpty)

    let atom2 = Math.AtomFactory.placeholder()
    list.append(atom)
    list.append(atom2)

    #expect(list.atoms.count == 2)
    list.removeLastAtomForTesting()
    #expect(list.atoms.count == 1)
    #expect(list.atoms[0] === atom)
  }

  @Test
  func removesAtomAtIndex() {
    let list = Math.AtomList()
    let first = Math.AtomFactory.placeholder()
    let second = Math.AtomFactory.placeholder()
    list.append(first)
    list.append(second)

    #expect(list.atoms.count == 2)
    #expect(list.removeAtomForTesting(at: 0))
    #expect(list.atoms.count == 1)
    #expect(list.atoms[0] === second)

    #expect(!list.removeAtomForTesting(at: 2))
  }

  @Test
  func removesAtomsInRange() {
    let list = Math.AtomList()
    let first = Math.AtomFactory.placeholder()
    let second = Math.AtomFactory.placeholder()
    let third = Math.AtomFactory.placeholder()
    list.append(first)
    list.append(second)
    list.append(third)

    #expect(list.atoms.count == 3)
    #expect(list.removeAtomsForTesting(in: 1...2))
    #expect(list.atoms.count == 1)
    #expect(list.atoms[0] === first)

    #expect(!list.removeAtomsForTesting(in: 1...3))
  }

  @Test
  func copiesAtomListsWithDistinctAtoms() throws {
    let list = Math.AtomList()
    let atom1 = Math.AtomFactory.placeholder()
    let atom2 = Math.AtomFactory.times()
    let atom3 = Math.AtomFactory.divide()
    list.append(atom1)
    list.append(atom2)
    list.append(atom3)

    let copy = Math.AtomList(list)
    try assertAtomListCopyMatches(copy, original: list, context: "atom list copy")
  }

  @Test
  func initializesAtomWithCorrectNucleusAndType() {
    var atom = Math.Atom(type: .open, value: "(")
    #expect(atom.nucleus == "(")
    #expect(atom.type == .open)

    atom = Math.Atom(type: .radical, value: "(")
    #expect(atom.nucleus.isEmpty)
    #expect(atom.type == .radical)
  }

  @Test
  func supportsScriptsWhenAllowed() {
    var atom = Math.Atom(type: .open, value: "(")
    #expect(atom.allowsScripts)

    atom.`subscript` = Math.AtomList()
    #expect(atom.`subscript` != nil)

    atom.superscript = Math.AtomList()
    #expect(atom.superscript != nil)

    atom = Math.Atom(type: .boundary, value: "(")
    #expect(!atom.allowsScripts)
    #expect(atom.`subscript` == nil)
    #expect(atom.superscript == nil)
  }

  @Test
  func copiesAtomsWithScripts() throws {
    let list = Math.AtomList()
    let atom1 = Math.AtomFactory.placeholder()
    let atom2 = Math.AtomFactory.times()
    let atom3 = Math.AtomFactory.divide()
    list.append(atom1)
    list.append(atom2)
    list.append(atom3)

    let list2 = Math.AtomList()
    list2.append(atom3)
    list2.append(atom2)

    let atom = Math.Atom(type: .open, value: "(")
    atom.`subscript` = list
    atom.superscript = list2

    let copy = atom.copy()
    try assertAtomCopyMatches(copy, original: atom, context: "atom copy")
    try assertAtomListCopyMatches(
      copy.superscript, original: atom.superscript, context: "superscript copy"
    )
    try assertAtomListCopyMatches(
      copy.`subscript`, original: atom.`subscript`, context: "subscript copy"
    )
  }

  @Test
  func copiesFraction() throws {
    let list = Math.AtomList()
    let atom1 = Math.AtomFactory.placeholder()
    let atom2 = Math.AtomFactory.times()
    let atom3 = Math.AtomFactory.divide()
    list.append(atom1)
    list.append(atom2)
    list.append(atom3)

    let list2 = Math.AtomList()
    list2.append(atom3)
    list2.append(atom2)

    let fraction = Math.Fraction(hasRule: false)
    #expect(fraction.type == .fraction)
    fraction.numerator = list
    fraction.denominator = list2
    fraction.leftDelimiter = "a"
    fraction.rightDelimiter = "b"

    let copy = Math.Fraction(fraction)
    try assertAtomCopyMatches(copy, original: fraction, context: "fraction copy")
    try assertAtomListCopyMatches(
      copy.numerator, original: fraction.numerator, context: "fraction numerator copy"
    )
    try assertAtomListCopyMatches(
      copy.denominator, original: fraction.denominator, context: "fraction denominator copy"
    )
    #expect(!copy.hasRule)
    #expect(copy.leftDelimiter == "a")
    #expect(copy.rightDelimiter == "b")
  }

  @Test
  func copiesRadical() throws {
    let list = Math.AtomList()
    let atom1 = Math.AtomFactory.placeholder()
    let atom2 = Math.AtomFactory.times()
    let atom3 = Math.AtomFactory.divide()
    list.append(atom1)
    list.append(atom2)
    list.append(atom3)

    let list2 = Math.AtomList()
    list2.append(atom3)
    list2.append(atom2)

    let radical = Math.Radical()
    #expect(radical.type == .radical)
    radical.radicand = list
    radical.degree = list2

    let copy = Math.Radical(radical)
    try assertAtomCopyMatches(copy, original: radical, context: "radical copy")
    try assertAtomListCopyMatches(
      copy.radicand,
      original: radical.radicand,
      context: "radicand copy"
    )
    try assertAtomListCopyMatches(copy.degree, original: radical.degree, context: "degree copy")
  }

  @Test
  func copiesLargeOperator() throws {
    let largeOperator = Math.LargeOperator(limits: true)
    largeOperator.nucleus = "lim"
    #expect(largeOperator.type == .largeOperator)
    #expect(largeOperator.limits)

    let copy = Math.LargeOperator(largeOperator)
    try assertAtomCopyMatches(copy, original: largeOperator, context: "large operator copy")
    #expect(copy.limits == largeOperator.limits)
  }

  @Test
  func copiesInnerAtom() throws {
    let list = Math.AtomList()
    let atom1 = Math.AtomFactory.placeholder()
    let atom2 = Math.AtomFactory.times()
    let atom3 = Math.AtomFactory.divide()
    list.append(atom1)
    list.append(atom2)
    list.append(atom3)

    let inner = Math.Inner()
    inner.innerList = list
    inner.leftBoundary = Math.Atom(type: .boundary, value: "(")
    inner.rightBoundary = Math.Atom(type: .boundary, value: ")")
    #expect(inner.type == .inner)

    let copy = Math.Inner(inner)
    try assertAtomCopyMatches(copy, original: inner, context: "inner atom copy")
    try assertAtomListCopyMatches(
      copy.innerList,
      original: inner.innerList,
      context: "inner list copy"
    )
    try assertAtomCopyMatches(
      copy.leftBoundary!,
      original: inner.leftBoundary,
      context: "left boundary copy"
    )
    try assertAtomCopyMatches(
      copy.rightBoundary!,
      original: inner.rightBoundary,
      context: "right boundary copy"
    )
  }

  @Test
  func setsInnerBoundaries() {
    let inner = Math.Inner()

    inner.leftBoundary = Math.Atom(type: .boundary, value: "(")
    inner.rightBoundary = Math.Atom(type: .boundary, value: ")")
    #expect(inner.leftBoundary != nil)
    #expect(inner.rightBoundary != nil)

    inner.leftBoundary = nil
    inner.rightBoundary = nil
    #expect(inner.leftBoundary == nil)
    #expect(inner.rightBoundary == nil)
  }

  @Test
  func copiesOverline() throws {
    let list = Math.AtomList()
    let atom1 = Math.AtomFactory.placeholder()
    let atom2 = Math.AtomFactory.times()
    let atom3 = Math.AtomFactory.divide()
    list.append(atom1)
    list.append(atom2)
    list.append(atom3)

    let overline = Math.Overline()
    #expect(overline.type == .overline)
    overline.innerList = list

    let copy = Math.Overline(overline)
    try assertAtomCopyMatches(copy, original: overline, context: "overline copy")
    try assertAtomListCopyMatches(
      copy.innerList,
      original: overline.innerList,
      context: "overline list copy"
    )
  }

  @Test
  func copiesUnderline() throws {
    let list = Math.AtomList()
    let atom1 = Math.AtomFactory.placeholder()
    let atom2 = Math.AtomFactory.times()
    let atom3 = Math.AtomFactory.divide()
    list.append(atom1)
    list.append(atom2)
    list.append(atom3)

    let underline = Math.Underline()
    #expect(underline.type == .underline)
    underline.innerList = list

    let copy = Math.Underline(underline)
    try assertAtomCopyMatches(copy, original: underline, context: "underline copy")
    try assertAtomListCopyMatches(
      copy.innerList,
      original: underline.innerList,
      context: "underline list copy"
    )
  }

  @Test
  func copiesAccent() throws {
    let list = Math.AtomList()
    let atom1 = Math.AtomFactory.placeholder()
    let atom2 = Math.AtomFactory.times()
    let atom3 = Math.AtomFactory.divide()
    list.append(atom1)
    list.append(atom2)
    list.append(atom3)

    let accent = Math.Accent(value: "^")
    #expect(accent.type == .accent)
    accent.innerList = list

    let copy = Math.Accent(accent)
    try assertAtomCopyMatches(copy, original: accent, context: "accent copy")
    try assertAtomListCopyMatches(
      copy.innerList,
      original: accent.innerList,
      context: "accent list copy"
    )
  }

  @Test
  func copiesSpace() throws {
    let space = Math.Space(amount: 3)
    #expect(space.type == .space)

    let copy = Math.Space(space)
    try assertAtomCopyMatches(copy, original: space, context: "space copy")
    #expect(space.amount == copy.amount)
  }

  @Test
  func copiesStyle() throws {
    let style = Math.Style(level: .script)
    #expect(style.type == .style)

    let copy = Math.Style(style)
    try assertAtomCopyMatches(copy, original: style, context: "style copy")
    #expect(style.level == copy.level)
  }

  @Test
  func createsTableAtom() {
    let table = Math.Table()
    #expect(table.type == .table)

    let list = Math.AtomList()
    let atom1 = Math.AtomFactory.placeholder()
    let atom2 = Math.AtomFactory.times()
    let atom3 = Math.AtomFactory.divide()
    list.append(atom1)
    list.append(atom2)
    list.append(atom3)

    let list2 = Math.AtomList()
    list2.append(atom3)
    list2.append(atom2)

    table.setCell(list, forRow: 3, column: 2)
    table.setCell(list2, forRow: 1, column: 0)

    table.setAlignment(.left, forColumn: 2)
    table.setAlignment(.right, forColumn: 1)

    #expect(table.cells.count == 4)
    #expect(table.cells[0].count == 0)
    #expect(table.cells[1].count == 1)
    #expect(table.cells[2].count == 0)
    #expect(table.cells[3].count == 3)

    #expect(table.cells[1][0].atoms.count == 2)
    #expect(table.cells[1][0] === list2)

    #expect(table.cells[3][0].atoms.isEmpty)
    #expect(table.cells[3][1].atoms.isEmpty)
    #expect(table.cells[3][2] === list)

    #expect(table.numberOfRows == 4)
    #expect(table.numberOfColumns == 3)

    #expect(table.alignments.count == 3)
    #expect(table.alignments[0] == .center)
    #expect(table.alignments[1] == .right)
    #expect(table.alignments[2] == .left)
  }

  @Test
  func copiesTableAtom() throws {
    let table = Math.Table()
    #expect(table.type == .table)

    let list = Math.AtomList()
    let atom1 = Math.AtomFactory.placeholder()
    let atom2 = Math.AtomFactory.times()
    let atom3 = Math.AtomFactory.divide()
    list.append(atom1)
    list.append(atom2)
    list.append(atom3)

    let list2 = Math.AtomList()
    list2.append(atom3)
    list2.append(atom2)

    table.setCell(list, forRow: 0, column: 1)
    table.setCell(list2, forRow: 0, column: 2)

    table.setAlignment(.left, forColumn: 2)
    table.setAlignment(.right, forColumn: 1)
    table.interRowAdditionalSpacing = 3
    table.interColumnSpacing = 10

    let copy = Math.Table(table)
    try assertAtomCopyMatches(copy, original: table, context: "table copy")
    #expect(copy.interColumnSpacing == table.interColumnSpacing)
    #expect(copy.interRowAdditionalSpacing == table.interRowAdditionalSpacing)
    #expect(copy.alignments == table.alignments)

    #expect(copy.cells[0].count == table.cells[0].count)
    #expect(copy.cells[0][0].atoms.isEmpty)
    #expect(copy.cells[0][0] !== table.cells[0][0])
    try assertAtomListCopyMatches(copy.cells[0][1], original: list, context: "table list copy")
    try assertAtomListCopyMatches(copy.cells[0][2], original: list2, context: "table list copy")
  }

  private func parseFinalizedAtomList(from input: String) throws -> Math.AtomList {
    let list = try #require(Math.Parser.build(fromString: input))
    return list.finalized
  }

  private func assertFinalizedAtomListContents(_ finalized: Math.AtomList) throws {
    #expect(finalized.atoms.count == 10, "Num atoms")

    var atom = finalized.atoms[0]
    try assertAtom(atom, type: .unaryOperator, nucleus: "−", range: NSRange(location: 0, length: 1))

    atom = finalized.atoms[1]
    try assertAtom(atom, type: .number, nucleus: "52", range: NSRange(location: 1, length: 2))

    atom = finalized.atoms[2]
    try assertAtom(atom, type: .variable, nucleus: "x", range: NSRange(location: 3, length: 1))

    let superscript = try #require(atom.superscript)
    #expect(superscript.atoms.count == 3, "Super script")

    atom = superscript.atoms[0]
    try assertAtom(atom, type: .number, nucleus: "13", range: NSRange(location: 0, length: 2))

    atom = superscript.atoms[1]
    try assertAtom(
      atom,
      type: .binaryOperator,
      nucleus: "+",
      range: NSRange(location: 2, length: 1)
    )

    atom = superscript.atoms[2]
    try assertAtom(atom, type: .variable, nucleus: "y", range: NSRange(location: 3, length: 1))

    atom = finalized.atoms[2]
    let subscriptList = try #require(atom.`subscript`)
    #expect(subscriptList.atoms.count == 2, "Sub script")

    atom = subscriptList.atoms[0]
    try assertAtom(atom, type: .number, nucleus: "15", range: NSRange(location: 0, length: 2))

    atom = subscriptList.atoms[1]
    try assertAtom(atom, type: .unaryOperator, nucleus: "−", range: NSRange(location: 2, length: 1))

    atom = finalized.atoms[3]
    try assertAtom(
      atom,
      type: .binaryOperator,
      nucleus: "+",
      range: NSRange(location: 4, length: 1)
    )

    atom = finalized.atoms[4]
    try assertAtom(atom, type: .open, nucleus: "(", range: NSRange(location: 5, length: 1))

    atom = finalized.atoms[5]
    try assertAtom(atom, type: .unaryOperator, nucleus: "−", range: NSRange(location: 6, length: 1))

    atom = finalized.atoms[6]
    try assertAtom(atom, type: .number, nucleus: "12.3", range: NSRange(location: 7, length: 4))

    atom = finalized.atoms[7]
    try assertAtom(
      atom,
      type: .unaryOperator,
      nucleus: "*",
      range: NSRange(location: 11, length: 1)
    )

    atom = finalized.atoms[8]
    try assertAtom(atom, type: .close, nucleus: ")", range: NSRange(location: 12, length: 1))

    let fraction = try #require(finalized.atoms[9] as? Math.Fraction)
    #expect(fraction.type == .fraction)
    #expect(fraction.nucleus.isEmpty)
    #expect(fraction.indexRange == NSRange(location: 13, length: 1))

    let numerator = try #require(fraction.numerator)
    #expect(numerator.atoms.count == 2, "Numerator")

    atom = numerator.atoms[0]
    try assertAtom(atom, type: .unaryOperator, nucleus: "−", range: NSRange(location: 0, length: 1))

    atom = numerator.atoms[1]
    try assertAtom(atom, type: .number, nucleus: "12", range: NSRange(location: 1, length: 2))

    let denominator = try #require(fraction.denominator)
    #expect(denominator.atoms.count == 1, "Denominator")

    atom = denominator.atoms[0]
    try assertAtom(atom, type: .number, nucleus: "15.2", range: NSRange(location: 0, length: 4))
  }

  private func assertAtom(
    _ atom: Math.Atom,
    type: Math.AtomType,
    nucleus: String,
    range: NSRange
  ) throws {
    #expect(atom.type == type)
    #expect(atom.nucleus == nucleus)
    #expect(atom.indexRange == range)
  }

  private func assertAtomCopyMatches(
    _ copy: Math.Atom?,
    original: Math.Atom?,
    context: String
  ) throws {
    let copy = try #require(copy, "Missing copy for \(context)")
    let original = try #require(original, "Missing original for \(context)")
    #expect(copy.type == original.type, "\(context) type")
    #expect(copy.nucleus == original.nucleus, "\(context) nucleus")
    #expect(copy !== original, "\(context) identity")
  }

  private func assertAtomListCopyMatches(
    _ copy: Math.AtomList?,
    original: Math.AtomList?,
    context: String
  ) throws {
    let copy = try #require(copy, "Missing copy for \(context)")
    let original = try #require(original, "Missing original for \(context)")
    #expect(copy.atoms.count == original.atoms.count, "\(context) count")

    for (index, copyAtom) in copy.atoms.enumerated() {
      let originalAtom = original.atoms[index]
      try assertAtomCopyMatches(
        copyAtom,
        original: originalAtom,
        context: "\(context) atom \(index)"
      )
    }
  }
}

extension Math.AtomList {
  func removeLastAtomForTesting() {
    guard !atoms.isEmpty else { return }
    atoms.removeLast()
  }

  func removeAtomForTesting(at index: Int) -> Bool {
    guard atoms.indices.contains(index) else { return false }
    atoms.remove(at: index)
    return true
  }

  func removeAtomsForTesting(in range: ClosedRange<Int>) -> Bool {
    guard !atoms.isEmpty else { return false }
    guard range.lowerBound >= 0, range.upperBound < atoms.count else { return false }
    atoms.removeSubrange(range)
    return true
  }
}
