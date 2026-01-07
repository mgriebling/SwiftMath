import XCTest
@testable import SwiftMath

/// Regression tests for limit operators and integral rendering
/// These tests prevent regressions of fixes made for:
/// - Subscript duplication bug (subscripts rendering twice)
/// - Subscript font sizing (subscripts not using proper script-sized font)
/// - Vertical spacing between operator and limits
/// - Integral sizing (integrals being too small)
final class LimitOperatorRegressionTests: XCTestCase {

    var font: MTFont?

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.font = MTFontManager.fontManager.defaultFont
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    // MARK: - Limit Operator Tests

    func testLimSubscript_NoDoubleRendering() throws {
        // Regression test: Subscript should render only once, not duplicated
        // Bug: Subscript was appearing twice - once below (too large) and once to the side
        guard let font = self.font else {
            XCTFail("Font should be initialized")
            return
        }

        let latex = "\\lim_{x\\to\\infty}f(x)"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let display = try XCTUnwrap(MTTypesetter.createLineForMathList(mathList, font: font, style: .text))
        XCTAssertEqual(display.type, .regular)

        // Find the limit operator display
        var limitsDisplay: MTLargeOpLimitsDisplay?
        for subDisplay in display.subDisplays {
            if let limitOp = subDisplay as? MTLargeOpLimitsDisplay {
                limitsDisplay = limitOp
                break
            }
        }

        let limOp = try XCTUnwrap(limitsDisplay, "Should have MTLargeOpLimitsDisplay for \\lim")

        // Verify lower limit exists (subscript)
        XCTAssertNotNil(limOp.lowerLimit, "Should have lower limit (x→∞)")

        // Verify subscript is positioned below (negative y position relative to baseline)
        let lowerLimit = try XCTUnwrap(limOp.lowerLimit)
        XCTAssertLessThan(lowerLimit.position.y, 0, "Subscript should be below baseline")

        // CRITICAL: Verify no script rendering on the nucleus display itself
        // The nucleus should not have hasScript = true, as scripts are already in the limits display
        XCTAssertFalse(limOp.hasScript, "Limit operator should not have separate scripts (they're in limits display)")
    }

    func testLimSubscript_ProperFontScaling() throws {
        // Regression test: Subscript should use script-sized font (~70% of base)
        // Bug: Subscript was rendering at full size (not scaled to script style)
        let baseFontSize: CGFloat = 20.0
        let testFont = try XCTUnwrap(MTFontManager.fontManager.termesFont(withSize: baseFontSize))

        let latex = "\\lim_{x\\to\\infty}f(x)"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let display = try XCTUnwrap(MTTypesetter.createLineForMathList(mathList, font: testFont, style: .text))

        // Find the limit operator display
        var limitsDisplay: MTLargeOpLimitsDisplay?
        for subDisplay in display.subDisplays {
            if let limitOp = subDisplay as? MTLargeOpLimitsDisplay {
                limitsDisplay = limitOp
                break
            }
        }

        let limOp = try XCTUnwrap(limitsDisplay)
        let lowerLimit = try XCTUnwrap(limOp.lowerLimit, "Should have lower limit")

        // Calculate expected script font size
        // Script style is typically 70% of base (scriptScaleDown from MATH table)
        let mathTable = try XCTUnwrap(testFont.mathTable)

        // The subscript height should be proportional to script font size
        // A full-size subscript at 20pt would be ~8-10pt tall
        // A properly scaled subscript at 14pt should be ~5-7pt tall
        let fullSizeHeight: CGFloat = 10.0  // Approximate height at base font size
        let expectedScriptHeight = fullSizeHeight * mathTable.scriptScaleDown

        // Verify subscript is noticeably smaller than full size
        // Allow some tolerance for glyph metrics variation
        XCTAssertLessThan(lowerLimit.ascent, fullSizeHeight * 0.85,
                         "Subscript ascent should be smaller than full size (properly scaled)")
        XCTAssertGreaterThan(lowerLimit.ascent, expectedScriptHeight * 0.8,
                            "Subscript should not be too small (sanity check)")

        // Verify overall dimensions are reasonable for script style
        let totalSubscriptHeight = lowerLimit.ascent + lowerLimit.descent
        XCTAssertLessThan(totalSubscriptHeight, fullSizeHeight * 0.9,
                         "Total subscript height should be smaller than full size")
    }

