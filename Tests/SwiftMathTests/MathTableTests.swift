import XCTest
@testable import SwiftMath

//
//  MathTableTests.swift
//
//
//  Created by Peter Tang on 12/9/2023.
//

final class MathTableTests: XCTestCase {
    func testMathFontScript() throws {
        let size = Int.random(in: 20 ... 40)
        MathFont.allCases.forEach {
            // print("\(#function) cgfont \($0.cgFont())")
            // print("\(#function) ctfont \($0.ctFont(withSize: CGFloat(size)))")
            // XCTAssertNotNil($0.cgFont())
            // XCTAssertNotNil($0.ctFont(withSize: CGFloat(size)))
            // XCTAssertEqual($0.ctFont(withSize: CGFloat(size))?.fontSize, CGFloat(size), "ctFont fontSize test")
            let ctFont = $0.ctFont(withSize: CGFloat(size))
            if let unitsPerEm = ctFont?.unitsPerEm {
                let mathTable = MathTable(withFont: $0, fontSize: CGFloat(size), unitsPerEm: unitsPerEm)
                
                let values = [
                mathTable.fractionNumeratorDisplayStyleShiftUp,
                mathTable.fractionNumeratorShiftUp,
                mathTable.fractionDenominatorDisplayStyleShiftDown,
                mathTable.fractionDenominatorShiftDown,
                mathTable.fractionNumeratorDisplayStyleGapMin,
                mathTable.fractionNumeratorGapMin,
                ]
                print("\(ctFont) -> \(values)")
            }
        }
    }
}
