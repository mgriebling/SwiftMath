//
//  MTConfig.swift
//  MathRenderSwift
//
//  Created by Mike Griebling on 2023-01-01.
//

import Foundation

#if os(iOS)

import UIKit

typealias MTView = UIView
typealias MTColor = UIColor
typealias MTBezierPath = UIBezierPath
typealias MTLabel = UILabel
typealias MTRect = CGRect

let MTEdgeInsetsZero = UIEdgeInsets.zero
func MTGraphicsGetCurrentContext() -> CGContext? { UIGraphicsGetCurrentContext() }

#else

import AppKit

typealias MTView = NSView
typealias MTColor = NSColor
typealias MTBezierPath = NSBezierPath
typealias MTEdgeInsets = NSEdgeInsets
typealias MTRect = NSRect

let MTEdgeInsetsZero = NSEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
func MTGraphicsGetCurrentContext() -> CGContext? { NSGraphicsContext.current?.cgContext }

#endif
