# SwiftMath Missing Features - Implementation Status

This document lists LaTeX features that are **not yet implemented** in SwiftMath, based on comprehensive testing against the LaTeX Mathematics reference.

## Summary

- **Total Features Tested**: 12
- **Fully Implemented**: 7 (58%)
- **Partially Implemented**: 0 (0%)
- **Not Implemented**: 5 (42%)

---

## HIGH PRIORITY Features (Not Implemented)

### 1. ✅ `\displaystyle` and `\textstyle` - **IMPLEMENTED**
**Status**: ✅ Working
**Description**: Commands to force display or text style rendering within expressions

**Test Results**: All tests passed
- `\displaystyle \sum_{i=1}^{n} x_i` - ✅ Works
- `\textstyle \int_{0}^{\infty} f(x) dx` - ✅ Works
- Inline displaystyle fractions - ✅ Works

---

### 2. ❌ `\middle` - Delimiter in Middle of Expression
**Status**: ❌ Not Implemented
**Error**: `Invalid command \middle`

**Description**: Used with `\left` and `\right` to add delimiters in the middle of expressions

**Examples**:
```latex
\left( \frac{a}{b} \middle| \frac{c}{d} \right)
\left\{ x \middle\| y \right\}
```

**Use Case**: Set notation, conditional expressions, piecewise functions with multiple sections

---

### 3. ✅ `\substack` - Multi-line Limits and Subscripts - **IMPLEMENTED**
**Status**: ✅ Working
**Description**: Creates multi-line subscripts and limits for operators

**Test Results**: All tests passed
- `\substack{a \\ b}` - ✅ Works
- `\sum_{\substack{0 \le i \le m \\ 0 < j < n}} P(i,j)` - ✅ Works (nested in subscript)
- `\prod_{\substack{p \text{ prime} \\ p < 100}} p` - ✅ Works (nested in subscript)
- `\substack{\frac{a}{b} \\ c}` - ✅ Works (with nested commands)

**Use Case**: Complex summation/product limits, constrained expressions

**Implementation**: Uses `buildInternal(true)` pattern, handles implicit tables created by `\\` within braces.

---

### 4. ❌ Manual Delimiter Sizing: `\big`, `\Big`, `\bigg`, `\Bigg`
**Status**: ❌ Not Implemented
**Error**: `Invalid command \big`

**Description**: Manually control delimiter sizes (4 levels beyond normal)

**Examples**:
```latex
\big( x \big)        % slightly larger
\Big[ y \Big]        % larger
\bigg\{ z \bigg\}    % even larger
\Bigg| w \Bigg|      % largest
```

**Use Case**: Fine control over delimiter appearance, nested expressions

---

### 5. ❌ Spacing Commands: `\,`, `\:`, `\;`, `\!`
**Status**: ❌ Partially Not Implemented
**Error**: `Invalid command \:` (and likely others)

**Description**: Fine-tuned horizontal spacing control

| Command | Description | Width |
|---------|-------------|-------|
| `\,` | Thin space | 3/18 em |
| `\:` | Medium space | 4/18 em |
| `\;` | Thick space | 5/18 em |
| `\!` | Negative thin space | -3/18 em |

**Examples**:
```latex
a\,b                              % thin space
\int\!\!\!\int f(x,y) dx dy      % tight double integral
x \, y \: z \; w                  % mixed spacing
```

**Use Case**: Fine typography control, integral notation, custom spacing

---

## MEDIUM PRIORITY Features

### 6. ✅ Multiple Integral Symbols: `\iint`, `\iiint`, `\iiiint` - **IMPLEMENTED**
**Status**: ✅ Working
**Description**: Special symbols for double, triple, and quadruple integrals

**Test Results**: All tests passed
- `\iint f(x,y) dx dy` - ✅ Works (double integral)
- `\iiint f(x,y,z) dx dy dz` - ✅ Works (triple integral)
- `\iiiint f(w,x,y,z) dw dx dy dz` - ✅ Works (quadruple integral)
- `\iint_{D} f(x,y) dA` - ✅ Works (with subscript limits)

**Use Case**: Multivariable calculus, surface and volume integrals

**Implementation**: Added U+2A0C (quadruple integral) Unicode character to operator definitions.

---

### 7. ✅ `\cfrac` - Continued Fractions - **IMPLEMENTED**
**Status**: ✅ Working
**Description**: Optimized layout for continued fractions

**Test Results**: All tests passed
- Simple `\cfrac{1}{2}` - ✅ Works
- Nested continued fractions - ✅ Works

---

### 7b. ✅ `\dfrac` and `\tfrac` - Display/Text Style Fractions - **IMPLEMENTED**
**Status**: ✅ Working
**Description**: Fractions with forced display or text style

**Test Results**: All tests passed
- `\dfrac{1}{2}` - ✅ Works (display-style fraction)
- `\tfrac{a}{b}` - ✅ Works (text-style fraction)
- `y'=-\dfrac{2}{x^{3}}` - ✅ Works (complex expression)
- Nested `\dfrac` and `\tfrac` - ✅ Works

