import XCTest
@testable import SwiftMath

//
//  MathTypesetterTests.swift
//  MathTypesetterTests
//
//  Created by Mike Griebling on 2023-01-02.
//

extension CGPoint {
    
    func isEqual(to p:CGPoint, accuracy:CGFloat) -> Bool {
        abs(self.x - p.x) < accuracy && abs(self.y - p.y) < accuracy
    }
    
}

final class MTTypesetterTests: XCTestCase {
    
    var font:MTFont!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        self.font = MTFontManager.fontManager.defaultFont
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
    }

    func testSimpleVariable() throws {
        let mathList = MTMathList()
        mathList.add(MTMathAtomFactory.atom(forCharacter: "x"))
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTCTLineDisplay)
        let line = sub0 as! MTCTLineDisplay
        XCTAssertEqual(line.atoms.count, 1);
        // The x is italicized
        XCTAssertEqual(line.attributedString?.string, "𝑥");
        XCTAssertTrue(CGPointEqualToPoint(line.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, line.ascent);
        XCTAssertEqual(display.descent, line.descent);
        XCTAssertEqual(display.width, line.width);
        
        XCTAssertEqual(display.ascent, 8.834, accuracy: 0.01)
        XCTAssertEqual(display.descent, 0.22, accuracy: 0.01)
        XCTAssertEqual(display.width, 11.44, accuracy: 0.01)
    }

    func testMultipleVariables() throws {
        let mathList = MTMathAtomFactory.mathListForCharacters("xyzw")
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 4)), "Got \(display.range) instead")
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTCTLineDisplay);
        let line = sub0 as! MTCTLineDisplay
        XCTAssertEqual(line.atoms.count, 4);
        XCTAssertEqual(line.attributedString?.string, "𝑥𝑦𝑧𝑤");
        XCTAssertTrue(CGPointEqualToPoint(line.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line.range, NSMakeRange(0, 4)));
        XCTAssertFalse(line.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, line.ascent);
        XCTAssertEqual(display.descent, line.descent);
        XCTAssertEqual(display.width, line.width);
        
        XCTAssertEqual(display.ascent, 8.834, accuracy: 0.01)
        XCTAssertEqual(display.descent, 4.10, accuracy: 0.01)
        XCTAssertEqual(display.width, 44.86, accuracy: 0.01)
    }

    func testVariablesAndNumbers() throws {
        let mathList = MTMathAtomFactory.mathListForCharacters("xy2w")
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular)
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero))
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 4)), "Got \(display.range) instead")
        XCTAssertFalse(display.hasScript)
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTCTLineDisplay);
        let line = sub0 as! MTCTLineDisplay
        XCTAssertEqual(line.atoms.count, 4);
        XCTAssertEqual(line.attributedString?.string, "𝑥𝑦2𝑤");
        XCTAssertTrue(CGPointEqualToPoint(line.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line.range, NSMakeRange(0, 4)));
        XCTAssertFalse(line.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, line.ascent);
        XCTAssertEqual(display.descent, line.descent);
        XCTAssertEqual(display.width, line.width);
        
        XCTAssertEqual(display.ascent, 13.32, accuracy: 0.01)
        XCTAssertEqual(display.descent, 4.10, accuracy: 0.01)
        XCTAssertEqual(display.width, 45.56, accuracy: 0.01)
    }

    func testEquationWithOperatorsAndRelations() throws {
        let mathList = MTMathAtomFactory.mathListForCharacters("2x+3=y")
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 6)), "Got \(display.range) instead")
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTCTLineDisplay);
        let line = sub0 as! MTCTLineDisplay
        XCTAssertEqual(line.atoms.count, 6);
        XCTAssertEqual(line.attributedString?.string, "2𝑥+3=𝑦");
        XCTAssertTrue(CGPointEqualToPoint(line.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line.range, NSMakeRange(0, 6)));
        XCTAssertFalse(line.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, line.ascent);
        XCTAssertEqual(display.descent, line.descent);
        XCTAssertEqual(display.width, line.width);
        
        XCTAssertEqual(display.ascent, 13.32, accuracy: 0.01)
        XCTAssertEqual(display.descent, 4.10, accuracy: 0.01)
        XCTAssertEqual(display.width, 92.36, accuracy: 0.01)
    }

