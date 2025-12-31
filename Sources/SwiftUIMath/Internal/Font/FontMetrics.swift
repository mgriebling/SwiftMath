@preconcurrency import CoreGraphics
@preconcurrency import CoreText
import Foundation

extension Math {
  struct FontMetrics: Sendable {
    struct GlyphPart: Sendable {
      let glyph: CGGlyph
      let fullAdvance: CGFloat
      let startConnectorLength: CGFloat
      let endConnectorLength: CGFloat
      let isExtender: Bool
    }

    var mathUnit: CGFloat {
      font.size / 18
    }

    private let font: Font
    private let unitsPerEm: UInt
    private let table: Table

    init(font: Font, unitsPerEm: UInt, table: Table) {
      self.font = font
      self.unitsPerEm = unitsPerEm
      self.table = table
    }

    func verticalVariants(forGlyph glyph: CGGlyph) -> [CGGlyph] {
      guard
        let graphicsFont = FontRegistry.shared.graphicsFont(named: font.name),
        let glyphName = graphicsFont.name(for: glyph) as String?,
        let variantGlyphs = table.vVariants[glyphName]
      else {
        return [glyph]
      }

      return variantGlyphs.map {
        graphicsFont.getGlyphWithGlyphName(name: $0 as CFString)
      }
    }

    func horizontalVariants(forGlyph glyph: CGGlyph) -> [CGGlyph] {
      guard
        let graphicsFont = FontRegistry.shared.graphicsFont(named: font.name),
        let glyphName = graphicsFont.name(for: glyph) as String?,
        let variantGlyphs = table.hVariants[glyphName]
      else {
        return [glyph]
      }

      return variantGlyphs.map {
        graphicsFont.getGlyphWithGlyphName(name: $0 as CFString)
      }
    }

    func largerGlyph(forGlyph glyph: CGGlyph) -> CGGlyph {
      guard
        let graphicsFont = FontRegistry.shared.graphicsFont(named: font.name),
        let glyphName = graphicsFont.name(for: glyph) as String?,
        let variantGlyphs = table.vVariants[glyphName]
      else {
        return glyph
      }

      return
        variantGlyphs
        .first { $0 != glyphName }
        .map {
          graphicsFont.getGlyphWithGlyphName(name: $0 as CFString)
        } ?? glyph
    }

    func italicCorrection(forGlyph glyph: CGGlyph) -> CGFloat {
      guard
        let graphicsFont = FontRegistry.shared.graphicsFont(named: font.name),
        let glyphName = graphicsFont.name(for: glyph) as String?,
        let value = table.italic[glyphName]
      else {
        return 0
      }

      return unitsToPoints(value)
    }

    func topAccentAdjustment(forGlyph glyph: CGGlyph) -> CGFloat {
      guard
        let graphicsFont = FontRegistry.shared.graphicsFont(named: font.name),
        let glyphName = graphicsFont.name(for: glyph) as String?,
        let value = table.accents[glyphName]
      else {
        // If no top accent is defined then it is the center of the advance width
        return advance(forGlyph: glyph).width / 2
      }

      return unitsToPoints(value)
    }

    func verticalAssembly(forGlyph glyph: CGGlyph) -> [GlyphPart] {
      guard
        let graphicsFont = FontRegistry.shared.graphicsFont(named: font.name),
        let glyphName = graphicsFont.name(for: glyph) as String?,
        let assembly = table.vAssembly[glyphName]
      else {
        return []
      }

      return assembly.parts.map { part in
        GlyphPart(
          glyph: graphicsFont.getGlyphWithGlyphName(name: part.glyph as CFString),
          fullAdvance: unitsToPoints(part.advance),
          startConnectorLength: unitsToPoints(part.startConnector),
          endConnectorLength: unitsToPoints(part.endConnector),
          isExtender: part.extender
        )
      }
    }
  }
}

// MARK: - Fractions

