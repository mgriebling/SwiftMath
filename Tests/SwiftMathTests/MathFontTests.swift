import XCTest
@testable import SwiftMath

//
//  MathFontTests.swift
//  
//
//  Created by Peter Tang on 12/9/2023.
//

final class MathFontTests: XCTestCase {
    func testMathFontScript() throws {
        // for family in UIFont.familyNames.sorted() {
        //     let names = UIFont.fontNames(forFamilyName: family)
        //     print("Family: \(family) Font names: \(names)")
        // }
        let size = Int.random(in: 20 ... 40)
        MathFont.allCases.forEach {
            // print("\(#function) cgfont \($0.cgFont())")
            // print("\(#function) ctfont \($0.ctFont(withSize: CGFloat(size)))")
            XCTAssertNotNil($0.cgFont())
            XCTAssertNotNil($0.ctFont(withSize: CGFloat(size)))
            XCTAssertEqual($0.ctFont(withSize: CGFloat(size))?.fontSize, CGFloat(size), "ctFont fontSize test")
        }
    }
}
