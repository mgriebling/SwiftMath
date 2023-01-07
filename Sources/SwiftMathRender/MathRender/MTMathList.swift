//
//  MTMathList.swift
//  MathRenderSwift
//
//  Created by Mike Griebling on 2022-12-31.
//

import Foundation

// type defines spacing and how it is rendered
public enum MTMathAtomType: String, CustomStringConvertible {
    case ordinary // number or text
    case number     // number
    case variable // text in italic
    case largeOperator // sin/cos, integral
    case binaryOperator // \bin
    case unaryOperator //
    case relation // = < >
    case open // open bracket
    case close // close bracket
    case fraction // \frac
    case radical // \sqrt
    case punctuation // ,
    case placeholder // inner atom
    case inner // embedded list
    case underline // underlined atom
    case overline // overlined atom
    case accent // accented atom
    
    // these atoms do not support subscripts/superscripts:
    case boundary
    case space
    
    // Denotes style changes during randering
    case style
    case color
    case colorBox
    
    case table
    
    func isNotBinaryOperator() -> Bool {
        switch self {
            case .binaryOperator, .relation, .open, .punctuation, .largeOperator: return true
            default: return false
        }
    }
    
    func isScriptAllowed() -> Bool {
        return self != .boundary && self != .space && self != .style && self != .table
    }
    
    // we want string representations to be capitalized
    public var description: String {
        self.rawValue.capitalized
    }
}

public enum MTFontStyle:Int {
    /// The default latex rendering style. i.e. variables are italic and numbers are roman.
    case defaultStyle = 0,
    /// Roman font style i.e. \mathrm
    roman,
    /// Bold font style i.e. \mathbf
    bold,
    /// Caligraphic font style i.e. \mathcal
    caligraphic,
    /// Typewriter (monospace) style i.e. \mathtt
    typewriter,
    /// Italic style i.e. \mathit
    italic,
    /// San-serif font i.e. \mathss
    sansSerif,
    /// Fractur font i.e \mathfrak
    fraktur,
    /// Blackboard font i.e. \mathbb
    blackboard,
    /// Bold italic
    boldItalic
}

public class MTMathAtom: CustomStringConvertible {
    public var type: MTMathAtomType
    public var subScript: MTMathList?
    public var superScript: MTMathList?
    var fontStyle: MTFontStyle = .defaultStyle
    var fusedAtoms: MTMathList?
    
    public static func atom(withType type:MTMathAtomType, value:String) -> MTMathAtom {
        switch type {
            case .largeOperator:
                return MTLargeOperator(value: value, limits: true)
            case .fraction:
                return MTFraction()
            case .radical:
                return MTRadical()
            case .placeholder:
                return MTMathAtom(type: type, value: UnicodeSymbol.whiteSquare)
            case .inner:
                return MTInner()
            case .underline:
                return MTUnderLine()
            case .overline:
                return MTOverLine()
            case .accent:
                return MTAccent(value: value)
            case .space:
                return MTMathSpace(space: 0)
            case .color:
                return MTMathColor()
            case .colorBox:
                return MTMathColorbox()
            default:
                return MTMathAtom(type: type, value: value)
        }
    }
    
    public func setSuperScript(_ list: MTMathList?) {
        if self.isScriptAllowed() {
            self.superScript = list
        } else {
            print("superscripts not allowed for atom \(self.type.rawValue)")
            self.superScript = nil
        }
    }
    
    public func setSubScript(_ list: MTMathList?) {
        if self.isScriptAllowed() {
            self.subScript = list
        } else {
            print("subscripts not allowed for atom \(self.type.rawValue)")
            self.subScript = nil
        }
    }
    
    public var description: String {
        var string = ""
        
        string += self.nucleus
        if self.superScript != nil {
            string += "^{\(self.superScript!.description)}"
        }
        if self.subScript != nil {
            string += "_{\(self.subScript!.description)}"
        }
        
        return string
    }
    
    public var nucleus: String = ""
    public var finalized: MTMathAtom {
        let finalized = self
        if finalized.superScript != nil {
            finalized.superScript = finalized.superScript!.finalized
        }
        if finalized.subScript != nil {
            finalized.subScript = finalized.subScript!.finalized
        }
        return finalized
    }
    
    // atoms that fused to create this one
    public var childAtoms = [MTMathAtom]()
    
    // indexRange in list that this atom tracks:
    public var indexRange = NSRange(location: 0, length: 0)
    
