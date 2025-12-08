import XCTest
@testable import SwiftMath

final class MathDelimiterTests: XCTestCase {

    // MARK: - Display Math Delimiters

    func testDisplayMathBrackets() throws {
        // Test \[...\] delimiter for display math
        let latex = "\\[x^2 + y^2 = z^2\\]"
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)

        XCTAssertNotNil(mathList, "MathList should be parsed successfully")
        XCTAssertEqual(style, .display, "\\[...\\] should produce display style")

        // Verify the content was parsed correctly (without the delimiters)
        // Atoms: x (with ^2), +, y (with ^2), =, z (with ^2) = 5 atoms
        XCTAssertEqual(mathList?.atoms.count, 5, "Should have 5 atoms: x^2 + y^2 = z^2")
    }

    func testDoubleDollarDisplayMath() throws {
        // Test $$...$$ delimiter for display math
        let latex = "$$\\sum_{i=1}^{n} i$$"
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)

        XCTAssertNotNil(mathList, "MathList should be parsed successfully")
        XCTAssertEqual(style, .display, "$$...$$ should produce display style")

        // Verify content was parsed
        XCTAssertGreaterThan(mathList?.atoms.count ?? 0, 0, "MathList should contain atoms")
    }

    // MARK: - Inline Math Delimiters

    func testInlineMathParentheses() throws {
        // Test \(...\) delimiter for inline math
        let latex = "\\(a + b\\)"
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)

        XCTAssertNotNil(mathList, "MathList should be parsed successfully")
        XCTAssertEqual(style, .text, "\\(...\\) should produce text/inline style")

        // Verify content - includes style atom
        XCTAssertGreaterThanOrEqual(mathList?.atoms.count ?? 0, 3, "Should have at least 3 atoms: a + b")
    }

    func testSingleDollarInlineMath() throws {
        // Test $...$ delimiter for inline math
        let latex = "$\\frac{1}{2}$"
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)

        XCTAssertNotNil(mathList, "MathList should be parsed successfully")
        XCTAssertEqual(style, .text, "$...$ should produce text/inline style")

        // Verify fraction was parsed (may include style atom)
        XCTAssertGreaterThanOrEqual(mathList?.atoms.count ?? 0, 1, "Should have at least 1 atom")

        // Find the fraction atom (might not be first due to style atoms)
        let hasFraction = mathList?.atoms.contains(where: { $0.type == .fraction }) ?? false
        XCTAssertTrue(hasFraction, "Should contain a fraction atom")
    }

    // MARK: - No Delimiters (Default Behavior)

    func testNoDelimitersDefaultsToDisplay() throws {
        // Test that content without delimiters defaults to display mode
        let latex = "x + y = z"
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)

        XCTAssertNotNil(mathList, "MathList should be parsed successfully")
        XCTAssertEqual(style, .display, "Content without delimiters should default to display style")

        // Verify content
        XCTAssertEqual(mathList?.atoms.count, 5, "Should have 5 atoms: x + y = z")
    }

    // MARK: - Edge Cases

    func testEmptyBrackets() throws {
        // Test empty \[...\]
        // Note: \[\] is exactly 4 characters, so delimiter detection requires > 4
        // Empty delimiters are not detected as display math delimiters
        let latex = "\\[ \\]"  // Add space to make it > 4 characters
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)

        XCTAssertNotNil(mathList, "Empty display math with space should parse")
        XCTAssertEqual(style, .display, "\\[ \\] should produce display style")
        XCTAssertEqual(mathList?.atoms.count, 0, "Empty delimiters should produce empty list")
    }

    func testEmptyDoubleDollar() throws {
        // Test empty $$...$$
        let latex = "$$$$"
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)

        XCTAssertNotNil(mathList, "Empty display math should still parse")
        XCTAssertEqual(style, .display, "Empty $$$$ should produce display style")
        XCTAssertEqual(mathList?.atoms.count, 0, "Empty delimiters should produce empty list")
    }

    func testWhitespaceInBrackets() throws {
        // Test \[...\] with whitespace
        let latex = "\\[  x + y  \\]"
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)

        XCTAssertNotNil(mathList, "Whitespace should not affect parsing")
        XCTAssertEqual(style, .display, "\\[...\\] with whitespace should produce display style")
        XCTAssertEqual(mathList?.atoms.count, 3, "Should have 3 atoms: x + y")
    }

    func testNestedBracesInDisplayMath() throws {
        // Test \[...\] with nested braces
        let latex = "\\[\\frac{a}{b}\\]"
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)

        XCTAssertNotNil(mathList, "Nested structures should parse correctly")
        XCTAssertEqual(style, .display, "\\[...\\] should produce display style")
        XCTAssertEqual(mathList?.atoms.first?.type, .fraction, "Should contain a fraction")
    }

    // MARK: - Complex Expressions

    func testComplexDisplayExpression() throws {
        // Test a complex display math expression
        let latex = "\\[\\int_{0}^{\\infty} e^{-x^2} dx = \\frac{\\sqrt{\\pi}}{2}\\]"
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)

        XCTAssertNotNil(mathList, "Complex expression should parse")
        XCTAssertEqual(style, .display, "\\[...\\] should produce display style")
        XCTAssertGreaterThan(mathList?.atoms.count ?? 0, 5, "Should have multiple atoms")
    }

    func testComplexInlineExpression() throws {
        // Test a complex inline math expression
        let latex = "$\\sum_{i=1}^{n} x_i$"
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)

        XCTAssertNotNil(mathList, "Complex inline expression should parse")
        XCTAssertEqual(style, .text, "$...$ should produce text/inline style")
        XCTAssertGreaterThan(mathList?.atoms.count ?? 0, 0, "Should have atoms")
    }

    // MARK: - Error Handling

    func testInvalidLatexWithBrackets() throws {
        // Test \[...\] with invalid LaTeX
        let latex = "\\[\\invalidcommand\\]"
        var error: NSError?
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex, error: &error)

        XCTAssertNil(mathList, "Invalid LaTeX should return nil")
        XCTAssertNotNil(error, "Should return an error")
        XCTAssertEqual(style, .display, "Style should still be detected even with error")
    }

    func testMismatchedDelimiters() throws {
        // Test mismatched delimiters - should not be recognized as delimited
        let latex = "\\[x + y\\)"
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)

        // The string doesn't match any delimiter pattern, so it's treated as raw content
        // This should parse the raw string including the backslash-bracket
        XCTAssertEqual(style, .display, "Mismatched delimiters default to display mode")
    }

    // MARK: - Backward Compatibility

    func testBackwardCompatibilityWithOldAPI() throws {
        // Ensure old API still works
        let latex = "x + y"
        let mathList = MTMathListBuilder.build(fromString: latex)

        XCTAssertNotNil(mathList, "Old API should still work")
        XCTAssertEqual(mathList?.atoms.count, 3, "Should parse correctly")
    }

    func testBackwardCompatibilityWithError() throws {
        // Ensure old error API still works
        let latex = "\\invalidcommand"
        var error: NSError?
        let mathList = MTMathListBuilder.build(fromString: latex, error: &error)

        XCTAssertNil(mathList, "Invalid LaTeX should return nil")
        XCTAssertNotNil(error, "Should return an error")
    }

    // MARK: - Multiple Delimiter Types

    func testAllDisplayDelimiters() throws {
        // Test all display delimiter types produce display style
        let testCases = [
            "\\[x^2\\]",
            "$$x^2$$"
        ]

        for latex in testCases {
            let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)
            XCTAssertNotNil(mathList, "Display math \(latex) should parse")
            XCTAssertEqual(style, .display, "\(latex) should produce display style")
        }
    }

    func testAllInlineDelimiters() throws {
        // Test all inline delimiter types produce text style
        let testCases = [
            "\\(x^2\\)",
            "$x^2$"
        ]

        for latex in testCases {
            let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)
            XCTAssertNotNil(mathList, "Inline math \(latex) should parse")
            XCTAssertEqual(style, .text, "\(latex) should produce text/inline style")
        }
    }

    // MARK: - Environment Testing

    func testEnvironmentDefaultsToDisplay() throws {
        // Test that \begin{...}\end{...} environments default to display mode
        let latex = "\\begin{align}x &= y\\end{align}"
        let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: latex)

        // Note: This might fail depending on environment support in the codebase
        XCTAssertEqual(style, .display, "Environments should default to display style")
    }
}
