//
//  MTDisplayGeneratorTests.swift
//  SwiftMathTests
//
//  Created by Claude Code on 2025-12-16.
//

import XCTest
@testable import SwiftMath

class MTDisplayGeneratorTests: XCTestCase {

    var font: MTFont!
    var generator: MTDisplayGenerator!

    override func setUp() {
        super.setUp()
        font = MTFont(fontWithName: "latinmodern-math", size: 20)
        generator = MTDisplayGenerator(font: font, style: .display)
    }

    override func tearDown() {
        font = nil
        generator = nil
        super.tearDown()
    }

    // MARK: - Basic Generation Tests

    func testGenerateFromEmptyLines() {
        let displays = generator.generateDisplays(from: [], startPosition: .zero)
        XCTAssertEqual(displays.count, 0)
    }

    func testGenerateSingleLine() {
        let element = createTextElement("x", width: 10)
        let lines = [[element]]

        let displays = generator.generateDisplays(from: lines, startPosition: .zero)

        XCTAssertGreaterThan(displays.count, 0)
    }

    func testGenerateMultipleLines() {
        let line1 = [createTextElement("x", width: 10), createTextElement("+", width: 10)]
        let line2 = [createTextElement("y", width: 10)]
        let lines = [line1, line2]

        let displays = generator.generateDisplays(from: lines, startPosition: .zero)

        XCTAssertGreaterThan(displays.count, 0)
    }

    func testGenerateWithPrerenderedDisplay() {
        let preDisplay = MTDisplay()
        preDisplay.width = 20
        preDisplay.ascent = 10
        preDisplay.descent = 5

        let element = createDisplayElement(preDisplay)
        let lines = [[element]]

        let displays = generator.generateDisplays(from: lines, startPosition: .zero)

        XCTAssertGreaterThan(displays.count, 0)
    }

    func testVerticalSpacingBetweenLines() {
        let line1 = [createTextElement("a", width: 10)]
        let line2 = [createTextElement("b", width: 10)]
        let lines = [line1, line2]

        let displays = generator.generateDisplays(from: lines, startPosition: CGPoint(x: 0, y: 0))

        // With multiple lines, y positions should differ
        if displays.count >= 2 {
            let y1 = displays[0].position.y
            let y2 = displays[1].position.y
            XCTAssertNotEqual(y1, y2, "Lines should have different y positions")
        }
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

    private func createDisplayElement(_ display: MTDisplay) -> MTBreakableElement {
        let atom = MTMathAtom(type: .fraction, value: "")
        return MTBreakableElement(
            content: .display(display),
            width: display.width,
            height: display.ascent + display.descent,
            ascent: display.ascent,
            descent: display.descent,
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
            indivisible: true
        )
    }
}