    public var string:String {
        var str = self.nucleus
        if let superScript = self.superScript {
            str.append("^{\(superScript.string)}")
        }
        if let subScript = self.subScript {
            str.append("_{\(subScript.string)}")
        }
        return str
    }
    
    func fuse(with atom: MTMathAtom) {
        assert(self.subScript == nil, "Cannot fuse into an atom which has a subscript: \(self)");
        assert(self.superScript == nil, "Cannot fuse into an atom which has a superscript: \(self)");
        assert(atom.type == self.type, "Only atoms of the same type can be fused. \(self), \(atom)");
        guard self.subScript == nil,
            self.superScript == nil,
            self.type == atom.type
        else {
            print("Can't fuse these 2 atom")
            return
        }
        
        self.childAtoms.append(self)
        if atom.childAtoms.count > 0 {
            self.childAtoms += atom.childAtoms
        } else {
            self.childAtoms.append(atom)
        }
        
        // Update nucleus:
        self.nucleus += atom.nucleus
        
        // Update range:
        self.indexRange.length += atom.indexRange.length
        
        // Update super/subscript:
        self.superScript = atom.superScript
        self.subScript = atom.subScript
    }
    
    func isScriptAllowed() -> Bool { self.type.isScriptAllowed() }
    
    public init(type: MTMathAtomType, value: String) {
        self.type = type
        self.nucleus = value
    }
    
    func isNotBinaryOperator() -> Bool { self.type.isNotBinaryOperator() }
    
}

func isNotBinaryOperator(_ prevNode:MTMathAtom?) -> Bool {
    if prevNode == nil { return true }
    return prevNode!.type.isNotBinaryOperator()
}

public class MTFraction: MTMathAtom {
    public var hasRule: Bool = true
    public var leftDelimiter: String?
    public var rightDelimiter: String?
    public var numerator:  MTMathList? =  MTMathList()
    public var denominator:  MTMathList? =  MTMathList()
    
    override public var description: String {
        var string = ""
        if self.hasRule {
            string += "\\atop"
        } else {
            string += "\\frac"
        }
        if self.leftDelimiter != nil {
            string += "[\(self.leftDelimiter!)]"
        }
        if self.rightDelimiter != nil {
            string += "[\(self.rightDelimiter!)]"
        }
        
        string += "{\(self.numerator?.description ?? "placeholder")}{\(self.denominator?.description ?? "placeholder")}"
        
        if self.superScript != nil {
            string += "^{\(self.superScript!.description)}"
        }
        if self.subScript != nil {
            string += "_{\(self.subScript!.description)}"
        }
        
        return string
    }
    
    override public var finalized: MTMathAtom {
        let finalized: MTFraction = super.finalized as! MTFraction
        
        finalized.numerator = finalized.numerator?.finalized
        finalized.denominator = finalized.denominator?.finalized
        
        return finalized
    }
    
    convenience init(hasRule: Bool = true) {
        self.init(type: .fraction, value: "")
        self.hasRule = hasRule
    }
}

public class MTRadical: MTMathAtom {
    // Under the roof
    public var radicand:  MTMathList? =  MTMathList()
    
    // Value on radical sign
    public var degree:  MTMathList?
    
    convenience init() {
        self.init(type: .radical, value: "")
    }
    
    override public var description: String {
        var string = "\\sqrt"
        
        if self.degree != nil {
            string += "[\(self.degree!.description)]"
        }
        
        if self.radicand != nil {
            string += "{\(self.radicand?.description ?? "placeholder")}"
        }
        
        if self.superScript != nil {
            string += "^{\(self.superScript!.description)}"
        }
        if self.subScript != nil {
            string += "_{\(self.subScript!.description)}"
        }
        
        return string
    }
    
    override public var finalized: MTMathAtom {
        let finalized: MTRadical = super.finalized as! MTRadical
        
        finalized.radicand = finalized.radicand?.finalized
        finalized.degree = finalized.degree?.finalized
        
        return finalized
    }
}

public class MTLargeOperator: MTMathAtom {
    public var limits: Bool = false
    
    convenience init(value: String, limits: Bool = false) {
        self.init(type: .largeOperator, value: value)
        self.limits = limits
    }
}

// MARK: - MTInner

public class MTInner: MTMathAtom {
    public var innerList: MTMathList?
    public var leftBoundary: MTMathAtom? {
        didSet {
            if leftBoundary != nil && leftBoundary!.type != .boundary {
                assertionFailure("Left boundary must be of type .boundary")
            }
        }
    }
    public var rightBoundary: MTMathAtom? {
        didSet {
            if rightBoundary != nil && rightBoundary!.type != .boundary {
                assertionFailure("Right boundary must be of type .boundary")
            }
        }
    }
    
