import XCTest
@testable import SwiftMath

/// MTLayoutConventions.current = .tex: fractions and limits in text style as in TeX and KaTeX
final class TeXConventionsTests: XCTestCase {

    private var font: MTFont!

    override func setUp() {
        super.setUp()
        font = MTFontManager.fontManager.latinModernFont(withSize: 20)
        MTLayoutConventions.current = .tex
    }

    override func tearDown() {
        MTLayoutConventions.current = .readable
        super.tearDown()
    }

    private func line(_ latex: String, style: MTLineStyle = .text) throws -> MTMathListDisplay {
        var error: NSError?
        let list = MTMathListBuilder.build(fromString: latex, error: &error)
        XCTAssertNil(error, latex)
        return try XCTUnwrap(MTTypesetter.createLineForMathList(try XCTUnwrap(list), font: font, style: style), latex)
    }

    private func fraction(in display: MTDisplay) -> MTFractionDisplay? {
        if let fraction = display as? MTFractionDisplay { return fraction }
        return (display as? MTMathListDisplay)?.subDisplays.lazy.compactMap { self.fraction(in: $0) }.first
    }

    func testInlineFractionPartsAreScriptSize() throws {
        let display = try line("\\frac{1}{2}")
        let fraction = try XCTUnwrap(fraction(in: display))
        let scriptSize = 20 * font.mathTable!.scriptScaleDown
        XCTAssertEqual(try XCTUnwrap(StyleCommandTests.textSize(try XCTUnwrap(fraction.numerator))), scriptSize, accuracy: 0.01)
        XCTAssertEqual(try XCTUnwrap(StyleCommandTests.textSize(try XCTUnwrap(fraction.denominator))), scriptSize, accuracy: 0.01)

        // In display style the parts are in text style, at full size
        let displayFraction = try XCTUnwrap(self.fraction(in: try line("\\frac{1}{2}", style: .display)))
        XCTAssertEqual(try XCTUnwrap(StyleCommandTests.textSize(try XCTUnwrap(displayFraction.numerator))), 20, accuracy: 0.01)
    }

    func testFractionHasTheNullDelimiterSpaceOnEachSide() throws {
        let display = try line("\\frac{1}{2}")
        let fraction = try XCTUnwrap(fraction(in: display))
        XCTAssertEqual(display.width, fraction.width + 2 * 0.12 * 20, accuracy: 0.01)
        XCTAssertEqual(fraction.position.x, 0.12 * 20, accuracy: 0.01)
    }

    func testDfracIsFullSizeInline() throws {
        let fraction = try XCTUnwrap(fraction(in: try line("\\dfrac{1}{2}")))
        XCTAssertEqual(try XCTUnwrap(StyleCommandTests.textSize(try XCTUnwrap(fraction.numerator))), 20, accuracy: 0.01)
    }

    func testInlineLimitsGoToTheSide() throws {
        let inline = try line("\\sum_{i=1}^n i")
        XCTAssertFalse(inline.subDisplays.contains { $0 is MTLargeOpLimitsDisplay })
        let display = try line("\\sum_{i=1}^n i", style: .display)
        XCTAssertTrue(display.subDisplays.contains { $0 is MTLargeOpLimitsDisplay })
    }

    func testReadableConventionsAreUnchanged() throws {
        MTLayoutConventions.current = .readable
        let fraction = try XCTUnwrap(fraction(in: try line("\\frac{1}{2}")))
        XCTAssertEqual(try XCTUnwrap(StyleCommandTests.textSize(try XCTUnwrap(fraction.numerator))), 20, accuracy: 0.01)
        XCTAssertTrue(try line("\\sum_{i=1}^n i").subDisplays.contains { $0 is MTLargeOpLimitsDisplay })
    }
}
