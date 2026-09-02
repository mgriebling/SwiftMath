//
//  MTTypesetter+Tokenization.swift
//  SwiftMath
//
//  Created by Claude Code on 2025-12-16.
//  This software may be modified and distributed under the terms of the
//  MIT license. See the LICENSE file for details.
//

import Foundation
import CoreGraphics

extension MTTypesetter {

    /// Create a line for a math list using the new tokenization approach
    /// This is an alternative to the existing createLineForMathList that uses
    /// pre-tokenization and greedy line fitting
    static func createLineForMathListWithTokenization(
        _ mathList: MTMathList?,
        font: MTFont?,
        style: MTLineStyle,
        cramped: Bool,
        spaced: Bool,
        maxWidth: CGFloat
    ) -> MTMathListDisplay? {
        guard let mathList = mathList else { return nil }
        guard let font = font else { return nil }
        guard !mathList.atoms.isEmpty else {
            // Return empty display instead of nil (matches KaTeX behavior)
            return MTMathListDisplay(withDisplays: [], range: NSMakeRange(0, 0))
        }

        // Phase 0: Preprocess atoms to fuse ordinary characters
        // This is critical for accents and other structures where multi-character
        // text like "xyzw" should stay together as a single atom
        //
        // INVARIANT: typesetting never changes its input.
        // `preprocessMathList` mutates the atoms it is handed (it rewrites `type`
        // and `nucleus`, and `MTMathAtom.fuse(with:)` appends the next atom's
        // nucleus onto the previous atom). Every internal typeset request funnels
        // through this function, and several of them typeset the same list more
        // than once (delimiter measurement, accent re-layout), so preprocessing
        // the caller's atoms made typesetting non-idempotent: pass 1 fused
        // "3","y" into "3y", pass 2 fused "3y","y" into "3yy" (issue #66).
        // Preprocess a deep copy instead. `MTMathAtom.copy()` is the
        // type-dispatched deep copy (sublists included); `finalized` is
        // deliberately not used here because it re-applies TeX rules 5 & 6.
        let atomsToPreprocess = MTMathList()
        atomsToPreprocess.atoms = mathList.atoms.map { $0.copy() }
        let preprocessedAtoms = MTTypesetter.preprocessMathList(atomsToPreprocess)

        // Phase 1: Tokenize atoms into breakable elements
        let tokenizer = MTAtomTokenizer(font: font, style: style, cramped: cramped, maxWidth: maxWidth)
        let elements = tokenizer.tokenize(preprocessedAtoms)

        guard !elements.isEmpty else { return nil }

        // Phase 2: Fit elements into lines
        let margin = spaced ? font.mathTable?.muUnit ?? 0 : 0
        let fitter = MTLineFitter(maxWidth: maxWidth, margin: margin)
        let fittedLines = fitter.fitLines(elements)

        // Phase 3: Generate displays from fitted lines
        let generator = MTDisplayGenerator(font: font, style: style)
        let displays = generator.generateDisplays(from: fittedLines, startPosition: CGPoint.zero)

        // Determine range from atoms
        let range: NSRange
        if let firstAtom = mathList.atoms.first, let lastAtom = mathList.atoms.last {
            let start = firstAtom.indexRange.location
            let end = NSMaxRange(lastAtom.indexRange)
            range = NSMakeRange(start, end - start)
        } else {
            range = NSMakeRange(0, 0)
        }

        // Create and return the math list display
        let mathListDisplay = MTMathListDisplay(withDisplays: displays, range: range)

        return mathListDisplay
    }
}
