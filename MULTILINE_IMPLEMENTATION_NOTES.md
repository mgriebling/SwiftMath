# Multiline/Line Breaking Implementation Notes

## Overview

SwiftMath supports automatic line breaking (multiline display) for mathematical equations. This document provides technical details about the implementation, supported cases, limitations, and potential areas for improvement.

## Implementation Architecture

### Two-Tier Breaking System

#### 1. Interatom Line Breaking (Primary)
**Location**: `MTTypesetter.swift:845-846`

**Mechanism**:
- Checks **before** adding each atom to the current line
- Calculates projected width: `currentLineWidth + atomWidth + interElementSpacing`
- If projected width > maxWidth: flushes current line, moves down, starts new line
- Line spacing: `fontSize × 1.5`

**Applies to atom types**:
- `.ordinary` - Variables, text, regular symbols
- `.binaryOperator` - `+`, `-`, `×`, `÷`
- `.relation` - `=`, `<`, `>`, `≤`, `≥`
- `.open` - Opening brackets `(`
- `.close` - Closing brackets `)`
- `.placeholder` - Placeholder squares
- `.punctuation` - Commas, periods

**Advantages**:
- Clean semantic breaks between mathematical elements
- Respects TeX inter-element spacing rules
- Fast width calculations using Core Text
- Preserves mathematical structure

#### 2. Universal Line Breaking (Fallback)
**Location**: `MTTypesetter.swift:877-950`

**Mechanism**:
- Checks **after** adding atom (for simple atoms without scripts)
- Uses Core Text's `CTTypesetterSuggestLineBreak` for Unicode-aware breaking
- Protects numbers from splitting (3.14, 1,000, etc.)
- Supports multiple locales (EN, FR, CH)

**Applies when**:
- Atoms have no superscripts/subscripts
- Used for very long single text atoms
- Fallback for cases where interatom breaking doesn't apply

## Supported Cases

### Simple Equations
```swift
"a + b + c + d + e + f"
"x = 1, y = 2, z = 3"
"α + β + γ + δ"
```
Works: Breaks between operators and variables.

### Mixed Text and Math
```swift
"\\text{Calculate } Δ = b^{2} - 4ac \\text{ with } a=1"
```
Works: Breaks between text and math atoms naturally.

### Long Sequences
```swift
"1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10"
```
Works: Breaks between numbers and operators.

### Relational Expressions
```swift
"a < b, b > c, c ≤ d, d ≥ e"
```
Works: Breaks after punctuation and relations.

### Fractions
```swift
"a + \\frac{1}{2} + b + \\frac{3}{4} + c"
```
Works: Fractions stay inline when they fit within width constraint.

**Implementation**: Lines 701-721 in MTTypesetter.swift
- Creates fraction display first
- Checks if adding it would exceed maxWidth
- Only breaks to new line if necessary

### Radicals
```swift
"x + \\sqrt{2} + y + \\sqrt{3} + z"
```
Works: Radicals stay inline when they fit. Handles both simple radicals and those with degrees.

**Implementation**: Lines 677-705 in MTTypesetter.swift

### Large Operators
```swift
"a + \\sum x_i + \\int f(x)dx + b"
```
Works: Large operators (∑, ∫, ∏, lim) stay inline when they fit within width constraints.

**Implementation**: Lines 729-748 in MTTypesetter.swift
- Creates operator display first (including limits if present)
- Checks both width AND height (breaks if height > fontSize * 2.5)

### Delimited Expressions
```swift
"(a+b) + \\left(\\frac{c}{d}\\right) + e"
```
Works: Delimiters stay inline when they fit.

**Implementation**: Lines 750-776 in MTTypesetter.swift
- Passes maxWidth to inner content for proper wrapping

### Colored Expressions
```swift
"a + \\color{red}{b + c + d} + e"
```
Works: Colored sections stay inline when they fit.

**Implementation**: Lines 622-685 in MTTypesetter.swift

### Matrices/Tables
```swift
"A = \\begin{pmatrix} 1 & 2 \\end{pmatrix} + B"
```
Works: Small matrices stay inline when they fit within width constraints.

**Implementation**: Lines 899-916 in MTTypesetter.swift

### Atoms with Scripts
```swift
"a^{2} + b^{2} + c^{2} + d^{2}"
```
Works: Atoms with superscripts and subscripts participate in width-based breaking.

**Implementation**: Lines 1123-1137 in MTTypesetter.swift

## Limited Support Cases

### Very Long Text Atoms
```swift
"\\text{This is an extremely long piece of text within a single text command}"
```
Works: Uses Core Text's word boundary breaking with number protection.

**Limitation**: Breaks within the text atom, not between atoms.

## Remaining Issues and Edge Cases

### 1. No Look-Ahead Optimization
**Problem**: Greedy algorithm breaks immediately without considering slightly better break points nearby.

