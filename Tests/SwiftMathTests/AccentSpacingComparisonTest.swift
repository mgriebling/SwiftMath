import XCTest
@testable import SwiftMath

final class AccentSpacingComparisonTest: XCTestCase {

    var font: MTFont!

    override func setUp() {
        super.setUp()
        font = MTFontManager().termesFont(withSize: 20)
    }

    func testCompareSpacing() throws {
        // Test with same content for comparison
        let content = "ABC"

        let widehatLatex = "\\widehat{\(content)}"
        let overrightarrowLatex = "\\overrightarrow{\(content)}"

        let widehatMathList = MTMathListBuilder.build(fromString: widehatLatex)
        let arrowMathList = MTMathListBuilder.build(fromString: overrightarrowLatex)

        let widehatDisplay = MTTypesetter.createLineForMathList(widehatMathList, font: font, style: .display)
        let arrowDisplay = MTTypesetter.createLineForMathList(arrowMathList, font: font, style: .display)

        print("\n=== Spacing Comparison for '\(content)' ===\n")

        guard let widehatAccentDisp = widehatDisplay?.subDisplays.first as? MTAccentDisplay,
              let widehatAccentee = widehatAccentDisp.accentee,
              let widehatAccent = widehatAccentDisp.accent else {
            XCTFail("Could not extract widehat display")
            return
        }

        print("\\widehat{\(content)}:")
        print("  Accentee ascent: \(widehatAccentee.ascent)")
        print("  Accent glyph ascent: \(widehatAccent.ascent)")
        print("  Accent glyph descent: \(widehatAccent.descent)")
        print("  Accent position.y: \(widehatAccent.position.y)")
        print("  Display ascent: \(widehatAccentDisp.ascent)")
        print("  Display descent: \(widehatAccentDisp.descent)")
        print("  Total height: \(widehatAccentDisp.ascent + widehatAccentDisp.descent)")

        // Calculate the baseline gap
        let widehatBaselineGap = widehatAccent.position.y - widehatAccentee.ascent
        print("  Baseline gap (accent.y - accentee.ascent): \(widehatBaselineGap)")

        // Calculate the visual bounding box gap
        // For glyphs with internal whitespace (minY > 0), we need to account for it
        // The visual bottom of the glyph is at position.y + minY (not position.y - descent)
        // We'll extract minY directly from the glyph's bounding rect
        let widehatGlyphMinY: CGFloat
        if let widehatGlyphDisp = widehatAccent as? MTGlyphDisplay,
           let widehatGlyphOpt = widehatGlyphDisp.glyph {
            var widehatGlyph = widehatGlyphOpt
            var widehatBoundingRect = CGRect.zero
            CTFontGetBoundingRectsForGlyphs(font.ctFont, .horizontal, &widehatGlyph, &widehatBoundingRect, 1)
            widehatGlyphMinY = widehatBoundingRect.minY
        } else {
            widehatGlyphMinY = 0
        }

        let widehatAccentBottomEdge = widehatAccent.position.y + max(0, widehatGlyphMinY)
        let widehatContentTopEdge = widehatAccentee.ascent
        let widehatVisualGap = widehatAccentBottomEdge - widehatContentTopEdge
        print("  Visual gap (bounding box): \(widehatVisualGap)")
        print("    Content top edge (ascent): \(widehatContentTopEdge)")
        print("    Accent visual bottom edge (y + minY): \(widehatAccentBottomEdge)")
        print("    Accent glyph minY: \(widehatGlyphMinY)")
        print()

        guard let arrowAccentDisp = arrowDisplay?.subDisplays.first as? MTAccentDisplay,
              let arrowAccentee = arrowAccentDisp.accentee,
              let arrowAccent = arrowAccentDisp.accent else {
            XCTFail("Could not extract arrow display")
            return
        }

        print("\\overrightarrow{\(content)}:")
        print("  Accentee ascent: \(arrowAccentee.ascent)")
        print("  Accent glyph ascent: \(arrowAccent.ascent)")
        print("  Accent glyph descent: \(arrowAccent.descent)")
        print("  Accent position.y: \(arrowAccent.position.y)")
        print("  Display ascent: \(arrowAccentDisp.ascent)")
        print("  Display descent: \(arrowAccentDisp.descent)")
        print("  Total height: \(arrowAccentDisp.ascent + arrowAccentDisp.descent)")

        // Calculate the baseline gap
        let arrowBaselineGap = arrowAccent.position.y - arrowAccentee.ascent
        print("  Baseline gap (accent.y - accentee.ascent): \(arrowBaselineGap)")

        // Calculate the visual bounding box gap
        // Extract minY for the arrow glyph too
        let arrowGlyphMinY: CGFloat
        if let arrowGlyphDisp = arrowAccent as? MTGlyphDisplay,
           let arrowGlyphOpt = arrowGlyphDisp.glyph {
            var arrowGlyph = arrowGlyphOpt
            var arrowBoundingRect = CGRect.zero
            CTFontGetBoundingRectsForGlyphs(font.ctFont, .horizontal, &arrowGlyph, &arrowBoundingRect, 1)
            arrowGlyphMinY = arrowBoundingRect.minY
        } else {
            arrowGlyphMinY = 0
        }

        let arrowAccentBottomEdge = arrowAccent.position.y + max(0, arrowGlyphMinY)
        let arrowContentTopEdge = arrowAccentee.ascent
        let arrowVisualGap = arrowAccentBottomEdge - arrowContentTopEdge
        print("  Visual gap (bounding box): \(arrowVisualGap)")
        print("    Content top edge (ascent): \(arrowContentTopEdge)")
        print("    Accent visual bottom edge (y + minY): \(arrowAccentBottomEdge)")
        print("    Accent glyph minY: \(arrowGlyphMinY)")
        print()

        // Also check the math table value
        if let mathTable = font.mathTable {
            print("Font math table:")
            print("  upperLimitGapMin: \(mathTable.upperLimitGapMin)")
            print()
        }

        // Compare the gaps
        print("=== Comparison ===")
        print("Baseline gaps:")
        print("  Widehat: \(widehatBaselineGap)")
        print("  Arrow: \(arrowBaselineGap)")
        print("  Difference: \(abs(widehatBaselineGap - arrowBaselineGap))")
        print()
        print("Visual gaps (bounding box):")
        print("  Widehat: \(widehatVisualGap)")
        print("  Arrow: \(arrowVisualGap)")
        print("  Difference: \(abs(widehatVisualGap - arrowVisualGap))")
        print()

        // Baseline gaps will differ because we compensate for different minY values
        // But visual gaps (which account for minY) should be approximately equal
        XCTAssertEqual(widehatVisualGap, arrowVisualGap, accuracy: 0.5,
                      "Visual gaps should be approximately equal after minY compensation")
    }
}
