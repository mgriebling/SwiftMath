## Summary

This PR implements manual delimiter sizing commands (`\big`, `\Big`, `\bigg`, `\Bigg` and variants) for SwiftMath.

### Changes

- Add `delimiterHeight` property to `MTInner` class for explicit size control
- Add `delimiterSizeCommands` dictionary with size multipliers (1.2x, 1.8x, 2.4x, 3.0x)
- Parse sizing commands and create `MTInner` atoms with explicit delimiter height
- Modify `MTTypesetter.makeLeftRight()` to use explicit height when provided

### Supported Commands

| Command Family | Size | Multiplier |
|----------------|------|------------|
| `\big`, `\bigl`, `\bigr`, `\bigm` | Slightly larger | 1.2x font size |
| `\Big`, `\Bigl`, `\Bigr`, `\Bigm` | Larger | 1.8x font size |
| `\bigg`, `\biggl`, `\biggr`, `\biggm` | Even larger | 2.4x font size |
| `\Bigg`, `\Biggl`, `\Biggr`, `\Biggm` | Largest | 3.0x font size |

### Examples

```latex
\big( x \big)        % slightly larger parentheses
\Big[ y \Big]        % larger brackets
\bigg\{ z \bigg\}    % even larger braces
\Bigg| w \Bigg|      % largest vertical bars
```

## Test Plan

- [x] Add unit tests for basic sizing commands (`\big`, `\Big`, `\bigg`, `\Bigg`)
- [x] Add unit tests for left/right variants (`\bigl`, `\bigr`, etc.)
- [x] Add unit tests for middle variants (`\bigm`, etc.)
- [x] Add unit tests for error handling (missing/invalid delimiter)
- [x] Add unit tests for sizing commands in expressions
- [x] Verify all existing tests pass

Generated with [Claude Code](https://claude.com/claude-code)
