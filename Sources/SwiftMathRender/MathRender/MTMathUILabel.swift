//
//  MTMathUILabel.swift
//  MathRenderSwift
//
//  Created by Mike Griebling on 2023-01-01.
//

import Foundation
import CoreText

/**
 Different display styles supported by the `MTMathUILabel`.
 
 The only significant difference between the two modes is how fractions
 and limits on large operators are displayed.
 */
public enum MTMathUILabelMode {
    /// Display mode. Equivalent to $$ in TeX
    case display
    /// Text mode. Equivalent to $ in TeX.
    case text
}

/**
 @typedef MTTextAlignment
 @brief Horizontal text alignment for `MTMathUILabel`.
 */
public enum MTTextAlignment : UInt {
    /// Align left.
    case left
    /// Align center.
    case center
    /// Align right.
    case right
}

/** The main view for rendering math.
 
 `MTMathLabel` accepts either a string in LaTeX or an `MTMathList` to display. Use
 `MTMathList` directly only if you are building it programmatically (e.g. using an
 editor), otherwise using LaTeX is the preferable method.
 
 The math display is centered vertically in the label. The default horizontal alignment is
 is left. This can be changed by setting `textAlignment`. The math is default displayed in
 *Display* mode. This can be changed using `labelMode`.
 
 When created it uses `[MTFontManager defaultFont]` as its font. This can be changed using
 the `font` parameter.
 */
@IBDesignable
public class MTMathUILabel : MTView {
    
    /** The `MTMathList` to render. Setting this will remove any
     `latex` that has already been set. If `latex` has been set, this will
     return the parsed `MTMathList` if the `latex` parses successfully. Use this
     setting if the `MTMathList` has been programmatically constructed, otherwise it
     is preferred to use `latex`.
     */
    var mathList:MTMathList? {
        didSet {
            self.error = nil
            self.latex = MTMathListBuilder.mathListToString(mathList)
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /** The latex string to be displayed. Setting this will remove any `mathList` that
     has been set. If latex has not been set, this will return the latex output for the
     `mathList` that is set.
     @see error */
    @IBInspectable
    public var latex = "" {
        didSet {
            self.error = nil
            var error : NSError? = nil
            self.mathList = MTMathListBuilder.build(fromString: latex, error: &error)
            if error != nil {
                self.mathList = nil
                self.error = error
                self.errorLabel?.text = error!.localizedDescription
                self.errorLabel?.frame = self.bounds
                self.errorLabel?.isHidden = !self.displayErrorInline
            } else {
                self.errorLabel?.isHidden = true
            }
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /** This contains any error that occurred when parsing the latex. */
    var error:NSError?
    
    /** If true, if there is an error it displays the error message inline. Default true. */
    var displayErrorInline = true
    
    /** The MTFont to use for rendering. */
    var font = MTFontManager.fontManager.defaultFont {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /** Convenience method to just set the size of the font without changing the fontface. */
    @IBInspectable
    public var fontSize = MTFontManager.fontManager.kDefaultFontSize {
        didSet {
            self.font = font?.copy(withSize: fontSize)
        }
    }
    
    /** This sets the text color of the rendered math formula. The default color is black. */
    @IBInspectable
    public var textColor:MTColor? = MTColor.black {
        didSet {
            self.displayList?.textColor = textColor
            self.setNeedsDisplay()
        }
    }
    
    /** The minimum distance from the margin of the view to the rendered math. This value is
     `UIEdgeInsetsZero` by default. This is useful if you need some padding between the math and
     the border/background color. sizeThatFits: will have its returned size increased by these insets.
     */
    @IBInspectable
    public var contentInsets = MTEdgeInsetsZero {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /** The Label mode for the label. The default mode is Display */
    var labelMode = MTMathUILabelMode.display {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /** Horizontal alignment for the text. The default is align left. */
    var textAlignment = MTTextAlignment.left {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /** The internal display of the MTMathUILabel. This is for advanced use only. */
    var displayList: MTMathListDisplay? = nil
    
    var currentStyle:MTLineStyle {
        switch labelMode {
            case .display: return .display
            case .text: return .text
        }
    }
    
    var errorLabel: MTLabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initCommon()
    }
    
    func initCommon() {
        #if os(macOS)
        self.layer?.isGeometryFlipped = true
        errorLabel?.layer?.isGeometryFlipped = true
        #else
        self.layer.isGeometryFlipped = true
        errorLabel?.layer.isGeometryFlipped = true
        #endif
        self.backgroundColor = MTColor.clear
        errorLabel = MTLabel()
        errorLabel?.isHidden = true
        errorLabel?.textColor = MTColor.red
        self.addSubview(errorLabel!)
    }
    
    override public func draw(_ dirtyRect: MTRect) {
        super.draw(dirtyRect)
        if self.mathList == nil { return }
     
        // drawing code
        let context = MTGraphicsGetCurrentContext()!
        context.saveGState()
        displayList!.draw(context)
        context.restoreGState()
    }
    
    func _layoutSubviews() {
        if mathList != nil {
            displayList = MTTypesetter.createLineForMathList(mathList, font: font, style: currentStyle)
            displayList?.textColor = textColor
            var textX = CGFloat(0)
            switch self.textAlignment {
                case .left:
                    textX = self.contentInsets.left
                case .center:
                    textX = (bounds.size.width - contentInsets.left - contentInsets.right - displayList!.width) / 2 +
                            contentInsets.left
                case .right:
                    textX = bounds.size.width - displayList!.width - contentInsets.right
            }
            let availableHeight = bounds.size.height - contentInsets.bottom - contentInsets.top
            
            // center things vertically
            var height = displayList!.ascent + displayList!.descent
            if height < fontSize/2 {
                height = fontSize/2  // set height to half the font size
            }
            let textY = (availableHeight - height) / 2 + displayList!.descent + contentInsets.bottom
            displayList?.position = CGPointMake(textX, textY)
        } else {
            displayList = nil
        }
        errorLabel?.frame = self.bounds
        self.setNeedsDisplay()
    }
    
    func _sizeThatFits(_ size:CGSize) -> CGSize {
        var size = size
        var displayList:MTMathListDisplay? = nil
        if mathList != nil {
            displayList = MTTypesetter.createLineForMathList(mathList, font: font, style: currentStyle)
        }
        size.width = displayList!.width + contentInsets.left + contentInsets.right
        size.height = displayList!.ascent + displayList!.descent + contentInsets.top + contentInsets.bottom
        return size
    }
    
    override public var intrinsicContentSize: CGSize { _sizeThatFits(CGSizeZero) }
    
    #if os(macOS)
    override public var isFlipped: Bool { false }
    func setNeedsDisplay() { self.needsDisplay = true }
    func setNeedsLayout() { self.needsLayout = true }
    override public func layout() {
        self._layoutSubviews()
        super.layout()
    }
    #else
    override public func layoutSubviews() { self._layoutSubviews() }
    override public func sizeThatFits(_ size: CGSize) -> CGSize { self._sizeThatFits(size) }
    #endif
    
}
