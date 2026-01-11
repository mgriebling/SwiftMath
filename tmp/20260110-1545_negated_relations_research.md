# Negated Relations Research for Task 4

## amssymb Negated Relations - Unicode Code Points

### Inequality Negations
| Command | Unicode | Hex | Description |
|---------|---------|-----|-------------|
| `\nless` | ≮ | U+226E | Not less than |
| `\ngtr` | ≯ | U+226F | Not greater than |
| `\nleq` | ≰ | U+2270 | Not less than or equal |
| `\ngeq` | ≱ | U+2271 | Not greater than or equal |
| `\nleqslant` | ⪇ | U+2A87 | Not less than or slanted equal |
| `\ngeqslant` | ⪈ | U+2A88 | Not greater than or slanted equal |
| `\lneq` | ⪇ | U+2A87 | Less than and not equal |
| `\gneq` | ⪈ | U+2A88 | Greater than and not equal |
| `\lneqq` | ≨ | U+2268 | Less than but not equal |
| `\gneqq` | ≩ | U+2269 | Greater than but not equal |
| `\lvertneqq` | ≨︀ | U+2268 + U+FE00 | Less than but not equal (variant) |
| `\gvertneqq` | ≩︀ | U+2269 + U+FE00 | Greater than but not equal (variant) |
| `\lnsim` | ⋦ | U+22E6 | Less than but not similar |
| `\gnsim` | ⋧ | U+22E7 | Greater than but not similar |
| `\lnapprox` | ⪉ | U+2A89 | Less than and not approximate |
| `\gnapprox` | ⪊ | U+2A8A | Greater than and not approximate |

### Ordering Negations
| Command | Unicode | Hex | Description |
|---------|---------|-----|-------------|
| `\nprec` | ⊀ | U+2280 | Does not precede |
| `\nsucc` | ⊁ | U+2281 | Does not succeed |
| `\npreceq` | ⋠ | U+22E0 | Does not precede or equal |
| `\nsucceq` | ⋡ | U+22E1 | Does not succeed or equal |
| `\precneqq` | ⪵ | U+2AB5 | Precedes but not equal |
| `\succneqq` | ⪶ | U+2AB6 | Succeeds but not equal |
| `\precnsim` | ⋨ | U+22E8 | Precedes but not similar |
| `\succnsim` | ⋩ | U+22E9 | Succeeds but not similar |
| `\precnapprox` | ⪹ | U+2AB9 | Precedes but not approximate |
| `\succnapprox` | ⪺ | U+2ABA | Succeeds but not approximate |

### Similarity/Congruence Negations
| Command | Unicode | Hex | Description |
|---------|---------|-----|-------------|
| `\nsim` | ≁ | U+2241 | Not similar |
| `\ncong` | ≇ | U+2247 | Not congruent |
| `\nshortmid` | ∤ | U+2224 | Does not divide (short) |
| `\nmid` | ∤ | U+2224 | Does not divide |
| `\nshortparallel` | ∦ | U+2226 | Not parallel (short) |
| `\nparallel` | ∦ | U+2226 | Not parallel |

### Set Relation Negations
| Command | Unicode | Hex | Description |
|---------|---------|-----|-------------|
| `\nsubseteq` | ⊈ | U+2288 | Not subset or equal |
| `\nsupseteq` | ⊉ | U+2289 | Not superset or equal |
| `\nsubseteqq` | ⊊ | U+228A | Not strict subset or equal |
| `\nsupseteqq` | ⊋ | U+228B | Not strict superset or equal |
| `\subsetneq` | ⊊ | U+228A | Strict subset not equal |
| `\supsetneq` | ⊋ | U+228B | Strict superset not equal |
| `\subsetneqq` | ⫋ | U+2ACB | Subset not double equal |
| `\supsetneqq` | ⫌ | U+2ACC | Superset not double equal |
| `\varsubsetneq` | ⊊︀ | U+228A + U+FE00 | Variant strict subset |
| `\varsupsetneq` | ⊋︀ | U+228B + U+FE00 | Variant strict superset |
| `\varsubsetneqq` | ⫋︀ | U+2ACB + U+FE00 | Variant subset not double equal |
| `\varsupsetneqq` | ⫌︀ | U+2ACC + U+FE00 | Variant superset not double equal |

### Triangle Negations
| Command | Unicode | Hex | Description |
|---------|---------|-----|-------------|
| `\ntriangleleft` | ⋪ | U+22EA | Not normal subgroup of |
| `\ntriangleright` | ⋫ | U+22EB | Not normal supergroup of |
| `\ntrianglelefteq` | ⋬ | U+22EC | Not normal subgroup or equal |
| `\ntrianglerighteq` | ⋭ | U+22ED | Not normal supergroup or equal |

### Turnstile Negations
| Command | Unicode | Hex | Description |
|---------|---------|-----|-------------|
| `\nvdash` | ⊬ | U+22AC | Does not prove |
| `\nvDash` | ⊭ | U+22AD | Not true |
| `\nVdash` | ⊮ | U+22AE | Does not force |
| `\nVDash` | ⊯ | U+22AF | Not double turnstile |

### Square Subset Negations
| Command | Unicode | Hex | Description |
|---------|---------|-----|-------------|
| `\nsqsubseteq` | ⋢ | U+22E2 | Not square subset or equal |
| `\nsqsupseteq` | ⋣ | U+22E3 | Not square superset or equal |

### Miscellaneous Negations
| Command | Unicode | Hex | Description |
|---------|---------|-----|-------------|
| `\notin` | ∉ | U+2209 | Not element of |
| `\notni` | ∌ | U+220C | Does not contain |
| `\nni` | ∌ | U+220C | Does not contain (alias) |

---

## Implementation Notes

All these should be added as type `.relation` in supportedLatexSymbols.

For variant forms with U+FE00, we may need to use the base character only if fonts don't support variation selectors.

## Priority List (most commonly used)

High priority:
- nless, ngtr, nleq, ngeq
- nprec, nsucc, npreceq, nsucceq
- nsim, ncong
- nsubseteq, nsupseteq, subsetneq, supsetneq
- ntriangleleft, ntriangleright, ntrianglelefteq, ntrianglerighteq
- nvdash, nvDash, nVdash, nVDash
- nmid, nparallel
- notin, notni

Medium priority:
- nleqslant, ngeqslant
- lneq, gneq, lneqq, gneqq
- precneqq, succneqq
- nsqsubseteq, nsqsupseteq

Lower priority (less common):
- lnsim, gnsim, lnapprox, gnapprox
- precnsim, succnsim, precnapprox, succnapprox
- Variant forms with FE00
