//
//  MTAtomTokenizerTests.swift
//  SwiftMathTests
//
//  Created by Claude Code on 2025-12-16.
//

import XCTest
@testable import SwiftMath

class MTAtomTokenizerTests: XCTestCase {

    var font: MTFont!
    var tokenizer: MTAtomTokenizer!

    override func setUp() {
        super.setUp()
        font = MTFont(fontWithName: "latinmodern-math", size: 20)
        tokenizer = MTAtomTokenizer(font: font, style: .display, cramped: false)
    }

    override func tearDown() {
        font = nil
        tokenizer = nil
        super.tearDown()
    }

    // MARK: - Basic Tokenization Tests

    func testTokenizeEmptyList() {
        let elements = tokenizer.tokenize([])
        XCTAssertEqual(elements.count, 0)
    }

    func testTokenizeSingleOrdinaryAtom() {
        let atom = MTMathAtom(type: .ordinary, value: "x")
        let elements = tokenizer.tokenize([atom])

        XCTAssertEqual(elements.count, 1)
        XCTAssertTrue(elements[0].isBreakBefore)
        XCTAssertTrue(elements[0].isBreakAfter)
        XCTAssertFalse(elements[0].indivisible)
    }

    func testTokenizeVariable() {
        let atom = MTMathAtom(type: .variable, value: "y")
        let elements = tokenizer.tokenize([atom])

        XCTAssertEqual(elements.count, 1)
        if case .text(let text) = elements[0].content {
            XCTAssertEqual(text, "y")
        } else {
            XCTFail("Expected text content")
        }
    }

    func testTokenizeNumber() {
        let atom = MTMathAtom(type: .number, value: "42")
        let elements = tokenizer.tokenize([atom])

        XCTAssertEqual(elements.count, 1)
        XCTAssertGreaterThan(elements[0].width, 0)
    }

    // MARK: - Operator Tokenization Tests

    func testTokenizeBinaryOperator() {
        let atom = MTMathAtom(type: .binaryOperator, value: "+")
        let elements = tokenizer.tokenize([atom])

        XCTAssertEqual(elements.count, 1)
        XCTAssertEqual(elements[0].penaltyBefore, MTBreakPenalty.best)
        XCTAssertEqual(elements[0].penaltyAfter, MTBreakPenalty.best)

        if case .operator(let op, let type) = elements[0].content {
            XCTAssertEqual(op, "+")
            XCTAssertEqual(type, .binaryOperator)
        } else {
            XCTFail("Expected operator content")
        }
    }

    func testTokenizeRelationOperator() {
        let atom = MTMathAtom(type: .relation, value: "=")
        let elements = tokenizer.tokenize([atom])

        XCTAssertEqual(elements.count, 1)
        XCTAssertEqual(elements[0].penaltyBefore, MTBreakPenalty.best)
    }

    func testTokenizeMultipleOperators() {
        let atoms = [
            MTMathAtom(type: .variable, value: "x"),
            MTMathAtom(type: .binaryOperator, value: "+"),
            MTMathAtom(type: .variable, value: "y")
        ]
        let elements = tokenizer.tokenize(atoms)

        XCTAssertEqual(elements.count, 3)
    }

    // MARK: - Delimiter Tokenization Tests

    func testTokenizeOpenDelimiter() {
        let atom = MTMathAtom(type: .open, value: "(")
        let elements = tokenizer.tokenize([atom])

        XCTAssertEqual(elements.count, 1)
        XCTAssertTrue(elements[0].isBreakBefore)
        XCTAssertFalse(elements[0].isBreakAfter, "Should NOT break after open delimiter")
    }

    func testTokenizeCloseDelimiter() {
        let atom = MTMathAtom(type: .close, value: ")")
        let elements = tokenizer.tokenize([atom])

        XCTAssertEqual(elements.count, 1)
        XCTAssertFalse(elements[0].isBreakBefore, "Should NOT break before close delimiter")
        XCTAssertTrue(elements[0].isBreakAfter)
    }

    // MARK: - Punctuation Tokenization Tests

    func testTokenizePunctuation() {
        let atom = MTMathAtom(type: .punctuation, value: ",")
        let elements = tokenizer.tokenize([atom])

        XCTAssertEqual(elements.count, 1)
        XCTAssertFalse(elements[0].isBreakBefore, "Should NOT break before punctuation")
        XCTAssertTrue(elements[0].isBreakAfter)
    }

    // MARK: - Script Tokenization Tests

    func testTokenizeAtomWithSuperscript() {
        let atom = MTMathAtom(type: .variable, value: "x")
        let superScript = MTMathList()
        superScript.add(MTMathAtom(type: .number, value: "2"))
        atom.superScript = superScript

        let elements = tokenizer.tokenize([atom])

        // Should have base + superscript = 2 elements
        XCTAssertGreaterThanOrEqual(elements.count, 2)

        // All elements should share same groupId
        if elements.count >= 2 {
            XCTAssertNotNil(elements[0].groupId)
            XCTAssertEqual(elements[0].groupId, elements[1].groupId)

            // Base cannot break after
            XCTAssertFalse(elements[0].isBreakAfter)

            // Superscript cannot break before
            XCTAssertFalse(elements[1].isBreakBefore)
        }
    }

