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
    internal func rawMathTable() -> NSDictionary {
        BundleManager.manager.obtainRawMathTable(font: self)
    }
    
    //Note: Below code are no longer supported, unable to tell if UIFont/NSFont is threadsafe, not used in SwiftMath.
    // #if os(iOS)
    // public func uiFont(withSize size: CGFloat) -> UIFont? {
    //     UIFont(name: fontName, size: size)
    // }
    // #endif
    // #if os(macOS)
    // public func nsFont(withSize size: CGFloat) -> NSFont? {
    //     NSFont(name: fontName, size: size)
    // }
    // #endif
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
    //Note: below should be lightweight and without threadsafe problem.
    static internal let manager = BundleManager()

    private var cgFonts = [MathFont: CGFont]()
    private var ctFonts = [CTFontSizePair: CTFont]()
    private var rawMathTables = [MathFont: NSDictionary]()

    private let threadSafeQueue = DispatchQueue(label: "com.smartmath.mathfont.threadsafequeue", attributes: .concurrent)

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
        
        /// This does not load the complete math font, it only has about half the glyphs of the full math font.
        /// In particular it does not have the math italic characters which breaks our variable rendering.
        /// So we first load a CGFont from the file and then convert it to a CTFont.
        var errorRef: Unmanaged<CFError>? = nil
        guard CTFontManagerRegisterGraphicsFont(defaultCGFont, &errorRef) else {
            throw FontError.registerFailed
        }
        let postsript  = (defaultCGFont.postScriptName as? String) ?? ""
        let cgfontName = (defaultCGFont.fullName as? String) ?? ""
        let threadName = Thread.isMainThread ? "main" : "global"
        debugPrint("mathFonts bundle resource: \(mathFont.rawValue), font: \(cgfontName), ps: \(postsript) registered on \(threadName).")
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
        
        rawMathTables[mathFont] = rawMathTable
        
        let threadName = Thread.isMainThread ? "main" : "global"
        debugPrint("mathFonts bundle resource: \(mathFont.rawValue).plist registered on \(threadName).")
    }
    
    private func onDemandRegistration(mathFont: MathFont) {
        guard threadSafeQueue.sync(execute: { cgFonts[mathFont] }) == nil else { return }
        // Note: resourceLoading is now serialized.
        threadSafeQueue.sync(flags: .barrier, execute: { [weak self] in
            if self?.cgFonts[mathFont] == nil {
                do {
                    try BundleManager.manager.registerCGFont(mathFont: mathFont)
                    try BundleManager.manager.registerMathTable(mathFont: mathFont)

                } catch {
                    fatalError("MTMathFonts:\(#function) ondemand loading failed, mathFont \(mathFont.rawValue), reason \(error)")
                }
            }
        })
    }
    fileprivate func obtainCGFont(font: MathFont) -> CGFont {
        onDemandRegistration(mathFont: font)
        guard let cgFont = threadSafeQueue.sync(execute: { cgFonts[font] }) else {
            fatalError("\(#function) unable to locate CGFont \(font.fontName)")
        }
        return cgFont
    }
    
    fileprivate func obtainCTFont(font: MathFont, withSize size: CGFloat) -> CTFont {
        onDemandRegistration(mathFont: font)
        let fontSizePair = CTFontSizePair(font: font, size: size)
        let ctFont = threadSafeQueue.sync(execute: { ctFonts[fontSizePair] })
        guard ctFont == nil else { return ctFont! }
        guard let cgFont = threadSafeQueue.sync(execute: { cgFonts[font] }) else {
            fatalError("\(#function) unable to locate CGFont \(font.fontName) to create CTFont")
        }
        //Note: ctfont creation and caching is now threadsafe.
        guard threadSafeQueue.sync(execute: { ctFonts[fontSizePair] }) == nil else { return ctFonts[fontSizePair]! }
        return threadSafeQueue.sync(flags: .barrier, execute: {
            if let ctfont = ctFonts[fontSizePair] {
                return ctfont
            } else {
                let result = CTFontCreateWithGraphicsFont(cgFont, size, nil, nil)
                ctFonts[fontSizePair] = result
                return result
            }
        })
    }
    fileprivate func obtainRawMathTable(font: MathFont) -> NSDictionary {
        onDemandRegistration(mathFont: font)
        guard let mathTable = threadSafeQueue.sync(execute: { rawMathTables[font] } ) else {
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
    
    private struct CTFontSizePair: Hashable {
        let font: MathFont
        let size: CGFloat
    }
}
