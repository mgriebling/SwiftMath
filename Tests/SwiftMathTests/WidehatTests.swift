import XCTest
@testable import SwiftMath

final class WidehatTests: XCTestCase {

    var font: MTFont!

    override func setUp() {
        super.setUp()
        font = MTFontManager().termesFont(withSize: 20)
    }

    // MARK: - Basic Functionality Tests

    func testWidehatVsHat() throws {
        // Test that \widehat and \hat produce different results
        let hatLatex = "\\hat{ABC}"
        let widehatLatex = "\\widehat{ABC}"

        let hatMathList = MTMathListBuilder.build(fromString: hatLatex)
        let widehatMathList = MTMathListBuilder.build(fromString: widehatLatex)

        let hatDisplay = MTTypesetter.createLineForMathList(hatMathList, font: font, style: .display)
        let widehatDisplay = MTTypesetter.createLineForMathList(widehatMathList, font: font, style: .display)

        XCTAssertNotNil(hatDisplay, "\\hat should render")
        XCTAssertNotNil(widehatDisplay, "\\widehat should render")

        // Get the accent displays
        guard let hatAccentDisp = hatDisplay?.subDisplays.first as? MTAccentDisplay,
              let widehatAccentDisp = widehatDisplay?.subDisplays.first as? MTAccentDisplay,
              let hatAccent = hatAccentDisp.accent,
              let widehatAccent = widehatAccentDisp.accent else {
            XCTFail("Could not extract accent displays")
            return
        }

        // Widehat should have greater width than hat for the same content
        XCTAssertGreaterThan(widehatAccent.width, hatAccent.width,
                            "\\widehat should be wider than \\hat for multi-character content")
    }

    func testWidetildeVsTilde() throws {
        // Test that \widetilde and \tilde produce different results
        let tildeLatex = "\\tilde{ABC}"
        let widetildeLatex = "\\widetilde{ABC}"

        let tildeMathList = MTMathListBuilder.build(fromString: tildeLatex)
        let widetildeMathList = MTMathListBuilder.build(fromString: widetildeLatex)

        let tildeDisplay = MTTypesetter.createLineForMathList(tildeMathList, font: font, style: .display)
        let widetildeDisplay = MTTypesetter.createLineForMathList(widetildeMathList, font: font, style: .display)

        XCTAssertNotNil(tildeDisplay, "\\tilde should render")
        XCTAssertNotNil(widetildeDisplay, "\\widetilde should render")

        guard let tildeAccentDisp = tildeDisplay?.subDisplays.first as? MTAccentDisplay,
              let widetildeAccentDisp = widetildeDisplay?.subDisplays.first as? MTAccentDisplay,
              let tildeAccent = tildeAccentDisp.accent,
              let widetildeAccent = widetildeAccentDisp.accent else {
            XCTFail("Could not extract accent displays")
            return
        }

        XCTAssertGreaterThan(widetildeAccent.width, tildeAccent.width,
                            "\\widetilde should be wider than \\tilde for multi-character content")
    }

    // MARK: - Coverage Tests

    func testWidehatSingleCharCoverage() throws {
        // Test that \widehat covers a single character
        let latex = "\\widehat{x}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

        guard let accentDisp = display?.subDisplays.first as? MTAccentDisplay,
              let accentee = accentDisp.accentee,
              let accent = accentDisp.accent else {
            XCTFail("Could not extract accent display")
            return
        }

        let coverage = accent.width / accentee.width * 100

        // Should cover at least 100% of content
        XCTAssertGreaterThanOrEqual(coverage, 100,
                                   "\\widehat should cover at least 100% of single character")
        // Should not be excessively wide (less than 150%)
        XCTAssertLessThan(coverage, 150,
                         "\\widehat should not be excessively wide for single character")
    }

    func testWidehatMultiCharCoverage() throws {
        // Test that \widehat covers multiple characters
        let testCases = [
            ("\\widehat{AB}", "two characters"),
            ("\\widehat{ABC}", "three characters"),
            ("\\widehat{ABCD}", "four characters"),
            ("\\widehat{ABCDEF}", "six characters")
        ]

        for (latex, description) in testCases {
            let mathList = MTMathListBuilder.build(fromString: latex)
            let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

            guard let accentDisp = display?.subDisplays.first as? MTAccentDisplay,
                  let accentee = accentDisp.accentee,
                  let accent = accentDisp.accent else {
                XCTFail("Could not extract accent display for \(description)")
                continue
            }

            let coverage = accent.width / accentee.width * 100

            // Should cover at least 100% of content (with padding)
            XCTAssertGreaterThanOrEqual(coverage, 100,
                                       "\\widehat should cover at least 100% for \(description)")
            // Should not be excessively wide (less than 150%)
            XCTAssertLessThan(coverage, 150,
                             "\\widehat should not be excessively wide for \(description)")
        }
    }

