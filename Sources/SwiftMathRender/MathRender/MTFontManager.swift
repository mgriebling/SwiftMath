//
//  MTFontManager.swift
//  MathRenderSwift
//
//  Created by Mike Griebling on 2022-12-31.
//

import Foundation

public class MTFontManager {
    
    static var manager:MTFontManager? = nil
    let kDefaultFontSize = CGFloat(20)
    
    static var fontManager : MTFontManager {
        if manager == nil {
            manager = MTFontManager()
        }
        return manager!
    }
    
    var nameToFontMap = [String: MTFont]()
    
    public func font(withName name:String, size:CGFloat) -> MTFont? {
        var f = self.nameToFontMap[name]
        if f == nil {
            f = MTFont(fontWithName: name, size: size)
            self.nameToFontMap[name] = f
        }
        
        if f!.fontSize == size { return f }
        else { return f!.copy(withSize: size) }
    }
    
    public func latinModernFont(withSize size:CGFloat) -> MTFont? {
        MTFontManager.fontManager.font(withName: "latinmodern-math", size: size)
    }
    
    public func xitsFont(withSize size:CGFloat) -> MTFont? {
        MTFontManager.fontManager.font(withName: "xits-math", size: size)
    }
    
    public func termesFont(withSize size:CGFloat) -> MTFont? {
        MTFontManager.fontManager.font(withName: "texgyretermes-math", size: size)
    }
    
    public var defaultFont: MTFont? {
        MTFontManager.fontManager.latinModernFont(withSize: kDefaultFontSize)
    }


}
