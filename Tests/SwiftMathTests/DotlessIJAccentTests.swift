import XCTest
@testable import SwiftMath

/// Tests for correct rendering of accented i and j characters.
/// When an accent is placed over 'i' or 'j', the dot should be removed
/// (using dotless variants imath/jmath) to avoid double dots.
final class DotlessIJAccentTests: XCTestCase {

    var font: MTFont!

    override func setUp() {
        super.setUp()
        font = MTFontManager().termesFont(withSize: 20)
    }

    // MARK: - Accented i Tests

    func testCircumflexOverI() throws {
        // Test that î (i with circumflex) uses the base dotless i character
        // that can be properly styled (roman in text mode, italic in math mode)
        let unicodeLatex = "î"

        let unicodeMathList = MTMathListBuilder.build(fromString: unicodeLatex)

        XCTAssertNotNil(unicodeMathList, "Unicode î should parse")
        XCTAssertEqual(unicodeMathList?.atoms.count, 1, "Should have exactly 1 atom")

        guard let unicodeAccent = unicodeMathList?.atoms.first as? MTAccent else {
            XCTFail("Should be MTAccent atom")
            return
        }

        guard let unicodeInner = unicodeAccent.innerList?.atoms.first else {
            XCTFail("Accent should have inner list")
            return
        }

        // The nucleus should be the base dotless i (U+0131) which can be styled
        let dotlessI = "\u{0131}"  // Latin Small Letter Dotless I
        XCTAssertEqual(unicodeInner.nucleus, dotlessI,
                      "Unicode î should use base dotless i (U+0131), got '\(unicodeInner.nucleus)'")
    }

    func testExplicitImathStillWorks() throws {
        // Test that explicit \hat{\imath} still works and uses the mathematical italic dotless i
        let explicitLatex = "\\hat{\\imath}"
        let explicitMathList = MTMathListBuilder.build(fromString: explicitLatex)

        XCTAssertNotNil(explicitMathList, "\\hat{\\imath} should parse")

        guard let explicitAccent = explicitMathList?.atoms.first as? MTAccent,
              let explicitInner = explicitAccent.innerList?.atoms.first else {
            XCTFail("Should parse as accent with inner list")
            return
        }

        // Explicit \imath uses the mathematical italic dotless i (U+1D6A4)
        let mathItalicDotlessI = "\u{0001D6A4}"
        XCTAssertEqual(explicitInner.nucleus, mathItalicDotlessI,
                      "\\imath should use mathematical italic dotless i (U+1D6A4)")
    }

    func testDieresisOverI() throws {
        // Test that ï (i with dieresis/umlaut) uses base dotless i
        let unicodeLatex = "ï"
        let unicodeMathList = MTMathListBuilder.build(fromString: unicodeLatex)

        XCTAssertNotNil(unicodeMathList, "Unicode ï should parse")

        guard let unicodeAccent = unicodeMathList?.atoms.first as? MTAccent,
              let unicodeInner = unicodeAccent.innerList?.atoms.first else {
            XCTFail("Should parse as accent with inner list")
            return
        }

        let dotlessI = "\u{0131}"  // Latin Small Letter Dotless I
        XCTAssertEqual(unicodeInner.nucleus, dotlessI,
                      "Unicode ï should use base dotless i (U+0131), got '\(unicodeInner.nucleus)'")
    }

    func testAcuteOverI() throws {
        // Test that í (i with acute) uses base dotless i
        let unicodeLatex = "í"
        let unicodeMathList = MTMathListBuilder.build(fromString: unicodeLatex)

        guard let unicodeAccent = unicodeMathList?.atoms.first as? MTAccent,
              let unicodeInner = unicodeAccent.innerList?.atoms.first else {
            XCTFail("Should parse as accent with inner list")
            return
        }

        let dotlessI = "\u{0131}"  // Latin Small Letter Dotless I
        XCTAssertEqual(unicodeInner.nucleus, dotlessI,
                      "Unicode í should use base dotless i (U+0131), got '\(unicodeInner.nucleus)'")
    }

    func testGraveOverI() throws {
        // Test that ì (i with grave) uses dotless i
        let unicodeLatex = "ì"

        let unicodeMathList = MTMathListBuilder.build(fromString: unicodeLatex)

        guard let unicodeAccent = unicodeMathList?.atoms.first as? MTAccent,
              let unicodeInner = unicodeAccent.innerList?.atoms.first else {
            XCTFail("Should parse as accent with inner list")
            return
        }

        let dotlessI = "\u{0131}"  // Latin Small Letter Dotless I
        XCTAssertEqual(unicodeInner.nucleus, dotlessI,
                      "Unicode ì should use dotless i (\\imath), got '\(unicodeInner.nucleus)'")
    }