    init() {
        super.init(type: .inner, value: "")
    }
    
    public override convenience init(type: MTMathAtomType, value: String) {
        if type == .inner {
            self.init(); return
        }
        assertionFailure("MTInner(type:value:) cannot be called. Use MTInner() instead.")
        self.init()
    }
    
    override public var description: String {
        var string = "\\inner"
        
        if self.leftBoundary != nil {
            string += "[\(self.leftBoundary!.nucleus)]"
        }
        string += "{\(self.innerList!.description)}"
        
        if self.rightBoundary != nil {
            string += "[\(self.rightBoundary!.nucleus)]"
        }
        
        if self.superScript != nil {
            string += "^{\(self.superScript!.description)}"
        }
        if self.subScript != nil {
            string += "_{\(self.subScript!.description)}"
        }
        
        return string
    }
    
    override public var finalized: MTMathAtom {
        let finalized: MTInner = super.finalized as! MTInner
        
        finalized.innerList = finalized.innerList?.finalized
        
        return finalized
    }
}

public class MTOverLine: MTMathAtom {
    public var innerList:  MTMathList?
    
    override public var finalized: MTMathAtom {
        let finalized: MTOverLine = super.finalized as! MTOverLine
        
        finalized.innerList = finalized.innerList?.finalized
        
        return finalized
    }
    
    convenience init() {
        self.init(type: .overline, value: "")
    }
}

public class MTUnderLine: MTMathAtom {
    public var innerList:  MTMathList?
    
    override public var finalized: MTMathAtom {
        let finalized: MTUnderLine = super.finalized as! MTUnderLine
        
        finalized.innerList = finalized.innerList?.finalized
        
        return finalized
    }
    
    convenience init() {
        self.init(type: .underline, value: "")
    }
}

public class MTAccent: MTMathAtom {
    public var innerList:  MTMathList?
    
    override public var finalized: MTMathAtom {
        let finalized: MTAccent = super.finalized as! MTAccent
        
        finalized.innerList = finalized.innerList?.finalized
        
        return finalized
    }
    
    convenience init(value: String) {
        self.init(type: .accent, value: value)
    }
}

public class MTMathSpace: MTMathAtom {
    public var space: CGFloat = 0
    
    convenience init(space: CGFloat) {
        self.init(type: .space, value: "")
        self.space = space
    }
}

public enum MTLineStyle {
    case display
    case text
    case script
    case scriptOfScript
    
    public func inc() -> MTLineStyle {
        switch self {
            case .display: return .text
            case .text: return .script
            case .script: return .scriptOfScript
            case .scriptOfScript: return .display
        }
    }
    
    public var isNotScript:Bool {
        self == .display || self == .text
    }
}

public class MTMathStyle: MTMathAtom {
    public var style: MTLineStyle = .display
    
    convenience init(style: MTLineStyle = .display) {
        self.init(type: .style, value: "")
        self.style = style
    }
}

public class MTMathColor: MTMathAtom {
    public var colorString:String=""
    public var innerList:MTMathList?
    
    init() {
        super.init(type: .color, value: "")
    }
    
    public override convenience init(type: MTMathAtomType, value: String) {
        if type == .color {
            self.init(); return
        }
        NSException(name: NSExceptionName("InvalidMethod"), reason: "MTMathColor(type:value) cannot be called. Use MTMathColor() instead.").raise()
        self.init()
    }
    
    public override var string: String {
        "\\color{\(self.colorString)}{\(self.innerList!.string)}"
    }
}

public class MTMathColorbox: MTMathAtom {
    public var colorString:String=""
    public var innerList:MTMathList?
    
    init() {
        super.init(type: .color, value: "")
    }
    
    public override convenience init(type: MTMathAtomType, value: String) {
        if type == .color {
            self.init(); return
        }
        NSException(name: NSExceptionName("InvalidMethod"), reason: "MTMathColorbox(type:value) cannot be called. Use MTMathColorbox() instead.").raise()
        self.init()
    }
    
    public override var string: String {
        "\\colorbox{\(self.colorString)}{\(self.innerList!.string)}"
    }
}

public enum MTColumnAlignment {
    case left
    case center
    case right
}

public class MTMathTable: MTMathAtom {
    public var alignments = [MTColumnAlignment]()
    public var cells = [[MTMathList]]()
    
    public var environment: String?
    public var interColumnSpacing: CGFloat = 0
    public var interRowAdditionalSpacing: CGFloat = 0
//    public var numColumns = 0
//    public var numRows = 0
    
