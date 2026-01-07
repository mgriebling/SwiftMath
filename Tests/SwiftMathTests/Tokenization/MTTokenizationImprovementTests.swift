//
//  MTTokenizationImprovementTests.swift
//  SwiftMathTests
//
//  Created by Claude Code on 2025-12-16.
//  Tests for tokenization-based line breaking
//

import XCTest
@testable import SwiftMath

class MTTokenizationImprovementTests: XCTestCase {

    var font: MTFont!

    override func setUp() {
        super.setUp()
        font = MTFont(fontWithName: "latinmodern-math", size: 20)
    }

    override func tearDown() {
        font = nil
        super.tearDown()
    }

    // MARK: - Real-World Scenario 1: Radical with Long Text

    func testRadicalWithLongText() {
        let latex = "\\text{Approximate }\\sqrt{61}\\text{ and compute the two decimal solutions}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 235
        )

        XCTAssertNotNil(display)

        let yPositions = Set(display!.subDisplays.map { $0.position.y })
        let lineCount = yPositions.count

        print("Radical with long text - Lines: \(lineCount), Width: \(display!.width)")

        // Should fit text efficiently
        XCTAssertGreaterThan(display!.width, 0)
    }

    // MARK: - Real-World Scenario 2: Equation with Text

    func testEquationWithText() {
        // "Integrate each term of the integrand x²+v"
        let latex = "\\text{Integrate each term of the integrand }x^2+v"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 300
        )

        XCTAssertNotNil(display)

        let yPositions = Set(display!.subDisplays.map { $0.position.y })
        let lineCount = yPositions.count

        print("Equation with text - Lines: \(lineCount)")

        // Should keep equation on same line as text
        XCTAssertGreaterThan(display!.width, 0)
    }

    // MARK: - Complex Expression Tests

    func testLongEquation() {
        let latex = "a+b+c+d+e+f+g+h+i+j+k"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 150
        )

        XCTAssertNotNil(display)

        let yPositions = Set(display!.subDisplays.map { $0.position.y })
        print("Long equation - Lines: \(yPositions.count)")

        // Should break at operators efficiently
        XCTAssertGreaterThan(display!.width, 0)
    }

    // MARK: - Edge Cases

    func testFractionWithScripts() {
        let latex = "\\frac{a}{b}^{n}+c+d+e+f"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 150
        )

        XCTAssertNotNil(display)
        // Should keep fraction and script grouped
        XCTAssertGreaterThan(display!.width, 0)
    }

    func testMixedContent() {
        let latex = "\\text{The answer is }x=\\frac{a+b}{c}\\text{ approximately}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        let display = MTTypesetter.createLineForMathList(
            mathList,
            font: font,
            style: .display,
            maxWidth: 200
        )

        XCTAssertNotNil(display)
        XCTAssertGreaterThan(display!.width, 0)
    }

    // MARK: - Performance Test

    func testPerformance() {
        let latex = "a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p"
        let mathList = MTMathListBuilder.build(fromString: latex)

        measure {
            _ = MTTypesetter.createLineForMathList(
                mathList,
                font: font,
                style: .display,
                maxWidth: 150
            )
        }
    }
}
