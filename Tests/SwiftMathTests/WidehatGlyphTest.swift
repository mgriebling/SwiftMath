import XCTest
@testable import SwiftMath

final class WidehatGlyphTest: XCTestCase {

    var font: MTFont!

    override func setUp() {
        super.setUp()
        font = MTFontManager().termesFont(withSize: 20)
    }

    func testWidehatGlyphAvailability() throws {
        // Test what glyphs are available for widehat (circumflex accent)
        print("\n=== Widehat Glyph Analysis ===")

        let circumflexChar = "\u{0302}"  // COMBINING CIRCUMFLEX ACCENT
        let baseGlyph = font.get(glyphWithName: circumflexChar)
        let glyphName = font.get(nameForGlyph: baseGlyph)

        print("Base circumflex character: U+0302")
        print("  Glyph ID: \(baseGlyph)")
        print("  Glyph name: \(glyphName)")

        // Check for horizontal variants
        if let mathTable = font.mathTable {
            let variants = mathTable.getHorizontalVariantsForGlyph(baseGlyph)
            print("  Found \(variants.count) horizontal variant(s)")

            for (index, variantNum) in variants.enumerated() {
                guard let variantNum = variantNum else { continue }
                let variantGlyph = CGGlyph(variantNum.uint16Value)
                let variantName = font.get(nameForGlyph: variantGlyph)

                var glyph = variantGlyph
                var advances = CGSize.zero
                CTFontGetAdvancesForGlyphs(font.ctFont, .horizontal, &glyph, &advances, 1)

                print("    [\(index)] \(variantName): width = \(String(format: "%.2f", advances.width))")
            }
        }

        // Try named glyphs
        print("\nNamed glyph lookup:")
        let namedGlyphs = [
            "uni0302",
            "circumflex",
            "asciicircum"
        ]

        for name in namedGlyphs {
            let glyph = font.get(glyphWithName: name)
            if glyph != 0 {
                let actualName = font.get(nameForGlyph: glyph)
                print("  \(name) -> \(actualName) (glyph \(glyph))")
            } else {
                print("  \(name) -> NOT FOUND")
            }
        }
    }

    func testWidetildeGlyphAvailability() throws {
        // Test what glyphs are available for widetilde
        print("\n=== Widetilde Glyph Analysis ===")

        let tildeChar = "\u{0303}"  // COMBINING TILDE
        let baseGlyph = font.get(glyphWithName: tildeChar)
        let glyphName = font.get(nameForGlyph: baseGlyph)

        print("Base tilde character: U+0303")
        print("  Glyph ID: \(baseGlyph)")
        print("  Glyph name: \(glyphName)")

        // Check for horizontal variants
        if let mathTable = font.mathTable {
            let variants = mathTable.getHorizontalVariantsForGlyph(baseGlyph)
            print("  Found \(variants.count) horizontal variant(s)")

            for (index, variantNum) in variants.enumerated() {
                guard let variantNum = variantNum else { continue }
                let variantGlyph = CGGlyph(variantNum.uint16Value)
                let variantName = font.get(nameForGlyph: variantGlyph)

                var glyph = variantGlyph
                var advances = CGSize.zero
                CTFontGetAdvancesForGlyphs(font.ctFont, .horizontal, &glyph, &advances, 1)

                print("    [\(index)] \(variantName): width = \(String(format: "%.2f", advances.width))")
            }
        }

        // Try named glyphs
        print("\nNamed glyph lookup:")
        let namedGlyphs = [
            "uni0303",
            "tilde",
            "asciitilde"
        ]

        for name in namedGlyphs {
            let glyph = font.get(glyphWithName: name)
            if glyph != 0 {
                let actualName = font.get(nameForGlyph: glyph)
                print("  \(name) -> \(actualName) (glyph \(glyph))")
            } else {
                print("  \(name) -> NOT FOUND")
            }
        }
    }

    func testCurrentWidehatBehavior() throws {
        // Test current behavior of \widehat vs \hat
        print("\n=== Current Widehat Behavior ===")

        let testCases = [
            ("\\hat{x}", "Single char hat"),
            ("\\widehat{x}", "Single char widehat"),
            ("\\hat{ABC}", "Multi-char hat"),
            ("\\widehat{ABC}", "Multi-char widehat")
        ]

        for (latex, description) in testCases {
            let mathList = MTMathListBuilder.build(fromString: latex)
            let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

            if let display = display,
               let accentDisp = display.subDisplays.first as? MTAccentDisplay,
               let accentee = accentDisp.accentee,
               let accent = accentDisp.accent {

                let coverage = accent.width / accentee.width * 100
                print("\n\(description): \(latex)")
                print("  Content width: \(String(format: "%.2f", accentee.width))")
                print("  Accent width: \(String(format: "%.2f", accent.width))")
                print("  Coverage: \(String(format: "%.1f", coverage))%")
            }
        }
    }
}