    override public var finalized: MTMathAtom {
        let finalized: MTMathTable = super.finalized as! MTMathTable
        
        for var row in finalized.cells {
            for i in 0..<row.count {
                row[i] = row[i].finalized
            }
        }
        
        return finalized
    }
    
    convenience init(environment: String? = nil) {
        self.init(type: .table, value: "")
        self.environment = environment
    }
    
    public func set(cell list: MTMathList, forRow row:Int, column:Int) {
        if self.cells.count <= row {
            for _ in self.cells.count...row {
                self.cells.append([])
            }
        }
        let rows = self.cells[row].count
        if rows <= column {
            for _ in rows...column {
                self.cells[row].append(MTMathList())
            }
        }
        self.cells[row][column] = list
    }
    
    public func set(alignment: MTColumnAlignment, forColumn col: Int) {
        if self.alignments.count <= col {
            for _ in self.alignments.count...col {
                self.alignments.append(MTColumnAlignment.center)
            }
        }
        
        self.alignments[col] = alignment
    }
    
    public func get(alignmentForColumn col: Int) -> MTColumnAlignment {
        if self.alignments.count <= col {
            return MTColumnAlignment.center
        } else {
            return self.alignments[col]
        }
    }
    
    public var numColumns: Int {
        var numberOfCols = 0
        
        for row in self.cells {
            numberOfCols = max(numberOfCols, row.count)
        }
        
        return numberOfCols
    }
    
    public var numRows: Int {
        return self.cells.count
    }
}

// represent list of math objects
extension MTMathList: CustomStringConvertible {
    public var description: String { self.atoms.description }
    public var string: String { self.description }
}

public class MTMathList {
    public var atoms = [MTMathAtom]()
    
    public var finalized: MTMathList {
        let finalizedList = MTMathList()
        let zeroRange = NSMakeRange(0, 0)
        
        var prevNode: MTMathAtom? = nil
        for atom in self.atoms {
            let newNode = atom.finalized
            
            if NSEqualRanges(zeroRange, atom.indexRange) {
                let index = prevNode == nil ? 0 : prevNode!.indexRange.location + prevNode!.indexRange.length
                newNode.indexRange = NSMakeRange(index, 1)
            }
            
            switch newNode.type {
            case .binaryOperator:
                if prevNode == nil || prevNode!.isNotBinaryOperator()  {
                    newNode.type = .unaryOperator
                }
                break
            case .relation, .punctuation, .close:
                if prevNode != nil &&
                    prevNode!.type == .binaryOperator {
                    prevNode!.type = .unaryOperator
                }
                break
            case .number:
                if prevNode != nil &&
                    prevNode!.type == .number &&
                    prevNode!.subScript == nil &&
                    prevNode!.superScript == nil {
                    prevNode!.fuse(with: newNode)
                    continue
                }
                break
            default: break
            }
            
            finalizedList.add(newNode)
            prevNode = newNode
        }
        
        if prevNode != nil && prevNode!.type == .binaryOperator {
            prevNode!.type = .unaryOperator
            finalizedList.removeLastAtom()
            finalizedList.add(prevNode!)
        }
        
        return finalizedList
    }
    
    public init(atoms: [MTMathAtom]) {
        self.atoms.append(contentsOf: atoms)
    }
    
    public init(atom: MTMathAtom) {
        self.atoms.append(atom)
    }
    
    public init() {
        self.atoms = []
    }
    
    func add(_ atom: MTMathAtom) {
        if self.isAtomAllowed(atom) {
            self.atoms.append(atom)
        } else {
            print("error, cannot add atom of type \(atom.type.rawValue) into atomlist")
        }
    }
    
    func insert(_ atom: MTMathAtom, at index: Int) {
        if self.isAtomAllowed(atom) {
            self.atoms.insert(atom, at: index)
        } else {
            print("error, cannot add atom of type \(atom.type.rawValue) into atomlist")
        }
    }
    
    func append(_ list: MTMathList) {
        self.atoms += list.atoms
    }
    
    func removeLastAtom() {
        if self.atoms.count > 0 {
            self.atoms.removeLast()
        }
    }
    
    func removeAtom(at index: Int) {
        self.atoms.remove(at: index)
    }
    
    func removeAtoms(in range: ClosedRange<Int>) {
        self.atoms.removeSubrange(range)
    }
    
    func isAtomAllowed(_ atom: MTMathAtom) -> Bool {
        return atom.type != .boundary
    }
}
