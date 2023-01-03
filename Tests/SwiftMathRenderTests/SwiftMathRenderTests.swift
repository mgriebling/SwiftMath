import XCTest
@testable import SwiftMathRender

//
//  MathRenderSwiftTests.swift
//  MathRenderSwiftTests
//
//  Created by Mike Griebling on 2023-01-02.
//

final class SwiftMathRenderTests: XCTestCase {

    func checkAtomTypes(_ list:MTMathList?, types:[MTMathAtomType], desc:String) {
        if let list = list {
            XCTAssertEqual(list.atoms.count, types.count, desc)
            for i in 0..<list.atoms.count {
                let atom = list.atoms[i]
                XCTAssertNotNil(atom, desc)
                XCTAssertEqual(atom.type, types[i], desc)
            }
        } else {
            XCTAssert(types.count == 0, "MathList should have no atoms!")
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    struct TestRecord {
        let build : String
        let atomType : [MTMathAtomType]
        let types : [MTMathAtomType]
        let extra : [MTMathAtomType]
        let result : String
        
        init(build: String, atomType: [MTMathAtomType], types: [MTMathAtomType], extra: [MTMathAtomType] = [MTMathAtomType](), result: String) {
            self.build = build
            self.atomType = atomType
            self.types = types
            self.extra = extra
            self.result = result
        }
    }
    
    func getTestDataSuperScript() -> [TestRecord] {
        [
            TestRecord(build: "x^2", atomType: [.variable], types: [.number], result: "x^{2}"),
            TestRecord(build: "x^23", atomType: [ .variable, .number ],  types: [ .number ], result: "x^{2}3"),
            TestRecord(build: "x^{23}", atomType: [ .variable ],  types: [ .number, .number ], result: "x^{23}"),
            TestRecord(build: "x^2^3", atomType: [ .variable, .ordinary ],  types: [ .number ], result: "x^{2}{}^{3}" ),
            TestRecord(build: "x^{2^3}", atomType: [ .variable ], types: [ .number], extra: [ .number ], result: "x^{2^{3}}"),
            TestRecord(build: "x^{^2*}", atomType: [ .variable ], types: [ .ordinary, .binaryOperator], extra:[ .number ], result:"x^{{}^{2}*}"),
            TestRecord(build: "^2",  atomType: [ .ordinary], types: [ .number ], result: "{}^{2}"),
            TestRecord(build: "{}^2",  atomType: [ .ordinary], types: [ .number ], result: "{}^{2}"),
            TestRecord(build: "x^^2", atomType: [ .variable, .ordinary ],  types: [ ], result: "x^{}{}^{2}"),
            TestRecord(build: "5{x}^2",  atomType: [ .number, .variable], types: [ ], result: "5x^{2}"),
        ]
    }
    
    func getTestDataSubScript() -> [TestRecord] {
        [
            TestRecord(build: "x_2", atomType: [.variable], types: [.number], result: "x_{2}"),
            TestRecord(build: "x_23", atomType: [ .variable, .number ],  types: [ .number ], result: "x_{2}3"),
            TestRecord(build: "x_{23}", atomType: [ .variable ],  types: [ .number, .number ], result: "x_{23}"),
            TestRecord(build: "x_2_3", atomType: [ .variable, .ordinary ],  types: [ .number ], result: "x_{2}{}_{3}" ),
            TestRecord(build: "x_{2_3}", atomType: [ .variable ], types: [ .number], extra: [ .number ], result: "x_{2_{3}}"),
            TestRecord(build: "x_{_2*}", atomType: [ .variable ], types: [ .ordinary, .binaryOperator], extra:[ .number ], result:"x_{{}_{2}*}"),
            TestRecord(build: "_2",  atomType: [ .ordinary], types: [ .number ], result: "{}_{2}"),
            TestRecord(build: "{}_2",  atomType: [ .ordinary], types: [ .number ], result: "{}_{2}"),
            TestRecord(build: "x__2", atomType: [ .variable, .ordinary ],  types: [ ], result: "x_{}{}_{2}"),
            TestRecord(build: "5{x}_2",  atomType: [ .number, .variable], types: [ ], result: "5x_{2}"),
        ]
    }
    
    func getTestDataSuperSubScript() -> [TestRecord] {
        [
            TestRecord(build: "x_2^*", atomType: [.variable], types: [.number], extra: [.binaryOperator], result: "x^{*}_{2}"),
            TestRecord(build: "x^*_2", atomType: [.variable], types: [.number], extra: [.binaryOperator], result: "x^{*}_{2}"),
            TestRecord(build: "x_^*", atomType: [.variable], types: [ ], extra: [.binaryOperator], result: "x^{*}_{}"),
            TestRecord(build: "x^_2", atomType: [.variable], types: [.number], result: "x^{}_{2}"),
            TestRecord(build: "x_{2^*}", atomType: [.variable], types: [.number], result: "x_{2^{*}}"),
            TestRecord(build: "x^{*_2}", atomType: [.variable], types: [ ], extra: [.binaryOperator], result: "x^{*_{2}}"),
            TestRecord(build: "_2^*", atomType: [.ordinary], types: [.number], extra: [.binaryOperator], result: "{}^{*}_{2}")
        ]
    }
    
    struct TestRecord2 {
        let build : String
        let type1 : [MTMathAtomType]
        let number : Int
        let type2 : [MTMathAtomType]
        let left : String
        let right : String
        let result : String
    }
    
    func getTestDataLeftRight() -> [TestRecord2] {
        [
            TestRecord2(build: "\\left( 2 \\right)", type1: [ .inner ], number: 0, type2: [ .number], left: "(", right: ")", result: "\\left( 2\\right) "),
            // spacing
            TestRecord2(build: "\\left ( 2 \\right )", type1: [ .inner ], number: 0, type2: [ .number], left: "(", right: ")", result: "\\left( 2\\right) "),
            // commands
            TestRecord2(build: "\\left\\{ 2 \\right\\}", type1: [ .inner ], number: 0, type2: [ .number], left: "{", right: "}", result: "\\left\\{ 2\\right\\} "),
            // complex commands
            TestRecord2(build: "\\left\\langle x \\right\\rangle", type1: [ .inner ], number: 0, type2: [ .variable], left: "\u{2329}", right: "\u{232A}", result: "\\left< x\\right> "),
            // bars
            TestRecord2(build: "\\left| x \\right\\|", type1: [ .inner ], number: 0, type2: [ .variable], left: "|", right: "\u{2016}", result: "\\left| x\\right\\| "),
            // inner in between
            TestRecord2(build: "5 + \\left( 2 \\right) - 2", type1: [ .number, .binaryOperator, .inner, .binaryOperator, .number ], number: 2, type2: [ .number], left: "(", right: ")", result: "5+\\left( 2\\right) -2"),
            // long inner
            TestRecord2(build: "\\left( 2 + \\frac12\\right)", type1: [ .inner ], number: 0, type2: [ .number, .binaryOperator, .fraction], left: "(", right: ")", result: "\\left( 2+\\frac{1}{2}\\right) "),
            // nested
            TestRecord2(build: "\\left[ 2 + \\left|\\frac{-x}{2}\\right| \\right]", type1: [ .inner ], number: 0, type2: [ .number, .binaryOperator, .inner], left: "[", right: "]", result: "\\left[ 2+\\left| \\frac{-x}{2}\\right| \\right] "),
            // With scripts
            TestRecord2(build: "\\left( 2 \\right)^2", type1: [ .inner ], number: 0, type2: [ .number], left: "(", right: ")", result: "\\left( 2\\right) ^{2}"),
            // Scripts on left
            TestRecord2(build: "\\left(^2 \\right )", type1: [ .inner], number: 0, type2: [ .ordinary], left: "(", right: ")", result: "\\left( {}^{2}\\right) "),
            // Dot
            TestRecord2(build: "\\left( 2 \\right.", type1: [ .inner], number: 0, type2: [ .number], left: "(", right: "", result: "\\left( 2\\right. ")
        ]
    }

    func testSuperScript() throws {
        let data = getTestDataSuperScript()
        for testCase in data {
            let str = testCase.build
            var error:NSError?
            let list = MTMathListBuilder.build(fromString: str, error:&error)
            XCTAssertNil(error)
            let desc = "Error for string:\(str)"
            let atomTypes = testCase.atomType
            checkAtomTypes(list, types:atomTypes, desc:desc)
            
            // get the first atom
            let first = list!.atoms[0]
            // check it's superscript
            let types = testCase.types
            if types.count > 0 {
                XCTAssertNotNil(first.superScript, desc)
            }
            let superlist = first.superScript
            checkAtomTypes(superlist, types:types, desc:desc)
            
            if !testCase.extra.isEmpty {
                // one more level
                let superFirst = superlist!.atoms[0]
                let supersuperList = superFirst.superScript
                checkAtomTypes(supersuperList, types:testCase.extra, desc:desc)
            }
            
            // convert it back to latex
            let latex = MTMathListBuilder.mathListToString(list)
            XCTAssertEqual(latex, testCase.result, desc)
        }
    }
    
    func testSubScript() throws {
        let data = getTestDataSubScript()
        for testCase in data {
            let str = testCase.build
            var error:NSError?
            let list = MTMathListBuilder.build(fromString: str, error:&error)
            XCTAssertNil(error)
            let desc = "Error for string:\(str)"
            let atomTypes = testCase.atomType
            checkAtomTypes(list, types:atomTypes, desc:desc)
            
            // get the first atom
            let first = list!.atoms[0]
            // check it's superscript
            let types = testCase.types
            if (types.count > 0) {
                XCTAssertNotNil(first.subScript, desc);
            }
            let sublist = first.subScript
            checkAtomTypes(sublist, types:types, desc:desc)
            
            if !testCase.extra.isEmpty {
                // one more level
                let subFirst = sublist!.atoms[0]
                let subsubList = subFirst.subScript
                checkAtomTypes(subsubList, types:testCase.extra, desc:desc)
            }
            
            // convert it back to latex
            let latex = MTMathListBuilder.mathListToString(list)
            XCTAssertEqual(latex, testCase.result, desc)
        }
    }
    
    func testSuperSubScript() throws {
        let data = getTestDataSuperSubScript()
        for testCase in data {
            let str = testCase.build
            var error:NSError?
            let list = MTMathListBuilder.build(fromString: str, error:&error)
            XCTAssertNil(error)
            let desc = "Error for string:\(str)"
            let atomTypes = testCase.atomType
            checkAtomTypes(list, types:atomTypes, desc:desc)
            
            // get the first atom
            let first = list!.atoms[0]
            // check its subscript
            let sub = testCase.types
            if sub.count > 0 {
                XCTAssertNotNil(first.subScript, desc)
                let sublist = first.subScript
                checkAtomTypes(sublist, types: sub, desc: desc)
            }
            let sup = testCase.extra
            if sup.count > 0 {
                XCTAssertNotNil(first.superScript, desc)
                let sublist = first.superScript
                checkAtomTypes(sublist, types: sup, desc: desc)
            }

            // convert it back to latex
            let latex = MTMathListBuilder.mathListToString(list)
            XCTAssertEqual(latex, testCase.result, desc)
        }
    }
    
    func testSymbols() throws {
        let str = "5\\times3^{2\\div2}";
        let list = MTMathListBuilder.build(fromString: str)!
        let desc = "Error for string:\(str)"
        
        XCTAssertNotNil(list, desc)
        XCTAssertEqual((list.atoms.count), 3, desc)
        var atom = list.atoms[0];
        XCTAssertEqual(atom.type, .number, desc)
        XCTAssertEqual(atom.nucleus, "5", desc)
        atom = list.atoms[1];
        XCTAssertEqual(atom.type, .binaryOperator, desc)
        XCTAssertEqual(atom.nucleus, "\u{00D7}", desc)
        atom = list.atoms[2];
        XCTAssertEqual(atom.type, .number, desc)
        XCTAssertEqual(atom.nucleus, "3", desc)
        
        // super script
        let superList = atom.superScript!
        XCTAssertNotNil(superList, desc)
        XCTAssertEqual((superList.atoms.count), 3, desc)
        atom = superList.atoms[0];
        XCTAssertEqual(atom.type, .number, desc)
        XCTAssertEqual(atom.nucleus, "2", desc)
        atom = superList.atoms[1];
        XCTAssertEqual(atom.type, .binaryOperator, desc)
        XCTAssertEqual(atom.nucleus, "\u{00F7}", desc)
        atom = superList.atoms[2];
        XCTAssertEqual(atom.type, .number, desc)
        XCTAssertEqual(atom.nucleus, "2", desc)
    }

    func testFrac() throws {
        let str = "\\frac1c";
        let list = MTMathListBuilder.build(fromString: str)!
        let desc = "Error for string:\(str)"
        
        XCTAssertNotNil(list, desc)
        XCTAssertEqual((list.atoms.count), 1, desc)
        let frac = list.atoms[0] as! MTFraction
        XCTAssertEqual(frac.type, .fraction, desc)
        XCTAssertEqual(frac.nucleus, "", desc)
        XCTAssertTrue(frac.hasRule);
        XCTAssertNil(frac.rightDelimiter);
        XCTAssertNil(frac.leftDelimiter);
        
        var subList = frac.numerator!
        XCTAssertNotNil(subList, desc)
        XCTAssertEqual((subList.atoms.count), 1, desc)
        var atom = subList.atoms[0];
        XCTAssertEqual(atom.type, .number, desc)
        XCTAssertEqual(atom.nucleus, "1", desc)
        
        atom = list.atoms[0];
        subList = frac.denominator!
        XCTAssertNotNil(subList, desc)
        XCTAssertEqual((subList.atoms.count), 1, desc)
        atom = subList.atoms[0];
        XCTAssertEqual(atom.type, .variable, desc)
        XCTAssertEqual(atom.nucleus, "c", desc)
        
        // convert it back to latex
        let latex = MTMathListBuilder.mathListToString(list)
        XCTAssertEqual(latex, "\\frac{1}{c}", desc)
    }

    func testFracInFrac() throws {
        let str = "\\frac1\\frac23";
        let list = MTMathListBuilder.build(fromString: str)!
        let desc = "Error for string:\(str)"
        
        XCTAssertNotNil(list, desc)
        XCTAssertEqual((list.atoms.count), 1, desc)
        var frac = list.atoms[0] as! MTFraction
        XCTAssertEqual(frac.type,  .fraction, desc)
        XCTAssertEqual(frac.nucleus, "", desc)
        XCTAssertTrue(frac.hasRule);
        
        var subList = frac.numerator!
        XCTAssertNotNil(subList, desc)
        XCTAssertEqual((subList.atoms.count), 1, desc)
        var atom = subList.atoms[0];
        XCTAssertEqual(atom.type, .number, desc)
        XCTAssertEqual(atom.nucleus, "1", desc)
        
        subList = frac.denominator!
        XCTAssertNotNil(subList, desc)
        XCTAssertEqual((subList.atoms.count), 1, desc)
        frac = subList.atoms[0] as! MTFraction
        XCTAssertEqual(frac.type,  .fraction, desc)
        XCTAssertEqual(frac.nucleus, "", desc)
        
        subList = frac.numerator!
        XCTAssertNotNil(subList, desc)
        XCTAssertEqual((subList.atoms.count), 1, desc)
        atom = subList.atoms[0];
        XCTAssertEqual(atom.type, .number, desc)
        XCTAssertEqual(atom.nucleus, "2", desc)
        
        subList = frac.denominator!
        XCTAssertNotNil(subList, desc)
        XCTAssertEqual((subList.atoms.count), 1, desc)
        atom = subList.atoms[0];
        XCTAssertEqual(atom.type, .number, desc)
        XCTAssertEqual(atom.nucleus, "3", desc)
        
        // convert it back to latex
        let latex = MTMathListBuilder.mathListToString(list)
        XCTAssertEqual(latex, "\\frac{1}{\\frac{2}{3}}", desc)
    }

    func testSqrt() throws {
        let str = "\\sqrt2";
        let list = MTMathListBuilder.build(fromString: str)!
        let desc = "Error for string:\(str)"

        XCTAssertNotNil(list, desc)
        XCTAssertEqual((list.atoms.count), 1, desc)
        let rad = list.atoms[0] as! MTRadical
        XCTAssertEqual(rad.type, .radical, desc)
        XCTAssertEqual(rad.nucleus, "", desc)

        let subList = rad.radicand!
        XCTAssertNotNil(subList, desc)
        XCTAssertEqual((subList.atoms.count), 1, desc)
        let atom = subList.atoms[0]
        XCTAssertEqual(atom.type, .number, desc)
        XCTAssertEqual(atom.nucleus, "2", desc)

        // convert it back to latex
        let latex = MTMathListBuilder.mathListToString(list)
        XCTAssertEqual(latex, "\\sqrt{2}", desc)
    }

    func testSqrtInSqrt() throws {
        let str = "\\sqrt\\sqrt2";
        let list = MTMathListBuilder.build(fromString: str)!
        let desc = "Error for string:\(str)"

        XCTAssertNotNil(list, desc)
        XCTAssertEqual((list.atoms.count), 1, desc)
        var rad = list.atoms[0] as! MTRadical
        XCTAssertEqual(rad.type, .radical, desc)
        XCTAssertEqual(rad.nucleus, "", desc)

        var subList = rad.radicand!
        XCTAssertNotNil(subList, desc)
        XCTAssertEqual((subList.atoms.count), 1, desc)
        rad = subList.atoms[0] as! MTRadical
        XCTAssertEqual(rad.type, .radical, desc)
        XCTAssertEqual(rad.nucleus, "", desc)


        subList = rad.radicand!
        XCTAssertNotNil(subList, desc)
        XCTAssertEqual((subList.atoms.count), 1, desc)
        let atom = subList.atoms[0];
        XCTAssertEqual(atom.type, .number, desc)
        XCTAssertEqual(atom.nucleus, "2", desc)

        // convert it back to latex
        let latex = MTMathListBuilder.mathListToString(list)
        XCTAssertEqual(latex, "\\sqrt{\\sqrt{2}}", desc)
    }

    func testRad() throws {
        let str = "\\sqrt[3]2";
        let list = MTMathListBuilder.build(fromString: str)!

        XCTAssertNotNil(list);
        XCTAssertEqual((list.atoms.count), 1);
        let rad = list.atoms[0] as! MTRadical
        XCTAssertEqual(rad.type, .radical);
        XCTAssertEqual(rad.nucleus, "");

        var subList = rad.radicand!
        XCTAssertNotNil(subList);
        XCTAssertEqual((subList.atoms.count), 1);
        var atom = subList.atoms[0];
        XCTAssertEqual(atom.type, .number);
        XCTAssertEqual(atom.nucleus, "2");

        subList = rad.degree!
        XCTAssertNotNil(subList);
        XCTAssertEqual((subList.atoms.count), 1);
        atom = subList.atoms[0];
        XCTAssertEqual(atom.type, .number);
        XCTAssertEqual(atom.nucleus, "3");

        // convert it back to latex
        let latex = MTMathListBuilder.mathListToString(list)
        XCTAssertEqual(latex, "\\sqrt[3]{2}");
    }
    
    func testLeftRight() throws {
        let data = getTestDataLeftRight()
        for testCase in data {
            let str = testCase.build
            
            var error:NSError?
            let list = MTMathListBuilder.build(fromString: str, error: &error)!
            
            XCTAssertNotNil(list, str);
            XCTAssertNil(error, str);
            
            checkAtomTypes(list, types:testCase.type1, desc:"\(str) outer")

            let innerLoc = testCase.number
            let inner = list.atoms[innerLoc] as! MTInner
            XCTAssertEqual(inner.type, .inner, str);
            XCTAssertEqual(inner.nucleus, "", str);
        
            let innerList = inner.innerList!
            XCTAssertNotNil(innerList, str);
            checkAtomTypes(innerList, types:testCase.type2, desc:"\(str) inner")
            
            XCTAssertNotNil(inner.leftBoundary, str);
            XCTAssertEqual(inner.leftBoundary!.type, .boundary, str);
            XCTAssertEqual(inner.leftBoundary!.nucleus, testCase.left, str);
            
            XCTAssertNotNil(inner.rightBoundary, str);
            XCTAssertEqual(inner.rightBoundary!.type, .boundary, str);
            XCTAssertEqual(inner.rightBoundary!.nucleus, testCase.right, str);
            
            // convert it back to latex
            let latex = MTMathListBuilder.mathListToString(list)
            XCTAssertEqual(latex, testCase.result, str);
        }
    }


//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

