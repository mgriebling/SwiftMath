# Priority 1 Symbol Unicode Research

## Research Summary

This document contains the Unicode code points for all Priority 1 symbols identified in the PRD for ExtendedSwiftMath.

---

## Existing Symbols (Already in MTMathAtomFactory.swift)

| Command | Unicode | Status | Notes |
|---------|---------|--------|-------|
| `sqsubseteq` | U+2291 | OK | Already exists (line 259) |
| `sqsupseteq` | U+2292 | OK | Already exists (line 260) |
| `wr` | U+2240 | OK | Already exists (line 280) |
| `uplus` | U+228E | OK | Already exists (line 281) |
| `varrho` | U+1D71A | OK | Already exists (line 178) |
| `varpi` | U+1D71B | OK | Already exists (line 179) |
| `aleph` | U+2135 | OK | Already exists (line 390) |
| `emptyset` | U+2205 | OK | Already exists (line 394) |

---

## Issues Found (Need Fixing)

### 1. `varsigma` - WRONG UNICODE
- **Current**: U+03C1 (Greek small letter rho ρ)
- **Correct**: U+03C2 (Greek small letter final sigma ς)
- **Location**: MTMathAtomFactory.swift line 164
- **Action**: Fix the unicode value

### 2. `square` - Maps to Placeholder
- **Current**: Maps to `MTMathAtomFactory.placeholder()` (U+25A1 white square used for placeholders)
- **Issue**: Should be a proper symbol, not a placeholder type
- **Action**: Consider adding a separate `\square` ordinary symbol or leave as placeholder

---

## New Symbols to Add

### Blackboard Bold Letters (Direct Symbols)

| Command | Unicode | Hex | Type | Description |
|---------|---------|-----|------|-------------|
| `N` (via mathbb) | ℕ | U+2115 | ordinary | Natural numbers |
| `Z` (via mathbb) | ℤ | U+2124 | ordinary | Integers |
| `Q` (via mathbb) | ℚ | U+211A | ordinary | Rationals |
| `R` (via mathbb) | ℝ | U+211D | ordinary | Reals |
| `C` (via mathbb) | ℂ | U+2102 | ordinary | Complex numbers |

**Note**: These are accessed via `\mathbb{N}` etc. The `\mathbb` command already exists in fontStyles and uses `MTFontStyle.blackboard`. The MTUnicode.swift already has `mathCapitalBlackboardStart = UInt32(0x1D538)` for styled rendering.

### Slanted Inequalities

| Command | Unicode | Hex | Type | Description |
|---------|---------|-----|------|-------------|
| `leqslant` | ⩽ | U+2A7D | relation | Less-than or slanted equal to |
| `geqslant` | ⩾ | U+2A7E | relation | Greater-than or slanted equal to |

### Set Relations (Precedence)

| Command | Unicode | Hex | Type | Description |
|---------|---------|-----|------|-------------|
| `preceq` | ⪯ | U+2AAF | relation | Precedes above single-line equals sign |
| `succeq` | ⪰ | U+2AB0 | relation | Succeeds above single-line equals sign |

### Arrows

| Command | Unicode | Hex | Type | Description |
|---------|---------|-----|------|-------------|
| `longmapsto` | ⟼ | U+27FC | relation | Long rightwards arrow from bar |
| `hookrightarrow` | ↪ | U+21AA | relation | Rightwards arrow with hook |
| `hookleftarrow` | ↩ | U+21A9 | relation | Leftwards arrow with hook |

### Operators

| Command | Unicode | Hex | Type | Description |
|---------|---------|-----|------|-------------|
| `diamond` | ⋄ | U+22C4 | binaryOperator | Diamond operator |
| `bowtie` | ⋈ | U+22C8 | relation | Bowtie |
| `vdash` | ⊢ | U+22A2 | relation | Right tack (turnstile) |
| `dashv` | ⊣ | U+22A3 | relation | Left tack (reverse turnstile) |

### Greek Variants

| Command | Unicode | Hex | Type | Description |
|---------|---------|-----|------|-------------|
| `varkappa` | ϰ | U+03F0 | ordinary | Greek kappa symbol |
| `digamma` | ϝ | U+03DD | variable | Greek small letter digamma |
| `Digamma` | Ϝ | U+03DC | variable | Greek capital letter digamma |

### Miscellaneous Symbols

| Command | Unicode | Hex | Type | Description |
|---------|---------|-----|------|-------------|
| `varnothing` | ∅ | U+2205 | ordinary | Empty set (same as emptyset, different style in LaTeX) |
| `Box` | □ | U+25A1 | ordinary | White square (same glyph as whiteSquare) |
| `measuredangle` | ∡ | U+2221 | ordinary | Measured angle |
| `beth` | ℶ | U+2136 | ordinary | Hebrew letter beth |
| `gimel` | ℷ | U+2137 | ordinary | Hebrew letter gimel |
| `daleth` | ℸ | U+2138 | ordinary | Hebrew letter daleth (bonus) |

