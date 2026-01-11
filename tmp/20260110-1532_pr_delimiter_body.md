## Summary

This PR implements manual delimiter sizing commands (`\big`, `\Big`, `\bigg`, `\Bigg` and variants) for precise control of delimiter heights.

### Supported Commands

| Command Family | Size Multiplier | Description |
|----------------|-----------------|-------------|
| `\big`, `\bigl`, `\bigr`, `\bigm` | 1.0x font size | Slightly larger than normal |
| `\Big`, `\Bigl`, `\Bigr`, `\Bigm` | 1.4x font size | Larger |
| `\bigg`, `\biggl`, `\biggr`, `\biggm` | 1.8x font size | Even larger |
| `\Bigg`, `\Biggl`, `\Biggr`, `\Biggm` | 2.2x font size | Largest |

### Implementation

- Add `delimiterHeight` property to `MTInner` class for explicit height control
- Add `delimiterSizeCommands` dictionary in `MTMathListBuilder` mapping commands to multipliers
- Parse delimiter commands and create `MTInner` atoms with explicit height
- Modify `MTTypesetter.makeLeftRight()` to use explicit height when set

## Test Plan

- [x] Unit tests for all delimiter sizing commands (6 tests)
- [x] Visual render tests generating 21 test images
- [x] Test delimiter size progression (sizes increase correctly)
- [x] All 326 existing tests pass

## Notes

- All changes are additive - no breaking changes to existing functionality
- Works alongside `\left...\right` auto-sizing delimiters