extension Math.FontMetrics {
  var fractionNumeratorDisplayStyleShiftUp: CGFloat {
    constant(named: "FractionNumeratorDisplayStyleShiftUp")
  }

  var fractionNumeratorShiftUp: CGFloat {
    constant(named: "FractionNumeratorShiftUp")
  }

  var fractionDenominatorDisplayStyleShiftDown: CGFloat {
    constant(named: "FractionDenominatorDisplayStyleShiftDown")
  }

  var fractionDenominatorShiftDown: CGFloat {
    constant(named: "FractionDenominatorShiftDown")
  }

  var fractionNumeratorDisplayStyleGapMin: CGFloat {
    constant(named: "FractionNumDisplayStyleGapMin")
  }

  var fractionNumeratorGapMin: CGFloat {
    constant(named: "FractionNumeratorGapMin")
  }

  var fractionDenominatorDisplayStyleGapMin: CGFloat {
    constant(named: "FractionDenomDisplayStyleGapMin")
  }

  var fractionDenominatorGapMin: CGFloat {
    constant(named: "FractionDenominatorGapMin")
  }

  var fractionRuleThickness: CGFloat {
    constant(named: "FractionRuleThickness")
  }

  var fractionDelimiterSize: CGFloat {
    1.01 * font.size
  }

  var fractionDelimiterDisplayStyleSize: CGFloat {
    2.39 * font.size
  }
}

// MARK: - Stacks

extension Math.FontMetrics {
  var skewedFractionHorizonalGap: CGFloat {
    constant(named: "SkewedFractionHorizontalGap")
  }

  var skewedFractionVerticalGap: CGFloat {
    constant(named: "SkewedFractionVerticalGap")
  }

  var stackTopDisplayStyleShiftUp: CGFloat {
    constant(named: "StackTopDisplayStyleShiftUp")
  }

  var stackTopShiftUp: CGFloat {
    constant(named: "StackTopShiftUp")
  }

  var stackDisplayStyleGapMin: CGFloat {
    constant(named: "StackDisplayStyleGapMin")
  }

  var stackGapMin: CGFloat {
    constant(named: "StackGapMin")
  }

  var stackBottomDisplayStyleShiftDown: CGFloat {
    constant(named: "StackBottomDisplayStyleShiftDown")
  }

  var stackBottomShiftDown: CGFloat {
    constant(named: "StackBottomShiftDown")
  }
}

// MARK: - Superscripts / Subscripts

extension Math.FontMetrics {
  var superscriptShiftUp: CGFloat {
    constant(named: "SuperscriptShiftUp")
  }

  var superscriptShiftUpCramped: CGFloat {
    constant(named: "SuperscriptShiftUpCramped")
  }

  var subscriptShiftDown: CGFloat {
    constant(named: "SubscriptShiftDown")
  }

  var superscriptBaselineDropMax: CGFloat {
    constant(named: "SuperscriptBaselineDropMax")
  }

  var subscriptBaselineDropMin: CGFloat {
    constant(named: "SubscriptBaselineDropMin")
  }

  var superscriptBottomMin: CGFloat {
    constant(named: "SuperscriptBottomMin")
  }

  var subscriptTopMax: CGFloat {
    constant(named: "SubscriptTopMax")
  }

  var subSuperscriptGapMin: CGFloat {
    constant(named: "SubSuperscriptGapMin")
  }

  var superscriptBottomMaxWithSubscript: CGFloat {
    constant(named: "SuperscriptBottomMaxWithSubscript")
  }

  var spaceAfterScript: CGFloat {
    constant(named: "SpaceAfterScript")
  }
}

// MARK: - Radicals

extension Math.FontMetrics {
  var radicalExtraAscender: CGFloat {
    constant(named: "RadicalExtraAscender")
  }

  var radicalRuleThickness: CGFloat {
    constant(named: "RadicalRuleThickness")
  }

