//
//  MTLabel.swift
//  MathRenderSwift
//
//  Created by Mike Griebling on 2022-12-31.
//

import Foundation
import SwiftUI

#if os(macOS)

public class MTLabel : NSTextField {
    
    init() {
        super.init(frame: .zero)
        self.stringValue = ""
        self.isBezeled = false
        self.drawsBackground = false
        self.isEditable = false
        self.isSelectable = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var text:String? {
        get { super.stringValue }
        set { super.stringValue = newValue! }
    }
    
}

#endif
