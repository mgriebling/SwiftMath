import XCTest
@testable import SwiftMath

// The rule under test: TYPESETTING NEVER CHANGES ITS INPUT.
//
// Consequences, both asserted here:
//   1. After typesetting a math list, every atom in it (recursively, through
//      sub/superscripts, inner lists, numerators, denominators, radicands) has
//      exactly the nucleus it had before.
//   2. Typesetting the same list N times produces the same display.
//
// Historically neither held. `MTTypesetter.preprocessMathList` mutates the
// atoms it is given: it rewrites `type` and `nucleus`, and
// `MTMathAtom.fuse(with:)` appends the following atom's nucleus onto the
// previous atom. Every internal typeset request goes through
// `createLineForMathListWithTokenization`, which preprocessed the caller's own
// atoms. Because `makeLeftRight` and the accent path typeset their inner list
// more than once, the second pass fused already-fused text again:
// `x\left( x+3y\right) +y^{2}=0` rendered as `x(x+3yy)+y²=0` (issue #66, PR #70
// fixed only the double-typeset symptom in `makeLeftRight`).
//
// These tests use the INTERNAL entry point on purpose — the two public
// `createLineForMathList` overloads copy via `finalized` first and so would
// hide the mutation.
final class TypesetIdempotenceTests: XCTestCase {

    private var font: MTFont!

    override func setUp() {
        super.setUp()
        font = MTFontManager.fontManager.defaultFont
    }

    // MARK: - Recursive nucleus snapshot

    /// Every nucleus in the list, depth first, including all sublists.
    /// Structural changes (fusion removes atoms) show up as a shorter array,
    /// content changes (`nucleus += other.nucleus`) as a different string, so a
    /// plain `XCTAssertEqual` on these arrays names the exact corruption.
    private func nuclei(of list: MTMathList?) -> [String] {
        guard let list = list else { return [] }
        var out = [String]()
        for atom in list.atoms {
            out.append(atom.nucleus)
            out.append(contentsOf: nuclei(of: atom.superScript))
            out.append(contentsOf: nuclei(of: atom.subScript))
            switch atom {
                case let frac as MTFraction:
                    out.append(contentsOf: nuclei(of: frac.numerator))
                    out.append(contentsOf: nuclei(of: frac.denominator))
                case let rad as MTRadical:
                    out.append(contentsOf: nuclei(of: rad.degree))
                    out.append(contentsOf: nuclei(of: rad.radicand))
                case let inner as MTInner:
                    out.append(contentsOf: nuclei(of: inner.innerList))
                case let accent as MTAccent:
                    out.append(contentsOf: nuclei(of: accent.innerList))
                case let over as MTOverLine:
                    out.append(contentsOf: nuclei(of: over.innerList))
                case let under as MTUnderLine:
                    out.append(contentsOf: nuclei(of: under.innerList))
                case let color as MTMathColor:
                    out.append(contentsOf: nuclei(of: color.innerList))
                case let color as MTMathTextColor:
                    out.append(contentsOf: nuclei(of: color.innerList))
                case let box as MTMathColorbox:
                    out.append(contentsOf: nuclei(of: box.innerList))
                default:
                    break
            }
        }
        return out
    }

    /// The internal (non-copying) typeset entry point.
    private func typeset(_ list: MTMathList) -> MTMathListDisplay? {
        MTTypesetter.createLineForMathList(list, font: font, style: .display,
                                           cramped: false, spaced: false, maxWidth: 0)
    }

    private static let cases = [
        "\\left( 3y\\right) y",
        "x\\left( x+3y\\right) +y^{2}=0",
        "\\left[ ab\\right] +\\left( cd\\right)",
        "\\hat{ab}^{2}",
        "\\widehat{abc}",
        "\\sqrt{\\left( xy\\right)}",
        "\\frac{\\left( ab\\right)}{cd}",
    ]

    // MARK: - Rule: typesetting never changes its input

    func testTypesettingDoesNotChangeItsInput() throws {
        for latex in Self.cases {
            guard let list = MTMathListBuilder.build(fromString: latex) else {
                XCTFail("Could not build \(latex)")
                continue
            }
            let before = nuclei(of: list)
            XCTAssertFalse(before.isEmpty, "\(latex): empty list")

            XCTAssertNotNil(typeset(list), "\(latex): first typeset returned nil")
            XCTAssertEqual(nuclei(of: list), before,
                           "\(latex): the list was mutated by the FIRST typeset pass")

            XCTAssertNotNil(typeset(list), "\(latex): second typeset returned nil")
            XCTAssertEqual(nuclei(of: list), before,
                           "\(latex): the list was mutated by the SECOND typeset pass")
        }
    }

