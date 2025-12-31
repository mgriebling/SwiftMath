import Foundation

extension String {
  static let multiplication = "\u{00D7}"
  static let division = "\u{00F7}"
  static let fractionSlash = "\u{2044}"
  static let whiteSquare = "\u{25A1}"
  static let blackSquare = "\u{25A0}"
  static let lessEqual = "\u{2264}"
  static let greaterEqual = "\u{2265}"
  static let notEqual = "\u{2260}"
  static let squareRoot = "\u{221A}"
  static let cubeRoot = "\u{221B}"
  static let infinity = "\u{221E}"
  static let angle = "\u{2220}"
  static let degree = "\u{00B0}"
}

extension UTF32Char {
  static let capitalGreekStart = UTF32Char(0x0391)
  static let capitalGreekEnd = UTF32Char(0x03A9)
  static let lowerGreekStart = UTF32Char(0x03B1)
  static let lowerGreekEnd = UTF32Char(0x03C9)
  static let planksConstant = UTF32Char(0x210e)
  static let lowerItalicStart = UTF32Char(0x1D44E)
  static let capitalItalicStart = UTF32Char(0x1D434)
  static let greekLowerItalicStart = UTF32Char(0x1D6FC)
  static let greekCapitalItalicStart = UTF32Char(0x1D6E2)
  static let greekSymbolItalicStart = UTF32Char(0x1D716)

  static let mathCapitalBoldStart = UTF32Char(0x1D400)
  static let mathLowerBoldStart = UTF32Char(0x1D41A)
  static let greekCapitalBoldStart = UTF32Char(0x1D6A8)
  static let greekLowerBoldStart = UTF32Char(0x1D6C2)
  static let greekSymbolBoldStart = UTF32Char(0x1D6DC)
  static let numberBoldStart = UTF32Char(0x1D7CE)

  static let mathCapitalBoldItalicStart = UTF32Char(0x1D468)
  static let mathLowerBoldItalicStart = UTF32Char(0x1D482)
  static let greekCapitalBoldItalicStart = UTF32Char(0x1D71C)
  static let greekLowerBoldItalicStart = UTF32Char(0x1D736)
  static let greekSymbolBoldItalicStart = UTF32Char(0x1D750)

  static let mathCapitalScriptStart = UTF32Char(0x1D49C)
  static let mathCapitalTTStart = UTF32Char(0x1D670)
  static let mathLowerTTStart = UTF32Char(0x1D68A)
  static let numberTTStart = UTF32Char(0x1D7F6)
  static let mathCapitalSansSerifStart = UTF32Char(0x1D5A0)
  static let mathLowerSansSerifStart = UTF32Char(0x1D5BA)
  static let numberSansSerifStart = UTF32Char(0x1D7E2)
  static let mathCapitalFrakturStart = UTF32Char(0x1D504)
  static let mathLowerFrakturStart = UTF32Char(0x1D51E)
  static let mathCapitalBlackboardStart = UTF32Char(0x1D538)
  static let mathLowerBlackboardStart = UTF32Char(0x1D552)
  static let numberBlackboardStart = UTF32Char(0x1D7D8)
}

extension Character {
  var utf32: UTF32Char { self.unicodeScalars.map { $0.value }.reduce(0, +) }
  var isLowerEnglish: Bool { self >= "a" && self <= "z" }
  var isUpperEnglish: Bool { self >= "A" && self <= "Z" }
  var isNumber: Bool { self >= "0" && self <= "9" }

  var isLowerGreek: Bool {
    (UTF32Char.lowerGreekStart...UTF32Char.lowerGreekEnd).contains(self.utf32)
  }

  var isCapitalGreek: Bool {
    (UTF32Char.capitalGreekStart...UTF32Char.capitalGreekEnd).contains(self.utf32)
  }

  var greekSymbolOrder: UInt32? {
    let greekSymbols: [UTF32Char] = [0x03F5, 0x03D1, 0x03F0, 0x03D5, 0x03F1, 0x03D6]
    let index = greekSymbols.firstIndex(of: self.utf32)
    if let pos = index { return UInt32(pos) }
    return nil
  }

  var isGreekSymbol: Bool { self.greekSymbolOrder != nil }
}