    func testLimSubscript_VerticalSpacing() throws {
        // Regression test: Vertical spacing between lim and subscript should match OpenType MATH metrics
        // Bug: Originally had 50% reduction in text mode, making spacing too tight
        let baseFontSize: CGFloat = 20.0
        let testFont = try XCTUnwrap(MTFontManager.fontManager.termesFont(withSize: baseFontSize))

        let latex = "\\lim_{x\\to\\infty}f(x)"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let display = try XCTUnwrap(MTTypesetter.createLineForMathList(mathList, font: testFont, style: .text))

        // Find the limit operator display
        var limitsDisplay: MTLargeOpLimitsDisplay?
        for subDisplay in display.subDisplays {
            if let limitOp = subDisplay as? MTLargeOpLimitsDisplay {
                limitsDisplay = limitOp
                break
            }
        }

        let limOp = try XCTUnwrap(limitsDisplay)

        // The lowerLimitGap should be set according to OpenType MATH metrics
        // Expected: max(lowerLimitGapMin, lowerLimitBaselineDropMin - subscript.ascent)
        // For typical fonts: lowerLimitGapMin ≈ 0.166 em, lowerLimitBaselineDropMin ≈ 0.6 em
        let mathTable = try XCTUnwrap(testFont.mathTable)

        // Calculate expected gap
        let lowerLimit = try XCTUnwrap(limOp.lowerLimit)
        let expectedMinGap = mathTable.lowerLimitGapMin
        let expectedBaselineDrop = mathTable.lowerLimitBaselineDropMin - lowerLimit.ascent
        let expectedGap = max(expectedMinGap, expectedBaselineDrop)

        // Verify the gap is set correctly (should match expected gap, not reduced by 50%)
        XCTAssertEqual(limOp.lowerLimitGap, expectedGap, accuracy: 0.1,
                      "Lower limit gap should use full MATH table metrics")

        // Verify gap is reasonable (not too tight)
        // The gap should be at least lowerLimitGapMin (typically ~0.166 em = ~3.3pt at 20pt)
        // But allow some tolerance since the actual gap is max(gapMin, baselineDrop - ascent)
        let minimumExpectedGap: CGFloat = mathTable.lowerLimitGapMin * 0.5
        XCTAssertGreaterThan(limOp.lowerLimitGap, minimumExpectedGap,
                            "Gap should be reasonable (at least half of lowerLimitGapMin)")
    }

    func testMaxMinSupInf_SameBehaviorAsLim() throws {
        // Regression test: Other limit operators (max, min, sup, inf) should behave same as lim
        guard let font = self.font else {
            XCTFail("Font should be initialized")
            return
        }

        let operators = ["max", "min", "sup", "inf"]

        for op in operators {
            let latex = "\\\(op)_{x\\to\\infty}f(x)"
            let mathList = MTMathListBuilder.build(fromString: latex)
            XCTAssertNotNil(mathList, "Should parse \\\(op)")

            let display = try XCTUnwrap(MTTypesetter.createLineForMathList(mathList, font: font, style: .text))

            // Find the limit operator display
            var foundLimitsDisplay = false
            for subDisplay in display.subDisplays {
                if let limOp = subDisplay as? MTLargeOpLimitsDisplay {
                    foundLimitsDisplay = true

                    // Verify has lower limit
                    XCTAssertNotNil(limOp.lowerLimit, "\\\(op) should have lower limit")

                    // Verify subscript is below
                    if let lowerLimit = limOp.lowerLimit {
                        XCTAssertLessThan(lowerLimit.position.y, 0,
                                         "\\\(op) subscript should be below baseline")
                    }

                    // Verify no double scripting
                    XCTAssertFalse(limOp.hasScript,
                                  "\\\(op) should not have separate scripts")

                    break
                }
            }

            XCTAssertTrue(foundLimitsDisplay, "\\\(op) should use MTLargeOpLimitsDisplay")
        }
    }

