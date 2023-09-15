//
//  MTFontV2Tests.swift
//  
//
//  Created by Peter Tang on 15/9/2023.
//

import XCTest
@testable import SwiftMath

final class MTFontV2Tests: XCTestCase {
    func testMTFontV2Script() throws {
        let size = CGFloat(Int.random(in: 20 ... 40))
        MathFont.allCases.forEach {
            let mtfont = $0.mtfont(size: size)
            let mTable = mtfont.mathTable?._mathTable
            XCTAssertNotNil(mtfont)
            XCTAssertNotNil(mTable)
        }
    }
}
