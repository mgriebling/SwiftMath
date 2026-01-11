# LaTeX Package Analysis for SwiftMath

## Current SwiftMath Architecture

### How Commands Are Organized

SwiftMath uses a **monolithic, single-basket approach**. All functionality is consolidated into a few static dictionaries:

1. **`MTMathAtomFactory.supportedLatexSymbols`** - Main symbol dictionary (~400+ entries)
   - Greek letters, relations, operators, arrows, miscellaneous symbols
   - Organized by comments but not by package origin

2. **`MTMathAtomFactory.aliases`** - Command aliases (e.g., `\ne` → `\neq`)

3. **`MTMathAtomFactory.delimiters`** - Bracket/delimiter mappings

4. **`MTMathAtomFactory.accents`** - Accent command mappings

5. **`MTMathAtomFactory.fontStyles`** - Font style commands (`\mathbb`, `\mathcal`, etc.)

6. **`MTMathListBuilder`** - Hardcoded command parsing for complex structures (`\frac`, `\sqrt`, `\begin`, etc.)

### No Package Selection Mechanism

Currently:
- All symbols are always available
- No way to enable/disable feature sets
- No way to override behavior (e.g., different `\phi` rendering)
- `MTMathAtomFactory.add(latexSymbol:value:)` allows runtime additions but not replacements with different behavior

---

## Package Analysis

### 1. Environments & Alignment

| Package | Purpose | SwiftMath Status |
|---------|---------|------------------|
| **eqnarray** | Multi-line equations with alignment | ⚠️ Partial - `eqalign` exists, not `eqnarray` |
| **align** (amsmath) | Modern alignment environments | ✅ `aligned`, `split` work |
| **cases** | Piecewise functions | ✅ Implemented |

**Gap**: `eqnarray` environment specifically is not implemented.

### 2. Font Packages

| Package | Purpose | SwiftMath Status |
|---------|---------|------------------|
| **amsfont** | AMS fonts | ✅ Font switching works |
| **amstext** | `\text{}` command | ✅ Implemented |
| **blackboard** | `\mathbb{}` | ✅ Implemented |
| **euscript** | Euler script (`\mathscr`) | ❌ Not implemented |
| **eufrak** | Euler Fraktur | ✅ `\mathfrak` works |

**Gap**: `\mathscr` (script font, different from `\mathcal`) is missing.

### 3. Symbol Packages

| Package | Purpose | SwiftMath Status |
|---------|---------|------------------|
| **amssymb** | Extended math symbols | ⚠️ ~70% - Many symbols, some missing |
| **pmat** | Matrix typesetting | ✅ Matrices work well |

**amssymb gaps**:
- Some geometric symbols
- Some additional arrows
- Some additional relations

### 4. Derivative/Calculus Packages

| Package | Purpose | SwiftMath Status |
|---------|---------|------------------|
| **bropd** | Partial derivatives with better notation | ❌ Not implemented |

**bropd commands** (all missing):
- `\br{}` - Automatic parentheses
- `\pd{}{}` - Partial derivative
- `\pdd{}{}{}` - Second partial derivative
- `\od{}{}` - Ordinary derivative
- `\odd{}{}{}` - Second ordinary derivative

### 5. Physics Packages

| Package | Purpose | SwiftMath Status |
|---------|---------|------------------|
| **physics** | Quantum mechanics, vectors, derivatives | ❌ Not implemented |
| **physics-patch** | Fixes for physics package | ❌ N/A |
| **arsenalmath** | Extended math for physics | ❌ Not implemented |

**physics commands** (all missing):
- `\bra{}`, `\ket{}`, `\braket{}` - Dirac notation
- `\abs{}`, `\norm{}` - Absolute value, norm
- `\dv{}{}`, `\pdv{}{}` - Derivatives
- `\vb{}`, `\va{}` - Vector notation
- `\mqty{}` - Matrix shortcuts

### 6. Units Packages

| Package | Purpose | SwiftMath Status |
|---------|---------|------------------|
| **siunitx** | SI units with proper formatting | ❌ Not implemented |
| **sistyle** | Older SI units package | ❌ Not implemented |

**siunitx commands** (all missing):
- `\SI{10}{\meter}` → "10 m"
- `\si{\kilo\gram}` → "kg"
- `\num{12345.678}` → "12,345.678"
- `\ang{30}` → "30°"

### 7. Diagram Packages

| Package | Purpose | SwiftMath Status |
|---------|---------|------------------|
| **tikz-feynhand** | Feynman diagrams | ❌ Not implementable |

**Note**: TikZ-based packages require a drawing engine. SwiftMath renders math, not diagrams. This would require a completely different approach (SVG generation or CoreGraphics drawing).

---

## Chemistry Packages (User Asked)

