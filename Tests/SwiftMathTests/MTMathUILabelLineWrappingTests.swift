//
//  MTMathUILabelLineWrappingTests.swift
//  SwiftMathTests
//
//  Tests for line wrapping functionality in MTMathUILabel
//

import XCTest
@testable import SwiftMath

class MTMathUILabelLineWrappingTests: XCTestCase {

    func testBasicIntrinsicContentSize() {
        let label = MTMathUILabel()
        label.latex = "\\(x + y\\)"
        label.font = MTFontManager.fontManager.defaultFont

        // Debug: check if parsing worked
        XCTAssertNotNil(label.mathList, "Math list should not be nil")
        XCTAssertNil(label.error, "Should have no parsing error, got: \(String(describing: label.error))")
        XCTAssertNotNil(label.font, "Font should not be nil")

        let size = label.intrinsicContentSize

        XCTAssertGreaterThan(size.width, 0, "Width should be greater than 0, got \(size.width)")
        XCTAssertGreaterThan(size.height, 0, "Height should be greater than 0, got \(size.height)")
    }

    func testTextModeIntrinsicContentSize() {
        let label = MTMathUILabel()
        label.latex = "\\(\\text{Hello World}\\)"
        label.font = MTFontManager.fontManager.defaultFont
        label.labelMode = .text

        let size = label.intrinsicContentSize

        XCTAssertGreaterThan(size.width, 0, "Width should be greater than 0, got \(size.width)")
        XCTAssertGreaterThan(size.height, 0, "Height should be greater than 0, got \(size.height)")
    }

    func testLongTextIntrinsicContentSize() {
        let label = MTMathUILabel()
        label.latex = "\\(\\text{Rappelons la conversion : 1 km équivaut à 1000 m.}\\)"
        label.font = MTFontManager.fontManager.defaultFont
        label.labelMode = .text

        let size = label.intrinsicContentSize

        XCTAssertGreaterThan(size.width, 0, "Width should be greater than 0, got \(size.width)")
        XCTAssertGreaterThan(size.height, 0, "Height should be greater than 0, got \(size.height)")
    }

    func testSizeThatFitsWithoutConstraint() {
        let label = MTMathUILabel()
        label.latex = "\\(\\text{Hello World}\\)"
        label.font = MTFontManager.fontManager.defaultFont

        let size = label.sizeThatFits(CGSize.zero)

        XCTAssertGreaterThan(size.width, 0, "Width should be greater than 0, got \(size.width)")
        XCTAssertGreaterThan(size.height, 0, "Height should be greater than 0, got \(size.height)")
    }

    func testSizeThatFitsWithWidthConstraint() {
        let label = MTMathUILabel()
        label.latex = "\\(\\text{Rappelons la conversion : 1 km équivaut à 1000 m.}\\)"
        label.font = MTFontManager.fontManager.defaultFont
        label.labelMode = .text

        // Get unconstrained size first
        let unconstrainedSize = label.sizeThatFits(CGSize.zero)
        XCTAssertGreaterThan(unconstrainedSize.width, 0, "Unconstrained width should be > 0")

        // Test with width constraint (use 300 since longest word might be ~237pt)
        let constrainedSize = label.sizeThatFits(CGSize(width: 300, height: CGFloat.greatestFiniteMagnitude))

        XCTAssertGreaterThan(constrainedSize.width, 0, "Constrained width should be greater than 0, got \(constrainedSize.width)")
        XCTAssertLessThan(constrainedSize.width, unconstrainedSize.width, "Constrained width (\(constrainedSize.width)) should be less than unconstrained (\(unconstrainedSize.width))")
        XCTAssertGreaterThan(constrainedSize.height, 0, "Constrained height should be greater than 0, got \(constrainedSize.height)")

        // When constrained, height should increase when text wraps
        XCTAssertGreaterThan(constrainedSize.height, unconstrainedSize.height,
                            "Constrained height (\(constrainedSize.height)) should be > unconstrained (\(unconstrainedSize.height)) when text wraps")
    }