    // MARK: - Rule: typesetting the same list twice gives the same display

    func testTypesettingSameListTwiceGivesSameDisplay() throws {
        for latex in Self.cases {
            guard let list = MTMathListBuilder.build(fromString: latex) else {
                XCTFail("Could not build \(latex)")
                continue
            }
            guard let first = typeset(list), let second = typeset(list) else {
                XCTFail("\(latex): typesetting returned nil")
                continue
            }
            XCTAssertEqual(first.width, second.width, accuracy: 0.0001,
                           "\(latex): width changed on the second typeset pass")
            XCTAssertEqual(first.ascent, second.ascent, accuracy: 0.0001,
                           "\(latex): ascent changed on the second typeset pass")
            XCTAssertEqual(first.descent, second.descent, accuracy: 0.0001,
                           "\(latex): descent changed on the second typeset pass")
            XCTAssertEqual(first.subDisplays.count, second.subDisplays.count,
                           "\(latex): sub-display count changed on the second typeset pass")
        }
    }

    /// The concrete symptom from issue #66, stated as a nucleus assertion so a
    /// regression names itself: the `3` and `y` inside `\left(...\right)` must
    /// still be two separate one-character atoms after typesetting.
    func testLeftRightInnerAtomsAreNotFused() throws {
        let list = try XCTUnwrap(MTMathListBuilder.build(fromString: "x\\left( x+3y\\right) +y^{2}=0"))
        _ = typeset(list)
        _ = typeset(list)
        let inner = try XCTUnwrap(list.atoms.compactMap { $0 as? MTInner }.first)
        XCTAssertEqual(nuclei(of: inner.innerList), ["x", "+", "3", "y"],
                       "Inner list of \\left...\\right was fused in place by typesetting")
    }

    // MARK: - Accents do not depend on prior typesets

    /// A freshly parsed list and a list that has already been typeset twice must
    /// produce identical accent geometry. Before the fix, the accented content
    /// was fused in place by the first pass, which both changed the wide-accent
    /// glyph-variant choice and (for `\hat{x}^2`) permanently moved the scripts
    /// off the accent onto the inner atom.
    func testAccentWidthDoesNotDependOnPriorTypesets() throws {
        for latex in ["\\widehat{ab}", "\\hat{x}^{2}"] {
            let reused = try XCTUnwrap(MTMathListBuilder.build(fromString: latex))
            _ = typeset(reused)
            let afterReuse = try XCTUnwrap(typeset(reused))

            let fresh = try XCTUnwrap(MTMathListBuilder.build(fromString: latex))
            let freshDisplay = try XCTUnwrap(typeset(fresh))

            XCTAssertEqual(afterReuse.width, freshDisplay.width, accuracy: 0.0001,
                           "\(latex): width depends on how many times the list was typeset")
            XCTAssertEqual(afterReuse.ascent, freshDisplay.ascent, accuracy: 0.0001,
                           "\(latex): ascent depends on how many times the list was typeset")
            XCTAssertEqual(afterReuse.descent, freshDisplay.descent, accuracy: 0.0001,
                           "\(latex): descent depends on how many times the list was typeset")
        }
    }

    /// `getWideAccentContentLength` counts the characters under a wide accent to
    /// pick a glyph variant. It reads `accent.innerList` AFTER that list has been
    /// typeset. While typesetting fused the inner list in place, the two atoms of
    /// `\widehat{ab}` had already collapsed into one `.ordinary` atom, which the
    /// counter scores as 1. With the input left alone it correctly counts 2.
    func testWideAccentContentLengthCountsUnfusedContent() throws {
        let list = try XCTUnwrap(MTMathListBuilder.build(fromString: "\\widehat{ab}"))
        _ = typeset(list)
        let accent = try XCTUnwrap(list.atoms.compactMap { $0 as? MTAccent }.first)
        let typesetter = MTTypesetter(withFont: font, style: .display, cramped: false, spaced: false)
        XCTAssertEqual(typesetter.getWideAccentContentLength(accent), 2,
                       "Accented content was fused in place by typesetting")
    }
}