| Package | Purpose | SwiftMath Status |
|---------|---------|------------------|
| **mhchem** | Chemical formulas: `\ce{H2O}` | ❌ Not implemented |
| **chemfig** | Structural formulas | ❌ Not implementable (TikZ-based) |
| **chemmacros** | Chemistry symbols | ❌ Not implemented |

**mhchem** would be valuable - it handles:
- `\ce{H2O}` → H₂O
- `\ce{Ca^2+}` → Ca²⁺
- `\ce{->}` → reaction arrows
- `\ce{A + B <=> C}` → equilibrium arrows

---

## Proposed Package System Architecture

### Option A: Compile-time Package Selection

```swift
// User could configure which packages to include
public struct SwiftMathConfiguration {
    public var packages: Set<MathPackage> = [.core, .amsmath, .amssymb]
}

public enum MathPackage {
    case core           // Basic LaTeX math
    case amsmath        // align, gather, cases, etc.
    case amssymb        // Extended symbols
    case physics        // bra, ket, derivatives
    case siunitx        // SI units
    case chemistry      // mhchem-style commands
}
```

### Option B: Runtime Package Loading

```swift
// Packages register their symbols at runtime
public protocol MathPackage {
    static var name: String { get }
    static var symbols: [String: MTMathAtom] { get }
    static var commands: [String: CommandHandler] { get }
    static var overrides: [String: MTMathAtom] { get } // Replace existing
}

// Usage
MTMathPackageManager.load(PhysicsPackage.self)
MTMathPackageManager.load(SIUnitxPackage.self)
```

### Benefits of Package System

1. **Modularity**: Only load what you need
2. **Conflict Resolution**: Choose which package's `\phi` to use
3. **Extensibility**: Users can create custom packages
4. **Smaller Footprint**: Core-only for simple apps
5. **Behavior Morphing**: Different packages can provide different implementations

### Implementation Considerations

1. **Symbol Registry**: Replace static dictionaries with a mutable registry
2. **Priority System**: Later-loaded packages can override earlier ones
3. **Dependencies**: Packages can depend on other packages
4. **Command Handlers**: For complex commands like `\ce{}` that need custom parsing

---

## Prioritized Implementation Roadmap

### High Value, Low Effort
1. `\mathscr` (euscript) - Just add font style
2. Missing spacing: `\:` (medium space)
3. `\overset`, `\underset` - Common amsmath commands
4. Additional amssymb symbols

### High Value, Medium Effort
5. **physics package basics**: `\bra`, `\ket`, `\abs`, `\norm`
6. **mhchem basics**: `\ce{}` for chemical formulas
7. `\boxed{}` - Box around equations
8. `\operatorname*{}` - With limits

### Medium Value, Higher Effort
9. **siunitx basics**: `\SI{}{}`, `\si{}`
10. **bropd**: Derivative notation
11. Package selection system architecture

### Lower Priority / Complex
12. Full siunitx (number formatting, unit macros)
13. TikZ-based packages (would need different approach)

---

## Existing Features by "Package" Origin

### Core LaTeX
- Basic math: +, -, ×, ÷, fractions, roots
- Greek letters (α-ω, Α-Ω)
- Basic relations (=, <, >, ≤, ≥)
- Subscripts, superscripts

### amsmath (Mostly Implemented)
| Feature | Status |
|---------|--------|
| `\frac`, `\dfrac`, `\tfrac`, `\cfrac` | ✅ |
| `align`, `aligned`, `gather` | ✅ |
| `cases` | ✅ |
| `matrix`, `pmatrix`, `bmatrix` | ✅ |
| `\text{}` | ✅ |
| `\overset`, `\underset` | ❌ |
| `\sideset` | ❌ |
| `\boxed` | ❌ |
| `\substack` | ✅ |
| Multiple integrals | ✅ |

### amssymb (Partially Implemented)
| Feature | Status |
|---------|--------|
| Negated relations | ✅ (just added) |
| Blackboard bold | ✅ |
| Additional arrows | ⚠️ Partial |
| Geometric symbols | ⚠️ Partial |

### Font Commands
| Command | Package Origin | Status |
|---------|----------------|--------|
| `\mathbb{}` | amsfonts | ✅ |
| `\mathcal{}` | core | ✅ |
| `\mathfrak{}` | amsfonts | ✅ |
| `\mathscr{}` | mathrsfs/euscript | ❌ |
| `\boldsymbol{}` | amsmath | ❌ |

---

## Summary

**Current State**: SwiftMath is a well-implemented core LaTeX math renderer with good amsmath/amssymb coverage but no package modularity.

**Key Gaps**:
1. No package selection mechanism
2. Missing physics notation (`\bra`, `\ket`)
3. No chemistry support (`\ce{}`)
4. No units support (`\SI{}{}`)
5. Missing `\mathscr`, `\boldsymbol`
6. Missing `\overset`, `\underset`

**Recommendation**: Implement a lightweight package registry system that allows:
- Runtime symbol/command registration
- Override capability for behavior morphing
- Optional lazy loading of package definitions