    func testTokenizeAtomWithSubscript() {
        let atom = MTMathAtom(type: .variable, value: "x")
        let subScript = MTMathList()
        subScript.add(MTMathAtom(type: .variable, value: "i"))
        atom.subScript = subScript

        let elements = tokenizer.tokenize([atom])

        XCTAssertGreaterThanOrEqual(elements.count, 2)

        if elements.count >= 2 {
            // Should be grouped
            XCTAssertNotNil(elements[0].groupId)
            XCTAssertEqual(elements[0].groupId, elements[1].groupId)
        }
    }

    func testTokenizeAtomWithBothScripts() {
        let atom = MTMathAtom(type: .variable, value: "x")

        let subScript = MTMathList()
        subScript.add(MTMathAtom(type: .variable, value: "i"))
        atom.subScript = subScript

        let superScript = MTMathList()
        superScript.add(MTMathAtom(type: .number, value: "2"))
        atom.superScript = superScript

        let elements = tokenizer.tokenize([atom])

        // Should have base + subscript + superscript = 3 elements
        XCTAssertGreaterThanOrEqual(elements.count, 3)

        if elements.count >= 3 {
            // All should share groupId
            let groupId = elements[0].groupId
            XCTAssertNotNil(groupId)
            XCTAssertEqual(elements[1].groupId, groupId)
            XCTAssertEqual(elements[2].groupId, groupId)
        }
    }

    // MARK: - Complex Structure Tests

    func testTokenizeFraction() {
        let fraction = MTFraction()
        fraction.numerator = MTMathList()
        fraction.numerator?.add(MTMathAtom(type: .variable, value: "a"))
        fraction.denominator = MTMathList()
        fraction.denominator?.add(MTMathAtom(type: .variable, value: "b"))

        let elements = tokenizer.tokenize([fraction])

        XCTAssertEqual(elements.count, 1, "Fraction should be single atomic element")
        XCTAssertTrue(elements[0].indivisible, "Fraction must be indivisible")

        if case .display(let display) = elements[0].content {
            XCTAssertTrue(display is MTFractionDisplay)
        } else {
            XCTFail("Expected display content for fraction")
        }
    }

    func testTokenizeRadical() {
        let radical = MTRadical()
        radical.radicand = MTMathList()
        radical.radicand?.add(MTMathAtom(type: .variable, value: "x"))

        let elements = tokenizer.tokenize([radical])

        XCTAssertEqual(elements.count, 1, "Radical should be single atomic element")
        XCTAssertTrue(elements[0].indivisible, "Radical must be indivisible")
    }

    // MARK: - Integration Tests

    func testTokenizeSimpleEquation() {
        // x + y = z
        let atoms = [
            MTMathAtom(type: .variable, value: "x"),
            MTMathAtom(type: .binaryOperator, value: "+"),
            MTMathAtom(type: .variable, value: "y"),
            MTMathAtom(type: .relation, value: "="),
            MTMathAtom(type: .variable, value: "z")
        ]

        let elements = tokenizer.tokenize(atoms)

        XCTAssertEqual(elements.count, 5)

        // Verify break points: should be able to break before/after operators
        XCTAssertTrue(elements[1].isBreakBefore)  // + operator
        XCTAssertTrue(elements[1].isBreakAfter)
        XCTAssertTrue(elements[3].isBreakBefore)  // = operator
        XCTAssertTrue(elements[3].isBreakAfter)
    }

    func testTokenizeParenthesizedExpression() {
        // (x + y)
        let atoms = [
            MTMathAtom(type: .open, value: "("),
            MTMathAtom(type: .variable, value: "x"),
            MTMathAtom(type: .binaryOperator, value: "+"),
            MTMathAtom(type: .variable, value: "y"),
            MTMathAtom(type: .close, value: ")")
        ]

        let elements = tokenizer.tokenize(atoms)

        XCTAssertEqual(elements.count, 5)

        // Cannot break after open paren
        XCTAssertFalse(elements[0].isBreakAfter)

        // Cannot break before close paren
        XCTAssertFalse(elements[4].isBreakBefore)
    }

    func testTokenizeComplexExpression() {
        // x^2 + y
        let x = MTMathAtom(type: .variable, value: "x")
        let superScript = MTMathList()
        superScript.add(MTMathAtom(type: .number, value: "2"))
        x.superScript = superScript

        let atoms: [MTMathAtom] = [
            x,
            MTMathAtom(type: .binaryOperator, value: "+"),
            MTMathAtom(type: .variable, value: "y")
        ]

        let elements = tokenizer.tokenize(atoms)

        // x^2 produces 2 elements (base + script), + is 1, y is 1 = 4 total
        XCTAssertGreaterThanOrEqual(elements.count, 4)
    }

    // MARK: - Width Tests

    func testElementWidthsArePositive() {
        let atoms = [
            MTMathAtom(type: .variable, value: "x"),
            MTMathAtom(type: .binaryOperator, value: "+"),
            MTMathAtom(type: .number, value: "1")
        ]

        let elements = tokenizer.tokenize(atoms)

        for element in elements {
            XCTAssertGreaterThan(element.width, 0, "All elements should have positive width")
        }
    }
}
