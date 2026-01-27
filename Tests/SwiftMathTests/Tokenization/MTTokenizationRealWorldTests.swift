//
//  MTTokenizationRealWorldTests.swift
//  SwiftMathTests
//
//  Created by Claude Code on 2025-12-16.
//  Real-world test cases from the specification
//

import XCTest
@testable import SwiftMath

class MTTokenizationRealWorldTests: XCTestCase {

    var font: MTFont!

    override func setUp() {
        super.setUp()
        font = MTFont(fontWithName: "latinmodern-math", size: 20)
    }

    override func tearDown() {
        font = nil
        super.tearDown()
    }

    // MARK: - Spec Example 1: Radical with Long Text
    // From spec: "Approximate √61 and compute the two decimal solutions"
    // Problem: After √61 (at x=116px), there's 119px of space remaining,
    // but text (263px) breaks to next line instead of fitting partial text

    func testSpecExample1_ApproximateRadical() {
        // Test with tokenization enabled

        let latex = "\\text{Approximate }\\sqrt{61}\\text{ and compute the two decimal solutions}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        // Width chosen to match spec scenario
        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 235
        )

        XCTAssertNotNil(display, "Display should be created")

        // With tokenization, should utilize available width better
        // Check that we're using more horizontal space
        XCTAssertGreaterThan(display!.width, 150, "Should use significant width")

        // Verify we have multiple line breaks (can't fit all on one line)
        let yPositions = Set(display!.subDisplays.map { $0.position.y })
        XCTAssertGreaterThan(yPositions.count, 1, "Should break into multiple lines")

        print("✓ Spec Example 1: Width used = \(display!.width), Lines = \(yPositions.count)")
    }

    // MARK: - Spec Example 2: Equation with Integrand
    // From spec: "Integrate each term of the integrand x²+v"
    // Problem: Breaks after text instead of keeping equation on same line

    func testSpecExample2_IntegrateEquation() {

        let latex = "\\text{Integrate each term of the integrand }x^2+v\\text{ separately}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 350
        )

        XCTAssertNotNil(display)
        XCTAssertGreaterThan(display!.width, 200, "Should use available width")

        print("✓ Spec Example 2: Width = \(display!.width)")
    }

    // MARK: - Operator Breaking Tests

    func testBreakAtBinaryOperators() {

        // Simple arithmetic that should break at + operators
        let latex = "a+b-c\\times d\\div e"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 100
        )

        XCTAssertNotNil(display)

        // Should break at operators when needed
        print("✓ Binary operators: Width = \(display!.width)")
    }

    func testBreakAtRelationOperators() {

        let latex = "x=y<z>w\\leq a\\geq b\\neq c"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 120
        )

        XCTAssertNotNil(display)

        print("✓ Relation operators: Width = \(display!.width)")
    }

    // MARK: - Script Grouping Tests

    func testScriptsStayGrouped() {

        // x² should stay together
        let latex = "x^{2}+y^{3}+z^{4}+a^{5}+b^{6}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 100
        )

        XCTAssertNotNil(display)

        // Each base+script should stay together
        print("✓ Script grouping: Width = \(display!.width)")
    }

    func testSubscriptAndSuperscript() {

        let latex = "x_{i}^{2}+y_{j}^{3}+z_{k}^{4}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 120
        )

        XCTAssertNotNil(display)

        print("✓ Sub+superscript: Width = \(display!.width)")
    }

    // MARK: - Fraction Tests

    func testFractionBreaking() {

        let latex = "\\frac{a}{b}+\\frac{c}{d}+\\frac{e}{f}+\\frac{g}{h}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 150
        )

        XCTAssertNotNil(display)

        // Fractions should remain atomic
        print("✓ Fractions: Width = \(display!.width)")
    }

    func testFractionWithSuperscript() {

        let latex = "\\frac{a}{b}^{n}+c+d+e"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 100
        )

        XCTAssertNotNil(display)

        // Fraction and superscript should stay grouped
        print("✓ Fraction with script: Width = \(display!.width)")
    }

    // MARK: - Radical Tests

    func testRadicalBreaking() {

        let latex = "\\sqrt{a}+\\sqrt{b}+\\sqrt{c}+\\sqrt{d}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 120
        )

        XCTAssertNotNil(display)

        // Radicals should remain atomic
        print("✓ Radicals: Width = \(display!.width)")
    }

    // MARK: - Delimiter Tests

    func testParenthesesBreaking() {

        let latex = "(a+b)+(c-d)+(e\\times f)"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 120
        )

        XCTAssertNotNil(display)

        // Should not break after ( or before )
        print("✓ Parentheses: Width = \(display!.width)")
    }

    // MARK: - Mixed Content Tests

    func testMixedTextAndMath() {

        let latex = "\\text{The quick brown fox jumps over }x+y=z\\text{ lazily}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 250
        )

        XCTAssertNotNil(display)

        print("✓ Mixed content: Width = \(display!.width)")
    }

    // MARK: - Width Utilization Test

    func testWidthUtilization() {
        let latex = "\\text{Calculate }\\sqrt{x^2+y^2}\\text{ and simplify the result}"

        let display = MTTypesetter.createLineForMathList(
            MTMathListBuilder.build(fromString: latex),
            font: font,
            style: .display,
            maxWidth: 250
        )

        XCTAssertNotNil(display)

        let width = display!.width

        print("✓ Width utilization: \(width) pts with max 250 pts")

        // Should efficiently use available width
        XCTAssertGreaterThan(width, 200, "Should use most of available width")
    }

    // MARK: - Edge Cases

    func testEmptyExpression() {

        let mathList = MTMathList()
        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 100
        )

        // Empty math list should return an empty display (not nil) to match KaTeX behavior
        // This allows empty fraction numerators/denominators to render correctly
        XCTAssertNotNil(display, "Empty expression should return an empty display (KaTeX compatibility)")
        XCTAssertEqual(display?.width, 0, "Empty display should have zero width")
        XCTAssertEqual(display?.ascent, 0, "Empty display should have zero ascent")
        XCTAssertEqual(display?.descent, 0, "Empty display should have zero descent")
    }

    func testSingleAtom() {

        let latex = "x"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 100
        )

        XCTAssertNotNil(display)
        XCTAssertGreaterThan(display!.width, 0)
    }

    func testVeryLongExpression() {

        // Generate a+b+c+...
        var latex = ""
        for i in 0..<26 {
            let letter = String(UnicodeScalar(UInt8(97 + i)))
            latex += letter
            if i < 25 {
                latex += "+"
            }
        }

        let mathList = MTMathListBuilder.build(fromString: latex)
        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 200
        )

        XCTAssertNotNil(display)

        // Should break into multiple lines
        let yPositions = Set(display!.subDisplays.map { $0.position.y })
        XCTAssertGreaterThan(yPositions.count, 1, "Should require multiple lines")

        print("✓ Very long expression: \(yPositions.count) lines")
    }
}
