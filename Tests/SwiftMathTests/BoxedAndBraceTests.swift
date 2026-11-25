import XCTest
@testable import SwiftMath

/// \boxed, \underbrace and \overbrace
final class BoxedAndBraceTests: XCTestCase {

    private var font: MTFont!

    override func setUp() {
        super.setUp()
        font = MTFontManager.fontManager.latinModernFont(withSize: 20)
    }

    private func build(_ latex: String) throws -> MTMathList {
        var error: NSError?
        let list = MTMathListBuilder.build(fromString: latex, error: &error)
        XCTAssertNil(error, latex)
        return try XCTUnwrap(list, latex)
    }

    private func line(_ latex: String, style: MTLineStyle = .display) throws -> MTMathListDisplay {
        try XCTUnwrap(MTTypesetter.createLineForMathList(try build(latex), font: font, style: style), latex)
    }

    // MARK: - \boxed

    func testBoxedParsesAndRoundTrips() throws {
        let list = try build("\\boxed{x=1}")
        let boxed = try XCTUnwrap(list.atoms.first as? MTBoxed)
        XCTAssertEqual(boxed.type, .boxed)
        XCTAssertEqual(boxed.innerList?.atoms.count, 3)
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\boxed{x=1}")
        XCTAssertEqual(MTMathListBuilder.mathListToString(list.finalized), "\\boxed{x=1}")
        let copied: MTMathAtom = list.atoms[0].copy()
        XCTAssertTrue(copied is MTBoxed)
    }

    func testBoxedFramesItsContent() throws {
        let box = try XCTUnwrap(try line("\\boxed{x+1}").subDisplays.first as? MTBoxDisplay)
        let inner = try XCTUnwrap(box.inner)
        let margin = box.padding + box.ruleThickness
        XCTAssertEqual(box.padding, 0.3 * font.fontSize, accuracy: 0.01)
        XCTAssertEqual(box.ruleThickness, font.mathTable!.fractionRuleThickness, accuracy: 0.01)
        XCTAssertEqual(box.width, inner.width + 2 * margin, accuracy: 0.01)
        XCTAssertEqual(box.ascent, inner.ascent + margin, accuracy: 0.01)
        XCTAssertEqual(box.descent, inner.descent + margin, accuracy: 0.01)
        XCTAssertEqual(inner.position.x, box.position.x + margin, accuracy: 0.01)
    }

    func testBoxedContentIsInDisplayStyle() throws {
        // Like \fbox{$\displaystyle ...$}: a sum in an inline \boxed still has its limits above and below
        let inline = try line("\\boxed{\\sum_{k=1}^n k}", style: .text)
        let box = try XCTUnwrap(inline.subDisplays.first as? MTBoxDisplay)
        XCTAssertTrue(box.inner?.subDisplays.contains { $0 is MTLargeOpLimitsDisplay } ?? false)
    }

    func testBoxedTakesPartInSpacingAsAnOrdinaryAtom() throws {
        let parts = try line("1+\\boxed{2}", style: .text).subDisplays.sorted { $0.position.x < $1.position.x }
        XCTAssertEqual(parts.count, 3)
        let gap = parts[2].position.x - (parts[1].position.x + parts[1].width)
        XCTAssertEqual(gap, 4 * font.mathTable!.muUnit, accuracy: 0.01)
    }

    // MARK: - \underbrace, \overbrace

    func testBracesParseAndRoundTrip() throws {
        let under = try build("\\underbrace{a+b}_{n}")
        let underAtom = try XCTUnwrap(under.atoms.first as? MTUnderLine)
        XCTAssertTrue(underAtom.isBrace)
        XCTAssertEqual(underAtom.subScript?.atoms.first?.nucleus, "n")
        XCTAssertEqual(MTMathListBuilder.mathListToString(under), "\\underbrace{a+b}_{n}")
        let underCopy: MTMathAtom = underAtom.copy()
        XCTAssertTrue((underCopy as? MTUnderLine)?.isBrace ?? false)
        XCTAssertTrue((under.finalized.atoms.first as? MTUnderLine)?.isBrace ?? false)

        let over = try build("\\overbrace{a+b}^{n}")
        let overAtom = try XCTUnwrap(over.atoms.first as? MTOverLine)
        XCTAssertTrue(overAtom.isBrace)
        XCTAssertEqual(MTMathListBuilder.mathListToString(over), "\\overbrace{a+b}^{n}")
        let overCopy: MTMathAtom = overAtom.copy()
        XCTAssertTrue((overCopy as? MTOverLine)?.isBrace ?? false)
        XCTAssertTrue((over.finalized.atoms.first as? MTOverLine)?.isBrace ?? false)

        // \underline and \overline are unchanged
        XCTAssertFalse(try XCTUnwrap(try build("\\underline{a}").atoms.first as? MTUnderLine).isBrace)
        XCTAssertEqual(MTMathListBuilder.mathListToString(try build("\\overline{a}")), "\\overline{a}")
    }