    func testPreferredMaxLayoutWidth() {
        let label = MTMathUILabel()
        label.latex = "\\(\\text{Rappelons la conversion : 1 km équivaut à 1000 m.}\\)"
        label.font = MTFontManager.fontManager.defaultFont
        label.labelMode = .text

        // Get unconstrained size
        let unconstrainedSize = label.intrinsicContentSize

        // Now set preferred max width (use 300 since longest word might be ~237pt)
        label.preferredMaxLayoutWidth = 300
        let constrainedSize = label.intrinsicContentSize

        XCTAssertGreaterThan(constrainedSize.width, 0, "Width should be greater than 0, got \(constrainedSize.width)")
        XCTAssertLessThan(constrainedSize.width, unconstrainedSize.width, "Constrained width (\(constrainedSize.width)) should be < unconstrained (\(unconstrainedSize.width))")
        XCTAssertGreaterThan(constrainedSize.height, unconstrainedSize.height, "Constrained height (\(constrainedSize.height)) should be > unconstrained (\(unconstrainedSize.height)) due to wrapping")
    }

    func testWordBoundaryBreaking() {
        let label = MTMathUILabel()
        label.latex = "\\(\\text{Word1 Word2 Word3 Word4 Word5}\\)"
        label.font = MTFontManager.fontManager.defaultFont
        label.labelMode = .text
        label.preferredMaxLayoutWidth = 150

        let size = label.intrinsicContentSize

        XCTAssertGreaterThan(size.width, 0, "Width should be greater than 0, got \(size.width)")
        XCTAssertGreaterThan(size.height, 0, "Height should be greater than 0, got \(size.height)")

        // Verify it actually uses the layout
        label.frame = CGRect(origin: .zero, size: size)
        #if os(macOS)
        label.layout()
        #else
        label.layoutSubviews()
        #endif

        XCTAssertNotNil(label.displayList, "Display list should be created")
    }

    func testEmptyLatex() {
        let label = MTMathUILabel()
        label.latex = ""
        label.font = MTFontManager.fontManager.defaultFont

        let size = label.intrinsicContentSize

        // Empty latex should still return a valid size (might be zero or minimal)
        XCTAssertGreaterThanOrEqual(size.width, 0, "Width should be >= 0 for empty latex, got \(size.width)")
        XCTAssertGreaterThanOrEqual(size.height, 0, "Height should be >= 0 for empty latex, got \(size.height)")
    }

    func testMathAndTextMixed() {
        let label = MTMathUILabel()
        label.latex = "\\(\\text{Result: } x^2 + y^2 = z^2\\)"
        label.font = MTFontManager.fontManager.defaultFont
        label.labelMode = .text

        let size = label.intrinsicContentSize

        XCTAssertGreaterThan(size.width, 0, "Width should be greater than 0, got \(size.width)")
        XCTAssertGreaterThan(size.height, 0, "Height should be greater than 0, got \(size.height)")
    }

    func testDebugSizeThatFitsWithConstraint() {
        let label = MTMathUILabel()
        label.latex = "\\(\\text{Word1 Word2 Word3 Word4 Word5}\\)"
        label.font = MTFontManager.fontManager.defaultFont
        label.labelMode = .text

        let unconstr = label.sizeThatFits(CGSize.zero)
        let constr = label.sizeThatFits(CGSize(width: 150, height: 999))

        XCTAssertLessThan(constr.width, unconstr.width, "Constrained (\(constr.width)) should be < unconstrained (\(unconstr.width))")
        XCTAssertGreaterThan(constr.height, unconstr.height, "Constrained height (\(constr.height)) should be > unconstrained (\(unconstr.height))")
    }

    func testAccentedCharactersWithLineWrapping() {
        let label = MTMathUILabel()
        // French text with accented characters: è, é, à
        label.latex = "\\(\\text{Rappelons la relation entre kilomètres et mètres.}\\)"
        label.font = MTFontManager.fontManager.defaultFont
        label.labelMode = .text

        // Get unconstrained size
        let unconstrainedSize = label.intrinsicContentSize

        // Set a width constraint that should cause wrapping
        label.preferredMaxLayoutWidth = 250
        let constrainedSize = label.intrinsicContentSize

        // Verify wrapping occurred
        XCTAssertGreaterThan(constrainedSize.width, 0, "Width should be > 0")
        XCTAssertLessThan(constrainedSize.width, unconstrainedSize.width, "Constrained width should be < unconstrained")
        XCTAssertGreaterThan(constrainedSize.height, unconstrainedSize.height, "Height should increase when wrapped")

        // Verify the label can render without errors
        label.frame = CGRect(origin: .zero, size: constrainedSize)
        #if os(macOS)
        label.layout()
        #else
        label.layoutSubviews()
        #endif

        XCTAssertNotNil(label.displayList, "Display list should be created")
        XCTAssertNil(label.error, "Should have no rendering error")
    }
}