    func testWidetildeCoverage() throws {
        // Test that \widetilde covers content properly
        let latex = "\\widetilde{ABC}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

        guard let accentDisp = display?.subDisplays.first as? MTAccentDisplay,
              let accentee = accentDisp.accentee,
              let accent = accentDisp.accent else {
            XCTFail("Could not extract accent display")
            return
        }

        let coverage = accent.width / accentee.width * 100

        XCTAssertGreaterThanOrEqual(coverage, 100,
                                   "\\widetilde should cover at least 100% of content")
        XCTAssertLessThan(coverage, 150,
                         "\\widetilde should not be excessively wide")
    }

    // MARK: - Flag Tests

    func testIsWideFlagSet() throws {
        // Test that isWide flag is set correctly by factory
        let widehat = MTMathAtomFactory.accent(withName: "widehat")
        let widetilde = MTMathAtomFactory.accent(withName: "widetilde")
        let hat = MTMathAtomFactory.accent(withName: "hat")
        let tilde = MTMathAtomFactory.accent(withName: "tilde")

        XCTAssertTrue(widehat?.isWide ?? false, "\\widehat should have isWide=true")
        XCTAssertTrue(widetilde?.isWide ?? false, "\\widetilde should have isWide=true")
        XCTAssertFalse(hat?.isWide ?? true, "\\hat should have isWide=false")
        XCTAssertFalse(tilde?.isWide ?? true, "\\tilde should have isWide=false")
    }

    // MARK: - Complex Content Tests

    func testWidehatWithFraction() throws {
        // Test widehat over a fraction
        let latex = "\\widehat{\\frac{a}{b}}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

        XCTAssertNotNil(display, "\\widehat with fraction should render")

        guard let accentDisp = display?.subDisplays.first as? MTAccentDisplay,
              let accentee = accentDisp.accentee,
              let accent = accentDisp.accent else {
            XCTFail("Could not extract accent display")
            return
        }

        let coverage = accent.width / accentee.width * 100

        // Should cover the fraction
        XCTAssertGreaterThanOrEqual(coverage, 90,
                                   "\\widehat should adequately cover fraction")
    }

    func testWidehatWithSubscript() throws {
        // Test widehat with subscripted content
        let latex = "\\widehat{x_i}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

        XCTAssertNotNil(display, "\\widehat with subscript should render")
    }

    func testWidehatWithSuperscript() throws {
        // Test widehat with superscripted content
        let latex = "\\widehat{x^2}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

        XCTAssertNotNil(display, "\\widehat with superscript should render")
    }

    // MARK: - Vertical Spacing Tests

    func testWidehatVerticalSpacing() throws {
        // Test that widehat has proper vertical spacing
        let latex = "\\widehat{ABC}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

        guard let accentDisp = display?.subDisplays.first as? MTAccentDisplay else {
            XCTFail("Could not extract accent display")
            return
        }

        // The overall display should be taller than just the content
        XCTAssertGreaterThan(accentDisp.ascent, accentDisp.accentee?.ascent ?? 0,
                            "Accent display should be taller than content alone")
    }

    // MARK: - Backward Compatibility Tests

    func testHatStillWorks() throws {
        // Test that \hat still works as before
        let latex = "\\hat{x}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

        XCTAssertNotNil(display, "\\hat should still render")
    }

    func testTildeStillWorks() throws {
        // Test that \tilde still works as before
        let latex = "\\tilde{x}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

        XCTAssertNotNil(display, "\\tilde should still render")
    }

    // MARK: - Edge Cases

    func testWidehatEmpty() throws {
        // Test widehat with empty content
        let latex = "\\widehat{}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

        // Should handle empty content gracefully
        XCTAssertNotNil(display, "\\widehat with empty content should not crash")
    }

    func testWidehatVeryLongContent() throws {
        // Test widehat with very long content
        let latex = "\\widehat{abcdefghijk}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        let display = MTTypesetter.createLineForMathList(mathList, font: font, style: .display)

        XCTAssertNotNil(display, "\\widehat with long content should render")

        guard let accentDisp = display?.subDisplays.first as? MTAccentDisplay,
              let accentee = accentDisp.accentee,
              let accent = accentDisp.accent else {
            XCTFail("Could not extract accent display")
            return
        }

        let coverage = accent.width / accentee.width * 100

        // Should still cover the content
        XCTAssertGreaterThanOrEqual(coverage, 90,
                                   "\\widehat should cover even very long content")
    }
}
