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
