import SwiftUI

#if canImport(UIKit)
  typealias PlatformColor = UIColor
  typealias PlatformBezierPath = UIBezierPath
#elseif canImport(AppKit)
  typealias PlatformColor = NSColor
  typealias PlatformBezierPath = NSBezierPath
#endif

extension PlatformColor {
  convenience init?(fromHexString hexString: String) {
    self.init(hexString: hexString)
  }

  convenience init?(hexString: String) {
    guard !hexString.isEmpty, hexString.hasPrefix("#") else { return nil }

    var rgbValue = UInt64(0)
    let scanner = Scanner(string: hexString)
    scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
    guard scanner.scanHexInt64(&rgbValue) else { return nil }

    self.init(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: 1.0
    )
  }
}
