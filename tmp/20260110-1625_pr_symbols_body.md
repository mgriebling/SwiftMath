## Summary

This PR adds Priority 1 LaTeX symbols and 48 negated relation symbols from amssymb.

### Priority 1 Symbol Additions

**Bug Fix:**
- **varsigma**: Corrected Unicode from U+03C1 (rho) to U+03C2 (final sigma)

**New Symbol Mappings (18 symbols):**

| Category | Symbols |
|----------|---------|
| Greek variants | varkappa (U+03F0) |
| Arrows | longmapsto (U+27FC), hookrightarrow (U+21AA), hookleftarrow (U+21A9) |
| Slanted inequalities | leqslant (U+2A7D), geqslant (U+2A7E) |
| Precedence relations | preceq (U+2AAF), succeq (U+2AB0) |
| Turnstile relations | vdash (U+22A2), dashv (U+22A3), bowtie (U+22C8) |
| Binary operators | diamond (U+22C4) |
| Hebrew letters | beth (U+2136), gimel (U+2137), daleth (U+2138) |
| Miscellaneous | varnothing (U+2205), Box (U+25A1), measuredangle (U+2221) |

Note: digamma (U+03DD) and Digamma (U+03DC) were initially added but removed as they are not supported by Latin Modern Math font.

### Negated Relations (48 symbols)

| Category | Symbols |
|----------|---------|
| Inequality negations (14) | `\nless`, `\ngtr`, `\nleq`, `\ngeq`, `\nleqslant`, `\ngeqslant`, `\lneq`, `\gneq`, `\lneqq`, `\gneqq`, `\lnsim`, `\gnsim`, `\lnapprox`, `\gnapprox` |
| Ordering negations (10) | `\nprec`, `\nsucc`, `\npreceq`, `\nsucceq`, `\precneqq`, `\succneqq`, `\precnsim`, `\succnsim`, `\precnapprox`, `\succnapprox` |
| Similarity/Congruence (6) | `\nsim`, `\ncong`, `\nmid`, `\nshortmid`, `\nparallel`, `\nshortparallel` |
| Set relations (12) | `\nsubseteq`, `\nsupseteq`, `\subsetneq`, `\supsetneq`, `\subsetneqq`, `\supsetneqq`, `\varsubsetneq`, `\varsupsetneq`, `\varsubsetneqq`, `\varsupsetneqq`, `\notni`, `\nni` |
| Triangle (4) | `\ntriangleleft`, `\ntriangleright`, `\ntrianglelefteq`, `\ntrianglerighteq` |
| Turnstile (4) | `\nvdash`, `\nvDash`, `\nVdash`, `\nVDash` |
| Square subset (2) | `\nsqsubseteq`, `\nsqsupseteq` |

## Test Plan

- [x] Run existing tests to verify no regressions
- [x] Unit tests for all new symbols verify correct parsing and Unicode values
- [x] Visual render tests generate PNG images for verification:
  - Priority 1 symbols: 10 test images
  - Negated relations: 18 test images
- [x] Verify all test images render correctly

## Notes

- All changes are additive - no breaking changes
- Some Priority 1 symbols may overlap with PR #59

🤖 Generated with [Claude Code](https://claude.com/claude-code)