    func testLimSuperscript_ProperPositioning() throws {
        // Test that superscripts (upper limits) work correctly too
        guard let font = self.font else {
            XCTFail("Font should be initialized")
            return
        }

        let latex = "\\limsup^{n\\to\\infty}f(x)"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let display = try XCTUnwrap(MTTypesetter.createLineForMathList(mathList, font: font, style: .text))

        // Find the limit operator display
        var limitsDisplay: MTLargeOpLimitsDisplay?
        for subDisplay in display.subDisplays {
            if let limitOp = subDisplay as? MTLargeOpLimitsDisplay {
                limitsDisplay = limitOp
                break
            }
        }

        let limOp = try XCTUnwrap(limitsDisplay)

        // Verify has upper limit
        XCTAssertNotNil(limOp.upperLimit, "Should have upper limit")

        // Verify superscript is above (positive y position)
        let upperLimit = try XCTUnwrap(limOp.upperLimit)
        XCTAssertGreaterThan(upperLimit.position.y, 0,
                            "Superscript should be above baseline")

        // Verify no double scripting
        XCTAssertFalse(limOp.hasScript,
                      "Limit operator should not have separate scripts")
    }

    func testLimBothLimits_ProperPositioning() throws {
        // Test operator with both subscript and superscript
        // Create manually since we don't have a standard operator with both
        guard let font = self.font else {
            XCTFail("Font should be initialized")
            return
        }

        let mathList = MTMathList()
        let op = try XCTUnwrap(MTMathAtomFactory.atom(forLatexSymbol: "lim"))

        // Add subscript
        op.subScript = MTMathList()
        op.subScript?.add(MTMathAtomFactory.atom(forCharacter: "x"))

        // Add superscript
        op.superScript = MTMathList()
        op.superScript?.add(MTMathAtomFactory.atom(forCharacter: "y"))

        mathList.add(op)

        let display = try XCTUnwrap(MTTypesetter.createLineForMathList(mathList, font: font, style: .text))

        // Find the limit operator display
        var limitsDisplay: MTLargeOpLimitsDisplay?
        for subDisplay in display.subDisplays {
            if let limitOp = subDisplay as? MTLargeOpLimitsDisplay {
                limitsDisplay = limitOp
                break
            }
        }

        let limOp = try XCTUnwrap(limitsDisplay)

        // Verify both limits exist
        XCTAssertNotNil(limOp.lowerLimit, "Should have lower limit")
        XCTAssertNotNil(limOp.upperLimit, "Should have upper limit")

        // Verify positioning
        let lowerLimit = try XCTUnwrap(limOp.lowerLimit)
        let upperLimit = try XCTUnwrap(limOp.upperLimit)

        XCTAssertLessThan(lowerLimit.position.y, 0, "Lower limit should be below")
        XCTAssertGreaterThan(upperLimit.position.y, 0, "Upper limit should be above")

        // Verify no double scripting
        XCTAssertFalse(limOp.hasScript, "Should not have separate scripts")
    }

    // MARK: - Integral Size Tests

