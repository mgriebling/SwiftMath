//
//  MTDisplayPreRendererTests.swift
//  SwiftMathTests
//
//  Created by Claude Code on 2025-12-16.
//

import XCTest
@testable import SwiftMath

class MTDisplayPreRendererTests: XCTestCase {

    var font: MTFont!
    var renderer: MTDisplayPreRenderer!

    override func setUp() {
        super.setUp()
        font = MTFont(fontWithName: "latinmodern-math", size: 20)
        renderer = MTDisplayPreRenderer(font: font, style: .display, cramped: false)
    }

    override func tearDown() {
        font = nil
        renderer = nil
        super.tearDown()
    }

    // MARK: - Script Rendering Tests

    func testRenderSuperscript() {
        // Create a simple superscript: 2
        let mathList = MTMathList()
        let atom = MTMathAtom(type: .number, value: "2")
        mathList.add(atom)

        let display = renderer.renderScript(mathList, isSuper: true)

        XCTAssertNotNil(display, "Superscript display should not be nil")
        XCTAssertGreaterThan(display!.width, 0, "Superscript should have positive width")
        XCTAssertGreaterThan(display!.ascent, 0, "Superscript should have positive ascent")
    }

    func testRenderSubscript() {
        // Create a simple subscript: i
        let mathList = MTMathList()
        let atom = MTMathAtom(type: .variable, value: "i")
        mathList.add(atom)

        let display = renderer.renderScript(mathList, isSuper: false)

        XCTAssertNotNil(display, "Subscript display should not be nil")
        XCTAssertGreaterThan(display!.width, 0, "Subscript should have positive width")
    }

    func testScriptStyleInDisplayMode() {
        // In display mode, scripts should use script style
        let displayRenderer = MTDisplayPreRenderer(font: font, style: .display, cramped: false)

        let mathList = MTMathList()
        mathList.add(MTMathAtom(type: .variable, value: "x"))

        let display = displayRenderer.renderScript(mathList, isSuper: true)

        XCTAssertNotNil(display)
        // Script style should be smaller than display style
        // We can't directly check the style, but we can verify it renders
    }

    func testScriptStyleInScriptMode() {
        // In script mode, scripts should use scriptOfScript style
        let scriptRenderer = MTDisplayPreRenderer(font: font, style: .script, cramped: false)

        let mathList = MTMathList()
        mathList.add(MTMathAtom(type: .variable, value: "x"))

        let display = scriptRenderer.renderScript(mathList, isSuper: true)

        XCTAssertNotNil(display)
    }

    // MARK: - Math List Rendering Tests

    func testRenderSimpleMathList() {
        let mathList = MTMathList()
        mathList.add(MTMathAtom(type: .variable, value: "x"))
        mathList.add(MTMathAtom(type: .binaryOperator, value: "+"))
        mathList.add(MTMathAtom(type: .variable, value: "y"))

        let display = renderer.renderMathList(mathList)

        XCTAssertNotNil(display, "Display should not be nil")
        XCTAssertGreaterThan(display!.width, 0, "Display should have positive width")
    }

    func testRenderNilMathList() {
        let display = renderer.renderMathList(nil)
        XCTAssertNil(display, "Nil math list should produce nil display")
    }

    func testRenderEmptyMathList() {
        let mathList = MTMathList()
        let display = renderer.renderMathList(mathList)

        // Empty math list may return nil or empty display depending on implementation
        // Just verify it doesn't crash
        if let display = display {
            XCTAssertEqual(display.width, 0, "Empty math list should have zero width")
        }
    }

    func testRenderWithCustomStyle() {
        let mathList = MTMathList()
        mathList.add(MTMathAtom(type: .variable, value: "x"))

        // Render with text style instead of display style
        let display = renderer.renderMathList(mathList, style: .text)

        XCTAssertNotNil(display)
        XCTAssertGreaterThan(display!.width, 0)
    }

    func testRenderWithCustomCramped() {
        let mathList = MTMathList()
        mathList.add(MTMathAtom(type: .variable, value: "x"))

        // Render with cramped mode
        let display = renderer.renderMathList(mathList, cramped: true)

        XCTAssertNotNil(display)
        XCTAssertGreaterThan(display!.width, 0)
    }

    // MARK: - Complex Content Tests

    func testRenderComplexScript() {
        // Create a complex superscript: a+b
        let mathList = MTMathList()
        mathList.add(MTMathAtom(type: .variable, value: "a"))
        mathList.add(MTMathAtom(type: .binaryOperator, value: "+"))
        mathList.add(MTMathAtom(type: .variable, value: "b"))

        let display = renderer.renderScript(mathList, isSuper: true)

        XCTAssertNotNil(display)
        XCTAssertGreaterThan(display!.width, 0)
    }

    func testRenderMultipleAtoms() {
        let mathList = MTMathList()
        mathList.add(MTMathAtom(type: .number, value: "1"))
        mathList.add(MTMathAtom(type: .binaryOperator, value: "+"))
        mathList.add(MTMathAtom(type: .number, value: "2"))
        mathList.add(MTMathAtom(type: .relation, value: "="))
        mathList.add(MTMathAtom(type: .number, value: "3"))

        let display = renderer.renderMathList(mathList)

        XCTAssertNotNil(display)
        XCTAssertGreaterThan(display!.width, 0)
    }

    // MARK: - Font and Style Tests

    func testRendererWithDifferentFonts() {
        let smallFont = MTFont(fontWithName: "latinmodern-math", size: 10)
        let smallRenderer = MTDisplayPreRenderer(font: smallFont, style: .display, cramped: false)

        let mathList = MTMathList()
        mathList.add(MTMathAtom(type: .variable, value: "x"))

        let normalDisplay = renderer.renderMathList(mathList)
        let smallDisplay = smallRenderer.renderMathList(mathList)

        XCTAssertNotNil(normalDisplay)
        XCTAssertNotNil(smallDisplay)

        // Smaller font should produce narrower display
        XCTAssertLessThan(smallDisplay!.width, normalDisplay!.width)
    }

    func testCrampedMode() {
        let normalRenderer = MTDisplayPreRenderer(font: font, style: .display, cramped: false)
        let crampedRenderer = MTDisplayPreRenderer(font: font, style: .display, cramped: true)

        let mathList = MTMathList()
        mathList.add(MTMathAtom(type: .variable, value: "x"))

        let normalDisplay = normalRenderer.renderMathList(mathList)
        let crampedDisplay = crampedRenderer.renderMathList(mathList)

        XCTAssertNotNil(normalDisplay)
        XCTAssertNotNil(crampedDisplay)
        // Both should render successfully
    }
}
