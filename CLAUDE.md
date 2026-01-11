# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## First Principles

### 1. Respect Existing Code Patterns

**Philosophy**: This is a fork intended for upstream contribution. Changes must blend seamlessly with the existing codebase.

**Implementation implications**:
- Follow existing naming conventions, formatting, and code style exactly
- Add new symbols to `supportedLatexSymbols` using the same pattern as existing entries
- Use existing atom types (`.relation`, `.binaryOperator`, `.ordinary`, `.variable`) appropriately
- Maintain thread-safety patterns (use `NSLock` where existing code does)
- Do not refactor existing code unless absolutely required for a feature
- Preserve all existing tests and ensure they continue to pass

### 2. Feature-by-Feature Development with Documentation

**Philosophy**: Each feature should be a self-contained, reviewable unit ready for upstream PR.

**Implementation implications**:
- Work on one logical feature at a time (e.g., "add slanted inequalities", "add Greek variants")
- Each feature must include: code changes, unit tests, documentation updates
- Update `MISSING_FEATURES.md` when implementing features listed there
- Update `README.md` when adding user-facing capabilities
- Create atomic commits for each logical change
- Create PRs that can be reviewed and merged independently

### 3. Pull Request Process

**Philosophy**: PRs target the upstream repository for contribution back to the main project.

**Implementation implications**:
- PRs must target `mgriebling/SwiftMath` (upstream), not our own fork
- PR body must use plain markdown only - NO ANSI escape codes or terminal formatting
- ALWAYS use --body-file with a clean markdown file, never use --body with heredoc/string
- After creating upstream PR, merge dev to main locally to keep fork in sync
- Continue development on dev branch for next feature
- Verify PR content is clean before finishing (use `gh pr view --json body`)

**PR Creation Process**:
1. Write PR body to a temporary file (tmp/pr_body.md)
2. Verify file contains only plain markdown
3. Create PR: `gh pr create --repo mgriebling/SwiftMath --base main --head ChrisGVE:dev --title "..." --body-file tmp/pr_body.md`
4. Verify PR: `gh pr view <number> --repo mgriebling/SwiftMath --json body`
5. Delete temporary file
6. Merge dev to main locally and push

## Build & Test Commands

```bash
# Build the package
swift build

# Run all tests
swift test

# Run a single test class
swift test --filter MTMathListBuilderTests

# Run a specific test method
swift test --filter MTMathListBuilderTests.testBuilder
```

## Architecture Overview

ExtendedSwiftMath is a Swift implementation of LaTeX math rendering for iOS (11+) and macOS (12+). The package name is `ExtendedSwiftMath` but the product/module is `SwiftMath` for drop-in compatibility.

### Core Processing Pipeline

**LaTeX String → MTMathList → MTDisplay → Rendered Output**

1. **MTMathListBuilder** (`MathRender/MTMathListBuilder.swift`) - Parses LaTeX strings into an abstract syntax tree (`MTMathList`). Handles math delimiters (`$...$`, `$$...$$`, `\(...\)`, `\[...\]`), commands, environments.

2. **MTMathList** (`MathRender/MTMathList.swift`) - The AST representation. Contains `MTMathAtom` objects representing mathematical elements (variables, operators, fractions, radicals, etc.). Each atom has a `MTMathAtomType` that determines rendering and spacing.

3. **MTTypesetter** (`MathRender/MTTypesetter.swift`) - Converts `MTMathList` to `MTDisplay` tree using TeX typesetting rules. Handles inter-element spacing, script positioning, and line breaking.

4. **MTDisplay** (`MathRender/MTMathListDisplay.swift`) - The display tree that knows how to draw itself via CoreText/CoreGraphics.

5. **MTMathUILabel** (`MathRender/MTMathUILabel.swift`) - The UIView/NSView that hosts the rendered math. Entry point for most usage.

### Font System

Located in `MathBundle/`:

- **MathFont** (`MathFont.swift`) - Enum of 12 bundled OTF math fonts with thread-safe loading via `BundleManager`
- **MTFont** (`MathRender/MTFont.swift`) - Font wrapper with math metrics access
- **MTFontMathTable** (`MathRender/MTFontMathTable.swift`) - Parses OpenType MATH table data from `.plist` files

Each font has a `.otf` file and a companion `.plist` containing math metrics (generated via included Python script).

### Key Classes

- **MTMathAtomFactory** (`MathRender/MTMathAtomFactory.swift`) - Factory for creating atoms, includes command mappings (`aliases`, `delimiters`, `accents`, `supportedLatexSymbols`)
- **MTFontManager** (`MathRender/MTFontManager.swift`) - Manages font instances and defaults

### Platform Abstraction

Cross-platform types defined in `MathRender/`:
- `MTBezierPath` - UIBezierPath/NSBezierPath
- `MTColor` - UIColor/NSColor
- `MTView` - UIView/NSView (via `#if os(iOS)` conditionals)

### Line Wrapping

The typesetter supports automatic line breaking via `preferredMaxLayoutWidth` on `MTMathUILabel`. Uses interatom breaking (breaks between atoms) as primary mechanism, with Unicode word boundary breaking as fallback.

## Task Master AI Instructions

**Import Task Master's development workflow commands and guidelines, treat as if import is in the main CLAUDE.md file.**
@./.taskmaster/CLAUDE.md
