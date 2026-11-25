//
//  MTLineFitter.swift
//  SwiftMath
//
//  Created by Claude Code on 2025-12-16.
//  This software may be modified and distributed under the terms of the
//  MIT license. See the LICENSE file for details.
//

import Foundation
import CoreGraphics

/// Fits breakable elements into lines respecting width constraints and break rules
class MTLineFitter {

    // MARK: - Properties

    let maxWidth: CGFloat
    let margin: CGFloat
    /// Space the display generator puts after a group with scripts
    let spaceAfterScript: CGFloat

    // MARK: - Initialization

    init(maxWidth: CGFloat, margin: CGFloat = 0, spaceAfterScript: CGFloat = 0) {
        self.maxWidth = maxWidth
        self.margin = margin
        self.spaceAfterScript = spaceAfterScript
    }

    // MARK: - Line Fitting

    /// Fit elements into lines using greedy algorithm with backtracking
    func fitLines(_ elements: [MTBreakableElement]) -> [[MTBreakableElement]] {
        guard !elements.isEmpty else { return [] }
        guard maxWidth > 0 else { return [elements] }  // No width constraint



        var lines: [[MTBreakableElement]] = [[]]
        var currentWidth: CGFloat = 0
        var i = 0

        while i < elements.count {
            let element = elements[i]


            // Handle grouped elements (base + scripts)
            if let groupId = element.groupId {
                let (groupElements, nextIndex) = collectGroup(elements, startIndex: i, groupId: groupId)

                // Calculate group width correctly for scripts
                // Scripts overlap vertically, so width = max(script widths), not sum
                let (groupWidth, trailingSpace) = calculateGroupWidth(groupElements)

                // Check if group fits on current line
                // The space after the scripts may end up past the end of the line: it draws nothing
                if !lines.last!.isEmpty && currentWidth + groupWidth - trailingSpace > maxWidth - margin {
                    // Group doesn't fit - check if first element of group can start a new line
                    if groupElements.first?.isBreakBefore ?? true {
                        // Can start new line
                        lines.append([])
                        currentWidth = 0
                    } else {
                        // Cannot start new line - keep with previous line (allow overflow)
                        // This handles cases like punctuation after base+script groups
                    }
                }

                // Add entire group to current line
                lines[lines.count - 1].append(contentsOf: groupElements)
                currentWidth += groupWidth
                i = nextIndex
                continue
            }

            // Check if element fits on current line
            if !lines.last!.isEmpty && currentWidth + element.width > maxWidth - margin {
                // Element doesn't fit - find best break point in current line
                if let breakIndex = findBestBreak(in: lines[lines.count - 1]) {
                    // Found a break point - move elements from breakIndex onward to next line
                    let moveElements = Array(lines[lines.count - 1][breakIndex...])
                    let oldLine = Array(lines[lines.count - 1][..<breakIndex])

                    // Verify the first element being moved can start a line
                    // (findBestBreak already ensures this, but double-check)
                    if moveElements.first?.isBreakBefore ?? true {
                        // Move elements to new line
                        lines[lines.count - 1] = oldLine
                        lines.append(moveElements)
                        currentWidth = moveElements.reduce(0) { $0 + $1.width }

                        // Now check if current element should go on new line or stay with old line
                        if !element.isBreakBefore {
                            // CRITICAL FIX: Current element cannot start a line, so it's part of the
                            // unbreakable sequence that was just moved to the new line.
                            // Add it to the NEW line, not the old line!
                            // Example: "matrices" breaks before 'm', so 'm','a','t','r','i' move to new line.
                            // When we process 'c', it can't start a line, so it must join the new line.
                            lines[lines.count - 1].append(element)
                            currentWidth += element.width
                            i += 1
                            continue
                        } else {
                        }
                        // Current element can start a line, will be added to new line below
                    } else {
                        // Should not happen if findBestBreak is correct, but handle gracefully
                        // Keep elements on current line (allow overflow)
                        lines[lines.count - 1].append(contentsOf: moveElements)
                        currentWidth += moveElements.reduce(0) { $0 + $1.width }
                    }
                } else {
                    // No good break point found
                    // Check if current element can start a new line
                    if element.isBreakBefore {
                        // Element can start new line
                        lines.append([])
                        currentWidth = 0
                    } else {
                        // Element cannot start a new line (e.g., closing punctuation)
                        // Keep it on current line even if it causes overflow
                        // This respects punctuation rules over width constraints
                        lines[lines.count - 1].append(element)
                        currentWidth += element.width
                        i += 1
                        continue
                    }
                }
            }

            // Add element to current line (may overflow if indivisible and too wide)
            lines[lines.count - 1].append(element)
            currentWidth += element.width
            i += 1
        }

        let finalLines = lines.filter { !$0.isEmpty }


        return finalLines
    }