---

## Implementation Notes

### Swift Code Format

Symbols should be added to `supportedLatexSymbols` dictionary in this format:

```swift
// Relations
"leqslant" : MTMathAtom(type: .relation, value: "\u{2A7D}"),
"geqslant" : MTMathAtom(type: .relation, value: "\u{2A7E}"),

// Binary Operators
"diamond" : MTMathAtom(type: .binaryOperator, value: "\u{22C4}"),

// Ordinary symbols
"varkappa" : MTMathAtom(type: .ordinary, value: "\u{03F0}"),

// Variables (for Greek letters that should italicize)
"digamma" : MTMathAtom(type: .variable, value: "\u{03DD}"),
```

### Type Selection Guide

- **relation**: Comparison operators, arrows, set relations (=, <, >, →, ⊆, etc.)
- **binaryOperator**: Operations between two operands (+, -, ×, ∧, etc.)
- **ordinary**: Standalone symbols, Hebrew letters, misc symbols
- **variable**: Greek letters (will be italicized in math mode)
- **open/close**: Brackets and delimiters

### Font Verification Needed

Before implementation, verify that the bundled fonts (especially latinmodern-math.otf) contain glyphs for:
- U+2A7D, U+2A7E (slanted inequalities)
- U+2AAF, U+2AB0 (precedence relations)
- U+27FC (long mapsto)
- U+03F0 (varkappa)
- U+03DD, U+03DC (digamma)
- U+2221 (measured angle)
- U+2136, U+2137, U+2138 (Hebrew letters)

---

## Complete Addition List (Copy-Ready)

```swift
// === PRIORITY 1 SYMBOL ADDITIONS ===

// Slanted inequalities
"leqslant" : MTMathAtom(type: .relation, value: "\u{2A7D}"),
"geqslant" : MTMathAtom(type: .relation, value: "\u{2A7E}"),

// Set relations (precedence)
"preceq" : MTMathAtom(type: .relation, value: "\u{2AAF}"),
"succeq" : MTMathAtom(type: .relation, value: "\u{2AB0}"),

// Arrows
"longmapsto" : MTMathAtom(type: .relation, value: "\u{27FC}"),
"hookrightarrow" : MTMathAtom(type: .relation, value: "\u{21AA}"),
"hookleftarrow" : MTMathAtom(type: .relation, value: "\u{21A9}"),

// Operators/Relations
"diamond" : MTMathAtom(type: .binaryOperator, value: "\u{22C4}"),
"bowtie" : MTMathAtom(type: .relation, value: "\u{22C8}"),
"vdash" : MTMathAtom(type: .relation, value: "\u{22A2}"),
"dashv" : MTMathAtom(type: .relation, value: "\u{22A3}"),

// Greek variants
"varkappa" : MTMathAtom(type: .ordinary, value: "\u{03F0}"),
"digamma" : MTMathAtom(type: .variable, value: "\u{03DD}"),
"Digamma" : MTMathAtom(type: .variable, value: "\u{03DC}"),

// Miscellaneous symbols
"varnothing" : MTMathAtom(type: .ordinary, value: "\u{2205}"),
"Box" : MTMathAtom(type: .ordinary, value: "\u{25A1}"),
"measuredangle" : MTMathAtom(type: .ordinary, value: "\u{2221}"),
"beth" : MTMathAtom(type: .ordinary, value: "\u{2136}"),
"gimel" : MTMathAtom(type: .ordinary, value: "\u{2137}"),
"daleth" : MTMathAtom(type: .ordinary, value: "\u{2138}"),
```

---

## Bug Fix Required

```swift
// FIX: varsigma has wrong unicode (currently U+03C1 = rho)
// Change from:
"varsigma" : MTMathAtom(type: .variable, value: "\u{03C1}"),
// To:
"varsigma" : MTMathAtom(type: .variable, value: "\u{03C2}"),
```

---

## References

- Unicode Mathematical Operators: https://unicode.org/charts/PDF/U2200.pdf
- Unicode Supplemental Mathematical Operators: https://unicode.org/charts/PDF/U2A00.pdf
- Unicode Greek and Coptic: https://unicode.org/charts/PDF/U0370.pdf
- Unicode Letterlike Symbols: https://unicode.org/charts/PDF/U2100.pdf
- LaTeX Comprehensive Symbol List: https://www.ctan.org/pkg/comprehensive
