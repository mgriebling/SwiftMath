//
//  MTBreakableElementTests.swift
//  SwiftMathTests
//
//  Created by Claude Code on 2025-12-16.
//

import XCTest
@testable import SwiftMath

class MTBreakableElementTests: XCTestCase {

    // MARK: - Data Structure Tests

    func testBreakableElementCreation() {
        // Create a sample atom
        let atom = MTMathAtom(type: .ordinary, value: "x")

        // Create a breakable element
        let element = MTBreakableElement(
            content: .text("x"),
            width: 10.5,
            height: 12.0,
            ascent: 8.0,
            descent: 4.0,
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

        // Verify properties
        XCTAssertEqual(element.width, 10.5)
        XCTAssertEqual(element.height, 12.0)
        XCTAssertEqual(element.ascent, 8.0)
        XCTAssertEqual(element.descent, 4.0)
        XCTAssertTrue(element.isBreakBefore)
        XCTAssertTrue(element.isBreakAfter)
        XCTAssertEqual(element.penaltyBefore, MTBreakPenalty.good)
        XCTAssertEqual(element.penaltyAfter, MTBreakPenalty.good)
        XCTAssertNil(element.groupId)
        XCTAssertNil(element.parentId)
        XCTAssertFalse(element.indivisible)
    }

    func testElementContentText() {
        let content = MTElementContent.text("hello")

        if case .text(let text) = content {
            XCTAssertEqual(text, "hello")
        } else {
            XCTFail("Expected text content")
        }
    }

    func testElementContentOperator() {
        let content = MTElementContent.operator("+", type: .binaryOperator)

        if case .operator(let op, let type) = content {
            XCTAssertEqual(op, "+")
            XCTAssertEqual(type, .binaryOperator)
        } else {
            XCTFail("Expected operator content")
        }
    }

    func testElementContentSpace() {
        let content = MTElementContent.space(5.0)

        if case .space(let width) = content {
            XCTAssertEqual(width, 5.0)
        } else {
            XCTFail("Expected space content")
        }
    }

    func testElementContentDisplay() {
        // Create a simple display
        let display = MTDisplay()
        display.width = 20.0
        display.ascent = 10.0
        display.descent = 5.0

        let content = MTElementContent.display(display)

        if case .display(let disp) = content {
            XCTAssertEqual(disp.width, 20.0)
            XCTAssertEqual(disp.ascent, 10.0)
            XCTAssertEqual(disp.descent, 5.0)
        } else {
            XCTFail("Expected display content")
        }
    }

    func testElementContentScript() {
        let display = MTDisplay()
        display.width = 8.0

        let content = MTElementContent.script(display, isSuper: true)

        if case .script(let disp, let isSuper) = content {
            XCTAssertEqual(disp.width, 8.0)
            XCTAssertTrue(isSuper)
        } else {
            XCTFail("Expected script content")
        }
    }

    func testGroupedElements() {
        let atom1 = MTMathAtom(type: .variable, value: "x")
        let atom2 = MTMathAtom(type: .ordinary, value: "2")

        let groupId = UUID()

        let element1 = MTBreakableElement(
            content: .text("x"),
            width: 10.0,
            height: 12.0,
            ascent: 8.0,
            descent: 4.0,
            isBreakBefore: true,
            isBreakAfter: false,  // Cannot break after - grouped with script
            penaltyBefore: MTBreakPenalty.good,
            penaltyAfter: MTBreakPenalty.never,
            groupId: groupId,
            parentId: nil,
            originalAtom: atom1,
            indexRange: NSMakeRange(0, 1),
            color: nil,
            backgroundColor: nil,
            indivisible: false
        )

        let element2 = MTBreakableElement(
            content: .text("2"),
            width: 6.0,
            height: 8.0,
            ascent: 6.0,
            descent: 2.0,
            isBreakBefore: false,  // Cannot break before - grouped with base
            isBreakAfter: true,
            penaltyBefore: MTBreakPenalty.never,
            penaltyAfter: MTBreakPenalty.good,
            groupId: groupId,
            parentId: nil,
            originalAtom: atom2,
            indexRange: NSMakeRange(1, 1),
            color: nil,
            backgroundColor: nil,
            indivisible: false
        )

        // Verify grouping
        XCTAssertNotNil(element1.groupId)
        XCTAssertEqual(element1.groupId, element2.groupId)
        XCTAssertFalse(element1.isBreakAfter)
        XCTAssertFalse(element2.isBreakBefore)
    }

    func testIndivisibleElement() {
        let atom = MTMathAtom(type: .fraction, value: "")
        let display = MTDisplay()

        let element = MTBreakableElement(
            content: .display(display),
            width: 50.0,
            height: 40.0,
            ascent: 25.0,
            descent: 15.0,
            isBreakBefore: true,
            isBreakAfter: true,
            penaltyBefore: MTBreakPenalty.moderate,
            penaltyAfter: MTBreakPenalty.moderate,
            groupId: nil,
            parentId: nil,
            originalAtom: atom,
            indexRange: NSMakeRange(0, 1),
            color: nil,
            backgroundColor: nil,
            indivisible: true  // Fractions are indivisible
        )

        XCTAssertTrue(element.indivisible)
    }

    func testPenaltyConstants() {
        XCTAssertEqual(MTBreakPenalty.best, 0)
        XCTAssertEqual(MTBreakPenalty.good, 10)
        XCTAssertEqual(MTBreakPenalty.moderate, 15)
        XCTAssertEqual(MTBreakPenalty.acceptable, 50)
        XCTAssertEqual(MTBreakPenalty.bad, 100)
        XCTAssertEqual(MTBreakPenalty.never, 150)
    }

    func testElementWithColor() {
        let atom = MTMathAtom(type: .ordinary, value: "x")
        let redColor = MTColor.red

        let element = MTBreakableElement(
            content: .text("x"),
            width: 10.0,
            height: 12.0,
            ascent: 8.0,
            descent: 4.0,
            isBreakBefore: true,
            isBreakAfter: true,
            penaltyBefore: MTBreakPenalty.good,
            penaltyAfter: MTBreakPenalty.good,
            groupId: nil,
            parentId: nil,
            originalAtom: atom,
            indexRange: NSMakeRange(0, 1),
            color: redColor,
            backgroundColor: nil,
            indivisible: false
        )

        XCTAssertNotNil(element.color)
        XCTAssertEqual(element.color, redColor)
    }
}
