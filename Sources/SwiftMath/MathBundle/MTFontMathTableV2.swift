//
//  MTFontMathTableV2.swift
//  
//
//  Created by Peter Tang on 15/9/2023.
//

import Foundation

// extension MathTable {
//     public func fontMathTableV2() -> MTFontMathTableV2 {
//         MTFontMathTableV2(mathFont: font, size: fontSize)
//     }
// }
internal class MTFontMathTableV2: MTFontMathTable {
    private let mathFont: MathFont
    private let fontSize: CGFloat
    private let unitsPerEm: UInt
    private let mTable: NSDictionary
    init(mathFont: MathFont, size: CGFloat) {
        self.mathFont = mathFont
        self.fontSize = size
        mTable = mathFont.mathTable()
        unitsPerEm = mathFont.ctFont(withSize: fontSize).unitsPerEm
        super.init(withFont: mathFont.mtfont(size: fontSize), mathTable: mTable)
        super._mathTable = nil
        // disable all possible access to _mathTable in superclass!
    }
    override var _mathTable: NSDictionary? {
        set { fatalError("\(#function) change to _mathTable \(mathFont.rawValue) not allowed.") }
        get { mTable }
    }
    override var muUnit: CGFloat { fontSize/18 }
    
    override func fontUnitsToPt(_ fontUnits:Int) -> CGFloat {
        CGFloat(fontUnits) * fontSize / CGFloat(unitsPerEm)
    }
    override func constantFromTable(_ constName: String) -> CGFloat {
        guard let consts = mTable[kConstants] as? NSDictionary, let val = consts[constName] as? NSNumber else {
            return .zero
        }
        return fontUnitsToPt(val.intValue)
    }
    override func percentFromTable(_ percentName: String) -> CGFloat {
        guard let consts = mTable[kConstants] as? NSDictionary, let val = consts[percentName] as? NSNumber else {
            return .zero
        }
        return CGFloat(val.floatValue) / 100
    }

}
