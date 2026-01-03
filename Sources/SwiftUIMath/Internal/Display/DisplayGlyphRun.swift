import CoreGraphics
import Foundation

extension Math {
  final class DisplayGlyphRun: DisplayShiftedNode {
    var glyphs: [UInt16]
    var offsets: [CGFloat]
    var font: Math.Font

    init(glyphs: [UInt16], offsets: [CGFloat], font: Math.Font) {
      self.glyphs = glyphs
      self.offsets = offsets
      self.font = font
      super.init()
      self.position = .zero
    }

    override var ascent: CGFloat {
      get { super.ascent - shiftDown }
      set { super.ascent = newValue }
    }

    override var descent: CGFloat {
      get { super.descent + shiftDown }
      set { super.descent = newValue }
    }
  }
}
