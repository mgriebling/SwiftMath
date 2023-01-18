//
//  MTMathList.swift
//  MathRenderSwift
//
//  Created by Mike Griebling on 2022-12-31.
//

import Foundation

// type defines spacing and how it is rendered
public enum MTMathAtomType: Int, CustomStringConvertible, Comparable {
 
    case ordinary = 1 // number or text
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
    case boundary = 101
    case space = 201
    
    // Denotes style changes during randering
    case style
    case color
    case colorBox
    
    case table = 1001
    
    func isNotBinaryOperator() -> Bool {
        switch self {
            case .binaryOperator, .relation, .open, .punctuation, .largeOperator: return true
            default: return false
        }
    }
    
    func isScriptAllowed() -> Bool { self < .boundary }
    
    // we want string representations to be capitalized
    public var description: String {
        switch self {
            case .ordinary:       return "Ordinary"
            case .number:         return "Number"
            case .variable:       return "Variable"
            case .largeOperator:  return "Large Operator"
            case .binaryOperator: return "Binary Operator"
            case .unaryOperator:  return "Unary Operator"
            case .relation:       return "Relation"
            case .open:           return "Open"
            case .close:          return "Close"
            case .fraction:       return "Fraction"
            case .radical:        return "Radical"
            case .punctuation:    return "Punctuation"
            case .placeholder:    return "Placeholder"
            case .inner:          return "Inner"
            case .underline:      return "Underline"
            case .overline:       return "Overline"
            case .accent:         return "Accent"
            case .boundary:       return "Boundary"
            case .space:          return "Space"
            case .style:          return "Style"
            case .color:          return "Color"
            case .colorBox:       return "Colorbox"
            case .table:          return "Table"
        }
    }
    
    // comparable support
    public static func < (lhs: MTMathAtomType, rhs: MTMathAtomType) -> Bool { lhs.rawValue < rhs.rawValue }
    
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

// MARK: - MTMathAtom

public class MTMathAtom: NSObject {
    
    public var type = MTMathAtomType.ordinary
    public var subScript: MTMathList? {
        didSet {
            if subScript != nil && !self.isScriptAllowed() {
                subScript = nil
                NSException(name: NSExceptionName(rawValue: "Error"), reason: "Subscripts not allowed for atom of type \(self.type)").raise()
            }
        }
    }
    public var superScript: MTMathList? {
        didSet {
            if superScript != nil && !self.isScriptAllowed() {
                superScript = nil
                NSException(name: NSExceptionName(rawValue: "Error"), reason: "Superscripts not allowed for atom of type \(self.type)").raise()
            }
        }
    }
    
    public var nucleus: String = ""
    public var indexRange = NSRange(location: 0, length: 0) // indexRange in list that this atom tracks:
    
    var fontStyle: MTFontStyle = .defaultStyle
    var fusedAtoms = [MTMathAtom]()             // atoms that fused to create this one
    
    init(_ atom:MTMathAtom?) {
        guard let atom = atom else { return }
        self.type = atom.type
        self.nucleus = atom.nucleus
        self.subScript = MTMathList(atom.subScript)
        self.superScript = MTMathList(atom.superScript)
        self.indexRange = atom.indexRange
        self.fontStyle = atom.fontStyle
        self.fusedAtoms = atom.fusedAtoms
    }
    
    override init() { }
    
    init(type:MTMathAtomType, value:String) {
        self.type = type
        self.nucleus = type == .radical ? "" : value
    }
    
    public func copy() -> MTMathAtom {
        switch self.type {
            case .largeOperator:
                return MTLargeOperator(self as? MTLargeOperator)
            case .fraction:
                return MTFraction(self as? MTFraction)
            case .radical:
                return MTRadical(self as? MTRadical)
            case .style:
                return MTMathStyle(self as? MTMathStyle)
            case .inner:
                return MTInner(self as? MTInner)
            case .underline:
                return MTUnderLine(self as? MTUnderLine)
            case .overline:
                return MTOverLine(self as? MTOverLine)
            case .accent:
                return MTAccent(self as? MTAccent)
            case .space:
                return MTMathSpace(self as? MTMathSpace)
            case .color:
                return MTMathColor(self as? MTMathColor)
            case .colorBox:
                return MTMathColorbox(self as? MTMathColorbox)
            case .table:
                return MTMathTable(self as! MTMathTable)
            default:
                return MTMathAtom(self)
        }
    }
    