**Use Case**:
- `\dfrac` forces display style (larger, more readable fractions)
- `\tfrac` forces text style (smaller, inline fractions)
- Useful when you want consistent fraction appearance regardless of context

**Implementation**: Prepends style atoms to numerator and denominator to force rendering style.

---

### 8. ❌ `\boldsymbol` - Bold Greek Letters
**Status**: ❌ Not Implemented
**Error**: `Invalid command \boldsymbol`

**Description**: Creates bold Greek letters (whereas `\mathbf` doesn't work for Greek)

**Examples**:
```latex
\boldsymbol{\alpha}        % bold alpha
\boldsymbol{\beta}         % bold beta
\boldsymbol{\Gamma}        % bold Gamma
\mathbf{x} + \boldsymbol{\mu}  % mix Roman and Greek bold
```

**Use Case**: Vectors with Greek symbols, bold emphasis for Greek letters

---

### 9. ✅ Starred Matrix Environments: `pmatrix*`, `bmatrix*`, etc. - **IMPLEMENTED**
**Status**: ✅ Working
**Description**: Matrix environments with optional column alignment

**Test Results**: All tests passed
- `\begin{pmatrix*}[r] 1 & 2 \\ 3 & 4 \end{pmatrix*}` - ✅ Works (right align)
- `\begin{bmatrix*}[l] a & b \\ c & d \end{bmatrix*}` - ✅ Works (left align)
- `\begin{vmatrix*}[c] x & y \\ z & w \end{vmatrix*}` - ✅ Works (center align)
- `\begin{matrix*}[r] 10 & 20 \\ 30 & 40 \end{matrix*}` - ✅ Works (no delimiters)

**Alignment Options**: `[r]` = right, `[l]` = left, `[c]` = center

**Use Case**: Financial tables, aligned numerical data in matrices

**Implementation**: Added `readOptionalAlignment()` function, modified `readString()` to accept asterisks, applies alignment to all columns.

---

### 10. ✅ `\smallmatrix` Environment - **IMPLEMENTED**
**Status**: ✅ Working
**Description**: Compact matrix for inline use (smaller than regular matrices)

**Test Results**: All tests passed
- `\left( \begin{smallmatrix} a & b \\ c & d \end{smallmatrix} \right)` - ✅ Works (with delimiters)
- `A = \left( \begin{smallmatrix} 1 & 0 \\ 0 & 1 \end{smallmatrix} \right)` - ✅ Works (identity matrix)
- `\begin{smallmatrix} x \\ y \end{smallmatrix}` - ✅ Works (column vector)

**Use Case**: Inline matrices, transformation matrices in text, compact notation

**Implementation**: Uses `.script` style for smaller font size, tighter column spacing (6 vs 18), no built-in delimiters.

---

## Implementation Priority Recommendations

### Remaining High Priority Features
1. **Spacing commands** (`\,`, `\:`, `\;`, `\!`) - Used in almost all advanced math
2. **Manual delimiter sizing** (`\big`, etc.) - Common in published mathematics
3. **`\middle`** - Useful for conditional notation

### Remaining Medium Priority Features
4. **`\boldsymbol`** - Important for vector notation with Greek letters

---

## Testing Coverage

All tests use the `MTMathListBuilder.build(fromString:error:)` API and automatically skip with `XCTSkip` when features are not implemented.

**Test File**: `Tests/SwiftMathTests/MTMathListBuilderTests.swift`
**Test Functions**:
- `testDisplayStyle()` - ✅ Passed (IMPLEMENTED)
- `testMiddleDelimiter()` - ⏭️ Skipped (not implemented)
- `testSubstack()` - ✅ Passed (IMPLEMENTED)
- `testManualDelimiterSizing()` - ⏭️ Skipped (not implemented)
- `testSpacingCommands()` - ⏭️ Skipped (not implemented)
- `testMultipleIntegrals()` - ✅ Passed (IMPLEMENTED)
- `testContinuedFractions()` - ✅ Passed (IMPLEMENTED)
- `testBoldsymbol()` - ⏭️ Skipped (not implemented)
- `testStarredMatrices()` - ✅ Passed (IMPLEMENTED)
- `testSmallMatrix()` - ✅ Passed (IMPLEMENTED)

---

## Notes for Future Implementation

### For `\middle`:
- Needs integration with existing `\left...\right` delimiter pairing system
- Should support all delimiter types that work with `\left` and `\right`

### For Manual Sizing (`\big`, etc.):
- Needs 4 size levels beyond normal
- Each size approximately 1.2x the previous
- Should work with all delimiter types

### For Spacing Commands:
- Need to insert proper `MTMathSpace` atoms
- Different space types: positive (`\,`, `\:`, `\;`) and negative (`\!`)
- Some might already be partially implemented

### For `\boldsymbol`:
- Needs access to bold math font variants
- Should work with both Greek and other symbols
- Different from `\mathbf` (which changes font family)

---

*Generated: 2025-10-01*
*SwiftMath Version: Based on iosMath v0.9.5*
*Last Updated: 2025-10-01 - Implemented 4 major features: \substack, \smallmatrix, starred matrices, \iiiint*
