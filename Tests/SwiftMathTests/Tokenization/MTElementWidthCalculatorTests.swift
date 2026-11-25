//
//  MTElementWidthCalculatorTests.swift
//  SwiftMathTests
//
//  Created by Claude Code on 2025-12-16.
//

import XCTest
@testable import SwiftMath

class MTElementWidthCalculatorTests: XCTestCase {

    var font: MTFont!
    var calculator: MTElementWidthCalculator!

    override func setUp() {
        super.setUp()
        font = MTFont(fontWithName: "latinmodern-math", size: 20)
        calculator = MTElementWidthCalculator(font: font, style: .display)
    }

    override func tearDown() {
        font = nil
        calculator = nil
        super.tearDown()
    }

    // MARK: - Text Width Tests

    func testMeasureSimpleText() {
        let width = calculator.measureText("x")
        XCTAssertGreaterThan(width, 0, "Text width should be positive")
    }

    func testMeasureEmptyText() {
        let width = calculator.measureText("")
        XCTAssertEqual(width, 0, "Empty text should have zero width")
    }

    func testMeasureMultiCharacterText() {
        let width = calculator.measureText("abc")
        XCTAssertGreaterThan(width, 0, "Multi-character text should have positive width")

        let singleWidth = calculator.measureText("a")
        XCTAssertGreaterThan(width, singleWidth, "Multi-character text should be wider than single character")
    }

    // MARK: - Display Width Tests

    func testMeasureDisplay() {
        let display = MTDisplay()
        display.width = 42.5

        let width = calculator.measureDisplay(display)
        XCTAssertEqual(width, 42.5)
    }

    // MARK: - Space Width Tests

    func testMeasureExplicitSpace() {
        let width = calculator.measureExplicitSpace(15.0)
        XCTAssertEqual(width, 15.0)
    }

    // MARK: - Inter-element Spacing Tests

    func testInterElementSpacingOrdinaryToOrdinary() {
        // Ordinary to ordinary: no space
        let spacing = calculator.getInterElementSpacing(left: .ordinary, right: .ordinary)
        XCTAssertEqual(spacing, 0)
    }

    func testInterElementSpacingOrdinaryToBinary() {
        // Ordinary to binary: medium space (4mu in display mode)
        let spacing = calculator.getInterElementSpacing(left: .ordinary, right: .binaryOperator)
        let expected = font.mathTable!.muUnit * 4
        XCTAssertEqual(spacing, expected, accuracy: 0.1)
    }

    func testInterElementSpacingOrdinaryToRelation() {
        // Ordinary to relation: thick space (5mu in display mode)
        let spacing = calculator.getInterElementSpacing(left: .ordinary, right: .relation)
        let expected = font.mathTable!.muUnit * 5
        XCTAssertEqual(spacing, expected, accuracy: 0.1)
    }

    func testInterElementSpacingBinaryToBinary() {
        // Binary to binary: invalid (should return 0)
        let spacing = calculator.getInterElementSpacing(left: .binaryOperator, right: .binaryOperator)
        XCTAssertEqual(spacing, 0)
    }

    func testInterElementSpacingInScriptMode() {
        // In script mode, nsMedium spacing should be 0
        let scriptCalculator = MTElementWidthCalculator(font: font, style: .script)
        let spacing = scriptCalculator.getInterElementSpacing(left: .ordinary, right: .binaryOperator)
        XCTAssertEqual(spacing, 0, "Script mode should have no nsMedium spacing")
    }

    func testInterElementSpacingOpenToClose() {
        // Open to close: no space
        let spacing = calculator.getInterElementSpacing(left: .open, right: .close)
        XCTAssertEqual(spacing, 0)
    }

    // MARK: - Edge Cases

    func testMeasureTextWithNumbers() {
        let width = calculator.measureText("123")
        XCTAssertGreaterThan(width, 0)
    }

    func testMeasureTextWithSpecialCharacters() {
        let width = calculator.measureText("α")
        XCTAssertGreaterThan(width, 0)
    }

    // MARK: - Consistency Tests

    func testWidthConsistency() {
        // Measuring same text twice should give same result
        let width1 = calculator.measureText("test")
        let width2 = calculator.measureText("test")
        XCTAssertEqual(width1, width2)
    }
}