    public override var description: String {
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
    
    public var finalized: MTMathAtom {
        let finalized : MTMathAtom = self.copy()
        finalized.superScript = finalized.superScript?.finalized
        finalized.subScript = finalized.subScript?.finalized
        return finalized
    }
    
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
        guard self.subScript == nil, self.superScript == nil, self.type == atom.type
        else { print("Can't fuse these 2 atoms"); return }
        
        // Update the fused atoms list
        if self.fusedAtoms.isEmpty {
            self.fusedAtoms.append(MTMathAtom(self))
        }
        if atom.fusedAtoms.count > 0 {
            self.fusedAtoms.append(contentsOf: atom.fusedAtoms)
        } else {
            self.fusedAtoms.append(atom)
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
    func isNotBinaryOperator() -> Bool { self.type.isNotBinaryOperator() }
    
}

func isNotBinaryOperator(_ prevNode:MTMathAtom?) -> Bool {
    guard let prevNode = prevNode else { return true }
    return prevNode.type.isNotBinaryOperator()
}

// MARK: - MTFraction

public class MTFraction: MTMathAtom {
    public var hasRule: Bool = true
    public var leftDelimiter: String?
    public var rightDelimiter: String?
    public var numerator: MTMathList?
    public var denominator: MTMathList?
    
    init(_ frac: MTFraction?) {
        super.init(frac)
        self.type = .fraction
        self.numerator = MTMathList(frac!.numerator)
        self.denominator = MTMathList(frac!.denominator)
        self.hasRule = frac!.hasRule
        self.leftDelimiter = frac!.leftDelimiter
        self.rightDelimiter = frac!.rightDelimiter
    }
    
    init(hasRule rule:Bool = true) {
        super.init()
        self.type = .fraction
        self.hasRule = rule
    }
    
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
        let newFrac = super.finalized as! MTFraction
        newFrac.numerator = newFrac.numerator?.finalized
        newFrac.denominator = newFrac.denominator?.finalized
        return newFrac
    }
    
}

// MARK: - MTRadical

public class MTRadical: MTMathAtom {
    // Under the roof
    public var radicand:  MTMathList?
    
    // Value on radical sign
    public var degree:  MTMathList?
    
    init(_ rad:MTRadical?) {
        super.init(rad)
        self.type = .radical
        self.radicand = MTMathList(rad?.radicand)
        self.degree = MTMathList(rad?.degree)
        self.nucleus = ""
    }
    
    override init() {
        super.init()
        self.type = .radical
        self.nucleus = ""
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
        let newRad = super.finalized as! MTRadical
        newRad.radicand = newRad.radicand?.finalized
        newRad.degree = newRad.degree?.finalized
        return newRad
    }
}

// MARK: - MTLargeOperator

public class MTLargeOperator: MTMathAtom {
    public var limits: Bool = false
    
    init(_ op:MTLargeOperator?) {
        super.init(op)
        self.type = .largeOperator
        self.limits = op!.limits
    }
    
    init(value: String, limits: Bool) {
        super.init(type: .largeOperator, value: value)
        self.limits = limits
    }
}

// MARK: - MTInner

public class MTInner: MTMathAtom {
    public var innerList: MTMathList?
    public var leftBoundary: MTMathAtom? {
        didSet {
            if leftBoundary != nil && leftBoundary!.type != .boundary {
                leftBoundary = nil
                NSException(name: NSExceptionName(rawValue: "Error"), reason: "Left boundary must be of type .boundary").raise()
            }
        }
    }
    public var rightBoundary: MTMathAtom? {
        didSet {
            if rightBoundary != nil && rightBoundary!.type != .boundary {
                rightBoundary = nil
                NSException(name: NSExceptionName(rawValue: "Error"), reason: "Right boundary must be of type .boundary").raise()
            }
        }
    }
    
    init(_ inner:MTInner?) {
        super.init(inner)
        self.type = .inner
        self.innerList = MTMathList(inner?.innerList)
        self.leftBoundary = MTMathAtom(inner?.leftBoundary)
        self.rightBoundary = MTMathAtom(inner?.rightBoundary)
    }
    
    override init() {
        super.init()
        self.type = .inner
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
        let newInner = super.finalized as! MTInner
        newInner.innerList = newInner.innerList?.finalized
        return newInner
    }
}

// MARK: - MTOverLIne

public class MTOverLine: MTMathAtom {
    public var innerList:  MTMathList?
    