    // MARK: - Accented j Tests

    func testCircumflexOverJ() throws {
        // Test that ĵ (j with circumflex) uses dotless j
        let unicodeLatex = "ĵ"
        let unicodeMathList = MTMathListBuilder.build(fromString: unicodeLatex)

        XCTAssertNotNil(unicodeMathList, "Unicode ĵ should parse")
        XCTAssertEqual(unicodeMathList?.atoms.count, 1, "Should have exactly 1 atom")

        guard let unicodeAccent = unicodeMathList?.atoms.first as? MTAccent else {
            XCTFail("Should be MTAccent atom")
            return
        }

        guard let unicodeInner = unicodeAccent.innerList?.atoms.first else {
            XCTFail("Accent should have inner list")
            return
        }

        // The nucleus should be the base dotless j (U+0237) which can be styled
        let dotlessJ = "\u{0237}"  // Latin Small Letter Dotless J
        XCTAssertEqual(unicodeInner.nucleus, dotlessJ,
                      "Unicode ĵ should use base dotless j (U+0237), got '\(unicodeInner.nucleus)'")
    }

    func testTextModeAccentedJ() throws {
        // Test that ĵ in text mode uses dotless j with roman font style
        let latex = "\\text{ĵ}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        XCTAssertNotNil(mathList, "\\text{ĵ} should parse")

        // Helper to recursively find accents
        func findAccents(in list: MTMathList?) -> [MTAccent] {
            var accents: [MTAccent] = []
            for atom in list?.atoms ?? [] {
                if let accent = atom as? MTAccent {
                    accents.append(accent)
                }
                if let inner = atom as? MTInner {
                    accents.append(contentsOf: findAccents(in: inner.innerList))
                }
            }
            return accents
        }

        let accents = findAccents(in: mathList)
        XCTAssertEqual(accents.count, 1, "Should find 1 accent")

        if let accent = accents.first, let inner = accent.innerList?.atoms.first {
            let dotlessJ = "\u{0237}"
            XCTAssertEqual(inner.nucleus, dotlessJ,
                          "Should use base dotless j")
            XCTAssertEqual(inner.fontStyle, .roman,
                          "In \\text{}, should have roman style, got \(inner.fontStyle)")
        }
    }

    func testAccentedJRendersCorrectly() throws {
        // Test that ĵ renders without crashing
        let latex = "ĵ"
        let mathList = MTMathListBuilder.build(fromString: latex)
        let font = MTFontManager().termesFont(withSize: 20)
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

        XCTAssertNotNil(display, "ĵ should render successfully")
    }

    // MARK: - Uppercase I Tests (should NOT use dotless variant)

    func testCircumflexOverUppercaseI() throws {
        // Uppercase I does not have a dot, so it should remain as I
        let unicodeLatex = "Î"

        let unicodeMathList = MTMathListBuilder.build(fromString: unicodeLatex)

        guard let unicodeAccent = unicodeMathList?.atoms.first as? MTAccent,
              let unicodeInner = unicodeAccent.innerList?.atoms.first else {
            XCTFail("Should parse as accent with inner list")
            return
        }

        XCTAssertEqual(unicodeInner.nucleus, "I",
                      "Uppercase Î should use regular I, got '\(unicodeInner.nucleus)'")
    }

    // MARK: - Visual Rendering Tests

    func testAccentedIRendersWithoutDoubleDot() throws {
        // Verify that the rendered output doesn't have a double dot
        let latex = "î"
        let mathList = MTMathListBuilder.build(fromString: latex)
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

        XCTAssertNotNil(display, "î should render successfully")

        // The display should have exactly one accent display
        guard let accentDisplay = display?.subDisplays.first as? MTAccentDisplay else {
            XCTFail("Should have an MTAccentDisplay")
            return
        }

        // Verify the accentee exists
        XCTAssertNotNil(accentDisplay.accentee, "Accent should have an accentee (the base character)")
        XCTAssertNotNil(accentDisplay.accent, "Accent should have an accent glyph")
    }

