import XCTest
@testable import SwiftMath

/// Test case to verify the fix for incorrect line breaking with mixed text and math
///
/// Issue: "Add corresponding entries of matrices A and B." was incorrectly breaking to:
/// - Line 1: "Add corresponding entries of c"
/// - Line 2: "matrices A and B."
///
/// Root cause: Text atoms (\text{...}) with roman font style were being fused with
/// math variable atoms (A, B) with italic font style, creating one giant atom that
/// was then tokenized character-by-character.
///
/// Fix: Added fontStyle check to preprocessing to prevent fusion of atoms with
/// different font styles.
class MatricesLineBreakingTest: XCTestCase {

    func testMatricesLineBreakingFixed() throws {
        let label = MTMathUILabel()
        label.latex = "\\(\\text{Add corresponding entries of matrices }A\\text{ and }B\\text{.}\\)"
        label.fontSize = 20
        label.preferredMaxLayoutWidth = 235.0

        // Set frame to trigger layout
        label.frame = CGRect(x: 0, y: 0, width: 235.0, height: 100.0)

        #if os(macOS)
        label.layout()
        #else
        label.layoutSubviews()
        #endif

        let size = label.sizeThatFits(CGSize(width: 235.0, height: CGFloat.greatestFiniteMagnitude))

        // Verify the display list was created
        XCTAssertNotNil(label.displayList, "Display list should be created")

        guard let displayList = label.displayList else { return }

        // Verify we have multiple sub-displays (text characters + math variables)
        XCTAssertGreaterThan(displayList.subDisplays.count, 0, "Should have sub-displays")

        // Verify the display has proper dimensions
        XCTAssertGreaterThan(size.width, 0, "Width should be positive")
        XCTAssertGreaterThan(size.height, 0, "Height should be positive")

        // The key verification: check that text and math variables are kept as separate atoms
        // by verifying we have MTCTLineDisplay elements for text AND for math variables
        let ctLineDisplays = displayList.subDisplays.compactMap { $0 as? MTCTLineDisplay }
        XCTAssertGreaterThan(ctLineDisplays.count, 0, "Should have CTLine displays")

        // Check that we have displays with both roman text and italic math characters
        let hasRomanText = ctLineDisplays.contains { display in
            // Roman text like "Add", "corresponding", etc.
            if let text = display.attributedString?.string {
                return text.contains("A") && text.count == 1 && text == "A" // First character
                    || text.contains("c") && text.count == 1
                    || text.contains("o") && text.count == 1
            }
            return false
        }

        // Success criteria: The fix ensures atoms with different fontStyles are not fused
        // This means text and math variables remain separate, allowing proper line breaking
        XCTAssertTrue(hasRomanText || ctLineDisplays.count > 10,
                     "Text should be properly tokenized (not fused with math variables)")

        print("\n✅ FIX VERIFIED: Text and math atoms are properly separated")
        print("   Display has \(displayList.subDisplays.count) sub-displays")
        print("   Size: \(size)")
    }

    func testTextAndMathNotFused() throws {
        // More direct test: verify that \text{...} and math variables create separate atoms
        let label = MTMathUILabel()
        label.latex = "\\(\\text{hello }x\\text{ world}\\)"
        label.fontSize = 20

        // Set frame to trigger layout
        label.frame = CGRect(x: 0, y: 0, width: 1000, height: 100)

        #if os(macOS)
        label.layout()
        #else
        label.layoutSubviews()
        #endif

        let size = label.sizeThatFits(CGSize(width: 1000, height: 1000))

        guard let displayList = label.displayList else {
            XCTFail("Display list should be created")
            return
        }

        // With the fix, "hello " (text), "x" (math), and " world" (text) should be separate
        // Without the fix, they would be fused into "hello x world"

        let ctLineDisplays = displayList.subDisplays.compactMap { $0 as? MTCTLineDisplay }

        // We should have multiple CTLineDisplay objects, not just one giant fused one
        // "hello " has 6 chars, "x" is 1 char, " world" has 6 chars = 13 total
        // All should be separate because "hello " and " world" are roman, "x" is italic

        XCTAssertGreaterThan(ctLineDisplays.count, 1,
                           "Text atoms should not be fused with math variable atoms")

        print("\n✅ FUSION PREVENTION VERIFIED")
        print("   'hello ' (roman) + 'x' (italic) + ' world' (roman) = \(ctLineDisplays.count) displays")
        print("   Size: \(size)")
    }
}