    // MARK: - Helper Methods

    /// Calculate the correct width for a group of elements (e.g., base + scripts), and the space
    /// after its scripts that this width includes. Scripts overlap vertically, so the group width is
    /// not the sum of all widths: like the display generator, count the base, the wider script and
    /// the space after the scripts. (Summing both scripts made x_1^2 look wider than it is, so a
    /// formula laid out at its own width, as a label sized to fit is, broke into two lines.)
    private func calculateGroupWidth(_ groupElements: [MTBreakableElement]) -> (width: CGFloat, trailingSpace: CGFloat) {
        var base: CGFloat = 0
        var script: CGFloat?
        for element in groupElements {
            if case .script = element.content {
                script = max(script ?? 0, element.width)
            } else {
                base += element.width
            }
        }
        guard let script else { return (base, 0) }
        return (base + script + spaceAfterScript, spaceAfterScript)
    }

    /// Collect all elements that share the same groupId
    private func collectGroup(_ elements: [MTBreakableElement], startIndex: Int, groupId: UUID) -> ([MTBreakableElement], Int) {
        var groupElements: [MTBreakableElement] = []
        var index = startIndex

        while index < elements.count && elements[index].groupId == groupId {
            groupElements.append(elements[index])
            index += 1
        }

        return (groupElements, index)
    }

    /// Find the best break point in a line
    /// Returns the index where the break should occur (elements from this index move to next line)
    private func findBestBreak(in line: [MTBreakableElement]) -> Int? {
        var bestIndex: Int? = nil
        var lowestPenalty = Int.max


        // Scan from right to left to prefer breaking later in the line
        // Note: Skip the last element (idx == line.count - 1) because breaking after it
        // would move 0 elements to the next line, which is pointless
        for (idx, element) in line.enumerated().reversed() {
            // Skip the last element - we need to move at least 1 element to the next line
            if idx >= line.count - 1 {
                continue
            }

            // Can we break after this element?
            let canBreakAfter = element.isBreakAfter
            let penaltyAfter = element.penaltyAfter

            // Check if next element (which would move to new line) allows breaking before it
            let canBreakBeforeNext = line[idx + 1].isBreakBefore
            let penaltyBeforeNext = line[idx + 1].penaltyBefore

            // We can break here only if BOTH:
            // 1. Current element allows breaking after it
            // 2. Next element allows breaking before it
            if canBreakAfter && canBreakBeforeNext {
                let totalPenalty = max(penaltyAfter, penaltyBeforeNext)
                if totalPenalty < lowestPenalty {
                    bestIndex = idx + 1
                    lowestPenalty = totalPenalty
                }
            }
        }


        // Only return if we found an acceptable break point
        if let index = bestIndex, lowestPenalty <= MTBreakPenalty.bad {
            return index
        }

        return nil
    }

    /// Check if a line width exceeds the maximum
    private func exceedsMaxWidth(_ width: CGFloat) -> Bool {
        return width > maxWidth - margin
    }
}
