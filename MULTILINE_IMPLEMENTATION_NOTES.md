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

## Unsupported Cases (Forced Line Breaks)

These atom types **always** flush the current line before rendering, meaning they start on their own line:

### ❌ Fractions
**Code location**: `MTTypesetter.swift:669-682`

```swift
"a + \\frac{1}{2} + b"
// Results in 3 lines:
// Line 1: "a +"
// Line 2: "½"
// Line 3: "+ b"
```

**Why**: Fractions require complex vertical layout (numerator/denominator) and force a line flush.

**Impact**: Expressions with multiple fractions have excessive line breaks.

### ❌ Radicals (Square Roots)
**Code location**: `MTTypesetter.swift:645-668`

```swift
"x + \\sqrt{2} + y"
// Results in 3 lines
```

**Why**: Radicals require special rendering (radical sign + vinculum) and force line flush.

### ❌ Large Operators
**Code location**: `MTTypesetter.swift:684-693`

```swift
"\\sum_{i=1}^{n} x_i + \\int_{0}^{1} f(x)dx"
```

**Why**: Large operators (∑, ∫, ∏, lim) with subscripts/superscripts require special vertical positioning.

**Impact**: Each operator gets its own line.

### ❌ Inner Lists (Delimiters)
**Code location**: `MTTypesetter.swift:694-709`

```swift
"a + \\left( \\frac{b}{c} \\right) + d"
```

**Why**: `\left...\right` pairs create inner lists that flush the line for proper delimiter sizing.

### ❌ Matrices/Tables
**Code location**: `MTTypesetter.swift:757-770`

```swift
"A = \\begin{pmatrix} 1 & 2 \\\\ 3 & 4 \\end{pmatrix}"
```

**Why**: Matrices require complex 2D layout.

### ❌ Colored Expressions
**Code locations**:
- `MTTypesetter.swift:590-600` (`.color`)
- `MTTypesetter.swift:602-630` (`.textcolor`)
- `MTTypesetter.swift:632-643` (`.colorBox`)

```swift
"a + \\color{red}{b + c} + d"
```

**Why**: Color atoms recursively create displays and flush the line.

### ❌ Accents
**Code location**: `MTTypesetter.swift:711-755`

```swift
"\\hat{x} + \\tilde{y}"
```

**Why**: Accents require special vertical positioning and may flush lines.

## Potential Issues and Edge Cases

### 1. Over-Breaking with Complex Atoms
**Problem**: Expressions mixing simple and complex atoms have too many breaks.

**Example**:
```swift
"a + \\frac{1}{2} + b + \\sqrt{3} + c"
// Becomes 5 lines instead of ideally 1-2
```

**Root cause**: Each complex atom flushes the line independently.

**Possible solution**: Check if complex atom + current line width fits within constraint before flushing.

### 2. No Look-Ahead Optimization
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

### 3. Fixed Line Height
**Problem**: All lines use `fontSize × 1.5` regardless of content height.

**Example**: A line with a fraction is much taller than a line with just variables, but spacing is uniform.

**Possible solution**: Calculate actual line height based on ascent/descent of atoms on each line.

### 4. Scripts Disable Interatom Breaking
**Problem**: Atoms with superscripts/subscripts fall back to universal breaking.

**Example**:
```swift
"a^{2} + b^{2} + c^{2}"
```

**Root cause**: Scripts cause line flushing for vertical positioning (line 892-908), interrupting interatom flow.

**Possible solution**: Refactor script handling to not require immediate line flush, or handle scripted atoms specially in interatom breaking.

### 5. No Break Quality Scoring
**Problem**: All break points are treated equally - no preference for breaking after operators vs. before.

**Example**: Breaking after `+` is generally better than breaking before it for readability.

**Possible solution**: Implement break penalty system:
- Low penalty: after binary operators, after relations, after punctuation
- Medium penalty: after ordinary atoms
- High penalty: after opening brackets, before closing brackets

### 6. No Widow/Orphan Control
**Problem**: Single atoms can end up alone on lines.

**Example**:
```swift
// Last line might just be: "+ e"
```

**Possible solution**: Minimum atoms per line constraint.

### 7. Inconsistent Behavior with Recursion
**Problem**: Nested math lists (inner, color, etc.) create their own displays recursively, potentially without width constraints.

**Example**:
```swift
"\\color{red}{a + b + c + d + e + f + g}"
// The entire colored portion might render on one line even if too wide
```

**Root cause**: Recursive calls to `createLineForMathList` at lines 596, 608, 638 don't pass `maxWidth`.

**Possible solution**: Propagate `maxWidth` to recursive calls.

## Future Enhancement Opportunities

### Priority 1: Fix Complex Atom Line Flushing
**Goal**: Allow fractions, radicals, etc. to coexist on lines with other atoms.

**Approach**:
1. Check if complex atom width + current line width fits
2. If yes, add to line without flushing
3. If no, flush current line, add complex atom to new line

**Implementation**: Modify switch cases for `.fraction`, `.radical`, `.largeOperator` to check width before flushing.

**Impact**: ⭐⭐⭐⭐⭐ (Huge improvement for mathematical expressions)

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
✅ Simple equations (6 tests in `MTTypesetterTests.swift:1577-1709`)
✅ Text and math mixing
✅ Atoms at boundaries
✅ Superscripts (limited)
✅ No breaking when not needed
✅ Breaking after operators

### Recommended Additional Tests
- [ ] Fractions in equations
- [ ] Radicals in equations
- [ ] Large operators with breaking
- [ ] Nested expressions
- [ ] Colored sections
- [ ] Very narrow widths (edge cases)
- [ ] Very wide atoms (overflow handling)
- [ ] Mixed scripts and non-scripts
- [ ] Matrices with surrounding content
- [ ] Multiple line breaks (3+ lines)
- [ ] Unicode text wrapping
- [ ] Number protection across languages

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

The current implementation provides **excellent support** for:
- ✅ Simple equations with operators
- ✅ Text and math mixing
- ✅ Long sequences of variables/numbers

**Limitations exist** for:
- ⚠️ Expressions with fractions, radicals, large operators
- ⚠️ Nested/colored expressions
- ⚠️ Scripted atoms (superscripts/subscripts)

The most impactful improvements would be:
1. **Fix complex atom flushing** (allow fractions/radicals inline)
2. **Improve script handling** (include in interatom breaking)
3. **Add break quality scoring** (prefer better break points)

These enhancements would significantly expand the range of expressions that break naturally and aesthetically across multiple lines.
