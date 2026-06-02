import XCTest
@testable import SwiftMath

//
//  MTExtraCommandsTests.swift
//
//  Tests for the extra LaTeX commands added in the SuperGooey fork:
//  \tfrac, \dfrac, \iint, \iiint, \underbrace, \overbrace.
//

final class MTExtraCommandsTests: XCTestCase {

    var font: MTFont!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.font = MTFontManager.fontManager.defaultFont
    }

    /// Parse a LaTeX string, asserting it parses without error.
    private func parse(_ latex: String, file: StaticString = #filePath, line: UInt = #line) -> MTMathList? {
        var error: NSError?
        let list = MTMathListBuilder.build(fromString: latex, error: &error)
        XCTAssertNil(error, "Unexpected parse error for \(latex): \(error?.localizedDescription ?? "")", file: file, line: line)
        XCTAssertNotNil(list, "Failed to parse \(latex)", file: file, line: line)
        return list
    }

    /// Assert a LaTeX string parses and typesets to a non-nil, non-empty display.
    private func assertRenders(_ latex: String, file: StaticString = #filePath, line: UInt = #line) {
        guard let list = parse(latex, file: file, line: line) else { return }
        let display = MTTypesetter.createLineForMathList(list, font: self.font, style: .display)
        XCTAssertNotNil(display, "No display produced for \(latex)", file: file, line: line)
        XCTAssertFalse(display!.subDisplays.isEmpty, "Empty display for \(latex)", file: file, line: line)
        XCTAssertGreaterThan(display!.width, 0, "Zero-width display for \(latex)", file: file, line: line)
    }

    // MARK: - \tfrac / \dfrac

    func testTfracParse() throws {
        let list = parse("\\tfrac12")
        XCTAssertEqual(list?.atoms.count, 1)
        XCTAssertEqual(list?.atoms.first?.type, .fraction)
        let frac = list?.atoms.first as? MTFraction
        XCTAssertEqual(frac?.forcedStyle, .text)
        XCTAssertTrue(frac?.hasRule ?? false)
    }

    func testDfracParse() throws {
        let list = parse("\\dfrac{a}{b}")
        XCTAssertEqual(list?.atoms.count, 1)
        let frac = list?.atoms.first as? MTFraction
        XCTAssertEqual(frac?.forcedStyle, .display)
    }

    func testTfracRoundTrip() throws {
        let list = parse("\\tfrac{1}{2}")
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\tfrac{1}{2}")
        let dlist = parse("\\dfrac{1}{2}")
        XCTAssertEqual(MTMathListBuilder.mathListToString(dlist), "\\dfrac{1}{2}")
    }

    func testTfracRenders() throws {
        assertRenders("\\tfrac12")
        assertRenders("\\dfrac1\\beta")
        assertRenders("x + \\tfrac{1}{2} \\dfrac{a+b}{c}")
    }

    // MARK: - \iint / \iiint

    func testIintParse() throws {
        let list = parse("\\iint")
        XCTAssertEqual(list?.atoms.count, 1)
        XCTAssertEqual(list?.atoms.first?.type, .largeOperator)
        XCTAssertEqual(list?.atoms.first?.nucleus, "\u{222C}")
    }

    func testIiintParse() throws {
        let list = parse("\\iiint")
        XCTAssertEqual(list?.atoms.first?.nucleus, "\u{222D}")
    }

    func testIintRenders() throws {
        assertRenders("\\iint")
        assertRenders("\\iiint")
        assertRenders("\\iint_{\\Theta^2} f \\, dx")
        assertRenders("\\iiint_V \\rho \\, dV")
    }

    // MARK: - \underbrace / \overbrace

    func testUnderbraceParse() throws {
        let list = parse("\\underbrace{x+y}")
        XCTAssertEqual(list?.atoms.count, 1)
        XCTAssertEqual(list?.atoms.first?.type, .underline)
        let under = list?.atoms.first as? MTUnderLine
        XCTAssertEqual(under?.underStyle, .brace)
        XCTAssertNotNil(under?.innerList)
    }

    func testOverbraceParse() throws {
        let list = parse("\\overbrace{x+y}")
        XCTAssertEqual(list?.atoms.first?.type, .overline)
        let over = list?.atoms.first as? MTOverLine
        XCTAssertEqual(over?.overStyle, .brace)
    }

    func testUnderbraceWithLabelParse() throws {
        let list = parse("\\underbrace{a+b}_{\\text{sum}}")
        XCTAssertEqual(list?.atoms.count, 1)
        let under = list?.atoms.first as? MTUnderLine
        XCTAssertEqual(under?.underStyle, .brace)
        // The label is attached as a subscript on the underbrace atom.
        XCTAssertNotNil(under?.subScript)
    }

    func testOverbraceWithLabelParse() throws {
        let list = parse("\\overbrace{a+b}^{n}")
        let over = list?.atoms.first as? MTOverLine
        XCTAssertEqual(over?.overStyle, .brace)
        XCTAssertNotNil(over?.superScript)
    }

    func testBraceRoundTrip() throws {
        XCTAssertEqual(MTMathListBuilder.mathListToString(parse("\\underbrace{x}")), "\\underbrace{x}")
        XCTAssertEqual(MTMathListBuilder.mathListToString(parse("\\overbrace{x}")), "\\overbrace{x}")
        // Ensure plain underline/overline still round-trip as lines.
        XCTAssertEqual(MTMathListBuilder.mathListToString(parse("\\underline{x}")), "\\underline{x}")
        XCTAssertEqual(MTMathListBuilder.mathListToString(parse("\\overline{x}")), "\\overline{x}")
    }

    func testUnderbraceRenders() throws {
        assertRenders("\\underbrace{x+y}")
        assertRenders("\\underbrace{x+y}_{\\text{label}}")
        assertRenders("\\overbrace{x+y}")
        assertRenders("\\overbrace{x+y}^{n}")
    }

    // MARK: - Full target block

    func testFullTargetBlockRenders() throws {
        let block = "\\mathcal{F}[\\mu] = \\underbrace{\\int_\\Theta V(\\theta)\\,d\\mu(\\theta)}_{\\text{external potential}} + \\tfrac12 \\iint_{\\Theta^2} W(\\theta,\\theta')\\,d\\mu(\\theta)\\,d\\mu(\\theta') + \\tfrac1\\beta \\int_\\Theta \\mu(\\theta)\\log\\mu(\\theta)\\,d\\theta"
        assertRenders(block)
    }
}
