//  Derived from SwiftMath by Mike Griebling (MIT License)

import SwiftUI

#if canImport(UIKit)
  typealias PlatformColor = UIColor
  typealias PlatformBezierPath = UIBezierPath
#elseif canImport(AppKit)
  typealias PlatformColor = NSColor
  typealias PlatformBezierPath = NSBezierPath
#endif
