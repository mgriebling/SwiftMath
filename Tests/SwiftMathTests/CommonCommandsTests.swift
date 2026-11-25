import XCTest
@testable import SwiftMath

/// Symbols and small commands that chat answers use often (they used to fail with "Invalid command")
final class CommonCommandsTests: XCTestCase {

    private func build(_ latex: String) throws -> MTMathList {
        var error: NSError?
        let list = MTMathListBuilder.build(fromString: latex, error: &error)
        XCTAssertNil(error, latex)
        return try XCTUnwrap(list, latex)
    }

    func testSymbols() throws {
        let cases: [(String, MTMathAtomType, String)] = [
            ("\\therefore", .relation, "\u{2234}"),
            ("\\because", .relation, "\u{2235}"),
            ("\\impliedby", .relation, "\u{27F8}"),
            ("\\dots", .ordinary, "\u{2026}"),
            ("\\bmod", .binaryOperator, "mod"),
            ("\\checkmark", .ordinary, "\u{2713}"),
            ("\\blacksquare", .ordinary, "\u{25A0}"),
            ("\\&", .ordinary, "&"),
            ("\\lvert", .open, "|"),
            ("\\rvert", .close, "|"),
            ("\\lVert", .open, "\u{2016}"),
            ("\\rVert", .close, "\u{2016}"),
        ]
        for (latex, type, nucleus) in cases {
            let atom = try XCTUnwrap(try build(latex).atoms.first, latex)
            XCTAssertEqual(atom.type, type, latex)
            XCTAssertEqual(atom.nucleus, nucleus, latex)
        }
    }

    func testNotWithACharacter() throws {
        for (latex, negated) in [("a\\not=b", "\u{2260}"), ("a\\not<b", "\u{226E}"), ("a\\not>b", "\u{226F}"), ("a\\not\\leq b", "\u{2270}"), ("a \\not = b", "\u{2260}")] {
            let atoms = try build(latex).atoms
            XCTAssertEqual(atoms.count, 3, latex)
            XCTAssertEqual(atoms[1].type, .relation, latex)
            XCTAssertEqual(atoms[1].nucleus, negated, latex)
        }
    }

    func testSidedBarsAsDelimiters() throws {
        let inner = try XCTUnwrap(try build("\\left\\lvert x \\right\\rvert").atoms.first as? MTInner)
        XCTAssertEqual(inner.leftBoundary?.nucleus, "|")
        XCTAssertEqual(inner.rightBoundary?.nucleus, "|")
    }

    func testBinomVariantsForceTheirStyle() throws {
        for (latex, style) in [("\\tbinom{n}{k}", MTLineStyle.text), ("\\dbinom{n}{k}", .display)] {
            let fraction = try XCTUnwrap(try build(latex).atoms.first as? MTFraction, latex)
            XCTAssertFalse(fraction.hasRule, latex)
            XCTAssertEqual(fraction.leftDelimiter, "(", latex)
            XCTAssertEqual((fraction.numerator?.atoms.first as? MTMathStyle)?.style, style, latex)
            XCTAssertEqual((fraction.denominator?.atoms.first as? MTMathStyle)?.style, style, latex)
        }
        XCTAssertNil((try build("\\binom{n}{k}").atoms.first as? MTFraction)?.numerator?.atoms.first as? MTMathStyle)
    }

    func testScriptLettersAndRingAccent() throws {
        XCTAssertEqual(try build("\\mathscr{L}").atoms.first?.fontStyle, .caligraphic)
        let accent = try XCTUnwrap(try build("\\mathring{A}").atoms.first as? MTAccent)
        XCTAssertEqual(accent.nucleus, "\u{030A}")
    }

