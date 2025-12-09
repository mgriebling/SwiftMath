//
//  MTLineFitterTests.swift
//  SwiftMathTests
//
//  Created by Claude Code on 2025-12-16.
//

import XCTest
@testable import SwiftMath

class MTLineFitterTests: XCTestCase {

    var font: MTFont!

    override func setUp() {
        super.setUp()
        font = MTFont(fontWithName: "latinmodern-math", size: 20)
    }

    override func tearDown() {
        font = nil
        super.tearDown()
    }

    // MARK: - Basic Fitting Tests

    func testFitEmptyList() {
        let fitter = MTLineFitter(maxWidth: 100)
        let lines = fitter.fitLines([])
        XCTAssertEqual(lines.count, 0)
    }

    func testFitSingleElement() {
        let element = createTextElement("x", width: 10)
        let fitter = MTLineFitter(maxWidth: 100)
        let lines = fitter.fitLines([element])

        XCTAssertEqual(lines.count, 1)
        XCTAssertEqual(lines[0].count, 1)
    }

    func testFitElementsThatFitOnOneLine() {
        let elements = [
            createTextElement("x", width: 20),
            createTextElement("+", width: 20),
            createTextElement("y", width: 20)
        ]
        let fitter = MTLineFitter(maxWidth: 100)
        let lines = fitter.fitLines(elements)

        XCTAssertEqual(lines.count, 1, "All elements should fit on one line")
        XCTAssertEqual(lines[0].count, 3)
    }

    func testFitElementsThatRequireMultipleLines() {
        let elements = [
            createTextElement("a", width: 40),
            createTextElement("+", width: 40),
            createTextElement("b", width: 40),
            createTextElement("=", width: 40),
            createTextElement("c", width: 40)
        ]
        let fitter = MTLineFitter(maxWidth: 100)
        let lines = fitter.fitLines(elements)

        XCTAssertGreaterThan(lines.count, 1, "Should require multiple lines")
    }

    func testNoWidthConstraint() {
        let elements = [
            createTextElement("x", width: 200),
            createTextElement("+", width: 200),
            createTextElement("y", width: 200)
        ]
        let fitter = MTLineFitter(maxWidth: 0)  // No constraint
        let lines = fitter.fitLines(elements)

        XCTAssertEqual(lines.count, 1, "With no width constraint, all elements on one line")
    }

    // MARK: - Break Point Tests

    func testBreakAtOperator() {
        let elements = [
            createTextElement("x", width: 30),
            createOperatorElement("+", width: 30),  // Good break point
            createTextElement("y", width: 30),
            createTextElement("z", width: 30)
        ]
        let fitter = MTLineFitter(maxWidth: 80)
        let lines = fitter.fitLines(elements)

        XCTAssertGreaterThan(lines.count, 1, "Should break at operator")
    }

    func testRespectGrouping() {
        let groupId = UUID()

        let elements = [
            createGroupedElement("x", width: 20, groupId: groupId, isLast: false),
            createGroupedElement("²", width: 15, groupId: groupId, isLast: true),
            createOperatorElement("+", width: 20),
            createTextElement("y", width: 20)
        ]

        let fitter = MTLineFitter(maxWidth: 50)
        let lines = fitter.fitLines(elements)

        // x² should stay together (35px), even if it means starting a new line
        if lines.count > 1 {
            // If broken, x² should be together
            for line in lines {
                let groupedCount = line.filter { $0.groupId == groupId }.count
                // Either all grouped elements together or none
                XCTAssertTrue(groupedCount == 0 || groupedCount == 2)
            }
        }
    }

    // MARK: - Margin Tests

    func testMargin() {
        let elements = [
            createTextElement("x", width: 40),
            createTextElement("y", width: 40),
            createTextElement("z", width: 40)
        ]

        let fitter = MTLineFitter(maxWidth: 100, margin: 10)
        let lines = fitter.fitLines(elements)

        // With margin, effective width is 90, so should break earlier
        XCTAssertGreaterThan(lines.count, 1)
    }

    // MARK: - Helper Methods

    private func createTextElement(_ text: String, width: CGFloat) -> MTBreakableElement {
        let atom = MTMathAtom(type: .ordinary, value: text)
        return MTBreakableElement(
            content: .text(text),
            width: width,
            height: 10,
            ascent: 8,
            descent: 2,
            isBreakBefore: true,
            isBreakAfter: true,
            penaltyBefore: MTBreakPenalty.good,
            penaltyAfter: MTBreakPenalty.good,
            groupId: nil,
            parentId: nil,
            originalAtom: atom,
            indexRange: NSMakeRange(0, 1),
            color: nil,
            backgroundColor: nil,
            indivisible: false
        )
    }

    private func createOperatorElement(_ op: String, width: CGFloat) -> MTBreakableElement {
        let atom = MTMathAtom(type: .binaryOperator, value: op)
        return MTBreakableElement(
            content: .operator(op, type: .binaryOperator),
            width: width,
            height: 10,
            ascent: 8,
            descent: 2,
            isBreakBefore: true,
            isBreakAfter: true,
            penaltyBefore: MTBreakPenalty.best,
            penaltyAfter: MTBreakPenalty.best,
            groupId: nil,
            parentId: nil,
            originalAtom: atom,
            indexRange: NSMakeRange(0, 1),
            color: nil,
            backgroundColor: nil,
            indivisible: false
        )
    }

    private func createGroupedElement(_ text: String, width: CGFloat, groupId: UUID, isLast: Bool) -> MTBreakableElement {
        let atom = MTMathAtom(type: .ordinary, value: text)
        return MTBreakableElement(
            content: .text(text),
            width: width,
            height: 10,
            ascent: 8,
            descent: 2,
            isBreakBefore: !isLast,  // First element can break before
            isBreakAfter: isLast,    // Last element can break after
            penaltyBefore: isLast ? MTBreakPenalty.never : MTBreakPenalty.good,
            penaltyAfter: isLast ? MTBreakPenalty.good : MTBreakPenalty.never,
            groupId: groupId,
            parentId: nil,
            originalAtom: atom,
            indexRange: NSMakeRange(0, 1),
            color: nil,
            backgroundColor: nil,
            indivisible: false
        )
    }
}
