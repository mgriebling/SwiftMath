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
        let brace = try XCTUnwrap(display.nucleus as? MTStretchedGlyphDisplay)
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
        let brace = try XCTUnwrap(display.nucleus as? MTStretchedGlyphDisplay)
        let label = try XCTUnwrap(display.upperLimit)
        XCTAssertGreaterThan(brace.glyphShiftUp, 0, "the brace is above the content")
        XCTAssertGreaterThan(brace.ascent, try XCTUnwrap(brace.inner).ascent)
        XCTAssertGreaterThan(label.position.y - label.descent, display.position.y + brace.ascent - 0.01)
    }

    func testBraceWithoutLabelAndAnyWidth() throws {
        // From narrower than the smallest brace to far wider than the widest one in the font
        for latex in ["\\underbrace{a}", "\\underbrace{a+b}", "\\overbrace{a+b+c+d+e+f+g+h+i+j+k+l+m+n}"] {
            let brace = try XCTUnwrap(try line(latex).subDisplays.first as? MTStretchedGlyphDisplay, latex)
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

/// \overset, \underset, \stackrel and the extensible arrows
final class StackAndArrowTests: XCTestCase {

    private var font: MTFont!
    private var mu: CGFloat { font.mathTable!.muUnit }

    override func setUp() {
        super.setUp()
        font = MTFontManager.manager.latinModernFont(withSize: 20)
    }

    private func build(_ latex: String) throws -> MTMathList {
        var error: NSError?
        let list = MTMathListBuilder.build(fromString: latex, error: &error)
        XCTAssertNil(error, latex)
        return try XCTUnwrap(list, latex)
    }

    private func line(_ latex: String) throws -> MTMathListDisplay {
        try XCTUnwrap(MTTypesetter.createLineForMathList(try build(latex), font: font, style: .text), latex)
    }

    func testStacksParseAndRoundTrip() throws {
        let over = try XCTUnwrap(try build("\\overset{?}{=}").atoms.first as? MTOverLine)
        XCTAssertEqual(over.decoration, .nothing)
        XCTAssertEqual(over.superScript?.atoms.first?.nucleus, "?")
        XCTAssertEqual(over.innerList?.atoms.first?.nucleus, "=")
        XCTAssertEqual(over.atomClass, .relation, "takes the class of a one-atom base")
        XCTAssertEqual(MTMathListBuilder.mathListToString(try build("\\overset{?}{=}")), "\\overset{?}{=}")

        let under = try XCTUnwrap(try build("\\underset{n\\to\\infty}{\\lim}").atoms.first as? MTUnderLine)
        XCTAssertEqual(under.decoration, .nothing)
        XCTAssertEqual(under.atomClass, .largeOperator)

        let stack = try XCTUnwrap(try build("\\stackrel{\\text{def}}{\\Delta}").atoms.first as? MTOverLine)
        XCTAssertEqual(stack.atomClass, .relation, "\\stackrel is always a relation")

        XCTAssertNil((try build("\\overset{a}{xy}").atoms.first as? MTOverLine)?.atomClass, "a longer base is ordinary")
        let copied: MTMathAtom = over.copy()
        XCTAssertEqual((copied as? MTOverLine)?.decoration, .nothing)
    }

    func testArrowsParseAndRoundTrip() throws {
        let arrow = try XCTUnwrap(try build("\\xrightarrow[\\text{below}]{\\text{above}}").atoms.first as? MTOverLine)
        XCTAssertEqual(arrow.decoration, .arrow(.right))
        XCTAssertEqual(arrow.atomClass, .relation)
        XCTAssertNotNil(arrow.superScript)
        XCTAssertNotNil(arrow.subScript)
        for latex in ["\\xrightarrow{x}", "\\xleftarrow[a]{b}", "\\xRightarrow{\\quad}", "\\xleftrightarrow{f}", "\\xmapsto{g}"] {
            XCTAssertEqual(MTMathListBuilder.mathListToString(try build(latex)).replacingOccurrences(of: " ", with: ""),
                           latex.replacingOccurrences(of: " ", with: ""), latex)
        }
    }

    func testOversetIsLaidOutAboveAndSpacedLikeItsBase() throws {
        let display = try line("a\\overset{?}{=}b")
        let parts = display.subDisplays.sorted { $0.position.x < $1.position.x }
        XCTAssertEqual(parts.count, 3)
        let stack = try XCTUnwrap(parts[1] as? MTLargeOpLimitsDisplay)
        XCTAssertNotNil(stack.upperLimit)
        XCTAssertNil(stack.lowerLimit)
        // Thick spaces on both sides, as for a relation
        XCTAssertEqual(parts[1].position.x - (parts[0].position.x + parts[0].width), 5 * mu, accuracy: 0.6)
        XCTAssertEqual(parts[2].position.x - (parts[1].position.x + parts[1].width), 5 * mu, accuracy: 0.6)
    }

    func testArrowIsAsWideAsItsLabels() throws {
        let short = try XCTUnwrap(try line("\\xrightarrow{a}").subDisplays.first as? MTLargeOpLimitsDisplay)
        let long = try XCTUnwrap(try line("\\xrightarrow{\\text{a long label}}").subDisplays.first as? MTLargeOpLimitsDisplay)
        let shortArrow = try XCTUnwrap(short.nucleus as? MTStretchedGlyphDisplay)
        let longArrow = try XCTUnwrap(long.nucleus as? MTStretchedGlyphDisplay)
        XCTAssertEqual(shortArrow.width, 1.75 * 20, accuracy: 0.5, "at least 1.75em")
        XCTAssertGreaterThan(longArrow.width, try XCTUnwrap(long.upperLimit).width + 19, "0.5em on each side of the label")
        XCTAssertGreaterThan(longArrow.width, shortArrow.width)
        // The label is above the arrow
        let label = try XCTUnwrap(long.upperLimit)
        XCTAssertGreaterThan(label.position.y - label.descent, long.position.y + longArrow.ascent - 0.01)
    }

    func testArrowWithBothLabelsAndAllKinds() throws {
        let both = try XCTUnwrap(try line("A\\xrightarrow[\\text{下}]{\\text{加热}}B").subDisplays.first { $0 is MTLargeOpLimitsDisplay } as? MTLargeOpLimitsDisplay)
        XCTAssertNotNil(both.upperLimit)
        XCTAssertNotNil(both.lowerLimit)
        for arrow in MTExtensibleArrow.allCases {
            let display = try line("\\\(arrow.rawValue){\\text{label}}")
            let stack = try XCTUnwrap(display.subDisplays.first as? MTLargeOpLimitsDisplay, arrow.rawValue)
            XCTAssertNotEqual((stack.nucleus as? MTStretchedGlyphDisplay)?.glyph ?? 0, 0, arrow.rawValue)
        }
    }
}
