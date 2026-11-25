//
//  MTElementWidthCalculator.swift
//  SwiftMath
//
//  Created by Claude Code on 2025-12-16.
//  This software may be modified and distributed under the terms of the
//  MIT license. See the LICENSE file for details.
//

import Foundation
import CoreText
import CoreGraphics

/// Calculates widths for breakable elements with appropriate spacing
class MTElementWidthCalculator {

    // MARK: - Properties

    let font: MTFont
    let style: MTLineStyle

    // MARK: - Initialization

    init(font: MTFont, style: MTLineStyle) {
        self.font = font
        self.style = style
    }

    // MARK: - Text Width Measurement

    /// Measure width of simple text
    func measureText(_ text: String) -> CGFloat {
        guard !text.isEmpty else { return 0 }

        let attrString = NSAttributedString(string: text, attributes: [
            kCTFontAttributeName as NSAttributedString.Key: font.ctFont as Any
        ])
        let line = CTLineCreateWithAttributedString(attrString as CFAttributedString)
        return CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
    }

    // MARK: - Display Width Measurement

    /// Measure width of a pre-rendered display
    func measureDisplay(_ display: MTDisplay) -> CGFloat {
        return display.width
    }

    // MARK: - Space Width Measurement

    /// Get width of an explicit spacing command from its amount in mu (1/18 em of the current
    /// style's font): \, = 3mu, \: = 4mu, \; = 5mu, \! = -3mu, \quad = 18mu, \qquad = 36mu.
    func measureSpace(_ space: CGFloat) -> CGFloat {
        guard let mathTable = font.mathTable else { return 0 }
        return space * mathTable.muUnit
    }

    /// Measure explicit space value
    func measureExplicitSpace(_ width: CGFloat) -> CGFloat {
        return width
    }

    // MARK: - Inter-element Spacing

    /// Get inter-element spacing between two atom types
    func getInterElementSpacing(left: MTMathAtomType, right: MTMathAtomType) -> CGFloat {
        let leftIndex = getInterElementSpaceArrayIndexForType(left, row: true)
        let rightIndex = getInterElementSpaceArrayIndexForType(right, row: false)
        let spaceArray = getInterElementSpaces()[Int(leftIndex)]
        let spaceType = spaceArray[Int(rightIndex)]

        guard spaceType != .invalid else {
            // Should not happen in well-formed math
            return 0
        }

        let spaceMultiplier = getSpacingInMu(spaceType)
        if spaceMultiplier > 0, let mathTable = font.mathTable {
            return CGFloat(spaceMultiplier) * mathTable.muUnit
        }
        return 0
    }

    /// Get spacing multiplier in mu units
    private func getSpacingInMu(_ spaceType: InterElementSpaceType) -> Int {
        switch style {
        case .display, .text:
            switch spaceType {
            case .none, .invalid:
                return 0
            case .thin:
                return 3
            case .nsThin, .nsMedium, .nsThick:
                // ns = non-script, same as regular in display/text mode
                switch spaceType {
                case .nsThin:  return 3
                case .nsMedium: return 4
                case .nsThick:  return 5
                default: return 0
                }
            }

        case .script, .scriptOfScript:
            switch spaceType {
            case .none, .invalid:
                return 0
            case .thin:
                return 3
            case .nsThin, .nsMedium, .nsThick:
                // In script mode, ns types don't add space
                return 0
            }
        }
    }
}
