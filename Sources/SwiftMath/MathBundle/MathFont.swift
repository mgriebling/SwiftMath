//
//  MathFont.swift
//  
//
//  Created by Peter Tang on 10/9/2023.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public enum MathFont: String, CaseIterable {
    
    case latinModernFont = "latinmodern-math"
    case kpMathLightFont = "KpMath-Light"
    case kpMathSansFont  = "KpMath-Sans"
    case xitsFont        = "xits-math"
    case termesFont      = "texgyretermes-math"
    
    var fontFamilyName: String {
        switch self {
        case .latinModernFont: return "Latin Modern Math"
        case .kpMathLightFont: return "KpMath"
        case .kpMathSansFont:  return "KpMath"
        case .xitsFont:        return "XITS Math"
        case .termesFont:      return "TeX Gyre Termes Math"
        }
    }
    var fontName: String {
        switch self {
        case .latinModernFont: return "LatinModernMath-Regular"
        case .kpMathLightFont: return "KpMath-Light"
        case .kpMathSansFont:  return "KpMath-Sans"
        case .xitsFont:        return "XITSMath"
        case .termesFont:      return "TeXGyreTermesMath-Regular"
        }
    }
    public func cgFont() -> CGFont {
        BundleManager.manager.obtainCGFont(font: self)
    }
    public func ctFont(withSize size: CGFloat) -> CTFont {
        BundleManager.manager.obtainCTFont(font: self, withSize: size)
    }
    #if os(iOS)
    public func uiFont(withSize size: CGFloat) -> UIFont? {
        UIFont(name: fontName, size: size)
    }
    #endif
    #if os(macOS)
    public func nsFont(withSize size: CGFloat) -> NSFont? {
        NSFont(name: fontName, size: size)
    }
    #endif
    internal func mathTable() -> NSDictionary {
        BundleManager.manager.obtainMathTable(font: self)
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
        debugPrint("mathFonts bundle resource: \(mathFont.rawValue), font: \(defaultCGFont.fullName!) registered.")
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
        mathTables[mathFont] = rawMathTable
        debugPrint("mathFonts bundle resource: \(mathFont.rawValue).plist registered.")
    }
    
    private func registerAllBundleResources() {
        guard !initializedOnceAlready else { return }
        MathFont.allCases.forEach { font in
            do {
                try BundleManager.manager.registerCGFont(mathFont: font)
                try BundleManager.manager.registerMathTable(mathFont: font)
            } catch {
                fatalError("MTMathFonts:\(#function) Couldn't load mathFont resource \(font.rawValue), reason \(error)")
            }
        }
        initializedOnceAlready.toggle()
    }
    
    private func onDemandRegistration(mathFont: MathFont) {
        guard cgFonts[mathFont] == nil else { return }
        do {
            try BundleManager.manager.registerCGFont(mathFont: mathFont)
            try BundleManager.manager.registerMathTable(mathFont: mathFont)

        } catch {
            fatalError("MTMathFonts:\(#function) ondemand loading failed, mathFont \(mathFont.rawValue), reason \(error)")
        }
    }
    fileprivate func obtainCGFont(font: MathFont) -> CGFont {
        // if !initializedOnceAlready { registerAllBundleResources() }
        onDemandRegistration(mathFont: font)
        guard let cgFont = cgFonts[font] else {
            fatalError("\(#function) unable to locate CGFont \(font.fontName)")
        }
        return cgFont
    }
    
    fileprivate func obtainCTFont(font: MathFont, withSize size: CGFloat) -> CTFont {
        // if !initializedOnceAlready { registerAllBundleResources() }
        onDemandRegistration(mathFont: font)
        let fontPair = CTFontPair(font: font, size: size)
        guard let ctFont = ctFonts[fontPair] else {
            if let cgFont = cgFonts[font] {
                let ctFont = CTFontCreateWithGraphicsFont(cgFont, size, nil, nil)
                ctFonts[fontPair] = ctFont
                return ctFont
            }
            fatalError("\(#function) unable to locate CGFont \(font.fontName), nor create CTFont")
        }
        return ctFont
    }
    fileprivate func obtainMathTable(font: MathFont) -> NSDictionary {
        // if !initializedOnceAlready { registerAllBundleResources() }
        onDemandRegistration(mathFont: font)
        guard let mathTable = mathTables[font] else {
            fatalError("\(#function) unable to locate mathTable: \(font.rawValue).plist")
        }
        return mathTable
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
