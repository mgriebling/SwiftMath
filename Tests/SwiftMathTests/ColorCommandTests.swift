import XCTest
@testable import SwiftMath

/// \color, \textcolor and \colorbox lay out their argument (the tokenized layout used to drop it)
final class ColorCommandTests: XCTestCase {

    private var font: MTFont!
    private let red = MTColor(fromHexString: "#FF0000")
    private let blue = MTColor(fromHexString: "#0000FF")

    override func setUp() {
        super.setUp()
        font = MTFontManager.fontManager.latinModernFont(withSize: 20)
    }

    private func line(_ latex: String, maxWidth: CGFloat = 0) throws -> MTMathListDisplay {
        var error: NSError?
        let list = MTMathListBuilder.build(fromString: latex, error: &error)
        XCTAssertNil(error, latex)
        let display = try XCTUnwrap(MTTypesetter.createLineForMathList(try XCTUnwrap(list), font: font, style: .text, maxWidth: maxWidth), latex)
        display.textColor = MTColor.black
        return display
    }

    /// Text of a line display, for finding pieces
    private func text(_ display: MTDisplay) -> String {
        (display as? MTCTLineDisplay)?.attributedString?.string ?? ""
    }

    func testColoredArgumentIsLaidOut() throws {
        let plain = try line("x+1")
        for latex in ["\\color{red}{x+1}", "\\textcolor{red}{x+1}", "\\colorbox{yellow}{x+1}"] {
            XCTAssertEqual(try line(latex).width, plain.width, accuracy: 0.01, latex)
        }
    }

    func testTextColorAppliesToTheArgumentOnly() throws {
        for latex in ["a+\\textcolor{#FF0000}{b}", "a+\\color{#FF0000}{b}"] {
            let display = try line(latex)
            let pieces = display.subDisplays.sorted { $0.position.x < $1.position.x }
            XCTAssertEqual(pieces.count, 3, latex)
            XCTAssertEqual(pieces[0].textColor, MTColor.black, latex)
            XCTAssertEqual(pieces[1].textColor, MTColor.black, latex)
            XCTAssertEqual(pieces[2].localTextColor, red, latex)
            XCTAssertEqual(pieces[2].textColor, red, latex)
        }
    }

    func testColoredArgumentIsSpacedLikeItsAtoms() throws {
        // The spaces next to the colored part come from its first and last atom
        XCTAssertEqual(try line("x=\\color{red}{y}").width, try line("x=y").width, accuracy: 0.01)
        XCTAssertEqual(try line("\\color{red}{x}=y").width, try line("x=y").width, accuracy: 0.01)
        XCTAssertEqual(try line("a+\\textcolor{red}{\\sqrt{2}}").width, try line("a+\\sqrt{2}").width, accuracy: 0.01)
    }

    func testNestedColorKeepsItsOwnColor() throws {
        let display = try line("\\color{#FF0000}{a+\\color{#0000FF}{b}+c}")
        let colors = display.subDisplays.sorted { $0.position.x < $1.position.x }.map(\.textColor)
        XCTAssertEqual(colors, [red, red, blue, red, red])
    }

    func testColoredArgumentBreaksAcrossLines() throws {
        let display = try line("a+\\color{blue}{b+c+d+e+f+g+h+i+j+k+l}+m", maxWidth: 100)
        let rows = Set(display.subDisplays.map { Int($0.position.y.rounded()) })
        XCTAssertGreaterThan(rows.count, 1, "should wrap inside the colored part")
        for piece in display.subDisplays {
            XCTAssertLessThanOrEqual(piece.position.x + piece.width, 100 * 1.3)
        }
    }

    func testColorboxHasABackgroundAndDoesNotBreak() throws {
        let display = try line("a\\colorbox{#FFFF00}{b}c")
        XCTAssertEqual(display.subDisplays.count, 3)
        let box = try XCTUnwrap(display.subDisplays.first { $0 is MTMathListDisplay })
        XCTAssertEqual(box.localBackgroundColor, MTColor(fromHexString: "#FFFF00"))
        XCTAssertNil(box.localTextColor)
    }
}