    override public var finalized: MTMathAtom {
        let newOverline = MTOverLine(self)
        newOverline.innerList = newOverline.innerList?.finalized
        return newOverline
    }
    
    init(_ over: MTOverLine?) {
        super.init(over)
        self.type = .overline
        self.innerList = MTMathList(over!.innerList)
    }
    
    override init() {
        super.init()
        self.type = .overline
    }
}

// MARK: - MTUnderLine

public class MTUnderLine: MTMathAtom {
    public var innerList:  MTMathList?
    
    override public var finalized: MTMathAtom {
        let newUnderline = super.finalized as! MTUnderLine
        newUnderline.innerList = newUnderline.innerList?.finalized
        return newUnderline
    }
    
    init(_ under: MTUnderLine?) {
        super.init(under)
        self.type = .underline
        self.innerList = MTMathList(under?.innerList)
    }
    
    override init() {
        super.init()
        self.type = .underline
    }
}

// MARK: - MTAccent

public class MTAccent: MTMathAtom {
    public var innerList:  MTMathList?
    
    override public var finalized: MTMathAtom {
        let newAccent = super.finalized as! MTAccent
        newAccent.innerList = newAccent.innerList?.finalized
        return newAccent
    }
    
    init(_ accent: MTAccent?) {
        super.init(accent)
        self.type = .accent
        self.innerList = MTMathList(accent?.innerList)
    }
    
    init(value: String) {
        super.init()
        self.type = .accent
        self.nucleus = value
    }
}

// MARK: - MTMathSpace

public class MTMathSpace: MTMathAtom {
    public var space: CGFloat = 0
    
    init(_ space: MTMathSpace?) {
        super.init(space)
        self.type = .space
        self.space = space?.space ?? 0
    }
    
    init(space:CGFloat) {
        super.init()
        self.type = .space
        self.space = space
    }
}

public enum MTLineStyle:Int, Comparable {

    case display
    case text
    case script
    case scriptOfScript
    
    public func inc() -> MTLineStyle {
        let raw = self.rawValue + 1
        if let style = MTLineStyle(rawValue: raw) { return style }
        return .display
    }
    
    public var isNotScript:Bool { self < .script }
    public static func < (lhs: MTLineStyle, rhs: MTLineStyle) -> Bool { lhs.rawValue < rhs.rawValue }
}

// MARK: - MTMathStyle

public class MTMathStyle: MTMathAtom {
    public var style: MTLineStyle = .display
    
    init(_ style:MTMathStyle?) {
        super.init(style)
        self.type = .style
        self.style = style!.style
    }
    
    init(style:MTLineStyle) {
        super.init()
        self.type = .style
        self.style = style
    }
}

// MARK: - MTMathColor

public class MTMathColor: MTMathAtom {
    public var colorString:String=""
    public var innerList:MTMathList?
    
    init(_ color: MTMathColor?) {
        super.init(color)
        self.type = .color
        self.colorString = color?.colorString ?? ""
        self.innerList = MTMathList(color?.innerList)
    }
    
    override init() {
        super.init()
        self.type = .color
    }
    
    public override var string: String {
        "\\color{\(self.colorString)}{\(self.innerList!.string)}"
    }
    
    override public var finalized: MTMathAtom {
        let newColor = super.finalized as! MTMathColor
        newColor.innerList = newColor.innerList?.finalized
        return newColor
    }
}

// MARK: - MTMathColorbox

public class MTMathColorbox: MTMathAtom {
    public var colorString:String=""
    public var innerList:MTMathList?
    
    init(_ cbox: MTMathColorbox?) {
        super.init(cbox)
        self.type = .colorBox
        self.colorString = cbox?.colorString ?? ""
        self.innerList = MTMathList(cbox?.innerList)
    }
    
    override init() {
        super.init()
        self.type = .colorBox
    }
    
    public override var string: String {
        "\\colorbox{\(self.colorString)}{\(self.innerList!.string)}"
    }
    
    override public var finalized: MTMathAtom {
        let newColor = super.finalized as! MTMathColorbox
        newColor.innerList = newColor.innerList?.finalized
        return newColor
    }
}

public enum MTColumnAlignment {
    case left
    case center
    case right
}

// MARK: - MTMathTable

public class MTMathTable: MTMathAtom {
    public var alignments = [MTColumnAlignment]()
    public var cells = [[MTMathList]]()
    
    public var environment: String?
    public var interColumnSpacing: CGFloat = 0
    public var interRowAdditionalSpacing: CGFloat = 0
    
