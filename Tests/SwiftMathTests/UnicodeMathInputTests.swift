import XCTest
@testable import SwiftMath

/// Math typed with Unicode characters instead of commands, and non-Latin text, as it often comes from
/// chat assistants and copy-paste. Nothing may be dropped silently: "36÷5=7.2" used to render as "365=7.2".
final class UnicodeMathInputTests: XCTestCase {

    private func build(_ latex: String) throws -> MTMathList {
        var error: NSError?
        let list = MTMathListBuilder.build(fromString: latex, error: &error)
        XCTAssertNil(error, latex)
        return try XCTUnwrap(list, latex)
    }

    func testUnicodeSymbolsParseLikeTheirCommands() throws {
        let pairs = [
            ("36÷5=7.2", "36\\div 5=7.2"),
            ("12×4=48", "12\\times 4=48"),
            ("a±b", "a\\pm b"),
            ("x≤3", "x\\leq 3"),
            ("x≥3", "x\\geq 3"),
            ("x≠3", "x\\neq 3"),
            ("x→0", "x\\rightarrow 0"),
            ("p⇒q", "p\\Rightarrow q"),
            ("α+β=γ", "\\alpha +\\beta =\\gamma "),
            ("∑_{i=1}^n i", "\\sum _{i=1}^n i"),
            ("60°", "60\\degree "),
            ("x−1", "x-1"),
        ]
        for (unicode, commands) in pairs {
            XCTAssertEqual(MTMathListBuilder.mathListToString(try build(unicode)),
                           MTMathListBuilder.mathListToString(try build(commands)), unicode)
        }
    }

    func testOtherCharactersAreKeptAsOrdinaryAtomsInMathMode() throws {
        let fraction = try XCTUnwrap(try build("\\frac{新}{原}").atoms.first as? MTFraction)
        XCTAssertEqual(fraction.numerator?.atoms.map(\.nucleus), ["新"])
        XCTAssertEqual(fraction.denominator?.atoms.map(\.nucleus), ["原"])

        let colon = try build("A：6")
        XCTAssertEqual(colon.atoms.map(\.nucleus), ["A", "：", "6"])
        XCTAssertEqual(colon.atoms[1].type, .ordinary)
    }

    func testTextCommandsKeepNonLatinTextAndSpaces() throws {
        let bold = try build("\\textbf{提高 4\\%}")
        XCTAssertEqual(bold.atoms.map(\.nucleus).joined(), "提高 4%")
        XCTAssertTrue(bold.atoms.allSatisfy { $0.fontStyle == .bold })

        // In text a Unicode symbol is just text
        let text = try build("\\text{a×b}")
        XCTAssertEqual(text.atoms.map(\.nucleus), ["a", "×", "b"])
        XCTAssertEqual(text.atoms[1].type, .ordinary)
    }

    func testInvisibleCharactersAndMathModeSpacesAreIgnored() throws {
        XCTAssertEqual(try build("a\u{200B}b").atoms.count, 2, "zero-width space")
        XCTAssertEqual(try build("a\u{00A0}b").atoms.count, 2, "no-break space in math mode")
        XCTAssertEqual(try build("\\text{a\u{00A0}b}").atoms.map(\.nucleus), ["a", " ", "b"], "no-break space in text")
    }

    func testUnicodeInputIsTypeset() throws {
        let font = try XCTUnwrap(MTFontManager.fontManager.latinModernFont(withSize: 20))
        func width(_ latex: String, _ style: MTLineStyle = .text) throws -> CGFloat {
            try XCTUnwrap(MTTypesetter.createLineForMathList(try build(latex), font: font, style: style)).width
        }
        XCTAssertEqual(try width("36÷5=7.2"), try width("36\\div 5=7.2"), accuracy: 0.01)
        // Two Chinese characters drawn with the fallback font are about 2em wide
        XCTAssertEqual(try width("新原"), 40, accuracy: 4)
    }
}