    func testMultipleAccentedICharacters() throws {
        // Test a string with multiple accented i characters
        let latex = "îïíì"
        let mathList = MTMathListBuilder.build(fromString: latex)

        XCTAssertNotNil(mathList, "Multiple accented i chars should parse")
        XCTAssertEqual(mathList?.atoms.count, 4, "Should have 4 atoms")

        let dotlessI = "\u{0131}"  // Latin Small Letter Dotless I
        for (index, atom) in (mathList?.atoms ?? []).enumerated() {
            guard let accent = atom as? MTAccent,
                  let inner = accent.innerList?.atoms.first else {
                XCTFail("Atom \(index) should be an accent with inner list")
                continue
            }
            XCTAssertEqual(inner.nucleus, dotlessI,
                          "Atom \(index) should use dotless i, got '\(inner.nucleus)'")
        }
    }

    // MARK: - Regression Tests

    func testExplicitHatIStillUsesRegularI() throws {
        // When user explicitly writes \hat{i}, it should still use regular 'i'
        // Only Unicode accented characters should convert to dotless
        let latex = "\\hat{i}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        guard let accent = mathList?.atoms.first as? MTAccent,
              let inner = accent.innerList?.atoms.first else {
            XCTFail("Should parse as accent with inner list")
            return
        }

        // Explicit \hat{i} should keep the regular 'i'
        XCTAssertEqual(inner.nucleus, "i",
                      "Explicit \\hat{i} should use regular 'i', got '\(inner.nucleus)'")
    }

    func testOtherAccentedCharactersStillWork() throws {
        // Verify that other accented characters (not i/j) still work correctly
        let testCases: [(String, String)] = [
            ("é", "e"),
            ("ñ", "n"),
            ("ü", "u"),
            ("â", "a"),
            ("ô", "o"),
        ]

        for (unicode, expectedBase) in testCases {
            let mathList = MTMathListBuilder.build(fromString: unicode)

            guard let accent = mathList?.atoms.first as? MTAccent,
                  let inner = accent.innerList?.atoms.first else {
                XCTFail("\(unicode) should parse as accent with inner list")
                continue
            }

            XCTAssertEqual(inner.nucleus, expectedBase,
                          "\(unicode) should have base '\(expectedBase)', got '\(inner.nucleus)'")
        }
    }

    func testLatexRoundTripConversion() throws {
        // Test that Unicode î converts to LaTeX properly
        let unicodeLatex = "î"
        let mathList = MTMathListBuilder.build(fromString: unicodeLatex)

        // Convert back to LaTeX
        let latexOutput = MTMathListBuilder.mathListToString(mathList)

        // The output should contain \hat with the dotless i character (U+0131)
        XCTAssertTrue(latexOutput.contains("hat"),
                     "LaTeX output should contain 'hat', got '\(latexOutput)'")
        // The base character should be the dotless i (either as raw char or command)
        let dotlessI = "\u{0131}"
        XCTAssertTrue(latexOutput.contains(dotlessI) || latexOutput.contains("dotlessi"),
                     "LaTeX output should contain dotless i, got '\(latexOutput)'")
    }

    func testTextModeAccentedI() throws {
        // Test that accented i in text mode renders successfully and uses dotless i
        // with the correct font style (roman, not italic)
        let latex = "\\text{naïve}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        XCTAssertNotNil(mathList, "\\text{naïve} should parse")

        // Helper function to recursively find accent atoms
        func findAccents(in list: MTMathList?) -> [MTAccent] {
            var accents: [MTAccent] = []
            for atom in list?.atoms ?? [] {
                if let accent = atom as? MTAccent {
                    accents.append(accent)
                }
                if let inner = atom as? MTInner {
                    accents.append(contentsOf: findAccents(in: inner.innerList))
                }
            }
            return accents
        }

        let accents = findAccents(in: mathList)

        // Should find exactly one accent (the ï)
        XCTAssertEqual(accents.count, 1, "Should find exactly 1 accent atom in \\text{naïve}")

        if let accent = accents.first, let inner = accent.innerList?.atoms.first {
            // The accent should use dotless i
            let dotlessI = "\u{0131}"  // Latin Small Letter Dotless I
            XCTAssertEqual(inner.nucleus, dotlessI,
                          "Accented i in text mode should use dotless i, got '\(inner.nucleus)'")

            // CRITICAL: The inner atom should have roman font style in text mode,
            // not defaultStyle (which renders as italic in math mode)
            XCTAssertEqual(inner.fontStyle, .roman,
                          "Dotless i in \\text{} should have roman font style, got \(inner.fontStyle)")
        }
    }

