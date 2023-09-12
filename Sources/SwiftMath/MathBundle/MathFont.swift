//
//  File.swift
//  
//
//  Created by Peter Tang on 10/9/2023.
//

import Foundation
import CoreText

public enum MathFont: String, CaseIterable {
    
    case latinModernFont = "latinmodern-math"
    case kpMathLightFont = "KpMath-Light"
    case kpMathSansFont  = "KpMath-Sans"
    case xitsFont        = "xits-math"
    case termesFont      = "texgyretermes-math"
    
    public func cgFont() -> CGFont? {
        BundleManager.manager.obtainCGFont(font: self)
    }
    public func ctFont(withSize size: CGFloat) -> CTFont? {
        BundleManager.manager.obtainCTFont(font: self, withSize: size)
    }
    internal func mathTable() -> NSDictionary? {
        BundleManager.manager.obtainMathTable(font: self)
    }
    internal func get(nameForGlyph glyph: CGGlyph) -> String {
        let name = cgFont()?.name(for: glyph) as? String
        return name ?? ""
    }
    internal func get(glyphWithName name: String) -> CGGlyph? {
        cgFont()?.getGlyphWithGlyphName(name: name as CFString)
    }
}
internal extension CTFont {
    /** The size of this font in points. */
    var fontSize: CGFloat {
        CTFontGetSize(self)
    }
    var unitsPerEm: UInt {
        return UInt(CTFontGetUnitsPerEm(self))
    }
}
private class BundleManager {
    static fileprivate(set) var manager: BundleManager = {
        return BundleManager()
    }()

    private var cgFonts = [MathFont: CGFont]()
    private var ctFonts = [CTFontPair: CTFont]()
    private var mathTables = [MathFont: NSDictionary]()

    private var initializedOnceAlready: Bool = false
    
    private func registerCGFont(mathFont: MathFont) throws {
        guard let frameworkBundleURL = Bundle.module.url(forResource: "mathFonts", withExtension: "bundle"),
              let resourceBundleURL = Bundle(url: frameworkBundleURL)?.path(forResource: mathFont.rawValue, ofType: "otf") else {
            throw FontError.fontPathNotFound
        }
        guard let fontData = NSData(contentsOfFile: resourceBundleURL), let dataProvider = CGDataProvider(data: fontData) else {
            throw FontError.invalidFontFile
        }
        guard let defaultCGFont = CGFont(dataProvider) else {
            throw FontError.initFontError
        }
        
        cgFonts[mathFont] = defaultCGFont
        
        var errorRef: Unmanaged<CFError>? = nil
        guard CTFontManagerRegisterGraphicsFont(defaultCGFont, &errorRef) else {
            throw FontError.registerFailed
        }
        print("mathFonts bundle: \(mathFont.rawValue) registered.")
    }
    
    private func registerMathTable(mathFont: MathFont) throws {
        guard let frameworkBundleURL = Bundle.module.url(forResource: "mathFonts", withExtension: "bundle"),
              let mathTablePlist = Bundle(url: frameworkBundleURL)?.url(forResource: mathFont.rawValue, withExtension:"plist") else {
            throw FontError.fontPathNotFound
        }
        guard let rawMathTable = NSDictionary(contentsOf: mathTablePlist),
                let version = rawMathTable["version"] as? String,
                version == "1.3" else {
            throw FontError.invalidMathTable
        }
        //FIXME: mathTable = MTFontMathTable(withFont:self, mathTable:rawMathTable)
        mathTables[mathFont] = rawMathTable
    }
    
    private func registerAllBundleResources() {
        guard !initializedOnceAlready else { return }
        MathFont.allCases.forEach { font in
            do {
                try BundleManager.manager.registerCGFont(mathFont: font)
                try BundleManager.manager.registerMathTable(mathFont: font)
            } catch {
                fatalError("MTMathFonts:\(#function) Couldn't load math fonts \(font.rawValue), reason \(error)")
            }
        }
        initializedOnceAlready.toggle()
    }
    
    fileprivate func obtainCGFont(font: MathFont) -> CGFont? {
        if !initializedOnceAlready { registerAllBundleResources() }
        return cgFonts[font]
    }
    
    fileprivate func obtainCTFont(font: MathFont, withSize size: CGFloat) -> CTFont? {
        if !initializedOnceAlready { registerAllBundleResources() }
        let fontPair = CTFontPair(font: font, size: size)
        guard let ctFont = ctFonts[fontPair] else {
            if let cgFont = cgFonts[font] {
                let ctFont = CTFontCreateWithGraphicsFont(cgFont, size, nil, nil)
                ctFonts[fontPair] = ctFont
                return ctFont
            }
            return nil
        }
        return ctFont
    }
    fileprivate func obtainMathTable(font: MathFont) -> NSDictionary? {
        if !initializedOnceAlready { registerAllBundleResources() }
        return mathTables[font]
    }
    deinit {
        ctFonts.removeAll()
        var errorRef: Unmanaged<CFError>? = nil
        cgFonts.values.forEach { cgFont in
            CTFontManagerUnregisterGraphicsFont(cgFont, &errorRef)
        }
        cgFonts.removeAll()
    }
    public enum FontError: Error {
        case invalidFontFile
        case fontPathNotFound
        case initFontError
        case registerFailed
        case invalidMathTable
    }
    
    private struct CTFontPair: Hashable {
        let font: MathFont
        let size: CGFloat
    }
}
