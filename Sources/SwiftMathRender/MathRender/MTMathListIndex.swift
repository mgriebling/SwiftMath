//
//  MTMathListIndex.swift
//  MathRenderSwift
//
//  Created by Mike Griebling on 2022-12-31.
//

import Foundation

public class MTMathListIndex {
    
    public enum MTMathListSubIndexType: Int {
        case none = 0
        case nucleus
        case superScript
        case subScript
        case numerator
        case denominator
        case radicand
        case degree
    }
    
    /// The index of the associated atom.
    var atomIndex: Int
    
    /// The type of subindex, e.g. superscript, numerator etc.
    var subIndexType: MTMathListSubIndexType = .none
    
    /// The index into the sublist.
    var subIndex: MTMathListIndex?
    
    var finalIndex: Int {
        if self.subIndexType == .none {
            return self.atomIndex
        } else {
            return self.subIndex?.finalIndex ?? 0
        }
    }
    
    func prevIndex() -> MTMathListIndex? {
        if self.subIndexType == .none {
            if self.atomIndex > 0 {
                return MTMathListIndex(level0Index: self.atomIndex - 1)
            }
        } else {
            if let prevSubIndex = self.subIndex?.prevIndex() {
                return MTMathListIndex(at: self.atomIndex, with: prevSubIndex, type: self.subIndexType)
            }
        }
        return nil
    }
    
    func nextIndex() -> MTMathListIndex {
        if self.subIndexType == .none {
            return MTMathListIndex(level0Index: self.atomIndex + 1)
        } else if self.subIndexType == .nucleus {
            return MTMathListIndex(at: self.atomIndex + 1, with: self.subIndex, type: self.subIndexType)
        } else {
            return MTMathListIndex(at: self.atomIndex, with: self.subIndex?.nextIndex(), type: self.subIndexType)
        }
    }
    
    /**
     * Returns true if this index represents the beginning of a line. Note there may be multiple lines in a MTMathList,
     * e.g. a superscript or a fraction numerator. This returns true if the innermost subindex points to the beginning of a
     * line.
     */
    func isBeginningOfLine() -> Bool {
        return self.finalIndex == 0
    }
    
    func isAtSameLevel(with index: MTMathListIndex?) -> Bool {
        if self.subIndexType != index?.subIndexType {
            return false
        } else if self.subIndexType == .none {
            // No subindexes, they are at the same level.
            return true
        } else if (self.atomIndex != index?.atomIndex) {
            return false
        } else {
            return self.subIndex?.isAtSameLevel(with: index?.subIndex) ?? false
        }
    }
    
    /** Returns the type of the innermost sub index. */
    func finalSubIndexType() -> MTMathListSubIndexType {
        if self.subIndex?.subIndex != nil {
            return self.subIndex!.finalSubIndexType()
        } else {
            return self.subIndexType
        }
    }
    
    /** Returns true if any of the subIndexes of this index have the given type. */
    func hasSubIndex(ofType type: MTMathListSubIndexType) -> Bool {
        if self.subIndexType == type {
            return true
        } else {
            return self.subIndex?.hasSubIndex(ofType: type) ?? false
        }
    }
    
    func levelUp(with subIndex: MTMathListIndex?, type: MTMathListSubIndexType) -> MTMathListIndex {
        if self.subIndexType == .none {
            return MTMathListIndex(at: self.atomIndex, with: subIndex, type: type)
        }
        
        return MTMathListIndex(at: self.atomIndex, with: self.subIndex?.levelUp(with: subIndex, type: type), type: self.subIndexType)
    }
    
    func levelDown() -> MTMathListIndex? {
        if self.subIndexType == .none {
            return nil
        }
        
        if let subIndexDown = self.subIndex?.levelDown() {
            return MTMathListIndex(at: self.atomIndex, with: subIndexDown, type: self.subIndexType)
        } else {
            return MTMathListIndex(level0Index: self.atomIndex)
        }
    }
    
    /** Factory function to create a `MTMathListIndex` with no subindexes.
     @param index The index of the atom that the `MTMathListIndex` points at.
     */
    public init(level0Index: Int) {
        self.atomIndex = level0Index
    }
    
    public convenience init(at location: Int, with subIndex: MTMathListIndex?, type: MTMathListSubIndexType) {
        self.init(level0Index: location)
        self.subIndexType = type
        self.subIndex = subIndex
    }
}

extension MTMathListIndex: CustomStringConvertible {
    public var description: String {
        if self.subIndex != nil {
            return "[\(self.atomIndex), \(self.subIndexType.rawValue):\(self.subIndex!)]"
        }
        return "[\(self.atomIndex)]"
    }
}

extension MTMathListIndex: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.atomIndex)
        hasher.combine(self.subIndexType)
        hasher.combine(self.subIndex)
    }

}

extension MTMathListIndex: Equatable {
    public static func ==(lhs: MTMathListIndex, rhs: MTMathListIndex) -> Bool {
        if lhs.atomIndex != rhs.atomIndex || lhs.subIndexType != rhs.subIndexType {
            return false
        }
        
        if rhs.subIndex != nil {
            return rhs.subIndex == lhs.subIndex
        } else {
            return lhs.subIndex == nil
        }
    }
}