    func testIntegral_DisplayModeSize() throws {
        // Regression test: Integrals in display mode should be enlarged (~2.2 em)
        // Bug: Integrals were too small, not using larger variants
        guard let font = self.font else {
            XCTFail("Font should be initialized")
            return
        }

        let latex = "\\int f(x) dx"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let display = try XCTUnwrap(MTTypesetter.createLineForMathList(mathList, font: font, style: .display))

        // Find the integral glyph
        var integralGlyph: MTGlyphDisplay?
        for subDisplay in display.subDisplays {
            if let glyph = subDisplay as? MTGlyphDisplay {
                // Check if this looks like an integral (tall glyph)
                if glyph.ascent + glyph.descent > font.fontSize * 1.5 {
                    integralGlyph = glyph
                    break
                }
            }
        }

        let integral = try XCTUnwrap(integralGlyph, "Should find integral glyph")

        // In display mode, integral should be significantly taller than base font
        // Expected: ~2.2 em = 2.2 * fontSize
        let totalHeight = integral.ascent + integral.descent

        XCTAssertGreaterThan(totalHeight, font.fontSize * 1.8,
                            "Display mode integral should be tall (using larger variant)")
        XCTAssertLessThan(totalHeight, font.fontSize * 2.6,
                         "Display mode integral should not be excessively tall")

        // Verify it's noticeably taller than surrounding content
        // f(x) should be approximately font size height
        XCTAssertGreaterThan(totalHeight, font.fontSize * 1.5,
                            "Integral should be taller than surrounding text")
    }

    func testIntegral_TextModeSize() throws {
        // Regression test: Integrals in text mode should be taller than surrounding text
        // Bug: Integrals in inline mode were not higher than f(x)
        let baseFontSize: CGFloat = 20.0
        let testFont = try XCTUnwrap(MTFontManager.fontManager.termesFont(withSize: baseFontSize))

        let latex = "\\int f(x) dx"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let display = try XCTUnwrap(MTTypesetter.createLineForMathList(mathList, font: testFont, style: .text))

        // Find the integral glyph
        var integralGlyph: MTGlyphDisplay?
        for subDisplay in display.subDisplays {
            if let glyph = subDisplay as? MTGlyphDisplay {
                // Check if this looks like an integral (taller than typical text)
                // In text mode, integrals are moderately enlarged (not as much as display mode)
                if glyph.ascent + glyph.descent > baseFontSize * 1.0 {
                    integralGlyph = glyph
                    break
                }
            }
        }

        let integral = try XCTUnwrap(integralGlyph, "Should find integral glyph")

        // In text mode, integral should still be taller than base font
        // Expected: at least 1.1x base font size (using incremental variant selection)
        let totalHeight = integral.ascent + integral.descent

        XCTAssertGreaterThan(totalHeight, baseFontSize * 1.1,
                            "Text mode integral should be taller than base font")

        // The integral should extend both above and below the baseline
        // to be visually taller than f(x)
        XCTAssertGreaterThan(integral.ascent, baseFontSize * 0.6,
                            "Integral should extend above baseline")
        XCTAssertGreaterThan(integral.descent, baseFontSize * 0.3,
                            "Integral should extend below baseline")
    }

    func testIntegral_WithScripts() throws {
        // Test that integral with scripts (bounds) renders correctly
        guard let font = self.font else {
            XCTFail("Font should be initialized")
            return
        }

        let latex = "\\int_0^1 f(x) dx"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let display = try XCTUnwrap(MTTypesetter.createLineForMathList(mathList, font: font, style: .display))

        // Integral with scripts should have reasonable dimensions
        XCTAssertGreaterThan(display.ascent, font.fontSize,
                            "Should have significant ascent for integral + superscript")
        XCTAssertGreaterThan(display.descent, font.fontSize * 0.3,
                            "Should have descent for integral + subscript")
    }

