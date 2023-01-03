//
//  MTColor.swift
//  MathRenderSwift
//
//  Created by Mike Griebling on 2022-12-31.
//

import Foundation

extension MTColor {
    
    static func color(fromHexString hexString:String) -> MTColor? {
        if hexString.isEmpty { return nil }
        if !hexString.hasPrefix("#") { return nil }
        
        var rgbValue = UInt64(0)
        let scanner = Scanner(string: hexString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt64(&rgbValue)
        return MTColor(red: CGFloat((rgbValue & 0xFF0000))/255.0,
                       green: CGFloat((rgbValue & 0xFF00))/255.0,
                       blue: CGFloat((rgbValue & 0xFF))/255.0, alpha: 1.0)
    }
    
}
