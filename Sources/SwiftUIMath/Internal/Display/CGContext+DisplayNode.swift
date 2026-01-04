import CoreGraphics
import CoreText
import Foundation

extension CGContext {
  func draw(_ displayNode: Math.DisplayNode, foregroundColor: CGColor) {
    let foregroundColor =
      displayNode.localTextColor?.cgColor
      ?? displayNode.textColor?.cgColor
      ?? foregroundColor

    switch displayNode {
    case let list as Math.DisplayList:
      draw(list, foregroundColor: foregroundColor)
    case let textRun as Math.DisplayTextRun:
      draw(textRun, foregroundColor: foregroundColor)
    case let glyph as Math.DisplayGlyph:
      draw(glyph, foregroundColor: foregroundColor)
    case let glyphRun as Math.DisplayGlyphRun:
      draw(glyphRun, foregroundColor: foregroundColor)
    case let fraction as Math.DisplayFraction:
      draw(fraction, foregroundColor: foregroundColor)
    case let radical as Math.DisplayRadical:
      draw(radical, foregroundColor: foregroundColor)
    case let line as Math.DisplayLine:
      draw(line, foregroundColor: foregroundColor)
    case let largeOperator as Math.DisplayLargeOperator:
      draw(largeOperator, foregroundColor: foregroundColor)
    case let accent as Math.DisplayAccent:
      draw(accent, foregroundColor: foregroundColor)
    default:
      break
    }
  }
}

extension CGContext {
  private func draw(_ list: Math.DisplayList, foregroundColor: CGColor) {
    saveGState()

    translateBy(x: list.position.x, y: list.position.y)
    textPosition = .zero

    for child in list.children {
      draw(child, foregroundColor: foregroundColor)
    }

    restoreGState()
  }

  private func draw(_ textRun: Math.DisplayTextRun, foregroundColor: CGColor) {
    let line = CTLineCreateWithAttributedString(textRun.attributedString)

    saveGState()
    setFillColor(foregroundColor)
    textPosition = textRun.position
    CTLineDraw(line, self)
    restoreGState()
  }

  private func draw(_ glyph: Math.DisplayGlyph, foregroundColor: CGColor) {
    guard let platformFont = Math.PlatformFont(font: glyph.font) else {
      return
    }

    saveGState()

    translateBy(x: glyph.position.x, y: glyph.position.y - glyph.shiftDown)
    textPosition = .zero

    setFillColor(foregroundColor)

    var cgGlyph = CGGlyph(glyph.glyph)
    var pos = CGPoint.zero
    CTFontDrawGlyphs(platformFont.ctFont, &cgGlyph, &pos, 1, self)

    restoreGState()
  }

  private func draw(_ glyphRun: Math.DisplayGlyphRun, foregroundColor: CGColor) {
    guard let platformFont = Math.PlatformFont(font: glyphRun.font) else {
      return
    }

    saveGState()

    translateBy(x: glyphRun.position.x, y: glyphRun.position.y - glyphRun.shiftDown)
    textPosition = .zero

    setFillColor(foregroundColor)

    var glyphs = glyphRun.glyphs.map { CGGlyph($0) }
    var positions = glyphRun.offsets.map { CGPoint(x: 0, y: $0) }
    CTFontDrawGlyphs(platformFont.ctFont, &glyphs, &positions, glyphs.count, self)

    restoreGState()
  }

  private func draw(_ fraction: Math.DisplayFraction, foregroundColor: CGColor) {
    if let numerator = fraction.numerator {
      draw(numerator, foregroundColor: foregroundColor)
    }
    if let denominator = fraction.denominator {
      draw(denominator, foregroundColor: foregroundColor)
    }

    guard fraction.lineThickness > 0 else {
      return
    }

    saveGState()

    setStrokeColor(foregroundColor)
    setLineWidth(fraction.lineThickness)

    let lineStart = CGPoint(
      x: fraction.position.x,
      y: fraction.position.y + fraction.linePosition
    )
    let lineEnd = CGPoint(
      x: fraction.position.x + fraction.width,
      y: lineStart.y
    )

    move(to: lineStart)
    addLine(to: lineEnd)
    strokePath()

    restoreGState()
  }

  private func draw(_ radical: Math.DisplayRadical, foregroundColor: CGColor) {
    if let radicand = radical.radicand {
      draw(radicand, foregroundColor: foregroundColor)
    }
    if let degree = radical.degree {
      draw(degree, foregroundColor: foregroundColor)
    }

    saveGState()

    setStrokeColor(foregroundColor)
    setFillColor(foregroundColor)

    translateBy(x: radical.position.x + radical.radicalShift, y: radical.position.y)
    textPosition = .zero

    if let radicalGlyph = radical.radicalGlyph {
      draw(radicalGlyph, foregroundColor: foregroundColor)
    }

    let heightFromTop = radical.topKern
    let glyphWidth = radical.radicalGlyph?.width ?? 0
    let radicandWidth = radical.radicand?.width ?? 0
    let lineStart = CGPoint(
      x: glyphWidth,
      y: radical.ascent - heightFromTop - radical.lineThickness / 2
    )
    let lineEnd = CGPoint(x: lineStart.x + radicandWidth, y: lineStart.y)

    setLineWidth(radical.lineThickness)
    setLineCap(.round)
    move(to: lineStart)
    addLine(to: lineEnd)
    strokePath()

    restoreGState()
  }

  private func draw(_ line: Math.DisplayLine, foregroundColor: CGColor) {
    if let inner = line.inner {
      draw(inner, foregroundColor: foregroundColor)
    }

    saveGState()

    setStrokeColor(foregroundColor)
    setLineWidth(line.lineThickness)

    let lineStart = CGPoint(x: line.position.x, y: line.position.y + line.lineShiftUp)
    let lineEnd = CGPoint(x: lineStart.x + (line.inner?.width ?? 0), y: lineStart.y)

    move(to: lineStart)
    addLine(to: lineEnd)
    strokePath()

    restoreGState()
  }

  private func draw(_ largeOperator: Math.DisplayLargeOperator, foregroundColor: CGColor) {
    if let upperLimit = largeOperator.upperLimit {
      draw(upperLimit, foregroundColor: foregroundColor)
    }
    if let lowerLimit = largeOperator.lowerLimit {
      draw(lowerLimit, foregroundColor: foregroundColor)
    }
    if let nucleus = largeOperator.nucleus {
      draw(nucleus, foregroundColor: foregroundColor)
    }
  }

  private func draw(_ accent: Math.DisplayAccent, foregroundColor: CGColor) {
    if let accentee = accent.accentee {
      draw(accentee, foregroundColor: foregroundColor)
    }

    guard let accentGlyph = accent.accent else {
      return
    }

    saveGState()

    translateBy(x: accent.position.x, y: accent.position.y)
    textPosition = .zero
    draw(accentGlyph, foregroundColor: foregroundColor)

    restoreGState()
  }
}
