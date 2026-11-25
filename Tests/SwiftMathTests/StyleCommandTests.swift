import XCTest
@testable import SwiftMath

/// \scriptstyle, \displaystyle and the like change the size of what follows them
final class StyleCommandTests: XCTestCase {

    private var font: MTFont!

    override func setUp() {
        super.setUp()
        font = MTFontManager.fontManager.latinModernFont(withSize: 20)
    }

    private func line(_ latex: String, style: MTLineStyle = .text) throws -> MTMathListDisplay {
        var error: NSError?
        let list = MTMathListBuilder.build(fromString: latex, error: &error)
        XCTAssertNil(error, latex)
        return try XCTUnwrap(MTTypesetter.createLineForMathList(try XCTUnwrap(list), font: font, style: style), latex)
    }

    /// Font size of the text of a display, looking into nested lists
    static func textSize(_ display: MTDisplay) -> CGFloat? {
        if let line = display as? MTCTLineDisplay, let string = line.attributedString, string.length > 0,
           let value = string.attribute(NSAttributedString.Key(kCTFontAttributeName as String), at: 0, effectiveRange: nil) {
            return CTFontGetSize(value as! CTFont)
        }
        if let list = display as? MTMathListDisplay {
            return list.subDisplays.lazy.compactMap { textSize($0) }.first
        }
        return nil
    }

    func testScriptStyleMakesTheRestSmaller() throws {
        let display = try line("a\\scriptstyle b")
        let parts = display.subDisplays.sorted { $0.position.x < $1.position.x }
        XCTAssertEqual(parts.count, 2)
        XCTAssertEqual(try XCTUnwrap(Self.textSize(parts[0])), 20, accuracy: 0.01)
        XCTAssertEqual(try XCTUnwrap(Self.textSize(parts[1])), 20 * font.mathTable!.scriptScaleDown, accuracy: 0.01)
        XCTAssertLessThan(display.width, try line("ab").width)
    }

    func testDisplayStyleInsideAScriptIsFullSize() throws {
        let display = try line("x^{\\displaystyle y}")
        let script = try XCTUnwrap(display.subDisplays.first { $0 is MTMathListDisplay })
        XCTAssertEqual(try XCTUnwrap(Self.textSize(script)), 20, accuracy: 0.01)
    }

    func testDfracAndTfracPartsUseTheirStyle() throws {
        // \tfrac in display: the parts are in text style, which is still full size; \dfrac likewise
        for latex in ["\\tfrac{1}{2}", "\\dfrac{1}{2}"] {
            let fraction = try XCTUnwrap(try line(latex, style: .display).subDisplays.first as? MTFractionDisplay, latex)
            XCTAssertEqual(try XCTUnwrap(Self.textSize(try XCTUnwrap(fraction.numerator))), 20, accuracy: 0.01, latex)
        }
    }
}