**Example**:
```swift
"abc + defgh"
// With narrow width might break: "abc +"
//                                 "defgh"
// Better might be:                "abc"
//                                 "+ defgh"
```

**Possible solution**: Implement k-atom look-ahead with break quality scoring.

### 2. Fixed Line Height
**Problem**: All lines use `fontSize × 1.5` regardless of content height.

**Example**: A line with a fraction is much taller than a line with just variables, but spacing is uniform.

**Possible solution**: Calculate actual line height based on ascent/descent of atoms on each line.

### 3. No Break Quality Scoring
**Problem**: All break points are treated equally - no preference for breaking after operators vs. before.

**Example**: Breaking after `+` is generally better than breaking before it for readability.

**Possible solution**: Implement break penalty system:
- Low penalty: after binary operators, after relations, after punctuation
- Medium penalty: after ordinary atoms
- High penalty: after opening brackets, before closing brackets

### 4. No Widow/Orphan Control
**Problem**: Single atoms can end up alone on lines.

**Possible solution**: Minimum atoms per line constraint.

## Implemented Enhancements

### Width-Based Breaking for Complex Atoms
All major complex atom types now check width before forcing line breaks:
1. Added `shouldBreakBeforeDisplay()` helper to check width before flushing
2. Modified `.fraction` case to check width before breaking
3. Modified `.radical` case to check width before breaking
4. Modified `.largeOperator` case with height+width checking
5. Modified `.inner` case with maxWidth propagation
6. Modified all 3 color cases (.color, .textcolor, .colorBox) with maxWidth propagation
7. Modified `.table` case to check width before breaking

### Script Handling Improvement
1. Added `estimateAtomWidthWithScripts()` helper function to calculate atom width including scripts
2. Check width constraint BEFORE flushing for scripted atoms (lines 1123-1137)
3. Only break line if adding scripted atom would exceed maxWidth

### Early Exit Optimization
**Goal**: Skip expensive line breaking checks when we know all remaining content will fit.

**Implementation**: Lines 376, 549-606 in MTTypesetter.swift
- Added `remainingContentFits` flag to track when optimization applies
- Once flag is set, all subsequent breaking checks return immediately (fast path)
- Flag is reset when line break actually occurs

## Testing Coverage

### Test File
`Tests/SwiftMathTests/MTTypesetterTests.swift`

### Test Categories

**Simple Equations** (6 tests, lines 1577-1711):
- Text and math mixing
- Atoms at boundaries
- Superscripts (limited)
- No breaking when not needed
- Breaking after operators

**Fractions and Radicals Inline** (8 tests, lines 1712-1869):
- Fractions inline
- Radicals inline
- Mixed fractions and radicals
- Fractions with complex content
- Radicals with degrees
- No breaking without width constraint

**Edge Cases** (6 tests, lines 1873-1983):
- Very narrow widths
- Very wide atoms (overflow handling)
- Mixed scripts and non-scripts
- Multiple line breaks (4+ lines)
- Unicode text wrapping
- Number protection

**Complex Atoms - Inline Layout** (20 tests, lines 2111-2534):
- Large operators inline (3 tests)
- Delimiters inline (4 tests)
- Colored expressions inline (3 tests)
- Matrices inline (3 tests)
- Integration tests (2 tests)
- Real-world examples (3 tests)
- Edge cases (2 tests)

**Scripted Atoms Inline** (8 tests, lines 2609-2780):
- Scripted atoms inline when fit
- Scripted atoms break when too wide
- Mixed scripted and non-scripted atoms
- Both subscripts and superscripts
- Real-world expressions with exponents

**Break Quality Scoring** (8 tests, lines 2797-3006):
- Prefer breaking after binary operators
- Prefer breaking after relation operators
- Avoid breaking after open brackets
- Look-ahead finds better break points

**Dynamic Line Height** (8 tests, lines 3007-3218):
- Tall content (fractions) gets more spacing
- Regular content has reasonable spacing
- Mixed content varies spacing appropriately
- Large operators with limits get adequate vertical space

**Total**: 97 tests in MTTypesetterTests.swift
**Overall**: 248 tests across entire test suite

## Performance Considerations

### Current Performance
- Width calculations use Core Text (relatively fast)
- No caching of calculated widths
- Greedy algorithm is O(n) where n = number of atoms
- Early exit optimization when remaining content fits

### Potential Optimizations
1. **Width caching**: Cache calculated atom widths
2. **Batch processing**: Calculate multiple atom widths together

## Summary

The multiline line breaking implementation provides comprehensive support for all complex atom types:

**Fully Supported**:
- Simple equations with operators
- Text and math mixing
- Long sequences of variables/numbers
- Fractions inline
- Radicals/square roots inline
- Large operators inline
- Delimited expressions inline
- Colored expressions inline
- Matrices/tables inline
- Scripted atoms (superscripts/subscripts)
- Mixed complex expressions
- Width constraint propagation to nested content

**Limited Support**:
- Very long text atoms - break within atom rather than between atoms
