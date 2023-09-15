//
//  MTFontMathTableV2Tests.swift
//  
//
//  Created by Peter Tang on 15/9/2023.
//

import XCTest
@testable import SwiftMath

final class MTFontMathTableV2Tests: XCTestCase {
    func testMTFontV2Script() throws {
        let size = CGFloat(Int.random(in: 20 ... 40))
        MathFont.allCases.forEach {
            let mTable = $0.mtfont(size: size).mathTable
            XCTAssertNotNil(mTable)
            let values = [
                mTable?.fractionNumeratorDisplayStyleShiftUp,
                mTable?.fractionNumeratorShiftUp,
                mTable?.fractionDenominatorDisplayStyleShiftDown,
                mTable?.fractionDenominatorShiftDown,
                mTable?.fractionNumeratorDisplayStyleGapMin,
                mTable?.fractionNumeratorGapMin,
            ].compactMap{$0}
            print("\($0.rawValue).plist: \(values)")
        }
    }
}
