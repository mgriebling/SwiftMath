//
//  MTTypesetter+TokenizationTests.swift
//  SwiftMathTests
//
//  Created by Claude Code on 2025-12-16.
//

import XCTest
@testable import SwiftMath

class MTTypesetterTokenizationTests: XCTestCase {

    var font: MTFont!

    override func setUp() {
        super.setUp()
        font = MTFont(fontWithName: "latinmodern-math", size: 20)
    }

    override func tearDown() {
        font = nil
        super.tearDown()
    }

    // MARK: - Integration Tests

    func testSimpleExpression() {
        // x + y
        let mathList = MTMathList()
        mathList.add(MTMathAtom(type: .variable, value: "x"))
        mathList.add(MTMathAtom(type: .binaryOperator, value: "+"))
        mathList.add(MTMathAtom(type: .variable, value: "y"))

        let display = MTTypesetter.createLineForMathListWithTokenization(
            mathList,
            font: font,
            style: .display,
            cramped: false,
            spaced: false,
            maxWidth: 0
        )

        XCTAssertNotNil(display)
        XCTAssertGreaterThan(display!.width, 0)
        XCTAssertGreaterThan(display!.subDisplays.count, 0)
    }

    func testExpressionWithWidthConstraint() {
        // Create a long expression
        let mathList = MTMathList()
        for i in 0..<10 {
            mathList.add(MTMathAtom(type: .variable, value: "x"))
            if i < 9 {
                mathList.add(MTMathAtom(type: .binaryOperator, value: "+"))
            }
        }

        let display = MTTypesetter.createLineForMathListWithTokenization(
            mathList,
            font: font,
            style: .display,
            cramped: false,
            spaced: false,
            maxWidth: 150
        )

        XCTAssertNotNil(display)
        // With width constraint, should create multiple lines
        // Check that display has reasonable dimensions
        XCTAssertGreaterThan(display!.subDisplays.count, 0)
    }

    func testExpressionWithScripts() {
        // x^2 + y
        let mathList = MTMathList()

        let x = MTMathAtom(type: .variable, value: "x")
        let superScript = MTMathList()
        superScript.add(MTMathAtom(type: .number, value: "2"))
        x.superScript = superScript
        mathList.add(x)

        mathList.add(MTMathAtom(type: .binaryOperator, value: "+"))
        mathList.add(MTMathAtom(type: .variable, value: "y"))

        let display = MTTypesetter.createLineForMathListWithTokenization(
            mathList,
            font: font,
            style: .display,
            cramped: false,
            spaced: false,
            maxWidth: 0
        )

        XCTAssertNotNil(display)
        XCTAssertGreaterThan(display!.width, 0)
    }

    func testFractionInExpression() {
        let mathList = MTMathList()

        let fraction = MTFraction()
        fraction.numerator = MTMathList()
        fraction.numerator?.add(MTMathAtom(type: .variable, value: "a"))
        fraction.denominator = MTMathList()
        fraction.denominator?.add(MTMathAtom(type: .variable, value: "b"))

        mathList.add(fraction)
        mathList.add(MTMathAtom(type: .binaryOperator, value: "+"))
        mathList.add(MTMathAtom(type: .variable, value: "c"))

        let display = MTTypesetter.createLineForMathListWithTokenization(
            mathList,
            font: font,
            style: .display,
            cramped: false,
            spaced: false,
            maxWidth: 0
        )

        XCTAssertNotNil(display)
        XCTAssertGreaterThan(display!.width, 0)
    }

    func testEmptyMathList() {
        let mathList = MTMathList()

        let display = MTTypesetter.createLineForMathListWithTokenization(
            mathList,
            font: font,
            style: .display,
            cramped: false,
            spaced: false,
            maxWidth: 0
        )

        XCTAssertNil(display, "Empty math list should return nil")
    }

    func testNilMathList() {
        let display = MTTypesetter.createLineForMathListWithTokenization(
            nil,
            font: font,
            style: .display,
            cramped: false,
            spaced: false,
            maxWidth: 0
        )

        XCTAssertNil(display, "Nil math list should return nil")
    }
}
