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
        let size = Int.random(in: 20 ... 40)
        MathFont.allCases.forEach {
            // print("\(#function) cgfont \($0.cgFont())")
            // print("\(#function) ctfont \($0.ctFont(withSize: CGFloat(size)))")
            XCTAssertNotNil($0.cgFont())
            XCTAssertNotNil($0.ctFont(withSize: CGFloat(size)))
            XCTAssertEqual($0.ctFont(withSize: CGFloat(size)).fontSize, CGFloat(size), "ctFont fontSize != size.")
            XCTAssertEqual($0.cgFont().postScriptName as? String, $0.postScriptName, "cgFont.postScriptName != postScriptName")
            // XCTAssertEqual($0.uiFont(withSize: CGFloat(size))?.familyName, $0.fontFamilyName, "uifont familyName != familyName.")
            XCTAssertEqual(CTFontCopyFamilyName($0.ctFont(withSize: CGFloat(size))) as String, $0.fontFamilyName, "ctfont.family != familyName")
        }
        #if os(iOS) || os(visionOS)
        // for family in UIFont.familyNames.sorted() {
        //     let names = UIFont.fontNames(forFamilyName: family)
        //     print("Family: \(family) Font names: \(names)")
        // }
        fontNames.forEach { name in
            XCTAssertNotNil(UIFont(name: name, size: CGFloat(size)))
        }
        fontFamilyNames.forEach { name in
            XCTAssertNotNil(UIFont.fontNames(forFamilyName: name))
        }
        #endif
        #if os(macOS)
        fontNames.forEach { name in
            let font = NSFont(name: name, size: CGFloat(size))
            XCTAssertNotNil(font)
        }
        #endif
    }
    func testOnDemandMathFontScript() throws {
        let size = Int.random(in: 20 ... 40)
        let mathFont = MathFont.allCases.randomElement()!
        XCTAssertNotNil(mathFont.cgFont())
        XCTAssertNotNil(mathFont.ctFont(withSize: CGFloat(size)))
        XCTAssertEqual(mathFont.ctFont(withSize: CGFloat(size)).fontSize, CGFloat(size), "ctFont fontSize test")
    }
    var fontNames: [String] {
        MathFont.allCases.map { $0.postScriptName }
    }
    var fontFamilyNames: [String] {
        MathFont.allCases.map { $0.fontFamilyName }
    }
    
    private let executionQueue = DispatchQueue(label: "com.swiftmath.mathbundle", attributes: .concurrent)
    private let executionGroup = DispatchGroup()
    
    let totalCases = 5000
    var testCount = 0
    func testConcurrentThreadsafeScript() throws {
        var mathFont: MathFont { .allCases.randomElement()! }
        for caseNumber in 0 ..< totalCases {
            switch caseNumber % 3 {
            case 0:
                helperConcurrentCGFont(caseNumber, mathFont: mathFont, in: executionGroup, on: executionQueue)
            case 1:
                helperConcurrentCTFont(caseNumber, mathFont: mathFont, in: executionGroup, on: executionQueue)
            case 2:
                helperConcurrentMathTable(caseNumber, mathFont: mathFont, in: executionGroup, on: executionQueue)
            default:
                continue
            }
        }
        executionGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            XCTAssertEqual(self.testCount, totalCases)
            print("\(self.testCount) completed =================")
        }
        executionGroup.wait()
    }
    // func helperConcurrentOnDemandRegistration(_ count: Int, mathFont: MathFont, in group: DispatchGroup, on queue: DispatchQueue) {
    //     let workitem = DispatchWorkItem {
    //         BundleManager.manager.onDemandRegistration(mathFont: mathFont)
    //     }
    //     workitem.notify(queue: .main) { [weak self] in
    //         self?.testCount += 1
    //     }
    //     queue.async(group: group, execute: workitem)
    // }
    // func helperConcurrentBundleRegistration(mathFont: MathFont, in group: DispatchGroup, on queue: DispatchQueue) {
    //     let workitem = DispatchWorkItem {
    //         // BundleManager.manager.onDemandRegistration(mathFont: mathFont)
    //         try? BundleManager.manager.registerCGFont(mathFont: mathFont)
    //         try? BundleManager.manager.registerMathTable(mathFont: mathFont)
    //         let font = BundleManager.manager.cgFonts[mathFont]
    //         XCTAssertNotNil(font, "font != nil")
    //     }
    //     workitem.notify(queue: .main) { [weak self] in
    //         // print("\(Thread.isMainThread ? "main" : "global") completed .....")
    //         let font = mathFont.cgFont()
    //         XCTAssertNotNil(font, "font != nil")
    //         self?.testCount += 1
    //     }
    //     queue.async(group: group, execute: workitem)
    // }
    func helperConcurrentCGFont(_ count: Int, mathFont: MathFont, in group: DispatchGroup, on queue: DispatchQueue) {
        let workitem = DispatchWorkItem {
            let font = mathFont.cgFont()
            XCTAssertNotNil(font, "font != nil")
        }
        workitem.notify(queue: .main) { [weak self] in
            // print("\(Thread.isMainThread ? "main" : "global") completed .....")
            let font = mathFont.cgFont()
            XCTAssertNotNil(font, "font != nil")
            self?.testCount += 1
        }
        queue.async(group: group, execute: workitem)
    }
    func helperConcurrentCTFont(_ count: Int, mathFont: MathFont, in group: DispatchGroup, on queue: DispatchQueue) {
        let size = CGFloat.random(in: 20 ... 40)
        let workitem = DispatchWorkItem {
            let font = mathFont.ctFont(withSize: size)
            XCTAssertNotNil(font, "font != nil")
        }
        workitem.notify(queue: .main) { [weak self] in
            // print("\(Thread.isMainThread ? "main" : "global") completed .....")
            let font = mathFont.ctFont(withSize: size)
            XCTAssertNotNil(font, "font != nil")
            self?.testCount += 1
        }
        queue.async(group: group, execute: workitem)
    }
    func helperConcurrentMathTable(_ count: Int, mathFont: MathFont, in group: DispatchGroup, on queue: DispatchQueue) {
        let workitem = DispatchWorkItem {
            let mathtable = mathFont.rawMathTable()
            XCTAssertNotNil(mathtable, "mathTable != nil")
        }
        workitem.notify(queue: .main) { [weak self] in
            // print("\(Thread.isMainThread ? "main" : "global") completed .....")
            let mathtable = mathFont.rawMathTable()
            XCTAssertNotNil(mathtable, "mathTable != nil")
            self?.testCount += 1
        }
        queue.async(group: group, execute: workitem)
    }

    func testFallbackFont() throws {
        #if os(iOS) || os(visionOS)
        let systemFont = UIFont.systemFont(ofSize: 20)
        let systemCTFont = CTFontCreateWithName(systemFont.fontName as CFString, 20, nil)
        #elseif os(macOS)
        let systemFont = NSFont.systemFont(ofSize: 20)
        let systemCTFont = CTFontCreateWithName(systemFont.fontName as CFString, 20, nil)
        #endif

        // Create a math font with fallback
        guard let mathFont = MTFontManager().font(withName: MathFont.latinModernFont.rawValue, size: 20) else {
            XCTFail("Failed to create math font")
            return
        }
        mathFont.fallbackFont = systemCTFont

        // Build a math list with Chinese text
        var error: NSError?
        let mathList = MTMathListBuilder.build(fromString: "\\text{中文测试}", error: &error)

        XCTAssertNil(error, "Should parse Chinese text without error")
        XCTAssertNotNil(mathList, "Math list should be created")

        // \text{...} creates atoms for each character (4 Chinese characters = 4 atoms)
        XCTAssertEqual(mathList?.atoms.count, 4, "Should have 4 atoms for 4 Chinese characters")

        // Verify atoms have the correct font style (roman for text)
        for atom in mathList?.atoms ?? [] {
            XCTAssertEqual(atom.fontStyle, .roman, "Text atoms should have roman font style")
        }

        // Create a display to verify glyph rendering works with fallback
        let display = MTTypesetter.createLineForMathList(mathList!, font: mathFont, style: .text)

        XCTAssertNotNil(display, "Display should be created with fallback font")

        // Verify the display was actually created (would be nil if all glyphs failed)
        XCTAssertGreaterThan(display?.width ?? 0, 0, "Display should have non-zero width with fallback font")
    }
}