    func testUnderbraceLabelIsCenteredBelowTheBrace() throws {
        let display = try XCTUnwrap(try line("\\underbrace{a+b+c+d+e+f}_{6}").subDisplays.first as? MTLargeOpLimitsDisplay)
        let brace = try XCTUnwrap(display.nucleus as? MTBraceDisplay)
        let label = try XCTUnwrap(display.lowerLimit)
        XCTAssertNil(display.upperLimit)
        XCTAssertEqual(brace.width, try XCTUnwrap(brace.inner).width, accuracy: 0.01, "the brace is as wide as its content")
        XCTAssertLessThan(brace.glyphShiftUp, 0, "the brace is below the baseline")
        XCTAssertGreaterThan(brace.descent, try XCTUnwrap(brace.inner).descent)
        // Centered, and below the brace
        XCTAssertEqual(label.position.x + label.width / 2, display.position.x + display.width / 2, accuracy: 0.01)
        XCTAssertLessThan(label.position.y + label.ascent, display.position.y - brace.descent + 0.01)
    }

    func testOverbraceLabelIsAboveTheBrace() throws {
        let display = try XCTUnwrap(try line("\\overbrace{a+b+c+d+e+f}^{6}").subDisplays.first as? MTLargeOpLimitsDisplay)
        let brace = try XCTUnwrap(display.nucleus as? MTBraceDisplay)
        let label = try XCTUnwrap(display.upperLimit)
        XCTAssertGreaterThan(brace.glyphShiftUp, 0, "the brace is above the content")
        XCTAssertGreaterThan(brace.ascent, try XCTUnwrap(brace.inner).ascent)
        XCTAssertGreaterThan(label.position.y - label.descent, display.position.y + brace.ascent - 0.01)
    }

    func testBraceWithoutLabelAndAnyWidth() throws {
        // From narrower than the smallest brace to far wider than the widest one in the font
        for latex in ["\\underbrace{a}", "\\underbrace{a+b}", "\\overbrace{a+b+c+d+e+f+g+h+i+j+k+l+m+n}"] {
            let brace = try XCTUnwrap(try line(latex).subDisplays.first as? MTBraceDisplay, latex)
            XCTAssertEqual(brace.width, try XCTUnwrap(brace.inner).width, accuracy: 0.01, latex)
            XCTAssertNotEqual(brace.glyph, 0, latex)
        }
    }

    func testBraceInsideAFormulaKeepsTheRestOfTheLine() throws {
        // The label must not be set as an ordinary subscript to the right of the brace
        let display = try line("x=\\underbrace{a+b}_{2}+c", style: .text)
        XCTAssertEqual(display.subDisplays.filter { $0 is MTLargeOpLimitsDisplay }.count, 1)
        let width = display.width
        let withoutLabel = try line("x=\\underbrace{a+b}+c", style: .text).width
        XCTAssertEqual(width, withoutLabel, accuracy: 0.01, "a narrow label adds no width")
    }

    func testBoxedAndBracesRenderToAnImage() throws {
        for latex in ["\\boxed{E=mc^2}", "\\underbrace{(1+2+3)}_{\\text{六}}\\times 2", "\\overbrace{x+\\cdots+x}^{k}"] {
            let (error, image) = MTMathImage(latex: latex, fontSize: 20, textColor: .black, labelMode: .display).asImage()
            XCTAssertNil(error, latex)
            XCTAssertNotNil(image, latex)
        }
    }
}
