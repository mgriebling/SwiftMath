import XCTest
@testable import SwiftMath
import CoreText
import CoreGraphics

final class GlyphBoundsTest: XCTestCase {

    var font: MTFont!

    override func setUp() {
        super.setUp()
        font = MTFontManager().termesFont(withSize: 20)
    }

    func testGlyphBounds() throws {
        // Get the actual glyph objects
        let circumflexGlyph = font.get(glyphWithName: "circumflex")
        let arrowGlyph = font.get(glyphWithName: "arrowright") // rightarrow for stretchy overrightarrow

        print("\n=== Detailed Glyph Bounds Analysis ===\n")

        // Get bounding rects for both glyphs
        var circumflexRect = CGRect.zero
        var circumflexGlyphCopy = circumflexGlyph
        CTFontGetBoundingRectsForGlyphs(font.ctFont, .horizontal, &circumflexGlyphCopy, &circumflexRect, 1)

        var arrowRect = CGRect.zero
        var arrowGlyphCopy = arrowGlyph
        CTFontGetBoundingRectsForGlyphs(font.ctFont, .horizontal, &arrowGlyphCopy, &arrowRect, 1)

        print("Circumflex glyph:")
        print("  Bounding rect: \(circumflexRect)")
        print("  minY (bottom): \(circumflexRect.minY)")
        print("  maxY (top): \(circumflexRect.maxY)")
        print("  height: \(circumflexRect.height)")
        print("  Calculated ascent: \(circumflexRect.maxY)")
        print("  Calculated descent: \(-circumflexRect.minY)")
        print()

        print("Arrow glyph (arrowright):")
        print("  Bounding rect: \(arrowRect)")
        print("  minY (bottom): \(arrowRect.minY)")
        print("  maxY (top): \(arrowRect.maxY)")
        print("  height: \(arrowRect.height)")
        print("  Calculated ascent: \(arrowRect.maxY)")
        print("  Calculated descent: \(-arrowRect.minY)")
        print()

        // Check if circumflex has significant space at the bottom
        if -circumflexRect.minY < 1.0 && circumflexRect.maxY > 10.0 {
            print("NOTE: Circumflex glyph sits on baseline with minimal descent")
            print("      The visual 'peak' of the hat is at the top of the bounding box")
            print("      Bottom whitespace in glyph: \(-circumflexRect.minY)")
        }

        if -arrowRect.minY < 1.0 && arrowRect.maxY < 10.0 {
            print("NOTE: Arrow glyph sits on baseline with minimal descent")
            print("      The arrow is more compact vertically")
            print("      Bottom whitespace in glyph: \(-arrowRect.minY)")
        }
    }
}