  var radicalDisplayStyleVerticalGap: CGFloat {
    constant(named: "RadicalDisplayStyleVerticalGap")
  }

  var radicalVerticalGap: CGFloat {
    constant(named: "RadicalVerticalGap")
  }

  var radicalKernBeforeDegree: CGFloat {
    constant(named: "RadicalKernBeforeDegree")
  }

  var radicalKernAfterDegree: CGFloat {
    constant(named: "RadicalKernAfterDegree")
  }

  var radicalDegreeBottomRaisePercent: CGFloat {
    constantPercent(named: "RadicalDegreeBottomRaisePercent")
  }
}

// MARK: - Limits

extension Math.FontMetrics {
  var upperLimitBaselineRiseMin: CGFloat {
    constant(named: "UpperLimitBaselineRiseMin")
  }

  var upperLimitGapMin: CGFloat {
    constant(named: "UpperLimitGapMin")
  }

  var lowerLimitGapMin: CGFloat {
    constant(named: "LowerLimitGapMin")
  }

  var lowerLimitBaselineDropMin: CGFloat {
    constant(named: "LowerLimitBaselineDropMin")
  }

  var limitExtraAscenderDescender: CGFloat {
    0
  }
}

// MARK: - Underline

extension Math.FontMetrics {
  var underbarVerticalGap: CGFloat {
    constant(named: "UnderbarVerticalGap")
  }

  var underbarRuleThickness: CGFloat {
    constant(named: "UnderbarRuleThickness")
  }

  var underbarExtraDescender: CGFloat {
    constant(named: "UnderbarExtraDescender")
  }
}

// MARK: - Overline

extension Math.FontMetrics {
  var overbarVerticalGap: CGFloat {
    constant(named: "OverbarVerticalGap")
  }

  var overbarRuleThickness: CGFloat {
    constant(named: "OverbarRuleThickness")
  }

  var overbarExtraAscender: CGFloat {
    constant(named: "OverbarExtraAscender")
  }
}

// MARK: - Constants

extension Math.FontMetrics {
  var axisHeight: CGFloat {
    constant(named: "AxisHeight")
  }

  var scriptScaleDown: CGFloat {
    constantPercent(named: "ScriptPercentScaleDown")
  }

  var scriptScriptScaleDown: CGFloat {
    constantPercent(named: "ScriptScriptPercentScaleDown")
  }

  var mathLeading: CGFloat {
    constant(named: "MathLeading")
  }

  var delimitedSubFormulaMinHeight: CGFloat {
    constant(named: "DelimitedSubFormulaMinHeight")
  }
}

// MARK: - Accent

extension Math.FontMetrics {
  var accentBaseHeight: CGFloat {
    constant(named: "AccentBaseHeight")
  }

  var flattenedAccentBaseHeight: CGFloat {
    constant(named: "FlattenedAccentBaseHeight")
  }
}

// MARK: - Glyph Construction

extension Math.FontMetrics {
  var minConnectorOverlap: CGFloat {
    constant(named: "MinConnectorOverlap")
  }
}

// MARK: - Private

extension Math.FontMetrics {
  private func constant(named name: String) -> CGFloat {
    guard let value = table.constants[name] else {
      return .zero
    }
    return unitsToPoints(value)
  }

  private func constantPercent(named name: String) -> CGFloat {
    guard let value = table.constants[name] else {
      return .zero
    }
    return CGFloat(value) / 100
  }

  private func unitsToPoints(_ units: Int) -> CGFloat {
    CGFloat(units) * font.size / CGFloat(unitsPerEm)
  }

  private func advance(forGlyph glyph: CGGlyph) -> CGSize {
    guard
      let font = Math.FontRegistry.shared.font(named: font.name, size: font.size)
    else {
      return .zero
    }

    var glyph = glyph
    var advance = CGSize.zero

    CTFontGetAdvancesForGlyphs(font, .horizontal, &glyph, &advance, 1)
    return advance
  }
}
