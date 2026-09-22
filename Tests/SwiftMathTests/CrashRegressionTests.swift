import XCTest
@testable import SwiftMath

/// Inputs that crashed the host process on 1.7.3. Each must come back as a math list or a
/// parse error — never a trap — and must typeset. Reaching the assertion *is* the test: the
/// broken code aborts before it.
final class CrashRegressionTests: XCTestCase {

    // MARK: - buildTable: a row break swallowed as a single-atom argument

    /// `x^\\` consumes the row break as the exponent, advancing `numRows` without ending the
    /// cell; the cell's own `\\` advances it again, so `currentRow` jumped by two while `rows`
    /// grew by one and `rows[currentRow]` went out of range.
    private let rowBreakInsideScript = [
        "\\begin{matrix} a^\\\\ \\\\ b \\end{matrix}",
        "\\begin{matrix} a & b^\\\\ \\\\ c & d \\end{matrix}",
        "\\begin{aligned} a &= b^\\\\ \\\\ c &= d \\end{aligned}",
        "\\begin{matrix} \\overline\\\\ a \\\\ b \\end{matrix}",
        "\\begin{matrix} a^\\cr \\\\ b \\end{matrix}",
    ]

    func testRowBreakInsideAScriptParsesWithoutTrapping() {
        for latex in rowBreakInsideScript {
            var error: NSError?
            let list = MTMathListBuilder.build(fromString: latex, error: &error)
            XCTAssertTrue(list != nil || error != nil, "\(latex) produced neither a list nor an error")
        }
    }

    func testRowBreakInsideAScriptTypesets() throws {
        let font = try XCTUnwrap(MTFontManager.fontManager.defaultFont)
        for latex in rowBreakInsideScript {
            var error: NSError?
            guard let list = MTMathListBuilder.build(fromString: latex, error: &error) else { continue }
            let display = MTTypesetter.createLineForMathList(list, font: font, style: .display)
            XCTAssertNotNil(display, latex)
        }
    }

    // MARK: - textcolor: a coloured group that does not open with a text run

    /// The spacing before a coloured group is read off its first atom, which only exists when
    /// the group starts with a text run. A group opening with a fraction, radical or table has
    /// no `MTCTLineDisplay` to read (a failed unconditional cast aborted the process), and an
    /// empty group has no sub-display at all (an index trap).
    private let colouredGroupWithoutLeadingText = [
        "x = \\textcolor{red}{\\frac{1}{2}}",
        "x = \\textcolor{red}{\\sqrt{2}}",
        "x = \\textcolor{red}{\\begin{matrix} a \\\\ b \\end{matrix}}",
        "x = \\textcolor{red}{}",
    ]

    func testColouredGroupWithoutLeadingTextTypesets() throws {
        let font = try XCTUnwrap(MTFontManager.fontManager.defaultFont)
        for latex in colouredGroupWithoutLeadingText {
            var error: NSError?
            let list = try XCTUnwrap(MTMathListBuilder.build(fromString: latex, error: &error), latex)
            let display = try XCTUnwrap(MTTypesetter.createLineForMathList(list, font: font, style: .display), latex)
            XCTAssertGreaterThan(display.width, 0, latex)
        }
    }

    /// The common, already-working form keeps its spacing: a coloured text run after a relation
    /// is still laid out with a thick space, so the fallback above did not flatten the normal case.
    func testColouredTextRunStillGetsRelationSpacing() throws {
        let font = try XCTUnwrap(MTFontManager.fontManager.defaultFont)
        func width(_ latex: String) throws -> CGFloat {
            var error: NSError?
            let list = try XCTUnwrap(MTMathListBuilder.build(fromString: latex, error: &error), latex)
            return try XCTUnwrap(MTTypesetter.createLineForMathList(list, font: font, style: .display)).width
        }
        XCTAssertGreaterThan(try width("x = \\textcolor{red}{3}"), try width("x\\textcolor{red}{3}"))
    }
}
