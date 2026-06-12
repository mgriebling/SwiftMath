import XCTest
@testable import SwiftMath

// Regression tests for GitHub issue #66:
// "Duplicate characters are rendered when \left and \right are used"
// https://github.com/mgriebling/SwiftMath/issues/66
//
// Root cause: makeLeftRight typeset the inner list twice (once for the
// delimiter height, once for placement). Typesetting an MTMathList twice is
// non-idempotent because preprocessMathList fuses ordinary atoms in place
// (MTMathAtom.fuse does `nucleus += atom.nucleus`), so the second pass
// duplicated any multi-atom run inside the \left...\right group.
final class LeftRightDuplicationTests: XCTestCase {

    /// Concatenate the text rendered by every MTCTLineDisplay in the tree.
    private func collectGlyphRuns(_ display: MTDisplay, into runs: inout [String]) {
        if let line = display as? MTCTLineDisplay {
            if let s = line.attributedString?.string, !s.isEmpty {
                runs.append(s)
            }
        }
        if let listDisplay = display as? MTMathListDisplay {
            for sub in listDisplay.subDisplays {
                collectGlyphRuns(sub, into: &runs)
            }
        }
        if let frac = display as? MTFractionDisplay {
            if let n = frac.numerator { collectGlyphRuns(n, into: &runs) }
            if let d = frac.denominator { collectGlyphRuns(d, into: &runs) }
        }
        if let radical = display as? MTRadicalDisplay, let radicand = radical.radicand {
            collectGlyphRuns(radicand, into: &runs)
        }
    }

    private func renderedText(_ latex: String) -> String {
        let mathList = MTMathListBuilder.build(fromString: latex)!
        let font = MTFontManager.fontManager.defaultFont!
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)!
        var runs = [String]()
        collectGlyphRuns(display, into: &runs)
        return runs.joined()
    }

    func testSimpleLeftRightDoesNotDuplicate() throws {
        let rendered = renderedText("\\left(x^3\\right)")
        // \left(...\right) renders the parentheses as glyphs, so the collected
        // CTLine text is the pure inner content. "x" and exponent "3" exactly once.
        XCTAssertEqual(rendered.filter { $0 == "3" }.count, 1,
                       "Exponent '3' duplicated. Rendered: \(rendered)")
        // The italic-math 'x' is U+1D465.
        XCTAssertEqual(rendered.filter { String($0) == "\u{1D465}" }.count, 1,
                       "Inner 'x' duplicated. Rendered: \(rendered)")
    }

    func testIssue66ReproDoesNotDuplicate() throws {
        // The exact reporter expression from issue #66, compared against the
        // delimiter-free variant the reporter confirmed renders correctly.
        let rendered = renderedText("\\phi = \\arctan\\left(\\frac{-C R \\omega}{1 - C L \\omega^2}\\right)")
        // \left( renders the paren as a glyph (not CTLine text); the literal '('
        // in the baseline renders as CTLine text. Strip the literal delimiters so
        // the comparison is apples-to-apples on the inner content.
        let baseline = renderedText("\\phi = \\arctan(\\frac{-C R \\omega}{1 - C L \\omega^2})")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        XCTAssertEqual(rendered, baseline,
                       "Issue #66 expression duplicated inner content.\n  baseline: \(baseline)\n  rendered: \(rendered)")
    }

    func testFractionInLeftRightDoesNotDuplicate() throws {
        let rendered = renderedText("\\left(\\frac{-C R \\omega}{1 - C L \\omega^2}\\right)")
        // 'C' (U+1D436) appears once in the numerator and once in the denominator.
        let cCount = rendered.filter { String($0) == "\u{1D436}" }.count
        XCTAssertEqual(cCount, 2, "C should appear exactly twice (num + denom). Rendered: \(rendered)")
        // 'R' (U+1D445) only in the numerator -> exactly once.
        let rCount = rendered.filter { String($0) == "\u{1D445}" }.count
        XCTAssertEqual(rCount, 1, "R duplicated. Rendered: \(rendered)")
        // 'L' (U+1D43F) only in the denominator -> exactly once.
        let lCount = rendered.filter { String($0) == "\u{1D43F}" }.count
        XCTAssertEqual(lCount, 1, "L duplicated. Rendered: \(rendered)")
    }

    func testLeftBracketRightBracketDoesNotDuplicate() throws {
        let rendered = renderedText("\\left[a+b\\right]")
        XCTAssertEqual(rendered.filter { String($0) == "\u{1D44E}" }.count, 1, "Inner 'a' duplicated. Rendered: \(rendered)") // a = U+1D44E
        XCTAssertEqual(rendered.filter { String($0) == "\u{1D44F}" }.count, 1, "Inner 'b' duplicated. Rendered: \(rendered)") // b = U+1D44F
    }

    func testNestedLeftRightDoesNotDuplicate() throws {
        // Nested \left\right around an inner \left\right around a multi-atom fraction.
        let rendered = renderedText("\\left(\\left[\\frac{C R}{L}\\right]\\right)")
        XCTAssertEqual(rendered.filter { String($0) == "\u{1D445}" }.count, 1, "Nested inner 'R' duplicated. Rendered: \(rendered)")
        XCTAssertEqual(rendered.filter { String($0) == "\u{1D43F}" }.count, 1, "Nested inner 'L' duplicated. Rendered: \(rendered)")
    }

    func testLeftDotRightDoesNotDuplicate() throws {
        let rendered = renderedText("\\left.\\frac{C R}{L}\\right)")
        XCTAssertEqual(rendered.filter { String($0) == "\u{1D445}" }.count, 1, "Inner 'R' duplicated. Rendered: \(rendered)")
        XCTAssertEqual(rendered.filter { String($0) == "\u{1D43F}" }.count, 1, "Inner 'L' duplicated. Rendered: \(rendered)")
    }
}
