# SwiftMath Missing Features - Implementation Status

This document lists LaTeX features and their implementation status in SwiftMath.

## Summary

- **Total Features Tracked**: 15
- **Fully Implemented**: 13 (87%)
- **Partially Implemented**: 1 (7%)
- **Not Implemented**: 1 (7%)

---

## Recently Implemented Features

### `\boldsymbol` - Bold Greek Letters and Symbols
**Status**: Implemented
**Description**: Creates bold italic versions of Greek letters and other symbols (whereas `\mathbf` only works for Latin letters)

**Examples**:
```latex
\boldsymbol{\alpha}        % bold alpha
\boldsymbol{\beta}         % bold beta
\boldsymbol{\Gamma}        % bold Gamma
\mathbf{x} + \boldsymbol{\mu}  % mix Roman and Greek bold
```

**Use Case**: Vectors with Greek symbols, bold emphasis for Greek letters

---

### `\operatorname` and `\operatorname*` - Custom Operators
**Status**: Implemented
**Description**: Creates user-defined operators with proper spacing

**Examples**:
```latex
\operatorname{argmax}_{x}     % operator without limits
\operatorname*{argmin}_{x}    % operator with limits (displays limits above/below in display mode)
\operatorname{Tr}(A)          % trace operator
```

**Use Case**: Custom mathematical operators like argmax, argmin, Tr, etc.

---

### Dirac Notation - `\bra`, `\ket`, `\braket`
**Status**: Implemented
**Description**: Quantum mechanics notation for bra-ket (Dirac) notation

**Examples**:
```latex
\bra{\psi}                    % ⟨ψ|
\ket{\phi}                    % |φ⟩
\braket{\psi}{\phi}           % ⟨ψ|φ⟩
```

**Use Case**: Quantum mechanics, quantum computing

---

### Manual Delimiter Sizing: `\big`, `\Big`, `\bigg`, `\Bigg`
**Status**: Implemented
**Description**: Manually control delimiter sizes (4 levels beyond normal)

**Examples**:
```latex
\big( x \big)                 % 1.0x font size
\Big[ y \Big]                 % 1.4x font size
\bigg\{ z \bigg\}             % 1.8x font size
\Bigg| w \Bigg|               % 2.2x font size
```

**Supported Commands**:
- `\big`, `\Big`, `\bigg`, `\Bigg` - basic sizing
- `\bigl`, `\Bigl`, `\biggl`, `\Biggl` - left delimiter variants
- `\bigr`, `\Bigr`, `\biggr`, `\Biggr` - right delimiter variants
- `\bigm`, `\Bigm`, `\biggm`, `\Biggm` - middle delimiter variants

**Use Case**: Fine control over delimiter appearance, nested expressions

**Implementation**: Added `delimiterHeight` property to `MTInner`, stores size multiplier, applied in `MTTypesetter.makeLeftRight()`.

---

### Binary Operators (amssymb)
**Status**: Implemented
**Description**: 24 additional binary operators from the amssymb package

**Examples**:
```latex
a \ltimes b                   % left semidirect product
a \rtimes b                   % right semidirect product
a \circledast b               % circled asterisk
a \boxplus b                  % boxed plus
```

**Full list**: `\ltimes`, `\rtimes`, `\circledast`, `\circledcirc`, `\circleddash`, `\boxdot`, `\boxminus`, `\boxplus`, `\boxtimes`, `\divideontimes`, `\dotplus`, `\lhd`, `\rhd`, `\unlhd`, `\unrhd`, `\intercal`, `\barwedge`, `\veebar`, `\curlywedge`, `\curlyvee`, `\doublebarwedge`, `\centerdot`

---

### Corner Brackets
**Status**: Implemented
**Description**: Corner bracket delimiters and double square brackets

**Examples**:
```latex
\ulcorner x \urcorner         % upper corner brackets
\llcorner y \lrcorner         % lower corner brackets
\llbracket z \rrbracket       % double square brackets
```

---

### Additional Trigonometric Functions
**Status**: Implemented
**Description**: 11 additional trig/hyperbolic functions

**Examples**:
```latex
\arccot x                     % inverse cotangent
\arcsec x                     % inverse secant
\sech x                       % hyperbolic secant
\arcsinh x                    % inverse hyperbolic sine
```

**Full list**: `\arccot`, `\arcsec`, `\arccsc`, `\sech`, `\csch`, `\arcsinh`, `\arccosh`, `\arctanh`, `\arccoth`, `\arcsech`, `\arccsch`

---

## Previously Implemented Features

### `\displaystyle` and `\textstyle`
**Status**: Implemented
**Description**: Commands to force display or text style rendering within expressions

### `\substack` - Multi-line Limits and Subscripts
**Status**: Implemented
**Description**: Creates multi-line subscripts and limits for operators

### Multiple Integral Symbols: `\iint`, `\iiint`, `\iiiint`
**Status**: Implemented
**Description**: Special symbols for double, triple, and quadruple integrals

### `\cfrac` - Continued Fractions
**Status**: Implemented
**Description**: Optimized layout for continued fractions

### `\dfrac` and `\tfrac` - Display/Text Style Fractions
**Status**: Implemented
**Description**: Fractions with forced display or text style

### Starred Matrix Environments: `pmatrix*`, `bmatrix*`, etc.
**Status**: Implemented
**Description**: Matrix environments with optional column alignment (`[r]`, `[l]`, `[c]`)

### `\smallmatrix` Environment
**Status**: Implemented
**Description**: Compact matrix for inline use

---

## Not Yet Implemented

### `\middle` - Delimiter in Middle of Expression
**Status**: Not Implemented
**Error**: `Invalid command \middle`

**Description**: Used with `\left` and `\right` to add delimiters in the middle of expressions

**Examples**:
```latex
\left( \frac{a}{b} \middle| \frac{c}{d} \right)
\left\{ x \middle\| y \right\}
```

**Use Case**: Set notation, conditional expressions, piecewise functions with multiple sections

---

### Spacing Commands: `\,`, `\:`, `\;`, `\!`
**Status**: Partially Implemented
**Note**: `\,` works, others may not

**Description**: Fine-tuned horizontal spacing control

| Command | Description | Width |
|---------|-------------|-------|
| `\,` | Thin space | 3/18 em |
| `\:` | Medium space | 4/18 em |
| `\;` | Thick space | 5/18 em |
| `\!` | Negative thin space | -3/18 em |

---

## Implementation Priority Recommendations

### Remaining High Priority Features
1. **Spacing commands** (`\:`, `\;`, `\!`) - Used in advanced math typography

### Remaining Medium Priority Features
2. **`\middle`** - Useful for conditional notation

---

## Testing Coverage

**Test File**: `Tests/SwiftMathTests/MTMathListBuilderTests.swift`

Tests for newly implemented features:
- `testBigDelimiterCommands()` - delimiter sizing
- `testBigDelimiterLeftRightVariants()` - left/right delimiter variants
- `testBigDelimiterMiddleVariants()` - middle delimiter variants
- `testBraCommand()` - Dirac bra notation
- `testKetCommand()` - Dirac ket notation
- `testBraketCommand()` - Dirac braket notation
- `testOperatornameBasic()` - custom operators
- `testOperatornameWithLimits()` - operators with limits
- `testBoldsymbol()` - bold Greek symbols
- `testAmsSymbBinaryOperators()` - binary operators
- `testCornerBracketDelimiters()` - corner brackets
- `testAdditionalTrigFunctions()` - trig functions

---

*Last Updated: 2026-01-11 - Added \boldsymbol, \operatorname, Dirac notation, binary operators, corner brackets, trig functions*