    func testTheyAreTypeset() throws {
        let font = try XCTUnwrap(MTFontManager.manager.latinModernFont(withSize: 20))
        for latex in ["\\because a>b \\therefore b<a", "7 \\bmod 3 = 1", "\\lvert x \\rvert \\le 1", "\\tbinom{n}{k}+\\dbinom{n}{k}", "\\mathscr{L}\\mathring{A}\\checkmark", "a\\not=b"] {
            let line = try XCTUnwrap(MTTypesetter.createLineForMathList(try build(latex), font: font, style: .text), latex)
            XCTAssertGreaterThan(line.width, 0, latex)
        }
    }
}

/// Display environments that answers wrap formulas in (align*, gathered, equation, ...)
final class MoreEnvironmentsTests: XCTestCase {

    private func build(_ latex: String) throws -> MTMathList {
        var error: NSError?
        let list = MTMathListBuilder.build(fromString: latex, error: &error)
        XCTAssertNil(error, latex)
        return try XCTUnwrap(list, latex)
    }

    func testAlignVariantsAreLaidOutLikeAligned() throws {
        for latex in ["\\begin{align*} a &= b \\\\ c &= d \\end{align*}", "\\begin{align} a &= b \\\\ c &= d \\end{align}",
                      "\\begin{flalign*} a &= b \\\\ c &= d \\end{flalign*}"] {
            let table = try XCTUnwrap(try build(latex).atoms.first as? MTMathTable, latex)
            XCTAssertEqual(table.numRows, 2, latex)
            XCTAssertEqual(table.numColumns, 2, latex)
            XCTAssertEqual(table.alignments, [.right, .left], latex)
            XCTAssertEqual(table.cells[0][1].atoms.first?.nucleus, "", "the {} before the second column: \(latex)")
        }
        let alignat = try XCTUnwrap(try build("\\begin{alignat}{2} a &= b & c &= d \\end{alignat}").atoms.first as? MTMathTable)
        XCTAssertEqual(alignat.numColumns, 4, "{2} is read as the argument, not as content")
        XCTAssertEqual(alignat.cells[0][0].atoms.map(\.nucleus), ["a"])
    }

    func testCenteredEnvironments() throws {
        for latex in ["\\begin{gathered} a \\\\ b \\end{gathered}", "\\begin{gather*} a \\\\ b \\end{gather*}", "\\begin{equation} E=mc^2 \\end{equation}",
                      "\\begin{equation*} E=mc^2 \\end{equation*}"] {
            let table = try XCTUnwrap(try build(latex).atoms.first as? MTMathTable, latex)
            XCTAssertEqual(table.numColumns, 1, latex)
            XCTAssertEqual(table.alignments, [.center], latex)
        }
    }

    func testCasesVariants() throws {
        let dcases = try XCTUnwrap(try build("\\begin{dcases} \\frac{1}{2} & x>0 \\\\ 0 & x \\le 0 \\end{dcases}").atoms.first as? MTInner)
        let dtable = try XCTUnwrap(dcases.innerList?.atoms.last as? MTMathTable)
        XCTAssertEqual((dtable.cells[0][0].atoms.first as? MTMathStyle)?.style, .display)
        XCTAssertEqual(dcases.leftBoundary?.nucleus, "{")

        let rcases = try XCTUnwrap(try build("\\begin{rcases} a & x>0 \\\\ b & x \\le 0 \\end{rcases}").atoms.first as? MTInner)
        XCTAssertEqual(rcases.rightBoundary?.nucleus, "}")
        XCTAssertTrue(rcases.innerList?.atoms.first is MTMathTable)
    }

    func testTheyAreTypeset() throws {
        let font = try XCTUnwrap(MTFontManager.manager.latinModernFont(withSize: 20))
        for latex in ["\\begin{align*} f(x) &= (x+1)^2 \\\\ &= x^2+2x+1 \\end{align*}", "\\begin{gathered} a \\\\ b \\end{gathered}",
                      "\\begin{rcases} a \\\\ b \\end{rcases}\\Rightarrow c"] {
            let line = try XCTUnwrap(MTTypesetter.createLineForMathList(try build(latex), font: font, style: .display), latex)
            XCTAssertGreaterThan(line.ascent + line.descent, 20, latex)
        }
    }
}
