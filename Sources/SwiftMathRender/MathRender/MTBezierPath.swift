//
//  MTBezierPath.swift
//  MathRenderSwift
//
//  Created by Mike Griebling on 2022-12-31.
//

import Foundation

#if os(macOS)

extension MTBezierPath {
    func addLine(to point: CGPoint) {
        self.line(to: point)
    }
}

extension MTView {
    
    var backgroundColor:MTColor? {
        get {
            MTColor(cgColor: self.layer?.backgroundColor ?? MTColor.clear.cgColor)
        }
        set {
            self.layer?.backgroundColor = MTColor.clear.cgColor
            self.wantsLayer = true
        }
    }
    
}

#endif

