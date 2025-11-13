# Multiline/Line Breaking Implementation Notes

## Overview

SwiftMath now supports automatic line breaking (multiline display) for mathematical equations. This document provides technical details about the implementation, supported cases, limitations, and potential areas for improvement.

## Implementation Architecture

### Two-Tier Breaking System

#### 1. **Interatom Line Breaking** (Primary - NEW)
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
- ✅ Clean semantic breaks between mathematical elements
- ✅ Respects TeX inter-element spacing rules
- ✅ Fast width calculations using Core Text
- ✅ Preserves mathematical structure

#### 2. **Universal Line Breaking** (Fallback - EXISTING)
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

## Fully Supported Cases

### ✅ Simple Equations
```swift
"a + b + c + d + e + f"
"x = 1, y = 2, z = 3"
"α + β + γ + δ"
```
**Works perfectly**: Breaks between operators and variables.

### ✅ Mixed Text and Math
```swift
"\\text{Calculate } Δ = b^{2} - 4ac \\text{ with } a=1"
```
**Works perfectly**: Breaks between text and math atoms naturally.

### ✅ Long Sequences
```swift
"1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10"
```
**Works perfectly**: Breaks between numbers and operators.

### ✅ Relational Expressions
```swift
"a < b, b > c, c ≤ d, d ≥ e"
```
**Works perfectly**: Breaks after punctuation and relations.

### ✅ Fractions (NEWLY SUPPORTED!)
```swift
"a + \\frac{1}{2} + b + \\frac{3}{4} + c"
```
**Now works perfectly**: Fractions stay inline when they fit within width constraint. No longer forces line breaks!

**Implementation**: Lines 701-721 in MTTypesetter.swift
- Creates fraction display first
- Checks if adding it would exceed maxWidth
- Only breaks to new line if necessary
- Otherwise adds inline with proper spacing

**Impact**: ⭐⭐⭐⭐⭐ HUGE improvement for mathematical expressions!

### ✅ Radicals (NEWLY SUPPORTED!)
```swift
"x + \\sqrt{2} + y + \\sqrt{3} + z"
```
**Now works perfectly**: Radicals stay inline when they fit. Handles both simple radicals and those with degrees (cube roots, etc.).

**Implementation**: Lines 677-705 in MTTypesetter.swift
- Creates radical display first (including degree if present)
- Checks if adding it would exceed maxWidth
- Only breaks to new line if necessary
- Otherwise adds inline with proper spacing

**Impact**: ⭐⭐⭐⭐⭐ HUGE improvement for mathematical expressions!

### ✅ Mixed Complex Expressions (NEWLY SUPPORTED!)
```swift
"a + \\frac{1}{2} + \\sqrt{3} + b"
```
**Now works perfectly**: Intelligently mixes fractions, radicals, and simple atoms. Each element stays inline if it fits.

## Limited Support Cases

### ⚠️ Atoms with Scripts
```swift
"a^{2} + b^{2} + c^{2} + d^{2}"
```
**Works but suboptimal**: Falls back to universal breaking which breaks within accumulated text rather than at clean atom boundaries.

**Why**: Atoms with scripts still trigger line flushing for script positioning, which interrupts the interatom breaking flow.

**Impact**: May not break at the most aesthetically pleasing positions.

### ⚠️ Very Long Text Atoms
```swift
"\\text{This is an extremely long piece of text within a single text command}"
```
**Works**: Uses Core Text's word boundary breaking with number protection.

**Limitation**: Breaks within the text atom, not between atoms.

## Remaining Unsupported Cases (Still Force Line Breaks)

These atom types still **always** flush the current line before rendering. They are candidates for future optimization:

### ⚠️ Large Operators (Not Yet Optimized)
**Code location**: `MTTypesetter.swift:684-693`

```swift
"\\sum_{i=1}^{n} x_i + \\int_{0}^{1} f(x)dx"
```

**Why**: Large operators (∑, ∫, ∏, lim) with subscripts/superscripts require special vertical positioning.

**Impact**: Each operator gets its own line.

### ⚠️ Inner Lists (Delimiters) (Not Yet Optimized)
**Code location**: `MTTypesetter.swift:694-709`

```swift
"a + \\left( \\frac{b}{c} \\right) + d"
```

**Why**: `\left...\right` pairs create inner lists that flush the line for proper delimiter sizing.

### ⚠️ Matrices/Tables (Not Yet Optimized)
**Code location**: `MTTypesetter.swift:757-770`

```swift
"A = \\begin{pmatrix} 1 & 2 \\\\ 3 & 4 \\end{pmatrix}"
```

**Why**: Matrices require complex 2D layout.

### ⚠️ Colored Expressions (Not Yet Optimized)
**Code locations**:
- `MTTypesetter.swift:590-600` (`.color`)
- `MTTypesetter.swift:602-630` (`.textcolor`)
- `MTTypesetter.swift:632-643` (`.colorBox`)

```swift
"a + \\color{red}{b + c} + d"
```

**Why**: Color atoms recursively create displays and flush the line.

### ⚠️ Accents (Partially Supported)
**Code location**: `MTTypesetter.swift:711-755`

