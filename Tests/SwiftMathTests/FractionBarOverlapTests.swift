//
//  FractionBarOverlapTests.swift
//  SwiftMathTests
//
//  Verifies that the numerator and denominator of a fraction do not overlap
//  the fraction bar, and that there is adequate clearance (the reported issue
//  is that boxes appear to touch / overlap the bar).
//

import XCTest
@testable import SwiftMath

final class FractionBarOverlapTests: XCTestCase {

    var font: MTFont!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.font = MTFontManager.fontManager.defaultFont
    }

    override func tearDownWithError() throws {
        self.font = nil
        try super.tearDownWithError()
    }

    /// Recursively collects every MTFractionDisplay in a display tree, descending
    /// into list displays as well as into the numerator/denominator of fractions.
    private func collectFractions(_ display: MTDisplay) -> [MTFractionDisplay] {
        var result = [MTFractionDisplay]()
        if let frac = display as? MTFractionDisplay {
            result.append(frac)
            if let num = frac.numerator { result += collectFractions(num) }
            if let denom = frac.denominator { result += collectFractions(denom) }
        } else if let list = display as? MTMathListDisplay {
            for sub in list.subDisplays {
                result += collectFractions(sub)
            }
        }
        return result
    }

    /// For a single fraction, returns the clearance (in points) between the bottom
    /// of the numerator and the top edge of the bar, and between the top of the
    /// denominator and the bottom edge of the bar. Negative means overlap.
    private func gaps(for frac: MTFractionDisplay) -> (numeratorGap: CGFloat, denominatorGap: CGFloat) {
        let halfThickness = frac.lineThickness / 2

        // Bar edges in absolute (line) coordinates.
        let barTop = frac.position.y + frac.linePosition + halfThickness
        let barBottom = frac.position.y + frac.linePosition - halfThickness

        // Numerator sits above the bar: its lowest drawn edge is position.y - descent.
        let numeratorBottom = frac.numerator!.position.y - frac.numerator!.descent
        // Denominator sits below the bar: its highest drawn edge is position.y + ascent.
        let denominatorTop = frac.denominator!.position.y + frac.denominator!.ascent

        let numeratorGap = numeratorBottom - barTop
        let denominatorGap = barBottom - denominatorTop
        return (numeratorGap, denominatorGap)
    }

    private func assertNoBarOverlap(latex: String, style: MTLineStyle = .display, file: StaticString = #file, line: UInt = #line) {
        guard let mathList = MTMathListBuilder.build(fromString: latex) else {
            XCTFail("Failed to parse: \(latex)", file: file, line: line)
            return
        }
        guard let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: style) else {
            XCTFail("Failed to typeset: \(latex)", file: file, line: line)
            return
        }

        let fractions = collectFractions(display)
        XCTAssertFalse(fractions.isEmpty, "Expected at least one fraction in: \(latex)", file: file, line: line)

        print("\n=== \(latex) (\(fractions.count) fraction(s)) ===")
        for (i, frac) in fractions.enumerated() {
            let g = gaps(for: frac)
            print(String(format: "  frac[%d]: barThickness=%.3f linePos=%.3f numeratorUp=%.3f denominatorDown=%.3f | numGap=%.3f denomGap=%.3f",
                         i, frac.lineThickness, frac.linePosition, frac.numeratorUp, frac.denominatorDown, g.numeratorGap, g.denominatorGap))

            // Only fractions that actually draw a rule are relevant here.
            guard frac.lineThickness > 0 else { continue }

            // The numerator/denominator boxes must not overlap the bar. A tiny
            // negative tolerance accounts for floating point rounding only.
            XCTAssertGreaterThanOrEqual(g.numeratorGap, -0.001,
                "Numerator overlaps the fraction bar (gap=\(g.numeratorGap)) in: \(latex)", file: file, line: line)
            XCTAssertGreaterThanOrEqual(g.denominatorGap, -0.001,
                "Denominator overlaps the fraction bar (gap=\(g.denominatorGap)) in: \(latex)", file: file, line: line)
        }
    }

    // MARK: - The reported equations

    func testSimpleFraction() {
        assertNoBarOverlap(latex: "\\(\\frac{3}{4}\\)")
    }

    func testNestedFraction() {
        assertNoBarOverlap(latex: "\\(\\frac{1 + \\frac{1}{x}}{2 - \\frac{1}{y}}\\)")
    }

    func testDerivativeFraction() {
        assertNoBarOverlap(latex: "\\(\\frac{d}{dx}f(x)\\)")
    }

    func testPartialDerivativeFraction() {
        assertNoBarOverlap(latex: "\\(\\frac{\\partial^2 f}{\\partial x \\partial y}\\)")
    }

    // MARK: - Aggregate, also exercising text style (inline) sizing

    /// `\(...\)` inline delimiters make the builder prepend a `\textstyle` atom,
    /// forcing text-style rendering. Plain TeX/KaTeX then use a minimal text-style
    /// gap (1× rule thickness ≈ 0.8pt at 20pt), which makes inline fractions hug
    /// the bar. SwiftMath intentionally raises the inline clearance to the
    /// display-style gap min (3× rule thickness ≈ 2.4pt) so inline fractions get
    /// the same breathing room as display fractions. This test guards that the
    /// inline denominator clearance is no longer the tight 0.8pt value.
    func testInlineUsesDisplayClearance() {
        // Bare LaTeX (no \(...\)) typeset in display style.
        let displayList = MTMathListBuilder.build(fromString: "\\frac{3}{4}")!
        let displayFrac = collectFractions(
            MTTypesetter.createLineForMathList(displayList, font: font, style: .display)!).first!
        let displayGaps = gaps(for: displayFrac)

        // Inline \(...\) → builder forces \textstyle.
        let inlineList = MTMathListBuilder.build(fromString: "\\(\\frac{3}{4}\\)")!
        let inlineFrac = collectFractions(
            MTTypesetter.createLineForMathList(inlineList, font: font, style: .display)!).first!
        let inlineGaps = gaps(for: inlineFrac)

        print(String(format: "\n=== inline vs display 3/4 ===\n  display: numGap=%.3f denomGap=%.3f\n  inline : numGap=%.3f denomGap=%.3f",
                     displayGaps.numeratorGap, displayGaps.denominatorGap,
                     inlineGaps.numeratorGap, inlineGaps.denominatorGap))

        // Inline clearance is now at least the display-style gap min (≈2.4pt),
        // not the old tight 0.8pt text-style value.
        XCTAssertGreaterThanOrEqual(inlineGaps.denominatorGap, 2.39,
                       "Inline denominator gap should use the display-style clearance")
        XCTAssertGreaterThanOrEqual(inlineGaps.numeratorGap, 2.39,
                       "Inline numerator gap should use the display-style clearance")
        XCTAssertGreaterThanOrEqual(displayGaps.denominatorGap, 2.39,
                       "Display-style denominator gap should be at least the display gap min")
    }

    func testAllReportedEquationsDisplayAndText() {
        let equations = [
            "\\(\\frac{3}{4}\\)",
            "\\(\\frac{1 + \\frac{1}{x}}{2 - \\frac{1}{y}}\\)",
            "\\(\\frac{d}{dx}f(x)\\)",
            "\\(\\frac{\\partial^2 f}{\\partial x \\partial y}\\)",
        ]
        for eq in equations {
            assertNoBarOverlap(latex: eq, style: .display)
            assertNoBarOverlap(latex: eq, style: .text)
        }
    }
}
