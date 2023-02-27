
//
//  Created by Mike Griebling on 2022-12-31.
//  Translated from an Objective-C implementation by Kostub Deshmukh.
//
//  This software may be modified and distributed under the terms of the
//  MIT license. See the LICENSE file for details.
//

import Foundation

public class MTFontManager {
    
    static public private(set) var manager:MTFontManager! = nil
    
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
    
    public func kpMathLightFont(withSize size:CGFloat) -> MTFont? {
        MTFontManager.fontManager.font(withName: "KpMath-Light", size: size)
    }
    
    public func kpMathSansFont(withSize size:CGFloat) -> MTFont? {
        MTFontManager.fontManager.font(withName: "KpMath-Sans", size: size)
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