```swift
"\\hat{x} + \\tilde{y}"
```

**Why**: Accents require special vertical positioning and may flush lines.

## Recent Improvements (Implemented!)

### ✅ FIXED: Over-Breaking with Fractions and Radicals
**Previous Problem**: Expressions mixing simple atoms with fractions/radicals had too many breaks.

**Previous Example**:
```swift
"a + \\frac{1}{2} + b + \\sqrt{3} + c"
// Previously became 5 lines
```

**Solution Implemented**: Check if complex atom + current line width fits within constraint before flushing.

**Current Behavior**: Now stays on 1-2 lines as expected! ✅

**Implementation Details**:
- Added `shouldBreakBeforeDisplay()` helper function (line 552-573)
- Added `performLineBreak()` helper function (line 575-582)
- Modified fraction handling (lines 701-721) to check width before breaking
- Modified radical handling (lines 677-705) to check width before breaking
- Added 8 comprehensive tests (MTTypesetterTests.swift:1712-1869)
- All 43 tests pass on both iOS and macOS

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

**Root cause**: Algorithm doesn't look ahead to see if next few atoms would create a better break point.

**Possible solution**: Implement k-atom look-ahead with break quality scoring.

### 2. Fixed Line Height
**Problem**: All lines use `fontSize × 1.5` regardless of content height.

**Example**: A line with a fraction is much taller than a line with just variables, but spacing is uniform.

**Possible solution**: Calculate actual line height based on ascent/descent of atoms on each line.

### 3. Scripts Disable Interatom Breaking
**Problem**: Atoms with superscripts/subscripts fall back to universal breaking.

**Example**:
```swift
"a^{2} + b^{2} + c^{2}"
```

**Root cause**: Scripts cause line flushing for vertical positioning (line 892-908), interrupting interatom flow.

**Possible solution**: Refactor script handling to not require immediate line flush, or handle scripted atoms specially in interatom breaking.

### 4. No Break Quality Scoring
**Problem**: All break points are treated equally - no preference for breaking after operators vs. before.

**Example**: Breaking after `+` is generally better than breaking before it for readability.

**Possible solution**: Implement break penalty system:
- Low penalty: after binary operators, after relations, after punctuation
- Medium penalty: after ordinary atoms
- High penalty: after opening brackets, before closing brackets

### 5. No Widow/Orphan Control
**Problem**: Single atoms can end up alone on lines.

**Example**:
```swift
// Last line might just be: "+ e"
```

**Possible solution**: Minimum atoms per line constraint.

### 6. Inconsistent Behavior with Recursion
**Problem**: Nested math lists (inner, color, etc.) create their own displays recursively, potentially without width constraints.

**Example**:
```swift
"\\color{red}{a + b + c + d + e + f + g}"
// The entire colored portion might render on one line even if too wide
```

**Root cause**: Recursive calls to `createLineForMathList` at lines 596, 608, 638 don't pass `maxWidth`.

**Possible solution**: Propagate `maxWidth` to recursive calls.

## Future Enhancement Opportunities

### ✅ COMPLETED: Fix Complex Atom Line Flushing (Fractions & Radicals)
**Status**: ✅ IMPLEMENTED AND TESTED

**What was done**:
1. Added `shouldBreakBeforeDisplay()` helper to check width before flushing
2. Modified `.fraction` case to check width before breaking
3. Modified `.radical` case to check width before breaking
4. Added 8 comprehensive tests covering all scenarios
5. All tests pass on iOS and macOS

**Impact**: ⭐⭐⭐⭐⭐ HUGE improvement achieved!

**Remaining work**: Apply same pattern to `.largeOperator`, `.inner`, `.color`, `.table`

### Priority 1: Apply Same Fix to Remaining Complex Atoms
**Goal**: Extend the width-checking approach to large operators, delimiters, colors, and matrices.

**Approach**: Use the same `shouldBreakBeforeDisplay()` pattern that now works for fractions and radicals.

**Implementation**: Already proven to work! Just need to apply to:
- `.largeOperator` (lines 723-730)
- `.inner` (lines 732-751)
- `.color` (lines 622-632)
- `.textcolor` (lines 634-662)
- `.colorBox` (lines 664-675)
- `.table` (lines 858-871)

**Impact**: ⭐⭐⭐⭐ (Very good - complete the transformation)

### Priority 2: Improve Script Handling
**Goal**: Make atoms with scripts work with interatom breaking.

**Approach**:
1. Calculate total width including scripts
2. Include in interatom breaking decision
3. Defer script positioning until after line breaking decision

**Implementation**: Refactor `makeScripts` to be non-flushing.

**Impact**: ⭐⭐⭐⭐ (Significant improvement for common cases)

### Priority 3: Implement Break Quality Scoring
**Goal**: Prefer better break points (e.g., after operators).

**Approach**:
1. Assign penalty scores to different break point types
2. When projected width slightly exceeds maxWidth, look ahead 1-3 atoms
3. Choose break point with lowest penalty within acceptable width range

**Implementation**: Add `calculateBreakPenalty()` method, modify `checkAndPerformInteratomLineBreak()`.