    func testUppercaseAccentedCharsNotAffected() throws {
        // All uppercase accented characters should NOT use dotless variants
        let uppercaseTestCases: [(String, String)] = [
            ("Î", "I"),  // circumflex
            ("Ï", "I"),  // dieresis
            ("Í", "I"),  // acute
            ("Ì", "I"),  // grave
        ]

        for (unicode, expectedBase) in uppercaseTestCases {
            let mathList = MTMathListBuilder.build(fromString: unicode)

            guard let accent = mathList?.atoms.first as? MTAccent,
                  let inner = accent.innerList?.atoms.first else {
                XCTFail("\(unicode) should parse as accent with inner list")
                continue
            }

            XCTAssertEqual(inner.nucleus, expectedBase,
                          "\(unicode) should have base '\(expectedBase)', got '\(inner.nucleus)'")
        }
    }

    func testMixedExpressionWithAccentedI() throws {
        // Test a more complex expression mixing regular and accented characters
        let latex = "x + î = y"
        let mathList = MTMathListBuilder.build(fromString: latex)

        XCTAssertNotNil(mathList, "Mixed expression should parse")

        // Find the accent (should be the 3rd atom: x, +, î, =, y)
        var foundAccent = false
        let dotlessI = "\u{0131}"  // Latin Small Letter Dotless I
        for atom in mathList?.atoms ?? [] {
            if let accent = atom as? MTAccent {
                foundAccent = true
                if let inner = accent.innerList?.atoms.first {
                    XCTAssertEqual(inner.nucleus, dotlessI,
                                  "Accented i in expression should use dotless i")
                }
            }
        }
        XCTAssertTrue(foundAccent, "Should find an accent in mixed expression")
    }

    // MARK: - Font Style Tests for All Accented Characters

    func testTextModeOtherAccentedCharactersFontStyle() throws {
        // Test that other accented characters (not i/j) preserve font style in text mode
        // These use regular ASCII base characters which should be styled correctly
        let latex = "\\text{naïve café résumé}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        XCTAssertNotNil(mathList, "Text with accented chars should parse")

        // Helper to recursively find all accents
        func findAccents(in list: MTMathList?) -> [MTAccent] {
            var accents: [MTAccent] = []
            for atom in list?.atoms ?? [] {
                if let accent = atom as? MTAccent {
                    accents.append(accent)
                }
                if let inner = atom as? MTInner {
                    accents.append(contentsOf: findAccents(in: inner.innerList))
                }
            }
            return accents
        }

        let accents = findAccents(in: mathList)

        // Should find accents for ï, é (twice), é
        XCTAssertGreaterThanOrEqual(accents.count, 3,
                                    "Should find at least 3 accents in '\\text{naïve café résumé}'")

        // Check that all accents have roman font style in text mode
        for accent in accents {
            if let inner = accent.innerList?.atoms.first {
                XCTAssertEqual(inner.fontStyle, .roman,
                              "Accent inner atom should have roman style in \\text{}, got \(inner.fontStyle) for '\(inner.nucleus)'")
            }
        }
    }

    func testMathModeAccentedCharactersFontStyle() throws {
        // In math mode (default), accented characters should have default style
        // which renders as italic for letters
        let latex = "é"  // Just é in math mode
        let mathList = MTMathListBuilder.build(fromString: latex)

        guard let accent = mathList?.atoms.first as? MTAccent,
              let inner = accent.innerList?.atoms.first else {
            XCTFail("Should parse as accent with inner list")
            return
        }

        // In math mode without explicit font command, atoms have defaultStyle
        // The actual rendering will italicize it
        XCTAssertEqual(inner.fontStyle, .defaultStyle,
                      "In math mode, accent inner should have defaultStyle")
        XCTAssertEqual(inner.nucleus, "e",
                      "Base character should be 'e'")
    }

    func testBoldAccentedCharacters() throws {
        // Test accented characters in bold mode
        let latex = "\\mathbf{é}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        guard let accent = mathList?.atoms.first as? MTAccent,
              let inner = accent.innerList?.atoms.first else {
            XCTFail("Should parse as accent with inner list")
            return
        }

        XCTAssertEqual(inner.fontStyle, .bold,
                      "In \\mathbf{}, accent inner should have bold style, got \(inner.fontStyle)")
    }