    func testMultipleIntegrals_ConsistentSizing() throws {
        // Test that multiple integrals maintain consistent sizing
        guard let font = self.font else {
            XCTFail("Font should be initialized")
            return
        }

        let latex = "\\int\\int\\int f(x,y,z) dx dy dz"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let display = try XCTUnwrap(MTTypesetter.createLineForMathList(mathList, font: font, style: .display))

        // Find all integral glyphs
        var integralGlyphs: [MTGlyphDisplay] = []
        for subDisplay in display.subDisplays {
            if let glyph = subDisplay as? MTGlyphDisplay {
                if glyph.ascent + glyph.descent > font.fontSize * 1.5 {
                    integralGlyphs.append(glyph)
                }
            }
        }

        XCTAssertGreaterThanOrEqual(integralGlyphs.count, 3, "Should have at least 3 integrals")

        // All integrals should have similar height
        if integralGlyphs.count >= 2 {
            let firstHeight = integralGlyphs[0].ascent + integralGlyphs[0].descent
            for integral in integralGlyphs {
                let height = integral.ascent + integral.descent
                XCTAssertEqual(height, firstHeight, accuracy: 1.0,
                              "All integrals should have consistent sizing")
            }
        }
    }

    func testOtherIntegralSymbols_SameBehavior() throws {
        // Test other integral variants (oint, iint, etc.)
        guard let font = self.font else {
            XCTFail("Font should be initialized")
            return
        }

        let operators = ["oint", "iint", "iiint"]

        for op in operators {
            let latex = "\\\(op) f(x) dx"
            let mathList = MTMathListBuilder.build(fromString: latex)
            XCTAssertNotNil(mathList, "Should parse \\\(op)")

            let display = try XCTUnwrap(MTTypesetter.createLineForMathList(mathList, font: font, style: .display))

            // Find the integral glyph
            var foundLargeIntegral = false
            for subDisplay in display.subDisplays {
                if let glyph = subDisplay as? MTGlyphDisplay {
                    let totalHeight = glyph.ascent + glyph.descent
                    if totalHeight > font.fontSize * 1.5 {
                        foundLargeIntegral = true

                        // Verify it's tall like regular integral
                        XCTAssertGreaterThan(totalHeight, font.fontSize * 1.8,
                                            "\\\(op) should be tall in display mode")
                        break
                    }
                }
            }

            XCTAssertTrue(foundLargeIntegral, "\\\(op) should render as large integral")
        }
    }

    // MARK: - Combined Tests

    func testComplexExpression_LimitAndIntegral() throws {
        // Test complex expression with both limit operator and integral
        guard let font = self.font else {
            XCTFail("Font should be initialized")
            return
        }

        let latex = "\\lim_{x\\to\\infty}\\int_0^x f(t) dt"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let display = try XCTUnwrap(MTTypesetter.createLineForMathList(mathList, font: font, style: .text))

        // Should have both limit operator and integral
        var hasLimitOperator = false
        var hasLargeIntegral = false

        for subDisplay in display.subDisplays {
            if subDisplay is MTLargeOpLimitsDisplay {
                hasLimitOperator = true
            }
            if let glyph = subDisplay as? MTGlyphDisplay {
                if glyph.ascent + glyph.descent > font.fontSize * 1.2 {
                    hasLargeIntegral = true
                }
            }
        }

        XCTAssertTrue(hasLimitOperator, "Should have limit operator display")
        XCTAssertTrue(hasLargeIntegral, "Should have enlarged integral")
    }

    func testRealWorldExpression_NoRegressions() throws {
        // Real-world expression combining limits, integrals, and fractions
        guard let font = self.font else {
            XCTFail("Font should be initialized")
            return
        }

        let latex = "\\lim_{n\\to\\infty}\\sum_{i=1}^{n}\\frac{1}{n}\\int_0^1 f(x) dx"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse complex LaTeX")

        let display = try XCTUnwrap(MTTypesetter.createLineForMathList(mathList, font: font, style: .text))

        // Should render without errors
        XCTAssertGreaterThan(display.width, 0, "Should have positive width")
        XCTAssertGreaterThan(display.ascent, 0, "Should have positive ascent")

        // Should have limit operator displays
        var limitOperatorCount = 0
        for subDisplay in display.subDisplays {
            if subDisplay is MTLargeOpLimitsDisplay {
                limitOperatorCount += 1
            }
        }

        XCTAssertGreaterThanOrEqual(limitOperatorCount, 1,
                                   "Should have at least one limit operator (lim or sum)")
    }
}