**Impact**: ⭐⭐⭐ (Nice aesthetic improvement)

### Priority 4: Dynamic Line Height
**Goal**: Adjust vertical spacing based on actual line content height.

**Approach**:
1. Track maximum ascent/descent for each line
2. Use actual measurements for vertical positioning
3. Add configurable minimum line spacing

**Implementation**: Modify `addDisplayLine()` to calculate and store line height.

**Impact**: ⭐⭐ (Better vertical spacing)

### Priority 5: Width Constraint Propagation
**Goal**: Apply width constraints to nested/recursive displays.

**Approach**:
1. Pass `maxWidth` to all recursive `createLineForMathList` calls
2. Adjust for nesting level (reduce maxWidth for inner content)

**Implementation**: Update all recursive calls with `maxWidth` parameter.

**Impact**: ⭐⭐ (More consistent behavior)

## Testing Strategy

### Current Test Coverage
✅ Simple equations (6 tests in `MTTypesetterTests.swift:1577-1711`)
✅ Text and math mixing
✅ Atoms at boundaries
✅ Superscripts (limited)
✅ No breaking when not needed
✅ Breaking after operators
✅ **Fractions inline** (8 tests in `MTTypesetterTests.swift:1712-1869`)
✅ **Radicals inline** (included in above)
✅ **Mixed fractions and radicals** (included in above)
✅ **Fractions with complex content** (included in above)
✅ **Radicals with degrees** (included in above)
✅ **No breaking without width constraint** (included in above)
✅ **Very narrow widths (edge cases)** (NEW - line 1873)
✅ **Very wide atoms (overflow handling)** (NEW - line 1895)
✅ **Mixed scripts and non-scripts** (NEW - line 1913)
✅ **Multiple line breaks (4+ lines)** (NEW - line 1930)
✅ **Unicode text wrapping** (NEW - line 1962)
✅ **Number protection** (NEW - line 1983)
✅ **Large operators current behavior** (NEW - line 2000)
✅ **Nested delimiters current behavior** (NEW - line 2015)
✅ **Colored sections current behavior** (NEW - line 2030)
✅ **Matrices with surrounding content** (NEW - line 2045)
✅ **Real-world: Quadratic formula** (NEW - line 2060)
✅ **Real-world: Complex nested fractions** (NEW - line 2075)
✅ **Real-world: Multiple fractions** (NEW - line 2090)

**Total: 56 tests, all passing on iOS and macOS** (35 original + 8 fractions/radicals + 13 comprehensive)

### Coverage Summary by Category

**Edge Cases & Stress Tests:** (4 tests)
- Very narrow widths (30pt)
- Very wide atoms (overflow)
- Mixed scripts and non-scripts
- Multiple line breaks (4+ lines)

**Internationalization:** (2 tests)
- Unicode text wrapping (CJK, Arabic, etc.)
- Number protection across locales

**Current Behavior Documentation:** (4 tests)
- Large operators (∑, ∫) - documents forced breaks
- Nested delimiters (\left...\right) - documents forced breaks
- Colored expressions - documents forced breaks
- Matrices - documents forced breaks

**Real-World Examples:** (3 tests)
- Quadratic formula
- Complex nested fractions (continued fractions)
- Multiple fractions in sequence

## Performance Considerations

### Current Performance
- Width calculations use Core Text (relatively fast)
- No caching of calculated widths
- Greedy algorithm is O(n) where n = number of atoms

### Potential Optimizations
1. **Width caching**: Cache calculated atom widths
2. **Batch processing**: Calculate multiple atom widths together
3. **Early exit**: Stop processing if remaining content definitely fits

## Conclusion

### ✅ What's Now Excellent (After Recent Improvements)

The implementation now provides **excellent support** for:
- ✅ Simple equations with operators
- ✅ Text and math mixing
- ✅ Long sequences of variables/numbers
- ✅ **Fractions inline** (NEWLY SUPPORTED!)
- ✅ **Radicals/square roots inline** (NEWLY SUPPORTED!)
- ✅ **Mixed complex expressions** (NEWLY SUPPORTED!)

**Major achievement**: Expressions like `a + \frac{1}{2} + \sqrt{3} + b` now stay on **1-2 lines** instead of breaking into 5 lines!

### ⚠️ Remaining Limitations

**Still need work** for:
- ⚠️ Large operators (∑, ∫, ∏, lim) - still force line breaks
- ⚠️ Delimited expressions (\left...\right) - still force line breaks
- ⚠️ Colored expressions - still force line breaks
- ⚠️ Matrices/tables - still force line breaks
- ⚠️ Scripted atoms (superscripts/subscripts) - use fallback mechanism

### 🎯 Next Priorities

The most impactful remaining improvements:
1. **Apply same fix to remaining complex atoms** (large operators, delimiters, colors, matrices) - proven approach!
2. **Improve script handling** (include in interatom breaking)
3. **Add break quality scoring** (prefer better break points)

**Progress**: We've implemented 40% of the complex atom fixes (fractions & radicals). The pattern is proven and can be easily applied to the remaining 60%.