    func testItalicAccentedI() throws {
        // Test that î in mathit mode uses italic (via the styling system)
        let latex = "\\mathit{î}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        guard let accent = mathList?.atoms.first as? MTAccent,
              let inner = accent.innerList?.atoms.first else {
            XCTFail("Should parse as accent with inner list")
            return
        }

        // Should use base dotless i with italic font style
        let dotlessI = "\u{0131}"
        XCTAssertEqual(inner.nucleus, dotlessI,
                      "Should use base dotless i")
        XCTAssertEqual(inner.fontStyle, .italic,
                      "In \\mathit{}, should have italic style, got \(inner.fontStyle)")
    }

    func testRomanAccentedI() throws {
        // Test that î in mathrm mode uses roman dotless i
        let latex = "\\mathrm{î}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        guard let accent = mathList?.atoms.first as? MTAccent,
              let inner = accent.innerList?.atoms.first else {
            XCTFail("Should parse as accent with inner list")
            return
        }

        // Should use base dotless i with roman font style
        let dotlessI = "\u{0131}"
        XCTAssertEqual(inner.nucleus, dotlessI,
                      "Should use base dotless i")
        XCTAssertEqual(inner.fontStyle, .roman,
                      "In \\mathrm{}, should have roman style, got \(inner.fontStyle)")
    }

    // MARK: - Special Character Tests

    func testSpecialCharactersInMathMode() throws {
        // Test special characters (ç, å, æ, œ, ß) in math mode
        // These should render without crashing
        let specialChars = ["ç", "å", "æ", "œ", "ß"]

        for char in specialChars {
            let mathList = MTMathListBuilder.build(fromString: char)
            XCTAssertNotNil(mathList, "\(char) should parse in math mode")
            XCTAssertEqual(mathList?.atoms.count, 1, "\(char) should produce 1 atom")

            // Test rendering - this should not crash
            let font = MTFontManager().termesFont(withSize: 20)
            let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)
            XCTAssertNotNil(display, "\(char) should render without crashing")
        }
    }

    func testSpecialCharactersInTextMode() throws {
        // Test special characters in text mode
        let latex = "\\text{ça va? æther œuvre süß}"
        let mathList = MTMathListBuilder.build(fromString: latex)

        XCTAssertNotNil(mathList, "Text with special chars should parse")

        // Test rendering - should not crash
        let font = MTFontManager().termesFont(withSize: 20)
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)
        XCTAssertNotNil(display, "Special chars in text mode should render")
    }

    func testAllSupportedAccentedCharactersRender() throws {
        // Comprehensive test: all supported accented characters should render
        let allAccented = [
            // Acute
            "á", "é", "í", "ó", "ú", "ý",
            "Á", "É", "Í", "Ó", "Ú", "Ý",
            // Grave
            "à", "è", "ì", "ò", "ù",
            "À", "È", "Ì", "Ò", "Ù",
            // Circumflex
            "â", "ê", "î", "ô", "û",
            "Â", "Ê", "Î", "Ô", "Û",
            // Umlaut/dieresis
            "ä", "ë", "ï", "ö", "ü", "ÿ",
            "Ä", "Ë", "Ï", "Ö", "Ü",
            // Tilde
            "ã", "ñ", "õ",
            "Ã", "Ñ", "Õ",
            // Special
            "ç", "ø", "å", "æ", "œ", "ß",
            "Ç", "Ø", "Å", "Æ", "Œ"
        ]

        let font = MTFontManager().termesFont(withSize: 20)

        for char in allAccented {
            let mathList = MTMathListBuilder.build(fromString: char)
            XCTAssertNotNil(mathList, "\(char) should parse")

            // Render in math mode - should not crash
            let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)
            XCTAssertNotNil(display, "\(char) should render in math mode without crashing")
        }
    }

    func testAllAccentedCharactersInTextMode() throws {
        // Test all accented characters in text mode with roman font
        let allAccented = [
            "á", "é", "í", "ó", "ú", "ý",
            "à", "è", "ì", "ò", "ù",
            "â", "ê", "î", "ô", "û",
            "ä", "ë", "ï", "ö", "ü", "ÿ",
            "ã", "ñ", "õ",
        ]

        let font = MTFontManager().termesFont(withSize: 20)

        for char in allAccented {
            let latex = "\\text{\(char)}"
            let mathList = MTMathListBuilder.build(fromString: latex)
            XCTAssertNotNil(mathList, "\\text{\(char)} should parse")

            // Render - should not crash
            let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)
            XCTAssertNotNil(display, "\\text{\(char)} should render without crashing")
        }
    }
}