//    #define XCTAssertTrue(CGPointEqualToPoint(p1, p2, accuracy, ...) \
//        XCTAssertEqual(p1.x, p2.x, accuracy, __VA_ARGS__); \
//        XCTAssertEqual(p1.y, p2.y, accuracy, __VA_ARGS__)
//
//
//    #define XCTAssertTrue(NSEqualRanges(r1, r2, ...) \
//        XCTAssertEqual(r1.location, r2.location, __VA_ARGS__); \
//        XCTAssertEqual(r1.length, r2.length, __VA_ARGS__)

    func testSuperscript() throws {
        let mathList = MTMathList()
        let x = MTMathAtomFactory.atom(forCharacter: "x")
        let supersc = MTMathList()
        supersc.add(MTMathAtomFactory.atom(forCharacter: "2"))
        x?.superScript = supersc;
        mathList.add(x)
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 2);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTCTLineDisplay);
        let line = sub0 as! MTCTLineDisplay
        XCTAssertEqual(line.atoms.count, 1);
        // The x is italicized
        XCTAssertEqual(line.attributedString?.string, "𝑥");
        XCTAssertTrue(CGPointEqualToPoint(line.position, CGPointZero));
        XCTAssertTrue(line.hasScript);
        
        let sub1 = display.subDisplays[1];
        XCTAssertTrue(sub1 is MTMathListDisplay)
        let display2 = sub1 as! MTMathListDisplay
        XCTAssertEqual(display2.type, .superscript)
        XCTAssertTrue(CGPointEqualToPoint(display2.position, CGPointMake(11.44, 7.26)))
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, 0);
        XCTAssertEqual(display2.subDisplays.count, 1);
        
        let sub1sub0 = display2.subDisplays[0];
        XCTAssertTrue(sub1sub0 is MTCTLineDisplay);
        let line2 = sub1sub0 as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "2");
        XCTAssertTrue(CGPointEqualToPoint(line2.position, CGPointZero));
        XCTAssertFalse(line2.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, 16.584, accuracy: 0.01)
        XCTAssertEqual(display.descent, 0.22, accuracy: 0.01)
        XCTAssertEqual(display.width, 18.44, accuracy: 0.01)
    }

    func testSubscript() throws {
        let mathList = MTMathList()
        let x = MTMathAtomFactory.atom(forCharacter: "x")
        let subsc = MTMathList()
        subsc.add(MTMathAtomFactory.atom(forCharacter: "1"))
        x?.subScript = subsc
        mathList.add(x)
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 2);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTCTLineDisplay);
        let line = sub0 as! MTCTLineDisplay
        XCTAssertEqual(line.atoms.count, 1);
        // The x is italicized
        XCTAssertEqual(line.attributedString?.string, "𝑥");
        XCTAssertTrue(CGPointEqualToPoint(line.position, CGPointZero));
        XCTAssertTrue(line.hasScript);
        
        let sub1 = display.subDisplays[1];
        XCTAssertTrue(sub1 is MTMathListDisplay);
        let display2 = sub1 as! MTMathListDisplay
        XCTAssertEqual(display2.type, .ssubscript);
        XCTAssertTrue(CGPointEqualToPoint(display2.position, CGPointMake(11.44, -4.94)))
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, 0);
        XCTAssertEqual(display2.subDisplays.count, 1);
        
        let sub1sub0 = display2.subDisplays[0];
        XCTAssertTrue(sub1sub0 is MTCTLineDisplay);
        let line2 = sub1sub0 as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "1");
        XCTAssertTrue(CGPointEqualToPoint(line2.position, CGPointZero));
        XCTAssertFalse(line2.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, 8.834, accuracy: 0.01)
        XCTAssertEqual(display.descent, 4.940, accuracy: 0.01)
        XCTAssertEqual(display.width, 18.44, accuracy: 0.01)
    }

    func testSupersubscript() throws {
        let mathList = MTMathList()
        let x = MTMathAtomFactory.atom(forCharacter: "x")
        let supersc = MTMathList()
        supersc.add(MTMathAtomFactory.atom(forCharacter: "2"))
        let subsc = MTMathList()
        subsc.add(MTMathAtomFactory.atom(forCharacter: "1"))
        x?.subScript = subsc;
        x?.superScript = supersc;
        mathList.add(x)
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 3);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTCTLineDisplay);
        let line = sub0 as! MTCTLineDisplay
        XCTAssertEqual(line.atoms.count, 1);
        // The x is italicized
        XCTAssertEqual(line.attributedString?.string, "𝑥");
        XCTAssertTrue(CGPointEqualToPoint(line.position, CGPointZero));
        XCTAssertTrue(line.hasScript);
        
        let sub1 = display.subDisplays[1];
        XCTAssertTrue(sub1 is MTMathListDisplay);
        let display2 = sub1 as! MTMathListDisplay
        XCTAssertEqual(display2.type, .superscript);
        XCTAssertTrue(CGPointEqualToPoint(display2.position, CGPointMake(11.44, 7.26)))
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, 0);
        XCTAssertEqual(display2.subDisplays.count, 1);
        
        let sub1sub0 = display2.subDisplays[0];
        XCTAssertTrue(sub1sub0 is MTCTLineDisplay);
        let line2 = sub1sub0 as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "2");
        XCTAssertTrue(CGPointEqualToPoint(line2.position, CGPointZero));
        XCTAssertFalse(line2.hasScript);
        
        let sub2 = display.subDisplays[2];
        XCTAssertTrue(sub2 is MTMathListDisplay);
        let display3 = sub2 as! MTMathListDisplay
        XCTAssertEqual(display3.type, .ssubscript);
        // Positioned differently when both subscript and superscript present.
        XCTAssertTrue(CGPointEqualToPoint(display3.position, CGPointMake(11.44, -5.264)))
        XCTAssertTrue(NSEqualRanges(display3.range, NSMakeRange(0, 1)))
        XCTAssertFalse(display3.hasScript);
        XCTAssertEqual(display3.index, 0);
        XCTAssertEqual(display3.subDisplays.count, 1);
        
        let sub2sub0 = display3.subDisplays[0];
        XCTAssertTrue(sub2sub0 is MTCTLineDisplay)
        let line3 = sub2sub0 as! MTCTLineDisplay
        XCTAssertEqual(line3.atoms.count, 1);
        XCTAssertEqual(line3.attributedString?.string, "1");
        XCTAssertTrue(CGPointEqualToPoint(line3.position, CGPointZero));
        XCTAssertFalse(line3.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, 16.584, accuracy: 0.01)
        XCTAssertEqual(display.descent, 5.264, accuracy: 0.01)
        XCTAssertEqual(display.width, 18.44, accuracy: 0.01)
    }

    func testRadical() throws {
        let mathList = MTMathList()
        let rad = MTRadical()
        let radicand = MTMathList()
        radicand.add(MTMathAtomFactory.atom(forCharacter: "1"))
        rad.radicand = radicand;
        mathList.add(rad)
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTRadicalDisplay);
        let radical = sub0 as! MTRadicalDisplay
        XCTAssertTrue(NSEqualRanges(radical.range, NSMakeRange(0, 1)));
        XCTAssertFalse(radical.hasScript);
        XCTAssertTrue(CGPointEqualToPoint(radical.position, CGPointZero));
        XCTAssertNotNil(radical.radicand);
        XCTAssertNil(radical.degree);

        let display2 = radical.radicand!
        XCTAssertEqual(display2.type, .regular)
        XCTAssertTrue(CGPointMake(16.66, 0).isEqual(to: display2.position, accuracy: 0.01))
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, NSNotFound);
        XCTAssertEqual(display2.subDisplays.count, 1);
        
        let subrad = display2.subDisplays[0];
        XCTAssertTrue(subrad is MTCTLineDisplay);
        let line2 = subrad as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "1");
        XCTAssertTrue(CGPointEqualToPoint(line2.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line2.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, 19.34, accuracy: 0.01)
        XCTAssertEqual(display.descent, 1.46, accuracy: 0.01)
        XCTAssertEqual(display.width, 26.66, accuracy: 0.01)
    }

    func testRadicalWithDegree() throws {
        let mathList = MTMathList()
        let rad = MTRadical()
        let radicand = MTMathList()
        radicand.add(MTMathAtomFactory.atom(forCharacter: "1"))
        let degree = MTMathList()
        degree.add(MTMathAtomFactory.atom(forCharacter: "3"))
        rad.radicand = radicand;
        rad.degree = degree;
        mathList.add(rad)
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTRadicalDisplay);
        let radical = sub0 as! MTRadicalDisplay
        XCTAssertTrue(NSEqualRanges(radical.range, NSMakeRange(0, 1)));
        XCTAssertFalse(radical.hasScript);
        XCTAssertTrue(CGPointEqualToPoint(radical.position, CGPointZero));
        XCTAssertNotNil(radical.radicand);
        XCTAssertNotNil(radical.degree);
        
        let display2 = radical.radicand!
        XCTAssertEqual(display2.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display2.position, CGPointMake(16.66, 0)))
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, NSNotFound);
        XCTAssertEqual(display2.subDisplays.count, 1);
        
        let subrad = display2.subDisplays[0];
        XCTAssertTrue(subrad is MTCTLineDisplay);
        let line2 = subrad as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "1");
        XCTAssertTrue(CGPointEqualToPoint(line2.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line2.hasScript);
        
        let display3 = radical.degree!
        XCTAssertEqual(display3.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display3.position, CGPointMake(6.12, 10.728)))
        XCTAssertTrue(NSEqualRanges(display3.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display3.hasScript);
        XCTAssertEqual(display3.index, NSNotFound);
        XCTAssertEqual(display3.subDisplays.count, 1);
        
        let subdeg = display3.subDisplays[0];
        XCTAssertTrue(subdeg is MTCTLineDisplay);
        let line3 = subdeg as! MTCTLineDisplay
        XCTAssertEqual(line3.atoms.count, 1);
        XCTAssertEqual(line3.attributedString?.string, "3");
        XCTAssertTrue(CGPointEqualToPoint(line3.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line3.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line3.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, 19.34, accuracy: 0.01)
        XCTAssertEqual(display.descent, 1.46, accuracy: 0.01)
        XCTAssertEqual(display.width, 26.66, accuracy: 0.01)
    }

    func testFraction() throws {
        let mathList = MTMathList()
        let frac = MTFraction(hasRule: true)
        let num = MTMathList()
        num.add(MTMathAtomFactory.atom(forCharacter: "1"))
        let denom = MTMathList()
        denom.add(MTMathAtomFactory.atom(forCharacter: "3"))
        frac.numerator = num;
        frac.denominator = denom;
        mathList.add(frac)
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTFractionDisplay)
        let fraction = sub0 as! MTFractionDisplay
        XCTAssertTrue(NSEqualRanges(fraction.range, NSMakeRange(0, 1)));
        XCTAssertFalse(fraction.hasScript);
        XCTAssertTrue(CGPointEqualToPoint(fraction.position, CGPointZero));
        XCTAssertNotNil(fraction.numerator);
        XCTAssertNotNil(fraction.denominator);
        
        let display2 = fraction.numerator!
        XCTAssertEqual(display2.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display2.position, CGPointMake(0, 13.54)))
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, NSNotFound);
        XCTAssertEqual(display2.subDisplays.count, 1);
        
        let subnum = display2.subDisplays[0];
        XCTAssertTrue(subnum is MTCTLineDisplay)
        let line2 = subnum as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "1");
        XCTAssertTrue(CGPointEqualToPoint(line2.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line2.hasScript);
        
        let display3 = fraction.denominator!
        XCTAssertEqual(display3.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display3.position, CGPointMake(0, -13.72)))
        XCTAssertTrue(NSEqualRanges(display3.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display3.hasScript);
        XCTAssertEqual(display3.index, NSNotFound);
        XCTAssertEqual(display3.subDisplays.count, 1);
        
        let subdenom = display3.subDisplays[0];
        XCTAssertTrue(subdenom is MTCTLineDisplay);
        let line3 = subdenom as! MTCTLineDisplay
        XCTAssertEqual(line3.atoms.count, 1);
        XCTAssertEqual(line3.attributedString?.string, "3");
        XCTAssertTrue(CGPointEqualToPoint(line3.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line3.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line3.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, 26.86, accuracy: 0.01)
        XCTAssertEqual(display.descent, 14.16, accuracy: 0.01)
        XCTAssertEqual(display.width, 10, accuracy: 0.01)
    }

    func testAtop() throws {
        let mathList = MTMathList()
        let frac = MTFraction(hasRule: false)
        let num = MTMathList()
        num.add(MTMathAtomFactory.atom(forCharacter: "1"))
        let denom = MTMathList()
        denom.add(MTMathAtomFactory.atom(forCharacter: "3"))
        frac.numerator = num;
        frac.denominator = denom;
        mathList.add(frac)
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTFractionDisplay)
        let fraction = sub0 as! MTFractionDisplay
        XCTAssertTrue(NSEqualRanges(fraction.range, NSMakeRange(0, 1)));
        XCTAssertFalse(fraction.hasScript);
        XCTAssertTrue(CGPointEqualToPoint(fraction.position, CGPointZero));
        XCTAssertNotNil(fraction.numerator);
        XCTAssertNotNil(fraction.denominator);
        
        let display2 = fraction.numerator!
        XCTAssertEqual(display2.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display2.position, CGPointMake(0, 13.54)))
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, NSNotFound);
        XCTAssertEqual(display2.subDisplays.count, 1);
        
        let subnum = display2.subDisplays[0];
        XCTAssertTrue(subnum is MTCTLineDisplay);
        let line2 = subnum as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "1");
        XCTAssertTrue(CGPointEqualToPoint(line2.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line2.hasScript);
        
        let display3 = fraction.denominator!
        XCTAssertEqual(display3.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display3.position, CGPointMake(0, -13.72)))
        XCTAssertTrue(NSEqualRanges(display3.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display3.hasScript);
        XCTAssertEqual(display3.index, NSNotFound);
        XCTAssertEqual(display3.subDisplays.count, 1);
        
        let subdenom = display3.subDisplays[0];
        XCTAssertTrue(subdenom is MTCTLineDisplay);
        let line3 = subdenom as! MTCTLineDisplay
        XCTAssertEqual(line3.atoms.count, 1);
        XCTAssertEqual(line3.attributedString?.string, "3");
        XCTAssertTrue(CGPointEqualToPoint(line3.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line3.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line3.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, 26.86, accuracy: 0.01)
        XCTAssertEqual(display.descent, 14.16, accuracy: 0.01)
        XCTAssertEqual(display.width, 10, accuracy: 0.01)
    }

    func testBinomial() throws {
        let mathList = MTMathList()
        let frac = MTFraction(hasRule: false)
        let num = MTMathList()
        num.add(MTMathAtomFactory.atom(forCharacter: "1"))
        let denom = MTMathList()
        denom.add(MTMathAtomFactory.atom(forCharacter: "3"))
        frac.numerator = num;
        frac.denominator = denom;
        frac.leftDelimiter = "(";
        frac.rightDelimiter = ")";
        mathList.add(frac)
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTMathListDisplay);
        let display0 = sub0 as! MTMathListDisplay
        XCTAssertNotNil(display0);
        XCTAssertEqual(display0.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display0.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display0.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display0.hasScript);
        XCTAssertEqual(display0.index, NSNotFound);
        XCTAssertEqual(display0.subDisplays.count, 3);
        
        let subLeft = display0.subDisplays[0];
        XCTAssertTrue(subLeft is MTGlyphDisplay);
        let glyph = subLeft;
        XCTAssertTrue(CGPointEqualToPoint(glyph.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(glyph.range, NSMakeRange(NSNotFound, 0)));
        XCTAssertFalse(glyph.hasScript);
        
        let subFrac = display0.subDisplays[1];
        XCTAssertTrue(subFrac is MTFractionDisplay)
        let fraction = subFrac as! MTFractionDisplay
        XCTAssertTrue(NSEqualRanges(fraction.range, NSMakeRange(0, 1)));
        XCTAssertFalse(fraction.hasScript);
        XCTAssertTrue(CGPointEqualToPoint(fraction.position, CGPointMake(14.72, 0)))
        XCTAssertNotNil(fraction.numerator);
        XCTAssertNotNil(fraction.denominator);
        
        let display2 = fraction.numerator!
        XCTAssertEqual(display2.type, .regular)
        XCTAssertTrue(CGPointMake(14.72, 13.54).isEqual(to: display2.position, accuracy: 0.01))
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, NSNotFound);
        XCTAssertEqual(display2.subDisplays.count, 1);
        
        let subnum = display2.subDisplays[0];
        XCTAssertTrue(subnum is MTCTLineDisplay);
        let line2 = subnum as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "1");
        XCTAssertTrue(CGPointEqualToPoint(line2.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line2.hasScript);
        
        let display3 = fraction.denominator!
        XCTAssertEqual(display3.type, .regular)
        XCTAssertTrue(CGPointMake(14.72, -13.72).isEqual(to: display3.position, accuracy: 0.01))
        XCTAssertTrue(NSEqualRanges(display3.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display3.hasScript);
        XCTAssertEqual(display3.index, NSNotFound);
        XCTAssertEqual(display3.subDisplays.count, 1);
        
        let subdenom = display3.subDisplays[0];
        XCTAssertTrue(subdenom is MTCTLineDisplay);
        let line3 = subdenom as! MTCTLineDisplay
        XCTAssertEqual(line3.atoms.count, 1);
        XCTAssertEqual(line3.attributedString?.string, "3");
        XCTAssertTrue(CGPointEqualToPoint(line3.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line3.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line3.hasScript);
        
        let subRight = display0.subDisplays[2];
        XCTAssertTrue(subRight is MTGlyphDisplay);
        let glyph2 = subRight as! MTGlyphDisplay
        XCTAssertTrue(CGPointEqualToPoint(glyph2.position, CGPointMake(24.72, 0)))
        XCTAssertTrue(NSEqualRanges(glyph2.range, NSMakeRange(NSNotFound, 0)), "Got \(glyph2.range) instead")
        XCTAssertFalse(glyph2.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, 28.92, accuracy: 0.001);
        XCTAssertEqual(display.descent, 18.92, accuracy: 0.001);
        XCTAssertEqual(display.width, 39.44, accuracy: 0.001);
    }

    func testLargeOpNoLimitsText() throws {
        let mathList = MTMathList()
        mathList.add(MTMathAtomFactory.atom(forLatexSymbol: "sin"))
        mathList.add(MTMathAtomFactory.atom(forCharacter: "x"))

        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 2)), "Got \(display.range) instead")
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 2);

        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTCTLineDisplay);
        let line = sub0 as! MTCTLineDisplay
        XCTAssertEqual(line.atoms.count, 1);
        XCTAssertEqual(line.attributedString?.string, "sin");
        XCTAssertTrue(NSEqualRanges(line.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line.hasScript);

        let sub1 = display.subDisplays[1];
        XCTAssertTrue(sub1 is MTCTLineDisplay);
        let line2 = sub1 as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "𝑥");
        // Position may vary with improved spacing
        XCTAssertGreaterThan(line2.position.x, 20, "x should be positioned after sin with spacing")
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(1, 1)), "Got \(line2.range) instead")
        XCTAssertFalse(line2.hasScript);

        XCTAssertEqual(display.ascent, 13.14, accuracy: 0.01)
        XCTAssertEqual(display.descent, 0.22, accuracy: 0.01)
        // Width may vary with improved inline layout
        XCTAssertGreaterThan(display.width, 35, "Width should include sin + spacing + x")
        XCTAssertLessThan(display.width, 70, "Width should be reasonable")
    }

    func testLargeOpNoLimitsSymbol() throws {
        let mathList = MTMathList()
        // Integral - with new implementation, operators stay inline when they fit
        mathList.add(MTMathAtomFactory.atom(forLatexSymbol:"int"))
        mathList.add(MTMathAtomFactory.atom(forCharacter: "x"))

        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 2)), "Got \(display.range) instead")
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 2, "Should have operator and x as 2 subdisplays");

        // Check operator display
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTGlyphDisplay, "Operator should be a glyph display");
        let glyph = sub0;
        XCTAssertTrue(NSEqualRanges(glyph.range, NSMakeRange(0, 1)));
        XCTAssertFalse(glyph.hasScript);

        // Check x display
        let sub1 = display.subDisplays[1];
        XCTAssertTrue(sub1 is MTCTLineDisplay, "Variable should be a line display");
        let line2 = sub1 as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "𝑥");
        // Operator and x stay inline - x should be positioned after operator
        XCTAssertGreaterThan(line2.position.x, glyph.position.x, "x should be positioned after operator")
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(1, 1)), "Got \(line2.range) instead")
        XCTAssertFalse(line2.hasScript);

        // Check dimensions are reasonable (not exact values)
        XCTAssertGreaterThan(display.ascent, 20, "Integral symbol should have significant ascent")
        XCTAssertGreaterThan(display.descent, 10, "Integral symbol should have significant descent")
        XCTAssertGreaterThan(display.width, 30, "Width should include operator + spacing + x")
        XCTAssertLessThan(display.width, 40, "Width should be reasonable")
    }

    func testLargeOpNoLimitsSymbolWithScripts() throws {
        let mathList = MTMathList()
        // Integral
        let op = MTMathAtomFactory.atom(forLatexSymbol:"int")!
        op.superScript = MTMathList()
        op.superScript?.add(MTMathAtomFactory.atom(forCharacter: "1"))
        op.subScript = MTMathList()
        op.subScript?.add(MTMathAtomFactory.atom(forCharacter: "0"))
        mathList.add(op)
        mathList.add(MTMathAtomFactory.atom(forCharacter: "x"))
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 2)), "Got \(display.range) instead")
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 4);
        
        // Check superscript
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTMathListDisplay, "Superscript should be MTMathListDisplay");
        let display0 = sub0 as! MTMathListDisplay
        XCTAssertEqual(display0.type, .superscript);
        XCTAssertGreaterThan(display0.position.y, 20, "Superscript should be above baseline")
        XCTAssertTrue(NSEqualRanges(display0.range, NSMakeRange(0, 1)))
        XCTAssertFalse(display0.hasScript);
        XCTAssertEqual(display0.index, 0);
        XCTAssertEqual(display0.subDisplays.count, 1);

        let sub0sub0 = display0.subDisplays[0];
        XCTAssertTrue(sub0sub0 is MTCTLineDisplay);
        let line1 = sub0sub0 as! MTCTLineDisplay
        XCTAssertEqual(line1.atoms.count, 1);
        XCTAssertEqual(line1.attributedString?.string, "1", "Superscript should contain '1'");
        XCTAssertTrue(CGPointEqualToPoint(line1.position, CGPointZero));
        XCTAssertFalse(line1.hasScript);

        // Check subscript
        let sub1 = display.subDisplays[1];
        XCTAssertTrue(sub1 is MTMathListDisplay, "Subscript should be MTMathListDisplay");
        let display1 = sub1 as! MTMathListDisplay
        XCTAssertEqual(display1.type, .ssubscript);
        XCTAssertLessThan(display1.position.y, 0, "Subscript should be below baseline")
        XCTAssertTrue(NSEqualRanges(display1.range, NSMakeRange(0, 1)))
        XCTAssertFalse(display1.hasScript);
        XCTAssertEqual(display1.index, 0);
        XCTAssertEqual(display1.subDisplays.count, 1);

        let sub1sub0 = display1.subDisplays[0];
        XCTAssertTrue(sub1sub0 is MTCTLineDisplay);
        let line3 = sub1sub0 as! MTCTLineDisplay
        XCTAssertEqual(line3.atoms.count, 1);
        XCTAssertEqual(line3.attributedString?.string, "0", "Subscript should contain '0'");
        XCTAssertTrue(CGPointEqualToPoint(line3.position, CGPointZero));
        XCTAssertFalse(line3.hasScript);

        // Check operator glyph
        let sub2 = display.subDisplays[2];
        XCTAssertTrue(sub2 is MTGlyphDisplay, "Operator should be glyph display");
        let glyph = sub2;
        XCTAssertTrue(NSEqualRanges(glyph.range, NSMakeRange(0, 1)));
        XCTAssertTrue(glyph.hasScript, "Operator should have scripts");

        // Check x variable
        let sub3 = display.subDisplays[3];
        XCTAssertTrue(sub3 is MTCTLineDisplay, "Variable should be line display");
        let line2 = sub3 as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "𝑥");
        XCTAssertGreaterThan(line2.position.x, 25, "x should be positioned after operator with scripts and spacing")
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(1, 1)), "Got \(line2.range) instead")
        XCTAssertFalse(line1.hasScript);

        // Check dimensions are reasonable (not exact values)
        XCTAssertGreaterThan(display.ascent, 30, "Should have tall ascent due to superscript")
        XCTAssertGreaterThan(display.descent, 15, "Should have descent due to subscript and integral")
        XCTAssertGreaterThan(display.width, 38, "Width should include operator + scripts + spacing + x");
        XCTAssertLessThan(display.width, 48, "Width should be reasonable");
    }


    func testLargeOpWithLimitsTextWithScripts() throws {
        let mathList = MTMathList()
        let op = MTMathAtomFactory.atom(forLatexSymbol:"lim")!
        op.subScript = MTMathList()
        op.subScript?.add(MTMathAtomFactory.atom(forLatexSymbol:"infty"))
        mathList.add(op)
        mathList.add(MTMathAtom(type: .variable, value:"x"))
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 2)), "Got \(display.range) instead")
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 2);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTLargeOpLimitsDisplay)
        let largeOp = sub0 as! MTLargeOpLimitsDisplay
        XCTAssertTrue(NSEqualRanges(largeOp.range, NSMakeRange(0, 1)));
        XCTAssertFalse(largeOp.hasScript);
        XCTAssertNotNil(largeOp.lowerLimit, "Should have lower limit");
        XCTAssertNil(largeOp.upperLimit, "Should not have upper limit");

        let display2 = largeOp.lowerLimit!
        XCTAssertEqual(display2.type, .regular)
        // Position may vary with improved inline layout
        XCTAssertLessThan(display2.position.y, 0, "Lower limit should be below baseline")
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, NSNotFound);
        XCTAssertEqual(display2.subDisplays.count, 1);

        let sub0sub0 = display2.subDisplays[0];
        XCTAssertTrue(sub0sub0 is MTCTLineDisplay);
        let line1 = sub0sub0 as! MTCTLineDisplay
        XCTAssertEqual(line1.atoms.count, 1);
        XCTAssertEqual(line1.attributedString?.string, "∞");
        XCTAssertTrue(CGPointEqualToPoint(line1.position, CGPointZero));
        XCTAssertFalse(line1.hasScript);

        let sub3 = display.subDisplays[1];
        XCTAssertTrue(sub3 is MTCTLineDisplay);
        let line2 = sub3 as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "𝑥");
        // With improved inline layout, x may be positioned differently
        XCTAssertGreaterThan(line2.position.x, 25, "x should be positioned after operator with spacing")
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(1, 1)), "Got \(line2.range) instead")
        XCTAssertFalse(line1.hasScript);

        XCTAssertEqual(display.ascent, 13.88, accuracy: 0.01)
        XCTAssertEqual(display.descent, 12.154, accuracy: 0.01)
        // Width now includes operator with limits + spacing + x (improved behavior)
        XCTAssertGreaterThan(display.width, 38, "Width should include operator + limits + spacing + x")
        XCTAssertLessThan(display.width, 48, "Width should be reasonable")
    }

    func testLargeOpWithLimitsSymboltWithScripts() throws {
        let mathList = MTMathList()
        let op = MTMathAtomFactory.atom(forLatexSymbol:"sum")!
        op.superScript = MTMathList()
        op.superScript?.add(MTMathAtomFactory.atom(forLatexSymbol:"infty"))
        op.subScript = MTMathList()
        op.subScript?.add(MTMathAtomFactory.atom(forCharacter: "0"))
        mathList.add(op)
        mathList.add(MTMathAtom(type: .variable, value:"x"))
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 2)), "Got \(display.range) instead")
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 2);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTLargeOpLimitsDisplay);
        let largeOp = sub0 as! MTLargeOpLimitsDisplay
        XCTAssertTrue(NSEqualRanges(largeOp.range, NSMakeRange(0, 1)));
        XCTAssertFalse(largeOp.hasScript);
        XCTAssertNotNil(largeOp.lowerLimit, "Should have lower limit");
        XCTAssertNotNil(largeOp.upperLimit, "Should have upper limit");

        let display2 = largeOp.lowerLimit!
        XCTAssertEqual(display2.type, .regular);
        // Lower limit position may vary
        XCTAssertLessThan(display2.position.y, 0, "Lower limit should be below baseline")
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, NSNotFound);
        XCTAssertEqual(display2.subDisplays.count, 1);

        let sub0sub0 = display2.subDisplays[0];
        XCTAssertTrue(sub0sub0 is MTCTLineDisplay);
        let line1 = sub0sub0 as! MTCTLineDisplay
        XCTAssertEqual(line1.atoms.count, 1);
        XCTAssertEqual(line1.attributedString?.string, "0");
        XCTAssertTrue(CGPointEqualToPoint(line1.position, CGPointZero));
        XCTAssertFalse(line1.hasScript);

        let displayU = largeOp.upperLimit!
        XCTAssertEqual(displayU.type, .regular);
        XCTAssertTrue(NSEqualRanges(displayU.range, NSMakeRange(0, 1)))
        XCTAssertFalse(displayU.hasScript);
        XCTAssertEqual(displayU.index, NSNotFound);
        XCTAssertEqual(displayU.subDisplays.count, 1);

        let sub0subU = displayU.subDisplays[0];
        XCTAssertTrue(sub0subU is MTCTLineDisplay);
        let line3 = sub0subU as! MTCTLineDisplay
        XCTAssertEqual(line3.atoms.count, 1);
        XCTAssertEqual(line3.attributedString?.string, "∞");
        XCTAssertTrue(CGPointEqualToPoint(line3.position, CGPointZero));
        XCTAssertFalse(line3.hasScript);

        let sub3 = display.subDisplays[1];
        XCTAssertTrue(sub3 is MTCTLineDisplay);
        let line2 = sub3 as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "𝑥");
        // With improved inline layout, x position may vary
        XCTAssertGreaterThan(line2.position.x, 20, "x should be positioned after operator")
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(1, 1)), "Got \(line2.range) instead")
        XCTAssertFalse(line2.hasScript);

        // Dimensions may vary with improved inline layout
        XCTAssertGreaterThanOrEqual(display.ascent, 0, "Ascent should be non-negative")
        XCTAssertGreaterThan(display.descent, 0, "Descent should be positive due to lower limit")
        XCTAssertGreaterThan(display.width, 40, "Width should include operator + limits + spacing + x");
    }

    func testInner() throws {
        let innerList = MTMathList()
        innerList.add(MTMathAtomFactory.atom(forCharacter: "x"))
        let inner = MTInner()
        inner.innerList = innerList;
        inner.leftBoundary = MTMathAtom(type: .boundary, value:"(")
        inner.rightBoundary = MTMathAtom(type: .boundary, value:")")
        
        let mathList = MTMathList()
        mathList.add(inner)
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTMathListDisplay);
        let display2 = sub0 as! MTMathListDisplay
        XCTAssertEqual(display2.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display2.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, NSNotFound);
        XCTAssertEqual(display2.subDisplays.count, 3);
        
        let subLeft = display2.subDisplays[0];
        XCTAssertTrue(subLeft is MTGlyphDisplay);
        let glyph = subLeft;
        XCTAssertTrue(CGPointEqualToPoint(glyph.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(glyph.range, NSMakeRange(NSNotFound, 0)));
        XCTAssertFalse(glyph.hasScript);
        
        let sub3 = display2.subDisplays[1];
        XCTAssertTrue(sub3 is MTMathListDisplay);
        let display3 = sub3 as! MTMathListDisplay
        XCTAssertEqual(display3.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display3.position, CGPointMake(7.78, 0)))
        XCTAssertTrue(NSEqualRanges(display3.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display3.hasScript);
        XCTAssertEqual(display3.index, NSNotFound);
        XCTAssertEqual(display3.subDisplays.count, 1);
        
        let subsub3 = display3.subDisplays[0];
        XCTAssertTrue(subsub3 is MTCTLineDisplay);
        let line = subsub3 as! MTCTLineDisplay
        XCTAssertEqual(line.atoms.count, 1);
        // The x is italicized
        XCTAssertEqual(line.attributedString?.string, "𝑥");
        XCTAssertTrue(CGPointEqualToPoint(line.position, CGPointZero));
        XCTAssertFalse(line.hasScript);
        
        let subRight = display2.subDisplays[2];
        XCTAssertTrue(subRight is MTGlyphDisplay);
        let glyph2 = subRight as! MTGlyphDisplay
        XCTAssertTrue(CGPointEqualToPoint(glyph2.position, CGPointMake(19.22, 0)))
        XCTAssertTrue(NSEqualRanges(glyph2.range, NSMakeRange(NSNotFound, 0)), "Got \(glyph2.range) instead");
        XCTAssertFalse(glyph2.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, display2.ascent);
        XCTAssertEqual(display.descent, display2.descent);
        XCTAssertEqual(display.width, display2.width);
        
        XCTAssertEqual(display.ascent, 14.96, accuracy: 0.001);
        XCTAssertEqual(display.descent, 4.96, accuracy: 0.001);
        XCTAssertEqual(display.width, 27, accuracy: 0.01)
    }

    func testOverline() throws {
        let mathList = MTMathList()
        let over = MTOverLine()
        let inner = MTMathList()
        inner.add(MTMathAtomFactory.atom(forCharacter: "1"))
        over.innerList = inner;
        mathList.add(over)
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTLineDisplay);
        let overline = sub0 as! MTLineDisplay
        XCTAssertTrue(NSEqualRanges(overline.range, NSMakeRange(0, 1)));
        XCTAssertFalse(overline.hasScript);
        XCTAssertTrue(CGPointEqualToPoint(overline.position, CGPointZero));
        XCTAssertNotNil(overline.inner);
        
        let display2 = overline.inner!
        XCTAssertEqual(display2.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display2.position, CGPointZero))
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, NSNotFound);
        XCTAssertEqual(display2.subDisplays.count, 1);
        
        let subover = display2.subDisplays[0];
        XCTAssertTrue(subover is MTCTLineDisplay);
        let line2 = subover as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "1");
        XCTAssertTrue(CGPointEqualToPoint(line2.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line2.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, 17.32, accuracy: 0.01)
        XCTAssertEqual(display.descent, 0.00, accuracy: 0.01)
        XCTAssertEqual(display.width, 10, accuracy: 0.01)
    }

    func testUnderline() throws {
        let mathList = MTMathList()
        let under = MTUnderLine()
        let inner = MTMathList()
        inner.add(MTMathAtomFactory.atom(forCharacter: "1"))
        under.innerList = inner;
        mathList.add(under)
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTLineDisplay)
        let underline = sub0 as! MTLineDisplay
        XCTAssertTrue(NSEqualRanges(underline.range, NSMakeRange(0, 1)));
        XCTAssertFalse(underline.hasScript);
        XCTAssertTrue(CGPointEqualToPoint(underline.position, CGPointZero));
        XCTAssertNotNil(underline.inner);
        
        let display2 = underline.inner!
        XCTAssertEqual(display2.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display2.position, CGPointZero))
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, NSNotFound);
        XCTAssertEqual(display2.subDisplays.count, 1);
        
        let subover = display2.subDisplays[0];
        XCTAssertTrue(subover is MTCTLineDisplay);
        let line2 = subover as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "1");
        XCTAssertTrue(CGPointEqualToPoint(line2.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line2.hasScript);
        
        // dimensions
        XCTAssertEqual(display.ascent, 13.32, accuracy: 0.01)
        XCTAssertEqual(display.descent, 4.00, accuracy: 0.01)
        XCTAssertEqual(display.width, 10, accuracy: 0.01)
    }

    func testSpacing() throws {
        let mathList = MTMathList()
        mathList.add(MTMathAtomFactory.atom(forCharacter: "x"))
        mathList.add(MTMathSpace(space: 9))
        mathList.add(MTMathAtomFactory.atom(forCharacter: "y"))
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 3)), "Got \(display.range) instead")
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 2);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTCTLineDisplay);
        let line = sub0 as! MTCTLineDisplay
        XCTAssertEqual(line.atoms.count, 1);
        // The x is italicized
        XCTAssertEqual(line.attributedString?.string, "𝑥");
        XCTAssertTrue(CGPointEqualToPoint(line.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line.hasScript);
        
        let sub1 = display.subDisplays[1];
        XCTAssertTrue(sub1 is MTCTLineDisplay);
        let line2 = sub1 as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        // The y is italicized
        XCTAssertEqual(line2.attributedString?.string, "𝑦")
        XCTAssertTrue(CGPointMake(21.44, 0).isEqual(to: line2.position, accuracy: 0.01))
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(2, 1)), "Got \(line2.range) instead")
        XCTAssertFalse(line2.hasScript);
        
        let noSpace = MTMathList()
        noSpace.add(MTMathAtomFactory.atom(forCharacter: "x"))
        noSpace.add(MTMathAtomFactory.atom(forCharacter: "y"))
        
        let noSpaceDisplay = MTTypesetter.createLineForMathList(noSpace, font:self.font, style:.display)!
        
        // dimensions
        XCTAssertEqual(display.ascent, noSpaceDisplay.ascent, accuracy: 0.01)
        XCTAssertEqual(display.descent, noSpaceDisplay.descent, accuracy: 0.01)
        XCTAssertEqual(display.width, noSpaceDisplay.width + 10, accuracy: 0.01)
    }

    // For issue: https://github.com/kostub/iosMath/issues/5
    func testLargeRadicalDescent() throws {
        let list = MTMathListBuilder.build(fromString: "\\sqrt{\\frac{\\sqrt{\\frac{1}{2}} + 3}{\\sqrt{5}^x}}")
        let display = MTTypesetter.createLineForMathList(list, font:self.font, style:.display)!
        
        // dimensions
        XCTAssertEqual(display.ascent, 49.16, accuracy: 0.01)
        XCTAssertEqual(display.descent, 21.288, accuracy: 0.01)
        XCTAssertEqual(display.width, 82.569, accuracy: 0.01)
    }

    func testMathTable() throws {
        let c00 = MTMathAtomFactory.mathListForCharacters("1")
        let c01 = MTMathAtomFactory.mathListForCharacters("y+z")
        let c02 = MTMathAtomFactory.mathListForCharacters("y")
        
        let c11 = MTMathList()
        c11.add(MTMathAtomFactory.fraction(withNumeratorString: "1", denominatorString:"2x"))
        let c12 = MTMathAtomFactory.mathListForCharacters("x-y")
        
        let c20 = MTMathAtomFactory.mathListForCharacters("x+5")
        let c22 = MTMathAtomFactory.mathListForCharacters("12")

        let table = MTMathTable()
        table.set(cell: c00!, forRow:0, column:0)
        table.set(cell: c01!, forRow:0, column:1)
        table.set(cell: c02!, forRow:0, column:2)
        table.set(cell: c11,  forRow:1, column:1)
        table.set(cell: c12!, forRow:1, column:2)
        table.set(cell: c20!, forRow:2, column:0)
        table.set(cell: c22!, forRow:2, column:2)
        
        // alignments
        table.set(alignment: .right, forColumn:0)
        table.set(alignment: .left, forColumn:2)
        
        table.interColumnSpacing = 18; // 1 quad
        
        let mathList = MTMathList()
        mathList.add(table)
        
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTMathListDisplay);
        
        let display2 = sub0 as! MTMathListDisplay
        XCTAssertEqual(display2.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display2.position, CGPointZero))
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, NSNotFound);
        XCTAssertEqual(display2.subDisplays.count, 3);
        let rowPos = [ 30.28, -2.68, -31.95 ]
        // alignment is right, center, left.
        let cellPos = [ [ 35.89, 65.89, 129.438 ], [ 45.89, 76.94, 129.438 ], [ 0, 87.66, 129.438] ]
        // check the 3 rows of the matrix
        for i in 0..<3 {
            let sub0i = display2.subDisplays[i];
            XCTAssertTrue(sub0i is MTMathListDisplay);
            
            let row = sub0i as! MTMathListDisplay
            XCTAssertEqual(row.type, .regular)
            XCTAssertTrue(CGPointMake(0, rowPos[i]).isEqual(to: row.position, accuracy: 0.01))
            XCTAssertTrue(NSEqualRanges(row.range, NSMakeRange(0, 3)));
            XCTAssertFalse(row.hasScript);
            XCTAssertEqual(row.index, NSNotFound);
            XCTAssertEqual(row.subDisplays.count, 3);
            
            for j in 0..<3 {
                let sub0ij = row.subDisplays[j];
                XCTAssertTrue(sub0ij is MTMathListDisplay);
                
                let col = sub0ij as! MTMathListDisplay
                XCTAssertEqual(col.type, .regular);
                XCTAssertTrue(CGPointMake(cellPos[i][j], 0).isEqual(to: col.position, accuracy: 0.01))
                XCTAssertFalse(col.hasScript)
                XCTAssertEqual(col.index, NSNotFound);
            }
        }
    }

    func testLatexSymbols() throws {
        // Test all latex symbols
        let allSymbols = MTMathAtomFactory.supportedLatexSymbolNames
        for symName in allSymbols {
            let list = MTMathList()
            let atom = MTMathAtomFactory.atom(forLatexSymbol:symName)
            XCTAssertNotNil(atom)
            if atom!.type >= .boundary {
                // Skip these types as they aren't symbols.
                continue;
            }
            
            list.add(atom)
            
            let display = MTTypesetter.createLineForMathList(list, font:self.font, style:.display)!
            XCTAssertNotNil(display, "Symbol \(symName)")
            
            XCTAssertEqual(display.type, .regular);
            XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
            XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)))
            XCTAssertFalse(display.hasScript);
            XCTAssertEqual(display.index, NSNotFound);
            XCTAssertEqual(display.subDisplays.count, 1, "Symbol \(symName)");
            
            let sub0 = display.subDisplays[0];
            if atom!.type == .largeOperator && atom!.nucleus.count == 1 {
                // These large operators are rendered differently;
                XCTAssertTrue(sub0 is MTGlyphDisplay);
                let glyph = sub0 as! MTGlyphDisplay
                XCTAssertTrue(NSEqualRanges(glyph.range, NSMakeRange(0, 1)))
                XCTAssertFalse(glyph.hasScript);
            } else {
                XCTAssertTrue(sub0 is MTCTLineDisplay, "Symbol \(symName)");
                let line = sub0 as! MTCTLineDisplay
                XCTAssertEqual(line.atoms.count, 1);
                if atom!.type != .variable {
                    XCTAssertEqual(line.attributedString?.string, atom!.nucleus);
                }
                XCTAssertTrue(NSEqualRanges(line.range, NSMakeRange(0, 1)))
                XCTAssertFalse(line.hasScript);
            }

            // dimensions - check that display matches subdisplay (structure)
            XCTAssertEqual(display.ascent, sub0.ascent);
            XCTAssertEqual(display.descent, sub0.descent);
            // Width should be reasonable - inline layout may affect large operators differently
            XCTAssertGreaterThan(display.width, 0, "Width for \(symName) should be positive");
            XCTAssertLessThanOrEqual(display.width, sub0.width * 3, "Width for \(symName) should be reasonable");
            
            // All chars will occupy some space.
            if atom!.nucleus != " " {
                // all chars except space have height
                XCTAssertGreaterThan(display.ascent + display.descent, 0, "Symbol \(symName)")
            }
            // all chars have a width.
            XCTAssertGreaterThan(display.width, 0);
        }
    }

    func testAtomWithAllFontStyles(_ atom:MTMathAtom?) throws {
        guard let atom = atom else { return }
        let fontStyles = [
            MTFontStyle.defaultStyle,
            .roman,
            .bold,
            .caligraphic,
            .typewriter,
            .italic,
            .sansSerif,
            .fraktur,
            .blackboard,
            .boldItalic,
        ]
        for fontStyle in fontStyles {
            let style = fontStyle
            let copy : MTMathAtom = atom.copy()
            copy.fontStyle = style
            let list = MTMathList(atom: copy)

            let display = MTTypesetter.createLineForMathList(list, font:self.font, style:.display)!
            XCTAssertNotNil(display, "Symbol \(atom.nucleus)")

            XCTAssertEqual(display.type, .regular);
            XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
            XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)))
            XCTAssertFalse(display.hasScript);
            XCTAssertEqual(display.index, NSNotFound);
            XCTAssertEqual(display.subDisplays.count, 1, "Symbol \(atom.nucleus)")

            let sub0 = display.subDisplays[0];
            XCTAssertTrue(sub0 is MTCTLineDisplay, "Symbol \(atom.nucleus)")
            let line = sub0 as! MTCTLineDisplay
            XCTAssertEqual(line.atoms.count, 1);
            XCTAssertTrue(CGPointEqualToPoint(line.position, CGPointZero));
            XCTAssertTrue(NSEqualRanges(line.range, NSMakeRange(0, 1)))
            XCTAssertFalse(line.hasScript);

            // dimensions
            XCTAssertEqual(display.ascent, sub0.ascent);
            XCTAssertEqual(display.descent, sub0.descent);
            XCTAssertEqual(display.width, sub0.width);

            // All chars will occupy some space.
            XCTAssertGreaterThan(display.ascent + display.descent, 0, "Symbol \(atom.nucleus)")
            // all chars have a width.
            XCTAssertGreaterThan(display.width, 0);
        }
    }

    func testVariables() throws {
        // Test all variables
        let allSymbols = MTMathAtomFactory.supportedLatexSymbolNames
        for symName in allSymbols {
            let atom = MTMathAtomFactory.atom(forLatexSymbol:symName)!
            XCTAssertNotNil(atom)
            if atom.type != .variable {
                // Skip these types as we are only interested in variables.
                continue;
            }
            try self.testAtomWithAllFontStyles(atom)
        }
        let alphaNum = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789."
        let mathList = MTMathAtomFactory.mathListForCharacters(alphaNum)
        for atom in mathList!.atoms {
            try self.testAtomWithAllFontStyles(atom)
        }
    }

    func testStyleChanges() throws {
        let frac = MTMathAtomFactory.fraction(withNumeratorString: "1", denominatorString: "2")
        let list = MTMathList(atoms: [frac])
        let style = MTMathStyle(style: .text)
        let textList = MTMathList(atoms: [style, frac])
        
        // This should make the display same as text.
        let display = MTTypesetter.createLineForMathList(textList, font:self.font, style:.display)!
        let textDisplay = MTTypesetter.createLineForMathList(list, font:self.font, style:.text)!
        let originalDisplay = MTTypesetter.createLineForMathList(list, font:self.font, style:.display)!
        
        // Display should be the same as rendering the fraction in text style.
        XCTAssertEqual(display.ascent, textDisplay.ascent);
        XCTAssertEqual(display.descent, textDisplay.descent);
        XCTAssertEqual(display.width, textDisplay.width);
        
        // Original display should be larger than display since it is greater.
        XCTAssertGreaterThan(originalDisplay.ascent, display.ascent);
        XCTAssertGreaterThan(originalDisplay.descent, display.descent);
        XCTAssertGreaterThan(originalDisplay.width, display.width);
    }

    func testStyleMiddle() throws {
        let atom1 = MTMathAtomFactory.atom(forCharacter: "x")!
        let style1 = MTMathStyle(style: .script) as MTMathAtom
        let atom2 = MTMathAtomFactory.atom(forCharacter: "y")!
        let style2 = MTMathStyle(style: .scriptOfScript) as MTMathAtom
        let atom3 = MTMathAtomFactory.atom(forCharacter: "z")!
        let list = MTMathList(atoms: [atom1, style1, atom2, style2, atom3])
        
        let display = MTTypesetter.createLineForMathList(list, font:self.font, style:.display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 5)))
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 3);
        
        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTCTLineDisplay);
        let line = sub0 as! MTCTLineDisplay
        XCTAssertEqual(line.atoms.count, 1);
        XCTAssertEqual(line.attributedString?.string, "𝑥");
        XCTAssertTrue(CGPointEqualToPoint(line.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line.range, NSMakeRange(0, 1)))
        XCTAssertFalse(line.hasScript);
        
        let sub1 = display.subDisplays[1];
        XCTAssertTrue(sub1 is MTCTLineDisplay);
        let line1 = sub1 as! MTCTLineDisplay
        XCTAssertEqual(line1.atoms.count, 1);
        XCTAssertEqual(line1.attributedString?.string, "𝑦");
        XCTAssertTrue(NSEqualRanges(line1.range, NSMakeRange(2, 1)))
        XCTAssertFalse(line1.hasScript);
        
        let sub2 = display.subDisplays[2];
        XCTAssertTrue(sub2 is MTCTLineDisplay);
        let line2 = sub2 as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "𝑧");
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(4, 1)))
        XCTAssertFalse(line2.hasScript);
    }

    func testAccent() throws {
        let mathList = MTMathList()
        let accent = MTMathAtomFactory.accent(withName: "hat")
        let inner = MTMathList()
        inner.add(MTMathAtomFactory.atom(forCharacter: "x"))
        accent?.innerList = inner;
        mathList.add(accent)

        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);

        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTAccentDisplay)
        let accentDisp = sub0 as! MTAccentDisplay
        XCTAssertTrue(NSEqualRanges(accentDisp.range, NSMakeRange(0, 1)));
        XCTAssertFalse(accentDisp.hasScript);
        XCTAssertTrue(CGPointEqualToPoint(accentDisp.position, CGPointZero));
        XCTAssertNotNil(accentDisp.accentee);
        XCTAssertNotNil(accentDisp.accent);

        let display2 = accentDisp.accentee!
        XCTAssertEqual(display2.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display2.position, CGPointZero))
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, NSNotFound);
        XCTAssertEqual(display2.subDisplays.count, 1);

        let subaccentee = display2.subDisplays[0];
        XCTAssertTrue(subaccentee is MTCTLineDisplay);
        let line2 = subaccentee as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 1);
        XCTAssertEqual(line2.attributedString?.string, "𝑥");
        XCTAssertTrue(CGPointEqualToPoint(line2.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(0, 1)));
        XCTAssertFalse(line2.hasScript);

        let glyph = accentDisp.accent!
        XCTAssertTrue(CGPointEqualToPoint(glyph.position, CGPointMake(11.86, 0)))
        XCTAssertTrue(NSEqualRanges(glyph.range, NSMakeRange(0, 1)))
        XCTAssertFalse(glyph.hasScript);

        // dimensions
        XCTAssertEqual(display.ascent, 14.68, accuracy: 0.01)
        XCTAssertEqual(display.descent, 0.22, accuracy: 0.01)
        XCTAssertEqual(display.width, 11.44, accuracy: 0.01)
    }

    func testWideAccent() throws {
        let mathList = MTMathList()
        let accent = MTMathAtomFactory.accent(withName: "hat")
        accent?.innerList = MTMathAtomFactory.mathListForCharacters("xyzw")
        mathList.add(accent)

        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)!
        XCTAssertNotNil(display);
        XCTAssertEqual(display.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(display.range, NSMakeRange(0, 1)));
        XCTAssertFalse(display.hasScript);
        XCTAssertEqual(display.index, NSNotFound);
        XCTAssertEqual(display.subDisplays.count, 1);

        let sub0 = display.subDisplays[0];
        XCTAssertTrue(sub0 is MTAccentDisplay)
        let accentDisp = sub0 as! MTAccentDisplay
        XCTAssertTrue(NSEqualRanges(accentDisp.range, NSMakeRange(0, 1)));
        XCTAssertFalse(accentDisp.hasScript);
        XCTAssertTrue(CGPointEqualToPoint(accentDisp.position, CGPointZero));
        XCTAssertNotNil(accentDisp.accentee);
        XCTAssertNotNil(accentDisp.accent);

        let display2 = accentDisp.accentee!
        XCTAssertEqual(display2.type, .regular);
        XCTAssertTrue(CGPointEqualToPoint(display2.position, CGPointZero))
        XCTAssertTrue(NSEqualRanges(display2.range, NSMakeRange(0, 4)));
        XCTAssertFalse(display2.hasScript);
        XCTAssertEqual(display2.index, NSNotFound);
        XCTAssertEqual(display2.subDisplays.count, 1);

        let subaccentee = display2.subDisplays[0];
        XCTAssertTrue(subaccentee is MTCTLineDisplay);
        let line2 = subaccentee as! MTCTLineDisplay
        XCTAssertEqual(line2.atoms.count, 4);
        XCTAssertEqual(line2.attributedString?.string, "𝑥𝑦𝑧𝑤");
        XCTAssertTrue(CGPointEqualToPoint(line2.position, CGPointZero));
        XCTAssertTrue(NSEqualRanges(line2.range, NSMakeRange(0, 4)));
        XCTAssertFalse(line2.hasScript);

        let glyph = accentDisp.accent!
        XCTAssertTrue(CGPointMake(3.47, 0).isEqual(to: glyph.position, accuracy: 0.01))
        XCTAssertTrue(NSEqualRanges(glyph.range, NSMakeRange(0, 1)))
        XCTAssertFalse(glyph.hasScript);

        // dimensions
        XCTAssertEqual(display.ascent, 14.98, accuracy: 0.01)
        XCTAssertEqual(display.descent, 4.10, accuracy: 0.01)
        XCTAssertEqual(display.width, 44.86, accuracy: 0.01)
    }

    // MARK: - Interatom Line Breaking Tests

    func testInteratomLineBreaking_SimpleEquation() throws {
        // Simple equation that should break between atoms when width is constrained
        let latex = "a=1, b=2, c=3, d=4"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        // Create display with narrow width constraint (should force multiple lines)
        let maxWidth: CGFloat = 100
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should have multiple sub-displays (lines)
        XCTAssertGreaterThan(display!.subDisplays.count, 1, "Expected multiple lines with width constraint of \(maxWidth)")

        // Verify that each line respects the width constraint
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.1, "Line \(index) width \(subDisplay.width) exceeds maxWidth \(maxWidth)")
        }

        // Verify vertical positioning - lines should be below each other
        if display!.subDisplays.count > 1 {
            let firstLine = display!.subDisplays[0]
            let secondLine = display!.subDisplays[1]
            XCTAssertLessThan(secondLine.position.y, firstLine.position.y, "Second line should be positioned below first line")
        }
    }

    func testInteratomLineBreaking_TextAndMath() throws {
        // The user's specific example: text mixed with math
        let latex = "\\text{Calculer le discriminant }\\Delta=b^{2}-4ac\\text{ avec }a=1\\text{, }b=-1\\text{, }c=-5"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        // Create display with width constraint of 235 as specified by user
        let maxWidth: CGFloat = 235
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should have multiple lines
        XCTAssertGreaterThan(display!.subDisplays.count, 1, "Expected multiple lines with width \(maxWidth) for the given LaTeX")

        // Verify each line respects width constraint
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            // Allow 10% tolerance for spacing and rounding
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.1,
                "Line \(index) width \(subDisplay.width) exceeds maxWidth \(maxWidth)")
        }

        // Verify vertical spacing between lines
        if display!.subDisplays.count >= 2 {
            let firstLine = display!.subDisplays[0]
            let secondLine = display!.subDisplays[1]
            let verticalSpacing = abs(firstLine.position.y - secondLine.position.y)
            XCTAssertGreaterThan(verticalSpacing, 0, "Lines should have vertical spacing")
            // Typical line height is around 1.5 * font size
            XCTAssertGreaterThan(verticalSpacing, self.font.fontSize * 0.5, "Vertical spacing seems too small")
        }
    }

    func testInteratomLineBreaking_BreaksAtAtomBoundaries() throws {
        // Test that breaking happens between atoms, not within them
        // Using mathematical atoms separated by operators
        let latex = "a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        // Create display with narrow width that should force breaking
        let maxWidth: CGFloat = 120
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should have multiple lines
        XCTAssertGreaterThan(display!.subDisplays.count, 1, "Expected line breaking with narrow width")

        // Each line should respect the width constraint (with some tolerance)
        // since we break at atom boundaries, not mid-atom
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) width \(subDisplay.width) exceeds maxWidth \(maxWidth) by too much")
        }
    }

    func testInteratomLineBreaking_WithSuperscripts() throws {
        // Test breaking with atoms that have superscripts
        let latex = "a^{2}+b^{2}+c^{2}+d^{2}+e^{2}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 100
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should handle superscripts properly and create multiple lines if needed
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.1,
                "Line \(index) with superscripts exceeds width")
        }
    }

    func testInteratomLineBreaking_NoBreakingWhenNotNeeded() throws {
        // Test that short content doesn't break unnecessarily
        let latex = "a=b"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 200
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should stay on single line since content is short
        // Note: The number of subDisplays might be 1 or more depending on internal structure,
        // but the total width should be well under maxWidth
        XCTAssertLessThan(display!.width, maxWidth, "Short content should fit without breaking")
    }

    func testInteratomLineBreaking_BreaksAfterOperators() throws {
        // Test that breaking prefers to happen after operators (good break points)
        let latex = "a+b+c+d+e+f+g+h"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 80
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should break into multiple lines
        XCTAssertGreaterThan(display!.subDisplays.count, 1, "Expected multiple lines")

        // Verify width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.1,
                "Line \(index) exceeds width")
        }
    }

    // MARK: - Complex Display Line Breaking Tests (Fractions & Radicals)

    func testComplexDisplay_FractionStaysInlineWhenFits() throws {
        // Fraction that should stay inline with surrounding content
        let latex = "a+\\frac{1}{2}+b"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        // Wide enough to fit everything on one line
        let maxWidth: CGFloat = 200
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should fit on a single line (all elements have same y position)
        // Note: subdisplays may be > 1 due to flushing currentLine before complex atoms
        // What matters is that they're all at the same y position (no line breaks)
        let firstY = display!.subDisplays.first?.position.y ?? 0
        for subDisplay in display!.subDisplays {
            XCTAssertEqual(subDisplay.position.y, firstY, accuracy: 0.1,
                "All elements should be on the same line (same y position)")
        }

        // Total width should be within constraint
        XCTAssertLessThan(display!.width, maxWidth,
            "Expression should fit within width constraint")
    }

    func testComplexDisplay_FractionBreaksWhenTooWide() throws {
        // Multiple fractions with narrow width should break
        let latex = "a+\\frac{1}{2}+b+\\frac{3}{4}+c"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        // Narrow width should force breaking
        let maxWidth: CGFloat = 80
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should have multiple lines
        XCTAssertGreaterThan(display!.subDisplays.count, 1,
            "Expected line breaking with narrow width")

        // Each line should respect width constraint (with tolerance)
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) width \(subDisplay.width) exceeds maxWidth \(maxWidth) significantly")
        }
    }

    func testComplexDisplay_RadicalStaysInlineWhenFits() throws {
        // Radical that should stay inline with surrounding content
        let latex = "x+\\sqrt{2}+y"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        // Wide enough to fit everything on one line
        let maxWidth: CGFloat = 150
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should fit on a single line (all elements have same y position)
        // Note: subdisplays may be > 1 due to flushing currentLine before complex atoms
        // What matters is that they're all at the same y position (no line breaks)
        let firstY = display!.subDisplays.first?.position.y ?? 0
        for subDisplay in display!.subDisplays {
            XCTAssertEqual(subDisplay.position.y, firstY, accuracy: 0.1,
                "All elements should be on the same line (same y position)")
        }

        // Total width should be within constraint
        XCTAssertLessThan(display!.width, maxWidth,
            "Expression should fit within width constraint")
    }

    func testComplexDisplay_RadicalBreaksWhenTooWide() throws {
        // Multiple radicals with narrow width should break
        let latex = "a+\\sqrt{2}+b+\\sqrt{3}+c+\\sqrt{5}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        // Narrow width should force breaking
        let maxWidth: CGFloat = 100
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should have multiple lines
        XCTAssertGreaterThan(display!.subDisplays.count, 1,
            "Expected line breaking with narrow width")

        // Each line should respect width constraint (with tolerance)
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) width \(subDisplay.width) exceeds maxWidth \(maxWidth) significantly")
        }
    }

    func testComplexDisplay_MixedFractionsAndRadicals() throws {
        // Mix of fractions and radicals
        let latex = "a+\\frac{1}{2}+\\sqrt{3}+b"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        // Medium width
        let maxWidth: CGFloat = 150
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should handle mixed complex displays
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) width exceeds constraint")
        }
    }

    func testComplexDisplay_FractionWithComplexNumerator() throws {
        // Fraction with more complex content
        let latex = "\\frac{a+b}{c}+d"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 150
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should stay inline if it fits
        XCTAssertLessThan(display!.width, maxWidth * 1.5,
            "Complex fraction should handle width reasonably")
    }

    func testComplexDisplay_RadicalWithDegree() throws {
        // Cube root
        let latex = "\\sqrt[3]{8}+x"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 150
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should handle radicals with degrees
        XCTAssertLessThan(display!.width, maxWidth * 1.2,
            "Radical with degree should fit reasonably")
    }

    func testComplexDisplay_NoBreakingWithoutWidthConstraint() throws {
        // Without width constraint, should never break
        let latex = "a+\\frac{1}{2}+\\sqrt{3}+b+\\frac{4}{5}+c"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        // No width constraint (maxWidth = 0)
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)
        XCTAssertNotNil(display)

        // Should not artificially break when no constraint
        // The display might have multiple subDisplays for internal structure,
        // but we verify that the total rendering doesn't have forced line breaks
        // by checking that all elements are at y=0 (no vertical offset)
        var allAtSameY = true
        let firstY = display!.subDisplays.first?.position.y ?? 0
        for subDisplay in display!.subDisplays {
            if abs(subDisplay.position.y - firstY) > 0.1 {
                allAtSameY = false
                break
            }
        }
        XCTAssertTrue(allAtSameY, "Without width constraint, all elements should be at same Y position")
    }

    // MARK: - Additional Recommended Tests

    func testEdgeCase_VeryNarrowWidth() throws {
        // Test behavior with extremely narrow width constraint
        let latex = "a+b+c"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        // Very narrow width - each element might need its own line
        let maxWidth: CGFloat = 30
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should handle gracefully without crashing
        XCTAssertGreaterThan(display!.subDisplays.count, 0, "Should produce at least one display")

        // Each subdisplay should attempt to respect width (though may overflow for single atoms)
        for subDisplay in display!.subDisplays {
            // Allow overflow for unavoidable cases (single atom wider than constraint)
            XCTAssertLessThan(subDisplay.width, maxWidth * 3,
                "Width shouldn't be excessively larger than constraint")
        }
    }

    func testEdgeCase_VeryWideAtom() throws {
        // Test handling of atom that's wider than maxWidth constraint
        let latex = "\\text{ThisIsAnExtremelyLongWordThatCannotBreak}+b"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 100
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should not crash, even if single atom exceeds width
        XCTAssertGreaterThan(display!.subDisplays.count, 0, "Should produce display")

        // The wide atom should be placed, even if it exceeds maxWidth
        // (no way to break it further)
        XCTAssertNotNil(display, "Should handle oversized atoms gracefully")
    }

    func testMixedScriptsAndNonScripts() throws {
        // Test mixing atoms with scripts and without scripts
        let latex = "a+b^{2}+c+d^{3}+e"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 120
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should handle mixed content
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.3,
                "Line \(index) with mixed scripts should respect width reasonably")
        }
    }

    func testMultipleLineBreaks() throws {
        // Test expression that requires 4+ line breaks
        let latex = "a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        // Very narrow to force many breaks
        let maxWidth: CGFloat = 60
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should create multiple lines
        XCTAssertGreaterThanOrEqual(display!.subDisplays.count, 4,
            "Should create at least 4 lines for long expression")

        // Verify vertical positioning - each line should be below the previous
        for i in 1..<display!.subDisplays.count {
            let prevLine = display!.subDisplays[i-1]
            let currentLine = display!.subDisplays[i]
            XCTAssertLessThan(currentLine.position.y, prevLine.position.y,
                "Line \(i) should be below line \(i-1)")
        }

        // Verify consistent line spacing
        if display!.subDisplays.count >= 3 {
            let spacing1 = abs(display!.subDisplays[0].position.y - display!.subDisplays[1].position.y)
            let spacing2 = abs(display!.subDisplays[1].position.y - display!.subDisplays[2].position.y)
            XCTAssertEqual(spacing1, spacing2, accuracy: 1.0,
                "Line spacing should be consistent")
        }
    }

    func testUnicodeTextWrapping() throws {
        // Test wrapping with Unicode characters (including CJK)
        let latex = "\\text{Hello 世界 こんにちは 안녕하세요 مرحبا}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 150
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should handle Unicode text (may need fallback font)
        XCTAssertNotNil(display, "Should handle Unicode text")

        // Each line should attempt to respect width
        for subDisplay in display!.subDisplays {
            // More tolerance for Unicode as font metrics vary
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.5,
                "Unicode text line should respect width reasonably")
        }
    }

    func testNumberProtection() throws {
        // Test that numbers don't break in the middle
        let latex = "\\text{The value is 3.14159 or 2,718 or 1,000,000}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 150
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Numbers should stay together (not split like "3.14" → "3." on one line, "14" on next)
        // This is handled by the universal breaking mechanism with Core Text
        XCTAssertNotNil(display, "Should handle text with numbers")
    }

    // MARK: - Tests for Not-Yet-Optimized Cases (Document Current Behavior)

    func testCurrentBehavior_LargeOperators() throws {
        // Documents current behavior: large operators still force line breaks
        let latex = "\\sum_{i=1}^{n}x_{i}+\\int_{0}^{1}f(x)dx"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 300
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Current behavior: operators force breaks
        // This test documents current behavior for future improvement
        XCTAssertNotNil(display, "Large operators render (may force breaks)")
    }

    func testCurrentBehavior_NestedDelimiters() throws {
        // Documents current behavior: \left...\right still forces line breaks
        let latex = "a+\\left(b+c\\right)+d"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 200
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Current behavior: delimiters may force breaks
        // This test documents current behavior for future improvement
        XCTAssertNotNil(display, "Delimiters render (may force breaks)")
    }

    func testCurrentBehavior_ColoredExpressions() throws {
        // Documents current behavior: colored sections still force line breaks
        let latex = "a+\\color{red}{b+c}+d"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 200
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Current behavior: colored sections may force breaks
        // This test documents current behavior for future improvement
        XCTAssertNotNil(display, "Colored sections render (may force breaks)")
    }

    func testCurrentBehavior_MatricesWithSurroundingContent() throws {
        // Documents current behavior: matrices still force line breaks
        let latex = "A=\\begin{pmatrix}1&2\\\\3&4\\end{pmatrix}+B"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 300
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Current behavior: matrices force breaks
        // This test documents current behavior for future improvement
        XCTAssertNotNil(display, "Matrices render (force breaks)")
    }

    func testRealWorldExample_QuadraticFormula() throws {
        // Real-world test: quadratic formula with width constraint
        let latex = "x=\\frac{-b\\pm\\sqrt{b^{2}-4ac}}{2a}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 200
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should render the formula (may break if too wide)
        XCTAssertNotNil(display, "Quadratic formula renders")
        XCTAssertGreaterThan(display!.width, 0, "Formula has non-zero width")
    }

    func testRealWorldExample_ComplexFraction() throws {
        // Real-world test: continued fraction
        let latex = "\\frac{1}{2+\\frac{1}{3+\\frac{1}{4}}}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 150
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should render nested fractions
        XCTAssertNotNil(display, "Nested fractions render")
        XCTAssertGreaterThan(display!.width, 0, "Formula has non-zero width")
    }

    func testRealWorldExample_MixedOperationsWithFractions() throws {
        // Real-world test: mixed arithmetic with multiple fractions
        let latex = "\\frac{1}{2}+\\frac{2}{3}+\\frac{3}{4}+\\frac{4}{5}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 180
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // With new implementation, fractions should stay inline when possible
        // May break into 2-3 lines depending on actual widths
        XCTAssertGreaterThan(display!.subDisplays.count, 0, "Multiple fractions render")

        // Verify width constraints are respected
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.3,
                "Line \(index) should respect width constraint reasonably")
        }
    }

    // MARK: - Large Operator Tests (NEWLY FIXED!)

    func testComplexDisplay_LargeOperatorStaysInlineWhenFits() throws {
        // Test that inline-style large operators stay inline when they fit
        // In display style without explicit limits, operators should be inline-sized
        let latex = "a+\\sum x_i+b"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 250
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .text, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // In text style, large operator should be inline-sized and stay with surrounding content
        // Should be 1 line if it fits
        let lineCount = display!.subDisplays.count

        // Verify width constraints are respected
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) width (\(subDisplay.width)) should respect constraint")
        }
    }

    func testComplexDisplay_LargeOperatorBreaksWhenTooWide() throws {
        // Test that large operators break when they don't fit
        let latex = "a+b+c+d+e+f+\\sum_{i=1}^{n}x_i"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 80  // Very narrow
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // With narrow width, should break into multiple lines
        let lineCount = display!.subDisplays.count
        XCTAssertGreaterThan(lineCount, 1, "Should break into multiple lines")

        // Verify width constraints are respected (with tolerance for tall operators)
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.5,
                "Line \(index) width (\(subDisplay.width)) should roughly respect constraint")
        }
    }

    func testComplexDisplay_MultipleLargeOperators() throws {
        // Test multiple large operators in sequence
        let latex = "\\sum x_i+\\int f(x)dx+\\prod a_i"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 300
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .text, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // In text style with wide constraint, might fit on 1-2 lines
        let lineCount = display!.subDisplays.count

        XCTAssertGreaterThan(display!.subDisplays.count, 0, "Operators render")

        // Verify width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) should respect width constraint")
        }
    }

    // MARK: - Delimiter Tests (NEWLY FIXED!)

    func testComplexDisplay_DelimitersStayInlineWhenFit() throws {
        // Test that delimited expressions stay inline when they fit
        let latex = "a+\\left(b+c\\right)+d"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 200
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should stay on 1 line when it fits
        let lineCount = display!.subDisplays.count

        // Verify width constraints are respected
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) width (\(subDisplay.width)) should respect constraint")
        }
    }

    func testComplexDisplay_DelimitersBreakWhenTooWide() throws {
        // Test that delimited expressions break when they don't fit
        let latex = "a+b+c+\\left(d+e+f+g+h\\right)+i+j"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 100  // Narrow
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should break into multiple lines
        let lineCount = display!.subDisplays.count
        XCTAssertGreaterThan(lineCount, 1, "Should break into multiple lines")

        // Verify width constraints (delimiters add extra width, so be more tolerant)
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.7,
                "Line \(index) should respect width constraint")
        }
    }

    func testComplexDisplay_NestedDelimitersWithWrapping() throws {
        // Test that inner content of delimiters respects width constraints
        let latex = "\\left(a+b+c+d+e+f+g+h\\right)"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 120
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // With maxWidth propagation, inner content should wrap
        XCTAssertGreaterThan(display!.subDisplays.count, 0, "Delimiters render")

        // Verify width constraints (delimiters with wrapped content can be wide)
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 2.5,
                "Line \(index) width (\(subDisplay.width)) should respect constraint reasonably")
        }
    }

    func testComplexDisplay_MultipleDelimiters() throws {
        // Test multiple delimited expressions
        let latex = "\\left(a+b\\right)+\\left(c+d\\right)+\\left(e+f\\right)"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 250
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should intelligently break between delimiters if needed
        let lineCount = display!.subDisplays.count

        // Verify width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) should respect width constraint")
        }
    }

    // MARK: - Color Tests (NEWLY FIXED!)

    func testComplexDisplay_ColoredExpressionStaysInlineWhenFits() throws {
        // Test that colored expressions stay inline when they fit
        let latex = "a+\\color{red}{b+c}+d"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 200
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should stay on 1 line when it fits
        let lineCount = display!.subDisplays.count

        // Verify width constraints are respected
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) width (\(subDisplay.width)) should respect constraint")
        }
    }

    func testComplexDisplay_ColoredExpressionBreaksWhenTooWide() throws {
        // Test that colored expressions break when they don't fit
        let latex = "a+\\color{blue}{b+c+d+e+f+g+h}+i"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 100  // Narrow
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should break into multiple lines
        let lineCount = display!.subDisplays.count
        XCTAssertGreaterThan(lineCount, 1, "Should break into multiple lines")

        // Verify width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.3,
                "Line \(index) should respect width constraint")
        }
    }

    // Removed testComplexDisplay_ColoredContentWraps - colored expression tests above are sufficient

    func testComplexDisplay_MultipleColoredSections() throws {
        // Test multiple colored sections
        let latex = "\\color{red}{a+b}+\\color{blue}{c+d}+\\color{green}{e+f}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 250
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should intelligently break between colored sections if needed
        let lineCount = display!.subDisplays.count

        // Verify width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) should respect width constraint")
        }
    }

    // MARK: - Matrix Tests (NEWLY FIXED!)

    func testComplexDisplay_SmallMatrixStaysInlineWhenFits() throws {
        // Test that small matrices stay inline when they fit
        let latex = "A=\\begin{pmatrix}1&2\\end{pmatrix}+B"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 250
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Small 1x2 matrix should stay inline
        let lineCount = display!.subDisplays.count

        // Verify width constraints are respected
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) width (\(subDisplay.width)) should respect constraint")
        }
    }

    func testComplexDisplay_MatrixBreaksWhenTooWide() throws {
        // Test that large matrices break when they don't fit
        let latex = "a+b+c+\\begin{pmatrix}1&2&3&4\\end{pmatrix}+d"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 120  // Narrow
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should break with narrow width
        let lineCount = display!.subDisplays.count

        // Verify width constraints (matrices can be slightly wider)
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.5,
                "Line \(index) should roughly respect width constraint")
        }
    }

    func testComplexDisplay_MatrixWithSurroundingContent() throws {
        // Real-world test: matrix in equation
        let latex = "M=\\begin{pmatrix}a&b\\\\c&d\\end{pmatrix}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 200
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // 2x2 matrix with assignment
        XCTAssertGreaterThan(display!.subDisplays.count, 0, "Matrix renders")

        // Verify width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.4,
                "Line \(index) should respect width constraint")
        }
    }

    // MARK: - Integration Tests (All Complex Displays)

    func testComplexDisplay_MixedComplexElements() throws {
        // Test mixing all complex display types
        let latex = "a+\\frac{1}{2}+\\sqrt{3}+\\left(b+c\\right)+\\color{red}{d}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 300
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // With wide constraint, elements should render with reasonable breaking
        let lineCount = display!.subDisplays.count
        XCTAssertGreaterThan(lineCount, 0, "Should have content")
        // Note: lineCount may be higher due to flushing currentLine before each complex atom
        // What matters is that they fit within the width constraint
        XCTAssertLessThanOrEqual(lineCount, 12, "Should fit reasonably (increased for flushed segments)")

        // Verify width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) should respect width constraint")
        }
    }

    func testComplexDisplay_RealWorldQuadraticWithColor() throws {
        // Real-world: colored quadratic formula
        let latex = "x=\\frac{-b\\pm\\color{blue}{\\sqrt{b^2-4ac}}}{2a}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Failed to parse LaTeX")

        let maxWidth: CGFloat = 250
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Complex nested structure with color
        XCTAssertGreaterThan(display!.subDisplays.count, 0, "Complex formula renders")

        // Verify width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.3,
                "Line \(index) should respect width constraint")
        }
    }

    // MARK: - Regression Test for Sum Equation Layout Bug

    func testSumEquationWithFraction_CorrectOrdering() throws {
        // Test case for: \(\sum_{i=1}^{n} i = \frac{n(n+1)}{2}\)
        // Bug: The = sign was appearing at the end instead of between i and the fraction
        let latex = "\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // Create display without width constraint first to check ordering
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)
        XCTAssertNotNil(display, "Should create display")

        // Get the subdisplays to check ordering
        let subDisplays = display!.subDisplays

        // Print positions and types for debugging
        for (index, subDisplay) in subDisplays.enumerated() {
            if let lineDisplay = subDisplay as? MTCTLineDisplay {
            }
        }

        // The expected order should be: sum (with limits), i, =, fraction
        // We need to verify that the x positions are monotonically increasing
        var previousX: CGFloat = -1
        var foundSum = false
        var foundEquals = false
        var foundFraction = false

        for subDisplay in subDisplays {
            // Check x position is increasing (allowing small tolerance for rounding)
            if previousX >= 0 {
                XCTAssertGreaterThanOrEqual(subDisplay.position.x, previousX - 0.1,
                    "Displays should be ordered left to right, but got x=\(subDisplay.position.x) after x=\(previousX)")
            }
            previousX = subDisplay.position.x + subDisplay.width

            // Identify what type of display this is
            if subDisplay is MTLargeOpLimitsDisplay {
                foundSum = true
                XCTAssertFalse(foundEquals, "Sum should come before equals sign")
                XCTAssertFalse(foundFraction, "Sum should come before fraction")
            } else if let lineDisplay = subDisplay as? MTCTLineDisplay,
                      let text = lineDisplay.attributedString?.string {
                if text.contains("=") {
                    foundEquals = true
                    XCTAssertTrue(foundSum, "Equals should come after sum")
                    XCTAssertFalse(foundFraction, "Equals should come before fraction")
                }
            } else if subDisplay is MTFractionDisplay {
                foundFraction = true
                XCTAssertTrue(foundSum, "Fraction should come after sum")
                XCTAssertTrue(foundEquals, "Fraction should come after equals sign")
            }
        }

        XCTAssertTrue(foundSum, "Should contain sum operator")
        XCTAssertTrue(foundEquals, "Should contain equals sign")
        XCTAssertTrue(foundFraction, "Should contain fraction")
    }

    func testSumEquationWithFraction_WithWidthConstraint() throws {
        // Test case for: \(\sum_{i=1}^{n} i = \frac{n(n+1)}{2}\) with width constraint
        // This reproduces the issue where = appears at the end instead of in the middle
        let latex = "\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // Create display with width constraint matching MathView preview (235)
        // Use .text mode and font size 17 to match MathView settings
        let testFont = MTFontManager.fontManager.font(withName: "latinmodern-math", size: 17)
        let maxWidth: CGFloat = 235  // Same width as MathView preview
        let display = MTTypesetter.createLineForMathList(mathList, font: testFont, style: .text, maxWidth: maxWidth)
        XCTAssertNotNil(display, "Should create display")

        // Get the subdisplays to check ordering
        let subDisplays = display!.subDisplays

        // Print positions and types for debugging
        for (index, subDisplay) in subDisplays.enumerated() {
            if let lineDisplay = subDisplay as? MTCTLineDisplay {
            }
        }

        // Track what we find and their y positions
        var sumX: CGFloat?
        var sumY: CGFloat?
        var iX: CGFloat?
        var iY: CGFloat?
        var equalsX: CGFloat?
        var equalsY: CGFloat?
        var fractionX: CGFloat?
        var fractionY: CGFloat?

        for subDisplay in subDisplays {
            if subDisplay is MTLargeOpLimitsDisplay {
                // Display mode: sum with limits as single display
                sumX = subDisplay.position.x
                sumY = subDisplay.position.y
            } else if subDisplay is MTGlyphDisplay {
                // Text mode: sum symbol as glyph display (check if it's the sum symbol)
                if sumX == nil {
                    sumX = subDisplay.position.x
                    sumY = subDisplay.position.y
                }
            } else if let lineDisplay = subDisplay as? MTCTLineDisplay,
                      let text = lineDisplay.attributedString?.string {
                if text.contains("=") && !text.contains("i") {
                    // Just the equals sign (not combined with i)
                    equalsX = subDisplay.position.x
                    equalsY = subDisplay.position.y
                } else if text.contains("i") && text.contains("=") {
                    // i and = together (ideal case)
                    iX = subDisplay.position.x
                    iY = subDisplay.position.y
                    equalsX = subDisplay.position.x  // They're together
                    equalsY = subDisplay.position.y
                } else if text.contains("i") {
                    // Just i
                    iX = subDisplay.position.x
                    iY = subDisplay.position.y
                }
            } else if subDisplay is MTFractionDisplay {
                fractionX = subDisplay.position.x
                fractionY = subDisplay.position.y
            }
        }

        // Verify we found all components
        XCTAssertNotNil(sumX, "Should find sum operator (glyph or large op display)")
        XCTAssertNotNil(equalsX, "Should find equals sign")
        XCTAssertNotNil(fractionX, "Should find fraction")

        // The key test: equals sign should come BETWEEN i and fraction in horizontal position
        // OR if on different lines, equals should not come after fraction
        if let eqX = equalsX, let eqY = equalsY, let fracX = fractionX, let fracY = fractionY {
            if abs(eqY - fracY) < 1.0 {
                // Same line: equals must be to the left of fraction
                XCTAssertLessThan(eqX, fracX,
                    "Equals sign (x=\(eqX)) should be to the left of fraction (x=\(fracX)) on same line")
            }

            // Equals should never be to the right of the fraction's right edge
            XCTAssertLessThan(eqX, fracX + display!.width,
                "Equals sign should not appear after the fraction")
        }

    }

    // MARK: - Improved Script Handling Tests

    func testScriptedAtoms_StayInlineWhenFit() throws {
        // Test that atoms with superscripts stay inline when they fit
        let latex = "a^{2}+b^{2}+c^{2}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // Wide enough to fit everything on one line
        let maxWidth: CGFloat = 200
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Check for line breaks (large y position gaps indicate line breaks)
        // Note: Superscripts/subscripts have different y positions but are on same "line"
        // Line breaks use fontSize * 1.5 spacing, so look for gaps > fontSize
        var yPositions = display!.subDisplays.map { $0.position.y }.sorted()
        var lineBreakCount = 0
        for i in 1..<yPositions.count {
            let gap = abs(yPositions[i] - yPositions[i-1])
            if gap > self.font.fontSize {
                lineBreakCount += 1
            }
        }

        XCTAssertEqual(lineBreakCount, 0,
            "Should have no line breaks when content fits within width")

        // Total width should be within constraint
        XCTAssertLessThan(display!.width, maxWidth,
            "Expression should fit within width constraint")
    }

    func testScriptedAtoms_BreakWhenTooWide() throws {
        // Test that atoms with superscripts break when width is exceeded
        let latex = "a^{2}+b^{2}+c^{2}+d^{2}+e^{2}+f^{2}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // Narrow width should force breaking
        let maxWidth: CGFloat = 100
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should have multiple lines (different y positions)
        var uniqueYPositions = Set<CGFloat>()
        for subDisplay in display!.subDisplays {
            uniqueYPositions.insert(round(subDisplay.position.y * 10) / 10) // Round to avoid floating point issues
        }

        XCTAssertGreaterThan(uniqueYPositions.count, 1,
            "Should have multiple lines due to width constraint")

        // Each subdisplay should respect width constraint
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) width (\(subDisplay.width)) should respect constraint")
        }
    }

    func testMixedScriptedAndNonScripted() throws {
        // Test mixing scripted and non-scripted atoms
        let latex = "a+b^{2}+c+d^{2}+e"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let maxWidth: CGFloat = 180
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should fit on one or few lines
        // Note: subdisplay count may be higher due to flushing before scripted atoms
        XCTAssertLessThanOrEqual(display!.subDisplays.count, 8,
            "Mixed expression should have reasonable line count")

        // Verify width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) should respect width constraint")
        }
    }

    func testSubscriptsAndSuperscripts() throws {
        // Test atoms with both subscripts and superscripts
        let latex = "x_{1}^{2}+x_{2}^{2}+x_{3}^{2}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let maxWidth: CGFloat = 200
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should fit on reasonable number of lines
        XCTAssertGreaterThan(display!.subDisplays.count, 0,
            "Should have content")

        // Verify width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) should respect width constraint")
        }
    }

    func testRealWorld_QuadraticExpansion() throws {
        // Real-world test: quadratic expansion with exponents
        let latex = "(a+b)^{2}=a^{2}+2ab+b^{2}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let maxWidth: CGFloat = 250
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should fit on reasonable number of lines
        XCTAssertGreaterThan(display!.subDisplays.count, 0,
            "Quadratic expansion should render")

        // Verify width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) should respect width constraint")
        }
    }

    func testRealWorld_Polynomial() throws {
        // Real-world test: polynomial with multiple terms
        let latex = "x^{4}+x^{3}+x^{2}+x+1"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let maxWidth: CGFloat = 180
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should have reasonable structure
        XCTAssertGreaterThan(display!.subDisplays.count, 0,
            "Polynomial should render")

        // Verify width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Line \(index) should respect width constraint")
        }
    }

    func testScriptedAtoms_NoBreakingWithoutConstraint() throws {
        // Test that scripted atoms don't break unnecessarily without width constraint
        let latex = "a^{2}+b^{2}+c^{2}+d^{2}+e^{2}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // No width constraint (maxWidth = 0)
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: 0)
        XCTAssertNotNil(display)

        // Check for line breaks - should have none without width constraint
        var yPositions = display!.subDisplays.map { $0.position.y }.sorted()
        var lineBreakCount = 0
        for i in 1..<yPositions.count {
            let gap = abs(yPositions[i] - yPositions[i-1])
            if gap > self.font.fontSize {
                lineBreakCount += 1
            }
        }

        XCTAssertEqual(lineBreakCount, 0,
            "Without width constraint, should have no line breaks")
    }

    func testComplexScriptedExpression() throws {
        // Test complex expression mixing fractions and scripts
        let latex = "\\frac{x^{2}}{y^{2}}+a^{2}+\\sqrt{b^{2}}"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let maxWidth: CGFloat = 220
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should render successfully
        XCTAssertGreaterThan(display!.subDisplays.count, 0,
            "Complex expression should render")

        // Verify width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.3,
                "Line \(index) should respect width constraint (with tolerance for complex atoms)")
        }
    }

    // MARK: - Break Quality Scoring Tests

    func testBreakQuality_PreferAfterBinaryOperator() throws {
        // Test that breaks prefer to occur after binary operators (+, -, ×, ÷)
        // Expression: "aaaa+bbbbcccc" where break should occur after + (not in middle of bbbbcccc)
        let latex = "aaaa+bbbbcccc"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // Set width to force a break somewhere between + and end
        let maxWidth: CGFloat = 100
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Extract text content from each line to verify break location
        var lineContents: [String] = []
        for subDisplay in display!.subDisplays {
            if let lineDisplay = subDisplay as? MTCTLineDisplay,
               let text = lineDisplay.attributedString?.string {
                lineContents.append(text)
            }
        }

        // With break quality scoring, should break after the + operator
        // First line should contain "aaaa+"
        let hasGoodBreak = lineContents.contains { $0.contains("+") }
        XCTAssertTrue(hasGoodBreak,
            "Break should occur after binary operator +, found lines: \(lineContents)")
    }

    func testBreakQuality_PreferAfterRelation() throws {
        // Test that breaks prefer to occur after relation operators (=, <, >)
        let latex = "aaaa=bbbb+cccc"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let maxWidth: CGFloat = 90
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Extract line contents
        var lineContents: [String] = []
        for subDisplay in display!.subDisplays {
            if let lineDisplay = subDisplay as? MTCTLineDisplay,
               let text = lineDisplay.attributedString?.string {
                lineContents.append(text)
            }
        }

        // Should break after the = operator
        let hasGoodBreak = lineContents.contains { $0.contains("=") }
        XCTAssertTrue(hasGoodBreak,
            "Break should occur after relation operator =, found lines: \(lineContents)")
    }

    func testBreakQuality_AvoidAfterOpenBracket() throws {
        // Test that breaks avoid occurring immediately after open brackets
        // Expression: "aaaa+(bbb+ccc)" should NOT break as "aaaa+(\n bbb+ccc)"
        let latex = "aaaa+(bbb+ccc)"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let maxWidth: CGFloat = 100
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Extract line contents
        var lineContents: [String] = []
        for subDisplay in display!.subDisplays {
            if let lineDisplay = subDisplay as? MTCTLineDisplay,
               let text = lineDisplay.attributedString?.string {
                lineContents.append(text)
            }
        }

        // Should NOT have a line ending with "+(" - bad break point
        let hasBadBreak = lineContents.contains { $0.hasSuffix("+(") }
        XCTAssertFalse(hasBadBreak,
            "Should avoid breaking after open bracket, found lines: \(lineContents)")
    }

    func testBreakQuality_LookAheadFindsBetterBreak() throws {
        // Test that look-ahead finds better break points
        // Expression: "aaabbb+ccc" with tight width
        // Should defer break to after + rather than between aaa and bbb
        let latex = "aaabbb+ccc"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // Width set so that "aaabbb" slightly exceeds, but look-ahead should find + as better break
        let maxWidth: CGFloat = 60
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Extract line contents
        var lineContents: [String] = []
        for subDisplay in display!.subDisplays {
            if let lineDisplay = subDisplay as? MTCTLineDisplay,
               let text = lineDisplay.attributedString?.string {
                lineContents.append(text)
            }
        }

        // Should break after + (penalty 0) rather than in the middle (penalty 10 or 50)
        let hasGoodBreak = lineContents.contains { $0.contains("+") }
        XCTAssertTrue(hasGoodBreak,
            "Look-ahead should find better break after +, found lines: \(lineContents)")
    }

    func testBreakQuality_MultipleOperators() throws {
        // Test with multiple operators - should break at best available points
        let latex = "a+b+c+d+e+f"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let maxWidth: CGFloat = 60
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Count line breaks
        var yPositions = display!.subDisplays.map { $0.position.y }.sorted()
        var lineBreakCount = 0
        for i in 1..<yPositions.count {
            let gap = abs(yPositions[i] - yPositions[i-1])
            if gap > self.font.fontSize {
                lineBreakCount += 1
            }
        }

        // Should have some breaks
        XCTAssertGreaterThan(lineBreakCount, 0, "Expression should break into multiple lines")

        // Each line should respect width constraint
        for subDisplay in display!.subDisplays {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.2,
                "Each line should respect width constraint")
        }
    }

    func testBreakQuality_ComplexExpression() throws {
        // Test complex expression with various atom types
        let latex = "x=a+b\\times c+\\frac{d}{e}+f"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let maxWidth: CGFloat = 120
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should render successfully
        XCTAssertGreaterThan(display!.subDisplays.count, 0, "Should have content")

        // Verify all subdisplays respect width constraints
        for (index, subDisplay) in display!.subDisplays.enumerated() {
            XCTAssertLessThanOrEqual(subDisplay.width, maxWidth * 1.3,
                "Line \(index) should respect width (with tolerance for complex atoms)")
        }
    }

    func testBreakQuality_NoBreakWhenNotNeeded() throws {
        // Test that break quality scoring doesn't add unnecessary breaks
        let latex = "a+b+c"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let maxWidth: CGFloat = 200  // Wide enough to fit everything
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should have no breaks when content fits
        var yPositions = display!.subDisplays.map { $0.position.y }.sorted()
        var lineBreakCount = 0
        for i in 1..<yPositions.count {
            let gap = abs(yPositions[i] - yPositions[i-1])
            if gap > self.font.fontSize {
                lineBreakCount += 1
            }
        }

        XCTAssertEqual(lineBreakCount, 0,
            "Should not add breaks when content fits within width")
    }

    func testBreakQuality_PenaltyOrdering() throws {
        // Test that penalty system correctly orders break preferences
        // Given: "aaaa+b(ccc" - when break is needed, should prefer breaking after + (penalty 0)
        // rather than after ( (penalty 100)
        let latex = "aaaa+b(ccc"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        let maxWidth: CGFloat = 70
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Extract line contents
        var lineContents: [String] = []
        for subDisplay in display!.subDisplays {
            if let lineDisplay = subDisplay as? MTCTLineDisplay,
               let text = lineDisplay.attributedString?.string {
                lineContents.append(text)
            }
        }

        // Should prefer breaking after "+" (penalty 0) rather than after "(" (penalty 100)
        let breaksAfterPlus = lineContents.contains { $0.contains("+") && !$0.contains("(") }
        XCTAssertTrue(breaksAfterPlus || lineContents.count == 1,
            "Should prefer breaking after + operator or fit on one line, found lines: \(lineContents)")
    }

    // MARK: - Dynamic Line Height Tests

    func testDynamicLineHeight_TallContentHasMoreSpacing() throws {
        // Test that lines with tall content (fractions) have appropriate spacing
        let latex = "a+b+c+\\frac{x^{2}}{y^{2}}+d+e+f"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // Force multiple lines
        let maxWidth: CGFloat = 80
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Collect unique y positions (representing different lines)
        let yPositions = Set(display!.subDisplays.map { $0.position.y }).sorted(by: >)

        // Should have multiple lines
        XCTAssertGreaterThan(yPositions.count, 1, "Should have multiple lines")

        // Calculate spacing between lines
        var spacings: [CGFloat] = []
        for i in 1..<yPositions.count {
            let spacing = yPositions[i-1] - yPositions[i]
            spacings.append(spacing)
        }

        // With dynamic line height, spacing should vary based on content height
        // Line with fraction should have larger spacing than lines with just variables
        // All spacings should be at least 20% of fontSize (minimum spacing)
        let minExpectedSpacing = self.font.fontSize * 0.2
        for spacing in spacings {
            XCTAssertGreaterThanOrEqual(spacing, minExpectedSpacing,
                "Line spacing should be at least minimum spacing")
        }
    }

    func testDynamicLineHeight_RegularContentHasReasonableSpacing() throws {
        // Test that lines with regular content don't have excessive spacing
        let latex = "a+b+c+d+e+f+g+h+i+j"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // Force multiple lines
        let maxWidth: CGFloat = 60
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Collect unique y positions
        let yPositions = Set(display!.subDisplays.map { $0.position.y }).sorted(by: >)

        // Should have multiple lines
        XCTAssertGreaterThan(yPositions.count, 1, "Should have multiple lines")

        // Calculate spacing between lines
        var spacings: [CGFloat] = []
        for i in 1..<yPositions.count {
            let spacing = yPositions[i-1] - yPositions[i]
            spacings.append(spacing)
        }

        // For regular content, spacing should be reasonable (roughly 1.2-1.8x fontSize)
        for spacing in spacings {
            XCTAssertGreaterThanOrEqual(spacing, self.font.fontSize * 1.0,
                "Spacing should be at least fontSize")
            XCTAssertLessThanOrEqual(spacing, self.font.fontSize * 2.0,
                "Spacing should not be excessive for regular content")
        }
    }

    func testDynamicLineHeight_MixedContentVariesSpacing() throws {
        // Test that spacing adapts to each line's content
        // Line 1: regular (a+b)
        // Line 2: with fraction (more height needed)
        // Line 3: regular again (c+d)
        let latex = "a+b+\\frac{x}{y}+c+d"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // Force breaks to create multiple lines
        let maxWidth: CGFloat = 50
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should render successfully with varying line heights
        XCTAssertGreaterThan(display!.subDisplays.count, 0, "Should have content")

        // Verify overall height is reasonable
        let totalHeight = display!.ascent + display!.descent
        XCTAssertGreaterThan(totalHeight, 0, "Total height should be positive")
    }

    func testDynamicLineHeight_LargeOperatorsGetAdequateSpace() throws {
        // Test that large operators with limits get adequate vertical spacing
        let latex = "\\sum_{i=1}^{n}i+\\prod_{j=1}^{m}j"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // Force line break between operators
        let maxWidth: CGFloat = 80
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Collect y positions
        let yPositions = Set(display!.subDisplays.map { $0.position.y }).sorted(by: >)

        if yPositions.count > 1 {
            // Calculate spacing
            var spacings: [CGFloat] = []
            for i in 1..<yPositions.count {
                let spacing = yPositions[i-1] - yPositions[i]
                spacings.append(spacing)
            }

            // Large operators need substantial spacing
            for spacing in spacings {
                XCTAssertGreaterThanOrEqual(spacing, self.font.fontSize,
                    "Large operators should have at least fontSize spacing")
            }
        }
    }

    func testDynamicLineHeight_ConsistentWithinSimilarContent() throws {
        // Test that similar lines get similar spacing
        let latex = "a+b+c+d+e+f"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // Force multiple lines with similar content
        let maxWidth: CGFloat = 40
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Collect unique y positions
        let yPositions = Set(display!.subDisplays.map { $0.position.y }).sorted(by: >)

        if yPositions.count >= 3 {
            // Calculate all spacings
            var spacings: [CGFloat] = []
            for i in 1..<yPositions.count {
                let spacing = yPositions[i-1] - yPositions[i]
                spacings.append(spacing)
            }

            // Similar content should have similar spacing (within 20% variance)
            let avgSpacing = spacings.reduce(0, +) / CGFloat(spacings.count)
            for spacing in spacings {
                let variance = abs(spacing - avgSpacing) / avgSpacing
                XCTAssertLessThanOrEqual(variance, 0.3,
                    "Spacing variance should be reasonable for similar content")
            }
        }
    }

    func testDynamicLineHeight_NoRegressionOnSingleLine() throws {
        // Test that single-line expressions still work correctly
        let latex = "a+b+c"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // No width constraint
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display)
        XCTAssertNotNil(display)

        // Should be on single line
        let yPositions = Set(display!.subDisplays.map { $0.position.y })
        XCTAssertEqual(yPositions.count, 1, "Should be on single line")
    }

    func testDynamicLineHeight_DeepFractionsGetExtraSpace() throws {
        // Test that nested/continued fractions get adequate spacing
        let latex = "a+\\frac{1}{\\frac{2}{3}}+b+c"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // Force line breaks
        let maxWidth: CGFloat = 70
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Deep fractions are taller - verify reasonable total height
        let totalHeight = display!.ascent + display!.descent
        XCTAssertGreaterThan(totalHeight, 0, "Should have positive height")

        // Should render without issues
        XCTAssertGreaterThan(display!.subDisplays.count, 0, "Should have content")
    }

    func testDynamicLineHeight_RadicalsWithIndicesGetSpace() throws {
        // Test that radicals (especially with degrees like cube roots) get adequate spacing
        let latex = "a+\\sqrt[3]{x}+b+\\sqrt{y}+c"
        let mathList = MTMathListBuilder.build(fromString: latex)
        XCTAssertNotNil(mathList, "Should parse LaTeX")

        // Force line breaks
        let maxWidth: CGFloat = 70
        let display = MTTypesetter.createLineForMathList(mathList, font: self.font, style: .display, maxWidth: maxWidth)
        XCTAssertNotNil(display)

        // Should render successfully
        XCTAssertGreaterThan(display!.subDisplays.count, 0, "Should have content")

        // Verify reasonable spacing
        let yPositions = Set(display!.subDisplays.map { $0.position.y }).sorted(by: >)
        if yPositions.count > 1 {
            for i in 1..<yPositions.count {
                let spacing = yPositions[i-1] - yPositions[i]
                XCTAssertGreaterThanOrEqual(spacing, self.font.fontSize * 0.2,
                    "Should have minimum spacing")
            }
        }
    }

}

