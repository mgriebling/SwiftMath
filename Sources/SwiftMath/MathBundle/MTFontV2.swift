//
//  MTFontV2.swift
//  
//
//  Created by Peter Tang on 15/9/2023.
//

import Foundation
import CoreGraphics
import CoreText

extension MathFont {
    public func mtfont(size: CGFloat) -> MTFontV2 {
        MTFontV2(font: self, size: size)
    }
}
public final class MTFontV2: MTFont {
    let font: MathFont
    let size: CGFloat
    private lazy var _cgFont: CGFont = {
        font.cgFont()
    }()
    private lazy var _ctFont: CTFont = {
        font.ctFont(withSize: size)
    }()
    private lazy var _mathTab = MTFontMathTableV2(mathFont: font, size: size)
    init(font: MathFont = .latinModernFont, size: CGFloat) {
        self.font = font
        self.size = size
        
        super.init()
        
        super.defaultCGFont = nil
        super.ctFont = nil
        super.mathTable = nil
        super.rawMathTable = nil
    }
    override var defaultCGFont: CGFont! {
        set { fatalError("\(#function): change to \(font.fontName) not allowed.") }
        get { _cgFont }
    }
    override var ctFont: CTFont! {
        set { fatalError("\(#function): change to \(font.fontName) not allowed.") }
        get { _ctFont }
    }
    override var mathTable: MTFontMathTable? {
        set { fatalError("\(#function): change to \(font.rawValue) not allowed.") }
        get { _mathTab }
    }
    override var rawMathTable: NSDictionary? {
        set { fatalError("\(#function): change to \(font.rawValue) not allowed.") }
        get { fatalError("\(#function): access to \(font.rawValue) not allowed.") }
    }
    public override func copy(withSize size: CGFloat) -> MTFont {
        MTFontV2(font: font, size: size)
    }
}