    override public var finalized: MTMathAtom {
        let table = super.finalized as! MTMathTable
        for var row in table.cells {
            for i in 0..<row.count {
                row[i] = row[i].finalized
            }
        }
        return table
    }
    
    init(environment: String?) {
        super.init()
        self.type = .table
        self.environment = environment
    }
    
    init(_ table:MTMathTable) {
        super.init(table)
        self.type = .table
        self.alignments = table.alignments
        self.interRowAdditionalSpacing = table.interRowAdditionalSpacing
        self.interColumnSpacing = table.interColumnSpacing
        self.environment = table.environment
        var cellCopy = [[MTMathList]]()
        for row in table.cells {
            var newRow = [MTMathList]()
            for col in row {
                newRow.append(MTMathList(col)!)
            }
            cellCopy.append(newRow)
        }
        self.cells = cellCopy
    }
    
    override init() {
        super.init()
        self.type = .table
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
    
    public var numRows: Int { self.cells.count }
}

// MARK: - MTMathList

// represent list of math objects
extension MTMathList {
    public override var description: String { self.atoms.description }
    public var string: String { self.description }
}

public class MTMathList : NSObject {
    
    init?(_ list:MTMathList?) {
        guard let list = list else { return nil }
        for atom in list.atoms {
            self.atoms.append(atom.copy())
        }
    }

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
                if isNotBinaryOperator(prevNode)  {
                    newNode.type = .unaryOperator
                }
            case .relation, .punctuation, .close:
                if prevNode != nil && prevNode!.type == .binaryOperator {
                    prevNode!.type = .unaryOperator
                }
            case .number:
                if prevNode != nil && prevNode!.type == .number && prevNode!.subScript == nil && prevNode!.superScript == nil {
                    prevNode!.fuse(with: newNode)
                    continue // skip the current node, we are done here.
                }
            default: break
            }
            finalizedList.add(newNode)
            prevNode = newNode
        }
        if prevNode != nil && prevNode!.type == .binaryOperator {
            prevNode!.type = .unaryOperator
        }
        return finalizedList
    }
    
    public init(atoms: [MTMathAtom]) {
        self.atoms.append(contentsOf: atoms)
    }
    
    public init(atom: MTMathAtom) {
        self.atoms.append(atom)
    }
    
    public override init() { super.init() }
    
    func NSParamException(_ param:Any?) {
        if param == nil {
            NSException(name: NSExceptionName(rawValue: "Error"), reason: "Parameter cannot be nil").raise()
        }
    }
    
    func NSIndexException(_ array:[Any], index: Int) {
        guard !array.indices.contains(index) else { return }
        NSException(name: NSExceptionName(rawValue: "Error"), reason: "Index \(index) out of bounds").raise()
    }
    
    func add(_ atom: MTMathAtom?) {
        guard let atom = atom else { return }
        if self.isAtomAllowed(atom) {
            self.atoms.append(atom)
        } else {
            NSException(name: NSExceptionName(rawValue: "Error"), reason: "Cannot add atom of type \(atom.type.rawValue) into mathlist").raise()
        }
    }
    
    func insert(_ atom: MTMathAtom?, at index: Int) {
        // NSParamException(atom)
        guard let atom = atom else { return }
        guard self.atoms.indices.contains(index) || index == self.atoms.endIndex else { return }
        // guard self.atoms.endIndex >= index else { NSIndexException(); return }
        if self.isAtomAllowed(atom) {
            // NSIndexException(self.atoms, index: index)
            self.atoms.insert(atom, at: index)
        } else {
            NSException(name: NSExceptionName(rawValue: "Error"), reason: "Cannot add atom of type \(atom.type.rawValue) into mathlist").raise()
        }
    }
    
    func append(_ list: MTMathList?) {
        guard let list = list else { return }
        self.atoms += list.atoms
    }
    
    func removeLastAtom() {
        if !self.atoms.isEmpty {
            self.atoms.removeLast()
        }
    }
    
    func removeAtom(at index: Int) {
        NSIndexException(self.atoms, index:index)
        self.atoms.remove(at: index)
    }
    
    func removeAtoms(in range: ClosedRange<Int>) {
        NSIndexException(self.atoms, index: range.lowerBound)
        NSIndexException(self.atoms, index: range.upperBound)
        self.atoms.removeSubrange(range)
    }
    
    func isAtomAllowed(_ atom: MTMathAtom?) -> Bool { atom?.type != .boundary }
}
