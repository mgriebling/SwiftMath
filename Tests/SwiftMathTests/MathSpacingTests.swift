import XCTest
@testable import SwiftMath

/// Horizontal spacing of the typeset line: explicit spacing commands and the spaces TeX puts between
/// atoms (TeXbook Appendix G), checked from the positions of the displays.
final class MathSpacingTests: XCTestCase {

    private var font: MTFont!
    private var mu: CGFloat { font.mathTable!.muUnit }

    override func setUp() {
        super.setUp()
        font = MTFontManager.fontManager.latinModernFont(withSize: 20)
    }

    private func line(_ latex: String, style: MTLineStyle = .text, maxWidth: CGFloat = 0) throws -> MTMathListDisplay {
        var error: NSError?
        let list = MTMathListBuilder.build(fromString: latex, error: &error)
        XCTAssertNil(error, latex)
        return try XCTUnwrap(MTTypesetter.createLineForMathList(try XCTUnwrap(list), font: font, style: style, maxWidth: maxWidth), latex)
    }

    /// Displays left to right. The formulas use digits and upright symbols, whose displays are exactly
    /// as wide as their advance, so the gaps between displays are the spaces.
    private func parts(_ display: MTMathListDisplay) -> [MTDisplay] {
        display.subDisplays.sorted { $0.position.x < $1.position.x }
    }

    private func gaps(_ latex: String, style: MTLineStyle = .text) throws -> [CGFloat] {
        let displays = parts(try line(latex, style: style))
        return zip(displays, displays.dropFirst()).map { $1.position.x - ($0.position.x + $0.width) }
    }

    private func assertGaps(_ latex: String, _ expected: [CGFloat], style: MTLineStyle = .text, file: StaticString = #filePath, line: UInt = #line) throws {
        let actual = try gaps(latex, style: style)
        XCTAssertEqual(actual.count, expected.count, latex, file: file, line: line)
        for (a, e) in zip(actual, expected) {
            XCTAssertEqual(a, e * mu, accuracy: 0.01, "\(latex): \(actual.map { $0 / mu }) mu", file: file, line: line)
        }
    }

    // MARK: - Explicit spacing commands

    func testExplicitSpacesUseTheirOwnWidth() throws {
        try assertGaps("1\\,2", [3])
        try assertGaps("1\\:2", [4])
        try assertGaps("1\\>2", [4])
        try assertGaps("1\\;2", [5])
        try assertGaps("1\\quad 2", [18])
        try assertGaps("1\\qquad 2", [36])
        try assertGaps("1\\!2", [-3])
    }

    func testExplicitSpaceAddsToTheSpaceBetweenAtoms() throws {
        // 1 \quad +2: the medium space before the binary operator stays, the quad adds to it
        try assertGaps("1\\quad +2", [18 + 4, 4])
    }

    // MARK: - Spaces between atoms

    func testBinaryOperatorsAndRelations() throws {
        try assertGaps("1+2=3", [4, 4, 5, 5])
    }

    func testNoSpaceAtTheStartOrEndOfAFormula() throws {
        let lone = try line("=")
        XCTAssertEqual(lone.subDisplays.count, 1)
        XCTAssertEqual(lone.subDisplays[0].position.x, 0, accuracy: 0.01)
        XCTAssertEqual(lone.width, lone.subDisplays[0].width, accuracy: 0.01)

        let leading = try line("=2")
        XCTAssertEqual(parts(leading)[0].position.x, 0, accuracy: 0.01)
        try assertGaps("=2", [5])
    }

    func testUnaryMinusGetsNoBinarySpace() throws {
        // The minus after = is unary and joins the 2: only the thick spaces around =
        try assertGaps("1=-2", [5, 5])
    }

    func testThinSpaceAfterPunctuation() throws {
        try assertGaps("1,2", [0, 3])
    }

    func testThinSpaceAfterAnOperatorName() throws {
        try assertGaps("\\sin 2", [3])
        try assertGaps("2\\log 3", [3, 3])
    }

    func testNoMediumOrThickSpacesInScripts() throws {
        let display = try line("2^{1+2=3}")
        var script = try XCTUnwrap(display.subDisplays.compactMap { $0 as? MTMathListDisplay }.first)
        while script.subDisplays.count == 1, let nested = script.subDisplays[0] as? MTMathListDisplay {
            script = nested
        }
        let inner = parts(script)
        XCTAssertEqual(inner.count, 5)
        for (left, right) in zip(inner, inner.dropFirst()) {
            XCTAssertEqual(right.position.x, left.position.x + left.width, accuracy: 0.01)
        }
    }

    func testScriptStyleKeepsOnlyThinSpaces() throws {
        try assertGaps("1+2=3", [0, 0, 0, 0], style: .script)
        try assertGaps("\\sin 2", [3], style: .script)
    }

    func testBrokenLinesDoNotStartWithASpace() throws {
        let display = try line("1+2+3+4+5+6+7+8+9+10+11+12+13+14+15", maxWidth: 120)
        let rows = Dictionary(grouping: display.subDisplays) { Int($0.position.y.rounded()) }
        XCTAssertGreaterThan(rows.count, 1, "should wrap")
        for (_, row) in rows {
            let first = try XCTUnwrap(row.map(\.position.x).min())
            XCTAssertEqual(first, 0, accuracy: 0.01)
        }
    }
}

/// A formula laid out with its own width as the maximum width stays on one line (a label sized
/// to fit lays it out like that)
final class NaturalWidthLineBreakTests: XCTestCase {
    func testFormulaFitsInItsOwnWidth() throws {
        let font = try XCTUnwrap(MTFontManager.manager.latinModernFont(withSize: 20))
        for latex in ["x_1^2+y_1^2=z", "A_n^m=\\frac{n!}{(n-m)!}", "a_n=a_1q^{n-1}", "\\sum_{i=1}^n i^2"] {
            let natural = try XCTUnwrap(MTTypesetter.createLineForMathList(try XCTUnwrap(MTMathListBuilder.build(fromString: latex)), font: font, style: .text))
            let fitted = try XCTUnwrap(MTTypesetter.createLineForMathList(try XCTUnwrap(MTMathListBuilder.build(fromString: latex)), font: font, style: .text, maxWidth: natural.width))
            // Lines are the base displays; scripts sit at other heights
            let bases = fitted.subDisplays.filter { ($0 as? MTMathListDisplay)?.type ?? .regular == .regular }
            XCTAssertEqual(Set(bases.map { Int($0.position.y.rounded()) }).count, 1, latex)
            XCTAssertEqual(fitted.width, natural.width, accuracy: 0.01, latex)
        }
    }
}
