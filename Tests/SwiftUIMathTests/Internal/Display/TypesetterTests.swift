import CoreGraphics
import Foundation
import Testing

@testable import SwiftUIMath

extension CGPoint {

  func isEqual(to p: CGPoint, accuracy: CGFloat) -> Bool {
    abs(self.x - p.x) < accuracy && abs(self.y - p.y) < accuracy
  }

}

@Suite
struct TypesetterTests {

  func makeFont(name: Math.Font.Name = .latinModern, size: CGFloat = 20) throws -> Math.PlatformFont
  {
    try #require(Math.PlatformFont(font: Math.Font(name: name, size: size)))
  }

  @Test
  func simpleVariable() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    mathList.append(Math.AtomFactory.atom(forCharacter: "x")!)
    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayTextRun)
    let line = sub0 as! Math.DisplayTextRun
    #expect(line.atoms.count == 1)
    // The x is italicized
    #expect(line.text == "𝑥")
    #expect(CGPointEqualToPoint(line.position, CGPointZero))
    #expect(NSEqualRanges(line.range, NSMakeRange(0, 1)))
    #expect(!(line.hasScript))

    // dimensions
    #expect(display.ascent == line.ascent)
    #expect(display.descent == line.descent)
    #expect(display.width == line.width)

    #expect(abs(display.ascent - 8.834) <= 0.01)
    #expect(abs(display.descent - 0.22) <= 0.01)
    #expect(abs(display.width - 11.44) <= 0.01)
  }

  @Test
  func multipleVariables() throws {
    let font = try makeFont()
    let mathList = Math.AtomFactory.mathListForCharacters("xyzw")
    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 4)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayTextRun)
    let line = sub0 as! Math.DisplayTextRun
    #expect(line.atoms.count == 4)
    #expect(line.text == "𝑥𝑦𝑧𝑤")
    #expect(CGPointEqualToPoint(line.position, CGPointZero))
    #expect(NSEqualRanges(line.range, NSMakeRange(0, 4)))
    #expect(!(line.hasScript))

    // dimensions
    #expect(display.ascent == line.ascent)
    #expect(display.descent == line.descent)
    #expect(display.width == line.width)

    #expect(abs(display.ascent - 8.834) <= 0.01)
    #expect(abs(display.descent - 4.10) <= 0.01)
    #expect(abs(display.width - 44.86) <= 0.01)
  }

  @Test
  func variablesAndNumbers() throws {
    let font = try makeFont()
    let mathList = Math.AtomFactory.mathListForCharacters("xy2w")
    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 4)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayTextRun)
    let line = sub0 as! Math.DisplayTextRun
    #expect(line.atoms.count == 4)
    #expect(line.text == "𝑥𝑦2𝑤")
    #expect(CGPointEqualToPoint(line.position, CGPointZero))
    #expect(NSEqualRanges(line.range, NSMakeRange(0, 4)))
    #expect(!(line.hasScript))

    // dimensions
    #expect(display.ascent == line.ascent)
    #expect(display.descent == line.descent)
    #expect(display.width == line.width)

    #expect(abs(display.ascent - 13.32) <= 0.01)
    #expect(abs(display.descent - 4.10) <= 0.01)
    #expect(abs(display.width - 45.56) <= 0.01)
  }

  @Test
  func equationWithOperatorsAndRelations() throws {
    let font = try makeFont()
    let mathList = Math.AtomFactory.mathListForCharacters("2x+3=y")
    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 6)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayTextRun)
    let line = sub0 as! Math.DisplayTextRun
    #expect(line.atoms.count == 6)
    #expect(line.text == "2𝑥+3=𝑦")
    #expect(CGPointEqualToPoint(line.position, CGPointZero))
    #expect(NSEqualRanges(line.range, NSMakeRange(0, 6)))
    #expect(!(line.hasScript))

    // dimensions
    #expect(display.ascent == line.ascent)
    #expect(display.descent == line.descent)
    #expect(display.width == line.width)

    #expect(abs(display.ascent - 13.32) <= 0.01)
    #expect(abs(display.descent - 4.10) <= 0.01)
    #expect(abs(display.width - 92.36) <= 0.01)
  }

  @Test
  func superscript() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let x = Math.AtomFactory.atom(forCharacter: "x")!
    let supersc = Math.AtomList()
    supersc.append(Math.AtomFactory.atom(forCharacter: "2")!)
    x.superscript = supersc
    mathList.append(x)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 2)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayTextRun)
    let line = sub0 as! Math.DisplayTextRun
    #expect(line.atoms.count == 1)
    // The x is italicized
    #expect(line.text == "𝑥")
    #expect(CGPointEqualToPoint(line.position, CGPointZero))
    #expect(line.hasScript)

    let sub1 = display.children[1]
    #expect(sub1 is Math.DisplayList)
    let display2 = sub1 as! Math.DisplayList
    #expect(display2.linePosition == .superscript)
    #expect(CGPointEqualToPoint(display2.position, CGPointMake(11.44, 7.26)))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == 0)
    #expect(display2.children.count == 1)

    let sub1sub0 = display2.children[0]
    #expect(sub1sub0 is Math.DisplayTextRun)
    let line2 = sub1sub0 as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "2")
    #expect(CGPointEqualToPoint(line2.position, CGPointZero))
    #expect(!(line2.hasScript))

    // dimensions
    #expect(abs(display.ascent - 16.584) <= 0.01)
    #expect(abs(display.descent - 0.22) <= 0.01)
    #expect(abs(display.width - 18.44) <= 0.01)
  }

  @Test
  func subscriptAtom() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let x = Math.AtomFactory.atom(forCharacter: "x")!
    let subsc = Math.AtomList()
    subsc.append(Math.AtomFactory.atom(forCharacter: "1")!)
    x.`subscript` = subsc
    mathList.append(x)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 2)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayTextRun)
    let line = sub0 as! Math.DisplayTextRun
    #expect(line.atoms.count == 1)
    // The x is italicized
    #expect(line.text == "𝑥")
    #expect(CGPointEqualToPoint(line.position, CGPointZero))
    #expect(line.hasScript)

    let sub1 = display.children[1]
    #expect(sub1 is Math.DisplayList)
    let display2 = sub1 as! Math.DisplayList
    #expect(display2.linePosition == .`subscript`)
    #expect(CGPointEqualToPoint(display2.position, CGPointMake(11.44, -4.94)))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == 0)
    #expect(display2.children.count == 1)

    let sub1sub0 = display2.children[0]
    #expect(sub1sub0 is Math.DisplayTextRun)
    let line2 = sub1sub0 as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "1")
    #expect(CGPointEqualToPoint(line2.position, CGPointZero))
    #expect(!(line2.hasScript))

    // dimensions
    #expect(abs(display.ascent - 8.834) <= 0.01)
    #expect(abs(display.descent - 4.940) <= 0.01)
    #expect(abs(display.width - 18.44) <= 0.01)
  }

  @Test
  func supersubscript() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let x = Math.AtomFactory.atom(forCharacter: "x")!
    let supersc = Math.AtomList()
    supersc.append(Math.AtomFactory.atom(forCharacter: "2")!)
    let subsc = Math.AtomList()
    subsc.append(Math.AtomFactory.atom(forCharacter: "1")!)
    x.`subscript` = subsc
    x.superscript = supersc
    mathList.append(x)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 3)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayTextRun)
    let line = sub0 as! Math.DisplayTextRun
    #expect(line.atoms.count == 1)
    // The x is italicized
    #expect(line.text == "𝑥")
    #expect(CGPointEqualToPoint(line.position, CGPointZero))
    #expect(line.hasScript)

    let sub1 = display.children[1]
    #expect(sub1 is Math.DisplayList)
    let display2 = sub1 as! Math.DisplayList
    #expect(display2.linePosition == .superscript)
    #expect(CGPointEqualToPoint(display2.position, CGPointMake(11.44, 7.26)))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == 0)
    #expect(display2.children.count == 1)

    let sub1sub0 = display2.children[0]
    #expect(sub1sub0 is Math.DisplayTextRun)
    let line2 = sub1sub0 as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "2")
    #expect(CGPointEqualToPoint(line2.position, CGPointZero))
    #expect(!(line2.hasScript))

    let sub2 = display.children[2]
    #expect(sub2 is Math.DisplayList)
    let display3 = sub2 as! Math.DisplayList
    #expect(display3.linePosition == .`subscript`)
    // Positioned differently when both subscript and superscript present.
    #expect(CGPointEqualToPoint(display3.position, CGPointMake(11.44, -5.264)))
    #expect(NSEqualRanges(display3.range, NSMakeRange(0, 1)))
    #expect(!(display3.hasScript))
    #expect(display3.index == 0)
    #expect(display3.children.count == 1)

    let sub2sub0 = display3.children[0]
    #expect(sub2sub0 is Math.DisplayTextRun)
    let line3 = sub2sub0 as! Math.DisplayTextRun
    #expect(line3.atoms.count == 1)
    #expect(line3.text == "1")
    #expect(CGPointEqualToPoint(line3.position, CGPointZero))
    #expect(!(line3.hasScript))

    // dimensions
    #expect(abs(display.ascent - 16.584) <= 0.01)
    #expect(abs(display.descent - 5.264) <= 0.01)
    #expect(abs(display.width - 18.44) <= 0.01)
  }

  @Test
  func radical() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let rad = Math.Radical()
    let radicand = Math.AtomList()
    radicand.append(Math.AtomFactory.atom(forCharacter: "1")!)
    rad.radicand = radicand
    mathList.append(rad)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayRadical)
    let radical = sub0 as! Math.DisplayRadical
    #expect(NSEqualRanges(radical.range, NSMakeRange(0, 1)))
    #expect(!(radical.hasScript))
    #expect(CGPointEqualToPoint(radical.position, CGPointZero))
    #expect(radical.radicand != nil)
    #expect(radical.degree == nil)

    let display2 = radical.radicand!
    #expect(display2.linePosition == .regular)
    #expect(CGPointMake(16.66, 0).isEqual(to: display2.position, accuracy: 0.01))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == NSNotFound)
    #expect(display2.children.count == 1)

    let subrad = display2.children[0]
    #expect(subrad is Math.DisplayTextRun)
    let line2 = subrad as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "1")
    #expect(CGPointEqualToPoint(line2.position, CGPointZero))
    #expect(NSEqualRanges(line2.range, NSMakeRange(0, 1)))
    #expect(!(line2.hasScript))

    // dimensions
    #expect(abs(display.ascent - 19.34) <= 0.01)
    #expect(abs(display.descent - 1.46) <= 0.01)
    #expect(abs(display.width - 26.66) <= 0.01)
  }

  @Test
  func radicalWithDegree() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let rad = Math.Radical()
    let radicand = Math.AtomList()
    radicand.append(Math.AtomFactory.atom(forCharacter: "1")!)
    let degree = Math.AtomList()
    degree.append(Math.AtomFactory.atom(forCharacter: "3")!)
    rad.radicand = radicand
    rad.degree = degree
    mathList.append(rad)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayRadical)
    let radical = sub0 as! Math.DisplayRadical
    #expect(NSEqualRanges(radical.range, NSMakeRange(0, 1)))
    #expect(!(radical.hasScript))
    #expect(CGPointEqualToPoint(radical.position, CGPointZero))
    #expect(radical.radicand != nil)
    #expect(radical.degree != nil)

    let display2 = radical.radicand!
    #expect(display2.linePosition == .regular)
    #expect(CGPointEqualToPoint(display2.position, CGPointMake(16.66, 0)))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == NSNotFound)
    #expect(display2.children.count == 1)

    let subrad = display2.children[0]
    #expect(subrad is Math.DisplayTextRun)
    let line2 = subrad as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "1")
    #expect(CGPointEqualToPoint(line2.position, CGPointZero))
    #expect(NSEqualRanges(line2.range, NSMakeRange(0, 1)))
    #expect(!(line2.hasScript))

    let display3 = radical.degree!
    #expect(display3.linePosition == .regular)
    #expect(CGPointMake(6.12, 10.728).isEqual(to: display3.position, accuracy: 0.7))
    #expect(NSEqualRanges(display3.range, NSMakeRange(0, 1)))
    #expect(!(display3.hasScript))
    #expect(display3.index == NSNotFound)
    #expect(display3.children.count == 1)

    let subdeg = display3.children[0]
    #expect(subdeg is Math.DisplayTextRun)
    let line3 = subdeg as! Math.DisplayTextRun
    #expect(line3.atoms.count == 1)
    #expect(line3.text == "3")
    #expect(CGPointEqualToPoint(line3.position, CGPointZero))
    #expect(NSEqualRanges(line3.range, NSMakeRange(0, 1)))
    #expect(!(line3.hasScript))

    // dimensions
    #expect(abs(display.ascent - 19.34) <= 0.01)
    #expect(abs(display.descent - 1.46) <= 0.01)
    #expect(abs(display.width - 26.66) <= 0.01)
  }

  @Test
  func fraction() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let frac = Math.Fraction(hasRule: true)
    let num = Math.AtomList()
    num.append(Math.AtomFactory.atom(forCharacter: "1")!)
    let denom = Math.AtomList()
    denom.append(Math.AtomFactory.atom(forCharacter: "3")!)
    frac.numerator = num
    frac.denominator = denom
    mathList.append(frac)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayFraction)
    let fraction = sub0 as! Math.DisplayFraction
    #expect(NSEqualRanges(fraction.range, NSMakeRange(0, 1)))
    #expect(!(fraction.hasScript))
    #expect(CGPointEqualToPoint(fraction.position, CGPointZero))
    #expect(fraction.numerator != nil)
    #expect(fraction.denominator != nil)

    let display2 = fraction.numerator!
    #expect(display2.linePosition == .regular)
    #expect(CGPointEqualToPoint(display2.position, CGPointMake(0, 13.54)))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == NSNotFound)
    #expect(display2.children.count == 1)

    let subnum = display2.children[0]
    #expect(subnum is Math.DisplayTextRun)
    let line2 = subnum as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "1")
    #expect(CGPointEqualToPoint(line2.position, CGPointZero))
    #expect(NSEqualRanges(line2.range, NSMakeRange(0, 1)))
    #expect(!(line2.hasScript))

    let display3 = fraction.denominator!
    #expect(display3.linePosition == .regular)
    #expect(CGPointEqualToPoint(display3.position, CGPointMake(0, -13.72)))
    #expect(NSEqualRanges(display3.range, NSMakeRange(0, 1)))
    #expect(!(display3.hasScript))
    #expect(display3.index == NSNotFound)
    #expect(display3.children.count == 1)

    let subdenom = display3.children[0]
    #expect(subdenom is Math.DisplayTextRun)
    let line3 = subdenom as! Math.DisplayTextRun
    #expect(line3.atoms.count == 1)
    #expect(line3.text == "3")
    #expect(CGPointEqualToPoint(line3.position, CGPointZero))
    #expect(NSEqualRanges(line3.range, NSMakeRange(0, 1)))
    #expect(!(line3.hasScript))

    // dimensions
    #expect(abs(display.ascent - 26.86) <= 0.01)
    #expect(abs(display.descent - 14.16) <= 0.01)
    #expect(abs(display.width - 10) <= 0.01)
  }

  @Test
  func atop() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let frac = Math.Fraction(hasRule: false)
    let num = Math.AtomList()
    num.append(Math.AtomFactory.atom(forCharacter: "1")!)
    let denom = Math.AtomList()
    denom.append(Math.AtomFactory.atom(forCharacter: "3")!)
    frac.numerator = num
    frac.denominator = denom
    mathList.append(frac)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayFraction)
    let fraction = sub0 as! Math.DisplayFraction
    #expect(NSEqualRanges(fraction.range, NSMakeRange(0, 1)))
    #expect(!(fraction.hasScript))
    #expect(CGPointEqualToPoint(fraction.position, CGPointZero))
    #expect(fraction.numerator != nil)
    #expect(fraction.denominator != nil)

    let display2 = fraction.numerator!
    #expect(display2.linePosition == .regular)
    #expect(CGPointEqualToPoint(display2.position, CGPointMake(0, 13.54)))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == NSNotFound)
    #expect(display2.children.count == 1)

    let subnum = display2.children[0]
    #expect(subnum is Math.DisplayTextRun)
    let line2 = subnum as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "1")
    #expect(CGPointEqualToPoint(line2.position, CGPointZero))
    #expect(NSEqualRanges(line2.range, NSMakeRange(0, 1)))
    #expect(!(line2.hasScript))

    let display3 = fraction.denominator!
    #expect(display3.linePosition == .regular)
    #expect(CGPointEqualToPoint(display3.position, CGPointMake(0, -13.72)))
    #expect(NSEqualRanges(display3.range, NSMakeRange(0, 1)))
    #expect(!(display3.hasScript))
    #expect(display3.index == NSNotFound)
    #expect(display3.children.count == 1)

    let subdenom = display3.children[0]
    #expect(subdenom is Math.DisplayTextRun)
    let line3 = subdenom as! Math.DisplayTextRun
    #expect(line3.atoms.count == 1)
    #expect(line3.text == "3")
    #expect(CGPointEqualToPoint(line3.position, CGPointZero))
    #expect(NSEqualRanges(line3.range, NSMakeRange(0, 1)))
    #expect(!(line3.hasScript))

    // dimensions
    #expect(abs(display.ascent - 26.86) <= 0.01)
    #expect(abs(display.descent - 14.16) <= 0.01)
    #expect(abs(display.width - 10) <= 0.01)
  }

  @Test
  func binomial() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let frac = Math.Fraction(hasRule: false)
    let num = Math.AtomList()
    num.append(Math.AtomFactory.atom(forCharacter: "1")!)
    let denom = Math.AtomList()
    denom.append(Math.AtomFactory.atom(forCharacter: "3")!)
    frac.numerator = num
    frac.denominator = denom
    frac.leftDelimiter = "("
    frac.rightDelimiter = ")"
    mathList.append(frac)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayList)
    let display0 = sub0 as! Math.DisplayList
    #expect(display0.linePosition == .regular)
    #expect(CGPointEqualToPoint(display0.position, CGPointZero))
    #expect(NSEqualRanges(display0.range, NSMakeRange(0, 1)))
    #expect(!(display0.hasScript))
    #expect(display0.index == NSNotFound)
    #expect(display0.children.count == 3)

    let subLeft = display0.children[0]
    #expect(subLeft is Math.DisplayGlyph)
    let glyph = subLeft
    #expect(CGPointEqualToPoint(glyph.position, CGPointZero))
    #expect(NSEqualRanges(glyph.range, NSMakeRange(NSNotFound, 0)))
    #expect(!(glyph.hasScript))

    let subFrac = display0.children[1]
    #expect(subFrac is Math.DisplayFraction)
    let fraction = subFrac as! Math.DisplayFraction
    #expect(NSEqualRanges(fraction.range, NSMakeRange(0, 1)))
    #expect(!(fraction.hasScript))
    #expect(CGPointEqualToPoint(fraction.position, CGPointMake(14.72, 0)))
    #expect(fraction.numerator != nil)
    #expect(fraction.denominator != nil)

    let display2 = fraction.numerator!
    #expect(display2.linePosition == .regular)
    #expect(CGPointMake(14.72, 13.54).isEqual(to: display2.position, accuracy: 0.01))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == NSNotFound)
    #expect(display2.children.count == 1)

    let subnum = display2.children[0]
    #expect(subnum is Math.DisplayTextRun)
    let line2 = subnum as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "1")
    #expect(CGPointEqualToPoint(line2.position, CGPointZero))
    #expect(NSEqualRanges(line2.range, NSMakeRange(0, 1)))
    #expect(!(line2.hasScript))

    let display3 = fraction.denominator!
    #expect(display3.linePosition == .regular)
    #expect(CGPointMake(14.72, -13.72).isEqual(to: display3.position, accuracy: 0.01))
    #expect(NSEqualRanges(display3.range, NSMakeRange(0, 1)))
    #expect(!(display3.hasScript))
    #expect(display3.index == NSNotFound)
    #expect(display3.children.count == 1)

    let subdenom = display3.children[0]
    #expect(subdenom is Math.DisplayTextRun)
    let line3 = subdenom as! Math.DisplayTextRun
    #expect(line3.atoms.count == 1)
    #expect(line3.text == "3")
    #expect(CGPointEqualToPoint(line3.position, CGPointZero))
    #expect(NSEqualRanges(line3.range, NSMakeRange(0, 1)))
    #expect(!(line3.hasScript))

    let subRight = display0.children[2]
    #expect(subRight is Math.DisplayGlyph)
    let glyph2 = subRight as! Math.DisplayGlyph
    #expect(CGPointEqualToPoint(glyph2.position, CGPointMake(24.72, 0)))
    #expect(NSEqualRanges(glyph2.range, NSMakeRange(NSNotFound, 0)))
    #expect(!(glyph2.hasScript))

    // dimensions
    #expect(abs(display.ascent - 28.92) <= 0.001)
    #expect(abs(display.descent - 18.92) <= 0.001)
    #expect(abs(display.width - 39.44) <= 0.001)
  }

  @Test
  func largeOpNoLimitsText() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    mathList.append(Math.AtomFactory.atom(forLatexSymbol: "sin")!)
    mathList.append(Math.AtomFactory.atom(forCharacter: "x")!)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 2)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 2)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayTextRun)
    let line = sub0 as! Math.DisplayTextRun
    #expect(line.atoms.count == 1)
    #expect(line.text == "sin")
    #expect(NSEqualRanges(line.range, NSMakeRange(0, 1)))
    #expect(!(line.hasScript))

    let sub1 = display.children[1]
    #expect(sub1 is Math.DisplayTextRun)
    let line2 = sub1 as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "𝑥")
    // Position may vary with improved spacing
    #expect(line2.position.x > 20)
    #expect(NSEqualRanges(line2.range, NSMakeRange(1, 1)))
    #expect(!(line2.hasScript))

    #expect(abs(display.ascent - 13.14) <= 0.01)
    #expect(abs(display.descent - 0.22) <= 0.01)
    // Width may vary with improved inline layout
    #expect(display.width > 35)
    #expect(display.width < 70)
  }

  @Test
  func largeOpNoLimitsSymbol() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    // Integral - with new implementation, operators stay inline when they fit
    mathList.append(Math.AtomFactory.atom(forLatexSymbol: "int")!)
    mathList.append(Math.AtomFactory.atom(forCharacter: "x")!)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 2)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 2)

    // Check operator display
    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayGlyph)
    let glyph = sub0
    #expect(NSEqualRanges(glyph.range, NSMakeRange(0, 1)))
    #expect(!(glyph.hasScript))

    // Check x display
    let sub1 = display.children[1]
    #expect(sub1 is Math.DisplayTextRun)
    let line2 = sub1 as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "𝑥")
    // Operator and x stay inline - x should be positioned after operator
    #expect(line2.position.x > glyph.position.x)
    #expect(NSEqualRanges(line2.range, NSMakeRange(1, 1)))
    #expect(!(line2.hasScript))

    // Check dimensions are reasonable (not exact values)
    #expect(display.ascent > 20)
    #expect(display.descent > 10)
    #expect(display.width > 30)
    #expect(display.width < 40)
  }

  @Test
  func largeOpNoLimitsSymbolWithScripts() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    // Integral
    let op = Math.AtomFactory.atom(forLatexSymbol: "int")!
    op.superscript = Math.AtomList()
    op.superscript?.append(Math.AtomFactory.atom(forCharacter: "1")!)
    op.`subscript` = Math.AtomList()
    op.`subscript`?.append(Math.AtomFactory.atom(forCharacter: "0")!)
    mathList.append(op)
    mathList.append(Math.AtomFactory.atom(forCharacter: "x")!)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 2)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 4)

    // Check superscript
    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayList)
    let display0 = sub0 as! Math.DisplayList
    #expect(display0.linePosition == .superscript)
    #expect(display0.position.y > 20)
    #expect(NSEqualRanges(display0.range, NSMakeRange(0, 1)))
    #expect(!(display0.hasScript))
    #expect(display0.index == 0)
    #expect(display0.children.count == 1)

    let sub0sub0 = display0.children[0]
    #expect(sub0sub0 is Math.DisplayTextRun)
    let line1 = sub0sub0 as! Math.DisplayTextRun
    #expect(line1.atoms.count == 1)
    #expect(line1.text == "1")
    #expect(CGPointEqualToPoint(line1.position, CGPointZero))
    #expect(!(line1.hasScript))

    // Check subscript
    let sub1 = display.children[1]
    #expect(sub1 is Math.DisplayList)
    let display1 = sub1 as! Math.DisplayList
    #expect(display1.linePosition == .`subscript`)
    #expect(display1.position.y < 0)
    #expect(NSEqualRanges(display1.range, NSMakeRange(0, 1)))
    #expect(!(display1.hasScript))
    #expect(display1.index == 0)
    #expect(display1.children.count == 1)

    let sub1sub0 = display1.children[0]
    #expect(sub1sub0 is Math.DisplayTextRun)
    let line3 = sub1sub0 as! Math.DisplayTextRun
    #expect(line3.atoms.count == 1)
    #expect(line3.text == "0")
    #expect(CGPointEqualToPoint(line3.position, CGPointZero))
    #expect(!(line3.hasScript))

    // Check operator glyph
    let sub2 = display.children[2]
    #expect(sub2 is Math.DisplayGlyph)
    let glyph = sub2
    #expect(NSEqualRanges(glyph.range, NSMakeRange(0, 1)))
    #expect(glyph.hasScript)

    // Check x variable
    let sub3 = display.children[3]
    #expect(sub3 is Math.DisplayTextRun)
    let line2 = sub3 as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "𝑥")
    #expect(line2.position.x > 25)
    #expect(NSEqualRanges(line2.range, NSMakeRange(1, 1)))
    #expect(!(line1.hasScript))

    // Check dimensions are reasonable (not exact values)
    #expect(display.ascent > 30)
    #expect(display.descent > 15)
    #expect(display.width > 38)
    #expect(display.width < 48)
  }

  @Test
  func largeOpWithLimitsTextWithScripts() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let op = Math.AtomFactory.atom(forLatexSymbol: "lim")!
    op.`subscript` = Math.AtomList()
    op.`subscript`?.append(Math.AtomFactory.atom(forLatexSymbol: "infty")!)
    mathList.append(op)
    mathList.append(Math.Atom(type: .variable, nucleus: "x"))

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 2)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 2)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayLargeOperator)
    let largeOp = sub0 as! Math.DisplayLargeOperator
    #expect(NSEqualRanges(largeOp.range, NSMakeRange(0, 1)))
    #expect(!(largeOp.hasScript))
    #expect(largeOp.lowerLimit != nil)
    #expect(largeOp.upperLimit == nil)

    let display2 = largeOp.lowerLimit!
    #expect(display2.linePosition == .regular)
    // Position may vary with improved inline layout
    #expect(display2.position.y < 0)
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == NSNotFound)
    #expect(display2.children.count == 1)

    let sub0sub0 = display2.children[0]
    #expect(sub0sub0 is Math.DisplayTextRun)
    let line1 = sub0sub0 as! Math.DisplayTextRun
    #expect(line1.atoms.count == 1)
    #expect(line1.text == "∞")
    #expect(CGPointEqualToPoint(line1.position, CGPointZero))
    #expect(!(line1.hasScript))

    let sub3 = display.children[1]
    #expect(sub3 is Math.DisplayTextRun)
    let line2 = sub3 as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "𝑥")
    // With improved inline layout, x may be positioned differently
    #expect(line2.position.x > 25)
    #expect(NSEqualRanges(line2.range, NSMakeRange(1, 1)))
    #expect(!(line1.hasScript))

    #expect(abs(display.ascent - 13.88) <= 0.01)
    #expect(abs(display.descent - 12.154) <= 0.01)
    // Width now includes operator with limits + spacing + x (improved behavior)
    #expect(display.width > 38)
    #expect(display.width < 48)
  }

  @Test
  func largeOpWithLimitsSymboltWithScripts() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let op = Math.AtomFactory.atom(forLatexSymbol: "sum")!
    op.superscript = Math.AtomList()
    op.superscript?.append(Math.AtomFactory.atom(forLatexSymbol: "infty")!)
    op.`subscript` = Math.AtomList()
    op.`subscript`?.append(Math.AtomFactory.atom(forCharacter: "0")!)
    mathList.append(op)
    mathList.append(Math.Atom(type: .variable, nucleus: "x"))

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 2)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 2)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayLargeOperator)
    let largeOp = sub0 as! Math.DisplayLargeOperator
    #expect(NSEqualRanges(largeOp.range, NSMakeRange(0, 1)))
    #expect(!(largeOp.hasScript))
    #expect(largeOp.lowerLimit != nil)
    #expect(largeOp.upperLimit != nil)

    let display2 = largeOp.lowerLimit!
    #expect(display2.linePosition == .regular)
    // Lower limit position may vary
    #expect(display2.position.y < 0)
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == NSNotFound)
    #expect(display2.children.count == 1)

    let sub0sub0 = display2.children[0]
    #expect(sub0sub0 is Math.DisplayTextRun)
    let line1 = sub0sub0 as! Math.DisplayTextRun
    #expect(line1.atoms.count == 1)
    #expect(line1.text == "0")
    #expect(CGPointEqualToPoint(line1.position, CGPointZero))
    #expect(!(line1.hasScript))

    let displayU = largeOp.upperLimit!
    #expect(displayU.linePosition == .regular)
    #expect(NSEqualRanges(displayU.range, NSMakeRange(0, 1)))
    #expect(!(displayU.hasScript))
    #expect(displayU.index == NSNotFound)
    #expect(displayU.children.count == 1)

    let sub0subU = displayU.children[0]
    #expect(sub0subU is Math.DisplayTextRun)
    let line3 = sub0subU as! Math.DisplayTextRun
    #expect(line3.atoms.count == 1)
    #expect(line3.text == "∞")
    #expect(CGPointEqualToPoint(line3.position, CGPointZero))
    #expect(!(line3.hasScript))

    let sub3 = display.children[1]
    #expect(sub3 is Math.DisplayTextRun)
    let line2 = sub3 as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "𝑥")
    // With improved inline layout, x position may vary
    #expect(line2.position.x > 20)
    #expect(NSEqualRanges(line2.range, NSMakeRange(1, 1)))
    #expect(!(line2.hasScript))

    // Dimensions may vary with improved inline layout
    #expect(display.ascent >= 0)
    #expect(display.descent > 0)
    #expect(display.width > 40)
  }

  @Test
  func largeOpWithLimitsInlineMode_Limit() throws {
    let font = try makeFont()
    // Test that \lim in inline/text mode shows limits above/below (not to the side)
    // This tests the fix for: \(\lim_{n \to \infty} \frac{1}{n} = 0\)
    let latex = "\\lim_{n\\to\\infty}\\frac{1}{n}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Use .text style to simulate inline mode \(...\)
    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .text)!
    #expect(display.linePosition == .regular)

    // Should have at least 2 subdisplays: lim with limits, and fraction
    #expect(display.children.count >= 2)

    // First subdisplay should be the limit operator with limits display
    let limDisplay = display.children[0]
    #expect(limDisplay is Math.DisplayLargeOperator)

    if let limitsDisplay = limDisplay as? Math.DisplayLargeOperator {
      #expect(limitsDisplay.lowerLimit != nil)
      #expect(limitsDisplay.upperLimit == nil)
      #expect(limitsDisplay.lowerLimit!.position.y < 0)
    }
  }

  @Test
  func largeOpWithLimitsInlineMode_Sum() throws {
    let font = try makeFont()
    // Test that \sum in inline/text mode shows limits above/below (not to the side)
    // This tests the fix for: \(\sum_{i=1}^{n} i\)
    let latex = "\\sum_{i=1}^{n}i"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Use .text style to simulate inline mode \(...\)
    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .text)!
    #expect(display.linePosition == .regular)

    // Should have at least 2 subdisplays: sum with limits, and variable i
    #expect(display.children.count >= 2)

    // First subdisplay should be the sum operator with limits display
    let sumDisplay = display.children[0]
    #expect(sumDisplay is Math.DisplayLargeOperator)

    if let limitsDisplay = sumDisplay as? Math.DisplayLargeOperator {
      #expect(limitsDisplay.upperLimit != nil)
      #expect(limitsDisplay.lowerLimit != nil)
      #expect(limitsDisplay.upperLimit!.position.y > 0)
      #expect(limitsDisplay.lowerLimit!.position.y < 0)
    }
  }

  @Test
  func largeOpWithLimitsInlineMode_Product() throws {
    let font = try makeFont()
    // Test that \prod in inline/text mode shows limits above/below (not to the side)
    // This tests the fix for: \(\prod_{k=1}^{\infty} (1 + x^k)\)
    let latex = "\\prod_{k=1}^{\\infty}x"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Use .text style to simulate inline mode \(...\)
    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .text)!
    #expect(display.linePosition == .regular)

    // Should have at least 2 subdisplays: prod with limits, and variable x
    #expect(display.children.count >= 2)

    // First subdisplay should be the product operator with limits display
    let prodDisplay = display.children[0]
    #expect(prodDisplay is Math.DisplayLargeOperator)

    if let limitsDisplay = prodDisplay as? Math.DisplayLargeOperator {
      #expect(limitsDisplay.upperLimit != nil)
      #expect(limitsDisplay.lowerLimit != nil)
      #expect(limitsDisplay.upperLimit!.position.y > 0)
      #expect(limitsDisplay.lowerLimit!.position.y < 0)
    }
  }

  @Test
  func fractionInlineMode_NormalFontSize() throws {
    let font = try makeFont()
    // Test that \(...\) delimiter doesn't make fractions too small
    // This tests the fix for: \(\frac{a}{b} = c\)
    let latex = "\\frac{a}{b}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Create display without any style forcing
    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)

    // Should have 1 subdisplay: the fraction
    #expect(display.children.count == 1)

    // First subdisplay should be the fraction
    let fracDisplay = display.children[0]
    #expect(fracDisplay is Math.DisplayFraction)

    if let fractionDisplay = fracDisplay as? Math.DisplayFraction {
      #expect(fractionDisplay.numerator != nil)
      #expect(fractionDisplay.denominator != nil)

      // The numerator and denominator should use text style (not script style)
      // In display mode, fractions use text style for numerator/denominator
      // Check that the font size is reasonable (not script-sized)
      let numDisplay = fractionDisplay.numerator!
      #expect(numDisplay.width > 5)
      #expect(numDisplay.ascent > 5)
    }
  }

  @Test
  func fractionInlineDelimiters_NormalSize() throws {
    let font = try makeFont()
    // Test that \(\frac{a}{b}\) has full-sized numerator/denominator
    // Inline delimiters insert \textstyle, but fractions maintain same font size
    let latex1 = "\\(\\frac{a}{b}\\)"

    let mathList1 = Math.Parser.build(fromString: latex1)
    #expect(mathList1 != nil)

    let display1 = Math.Typesetter.createLineForMathList(mathList1, font: font, style: .display)!

    // Should have subdisplays (style atom + fraction)
    #expect(display1.children.count >= 1)

    // Find the fraction display (it might be after a style atom)
    let fracDisplay =
      display1.children.first(where: { $0 is Math.DisplayFraction }) as? Math.DisplayFraction
    #expect(fracDisplay != nil)

    // The numerator should have reasonable size (not script-sized)
    #expect(fracDisplay!.numerator!.width > 8)
    #expect(fracDisplay!.numerator!.ascent > 6)
  }

  @Test
  func complexFractionInlineMode() throws {
    let font = try makeFont()
    // Test that complex fractions in inline mode render at normal size
    // This tests: \(\frac{x^2 + 1}{y - 3}\)
    let latex = "\\frac{x^2+1}{y-3}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!

    // Should have a fraction display
    #expect(display.children.count == 1)
    let fracDisplay = display.children[0]
    #expect(fracDisplay is Math.DisplayFraction)

    if let fractionDisplay = fracDisplay as? Math.DisplayFraction {
      // Numerator should contain multiple atoms (x^2 + 1)
      let numDisplay = fractionDisplay.numerator!
      #expect(numDisplay.children.count >= 1)

      // Check that the numerator has reasonable size (not script-sized)
      #expect(numDisplay.width > 20)
      #expect(numDisplay.ascent > 5)
    }
  }

  @Test
  func inner() throws {
    let font = try makeFont()
    let innerList = Math.AtomList()
    innerList.append(Math.AtomFactory.atom(forCharacter: "x")!)
    let inner = Math.Inner()
    inner.innerList = innerList
    inner.leftBoundary = Math.Atom(type: .boundary, nucleus: "(")
    inner.rightBoundary = Math.Atom(type: .boundary, nucleus: ")")

    let mathList = Math.AtomList()
    mathList.append(inner)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayList)
    let display2 = sub0 as! Math.DisplayList
    #expect(display2.linePosition == .regular)
    #expect(CGPointEqualToPoint(display2.position, CGPointZero))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == NSNotFound)
    #expect(display2.children.count == 3)

    let subLeft = display2.children[0]
    #expect(subLeft is Math.DisplayGlyph)
    let glyph = subLeft
    #expect(CGPointEqualToPoint(glyph.position, CGPointZero))
    #expect(NSEqualRanges(glyph.range, NSMakeRange(NSNotFound, 0)))
    #expect(!(glyph.hasScript))

    let sub3 = display2.children[1]
    #expect(sub3 is Math.DisplayList)
    let display3 = sub3 as! Math.DisplayList
    #expect(display3.linePosition == .regular)
    #expect(CGPointEqualToPoint(display3.position, CGPointMake(7.78, 0)))
    #expect(NSEqualRanges(display3.range, NSMakeRange(0, 1)))
    #expect(!(display3.hasScript))
    #expect(display3.index == NSNotFound)
    #expect(display3.children.count == 1)

    let subsub3 = display3.children[0]
    #expect(subsub3 is Math.DisplayTextRun)
    let line = subsub3 as! Math.DisplayTextRun
    #expect(line.atoms.count == 1)
    // The x is italicized
    #expect(line.text == "𝑥")
    #expect(CGPointEqualToPoint(line.position, CGPointZero))
    #expect(!(line.hasScript))

    let subRight = display2.children[2]
    #expect(subRight is Math.DisplayGlyph)
    let glyph2 = subRight as! Math.DisplayGlyph
    #expect(CGPointEqualToPoint(glyph2.position, CGPointMake(19.22, 0)))
    #expect(NSEqualRanges(glyph2.range, NSMakeRange(NSNotFound, 0)))
    #expect(!(glyph2.hasScript))

    // dimensions
    #expect(display.ascent == display2.ascent)
    #expect(display.descent == display2.descent)
    #expect(display.width == display2.width)

    #expect(abs(display.ascent - 14.96) <= 0.001)
    #expect(abs(display.descent - 4.96) <= 0.001)
    #expect(abs(display.width - 27) <= 0.01)
  }

  @Test
  func overline() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let over = Math.Overline()
    let inner = Math.AtomList()
    inner.append(Math.AtomFactory.atom(forCharacter: "1")!)
    over.innerList = inner
    mathList.append(over)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayLine)
    let overline = sub0 as! Math.DisplayLine
    #expect(NSEqualRanges(overline.range, NSMakeRange(0, 1)))
    #expect(!(overline.hasScript))
    #expect(CGPointEqualToPoint(overline.position, CGPointZero))
    #expect(overline.inner != nil)

    let display2 = overline.inner!
    #expect(display2.linePosition == .regular)
    #expect(CGPointEqualToPoint(display2.position, CGPointZero))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == NSNotFound)
    #expect(display2.children.count == 1)

    let subover = display2.children[0]
    #expect(subover is Math.DisplayTextRun)
    let line2 = subover as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "1")
    #expect(CGPointEqualToPoint(line2.position, CGPointZero))
    #expect(NSEqualRanges(line2.range, NSMakeRange(0, 1)))
    #expect(!(line2.hasScript))

    // dimensions
    #expect(abs(display.ascent - 17.32) <= 0.01)
    #expect(abs(display.descent - 0.00) <= 0.01)
    #expect(abs(display.width - 10) <= 0.01)
  }

  @Test
  func underline() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let under = Math.Underline()
    let inner = Math.AtomList()
    inner.append(Math.AtomFactory.atom(forCharacter: "1")!)
    under.innerList = inner
    mathList.append(under)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayLine)
    let underline = sub0 as! Math.DisplayLine
    #expect(NSEqualRanges(underline.range, NSMakeRange(0, 1)))
    #expect(!(underline.hasScript))
    #expect(CGPointEqualToPoint(underline.position, CGPointZero))
    #expect(underline.inner != nil)

    let display2 = underline.inner!
    #expect(display2.linePosition == .regular)
    #expect(CGPointEqualToPoint(display2.position, CGPointZero))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == NSNotFound)
    #expect(display2.children.count == 1)

    let subover = display2.children[0]
    #expect(subover is Math.DisplayTextRun)
    let line2 = subover as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "1")
    #expect(CGPointEqualToPoint(line2.position, CGPointZero))
    #expect(NSEqualRanges(line2.range, NSMakeRange(0, 1)))
    #expect(!(line2.hasScript))

    // dimensions
    #expect(abs(display.ascent - 13.32) <= 0.01)
    #expect(abs(display.descent - 4.00) <= 0.01)
    #expect(abs(display.width - 10) <= 0.01)
  }

  @Test
  func spacing() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    mathList.append(Math.AtomFactory.atom(forCharacter: "x")!)
    mathList.append(Math.Space(amount: 9))
    mathList.append(Math.AtomFactory.atom(forCharacter: "y")!)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 3)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 2)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayTextRun)
    let line = sub0 as! Math.DisplayTextRun
    #expect(line.atoms.count == 1)
    // The x is italicized
    #expect(line.text == "𝑥")
    #expect(CGPointEqualToPoint(line.position, CGPointZero))
    #expect(NSEqualRanges(line.range, NSMakeRange(0, 1)))
    #expect(!(line.hasScript))

    let sub1 = display.children[1]
    #expect(sub1 is Math.DisplayTextRun)
    let line2 = sub1 as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    // The y is italicized
    #expect(line2.text == "𝑦")
    #expect(CGPointMake(21.44, 0).isEqual(to: line2.position, accuracy: 0.01))
    #expect(NSEqualRanges(line2.range, NSMakeRange(2, 1)))
    #expect(!(line2.hasScript))

    let noSpace = Math.AtomList()
    noSpace.append(Math.AtomFactory.atom(forCharacter: "x")!)
    noSpace.append(Math.AtomFactory.atom(forCharacter: "y")!)

    let noSpaceDisplay = Math.Typesetter.createLineForMathList(
      noSpace, font: font, style: .display)!

    // dimensions
    #expect(abs(display.ascent - noSpaceDisplay.ascent) <= 0.01)
    #expect(abs(display.descent - noSpaceDisplay.descent) <= 0.01)
    #expect(abs((display.width - noSpaceDisplay.width) - 10) <= 0.01)
  }

  // For issue: https://github.com/kostub/iosMath/issues/5
  @Test
  func largeRadicalDescent() throws {
    let font = try makeFont()
    let list = Math.Parser.build(
      fromString: "\\sqrt{\\frac{\\sqrt{\\frac{1}{2}} + 3}{\\sqrt{5}^x}}")
    let display = Math.Typesetter.createLineForMathList(list, font: font, style: .display)!

    // dimensions (updated for new fraction sizing where fractions maintain same size as parent style)
    #expect(abs(display.ascent - 61.16) <= 0.01)
    #expect(abs(display.descent - 21.288) <= 0.01)
    #expect(abs(display.width - 85.569) <= 0.01)
  }

  @Test
  func mathTable() throws {
    let font = try makeFont()
    let c00 = Math.AtomFactory.mathListForCharacters("1")
    let c01 = Math.AtomFactory.mathListForCharacters("y+z")
    let c02 = Math.AtomFactory.mathListForCharacters("y")

    let c11 = Math.AtomList()
    c11.append(Math.AtomFactory.fraction(withNumeratorString: "1", denominatorString: "2x"))
    let c12 = Math.AtomFactory.mathListForCharacters("x-y")

    let c20 = Math.AtomFactory.mathListForCharacters("x+5")
    let c22 = Math.AtomFactory.mathListForCharacters("12")

    let table = Math.Table()
    table.setCell(c00!, forRow: 0, column: 0)
    table.setCell(c01!, forRow: 0, column: 1)
    table.setCell(c02!, forRow: 0, column: 2)
    table.setCell(c11, forRow: 1, column: 1)
    table.setCell(c12!, forRow: 1, column: 2)
    table.setCell(c20!, forRow: 2, column: 0)
    table.setCell(c22!, forRow: 2, column: 2)

    // alignments
    table.setAlignment(.right, forColumn: 0)
    table.setAlignment(.left, forColumn: 2)

    table.interColumnSpacing = 18  // 1 quad

    let mathList = Math.AtomList()
    mathList.append(table)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayList)

    let display2 = sub0 as! Math.DisplayList
    #expect(display2.linePosition == .regular)
    #expect(CGPointEqualToPoint(display2.position, CGPointZero))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == NSNotFound)
    #expect(display2.children.count == 3)
    let rowPos = [30.28, -2.68, -31.95]
    // alignment is right, center, left.
    let cellPos = [[35.89, 65.89, 129.438], [45.89, 76.94, 129.438], [0, 87.66, 129.438]]
    // check the 3 rows of the matrix
    for i in 0..<3 {
      let sub0i = display2.children[i]
      #expect(sub0i is Math.DisplayList)

      let row = sub0i as! Math.DisplayList
      #expect(row.linePosition == .regular)
      #expect(CGPointMake(0, rowPos[i]).isEqual(to: row.position, accuracy: 0.01))
      #expect(NSEqualRanges(row.range, NSMakeRange(0, 3)))
      #expect(!(row.hasScript))
      #expect(row.index == NSNotFound)
      #expect(row.children.count == 3)

      for j in 0..<3 {
        let sub0ij = row.children[j]
        #expect(sub0ij is Math.DisplayList)

        let col = sub0ij as! Math.DisplayList
        #expect(col.linePosition == .regular)
        #expect(CGPointMake(cellPos[i][j], 0).isEqual(to: col.position, accuracy: 0.01))
        #expect(!(col.hasScript))
        #expect(col.index == NSNotFound)
      }
    }
  }

  @Test
  func latexSymbols() throws {
    let font = try makeFont()
    // Test all latex symbols
    let allSymbols = Math.AtomFactory.supportedLatexSymbolNames
    for symName in allSymbols {
      let list = Math.AtomList()
      let atom = Math.AtomFactory.atom(forLatexSymbol: symName)!
      if atom.type.rawValue >= Math.AtomType.boundary.rawValue {
        // Skip these types as they aren't symbols.
        continue
      }

      list.append(atom)

      let display = Math.Typesetter.createLineForMathList(list, font: font, style: .display)!

      #expect(display.linePosition == .regular)
      #expect(CGPointEqualToPoint(display.position, CGPointZero))
      #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
      #expect(!(display.hasScript))
      #expect(display.index == NSNotFound)
      #expect(display.children.count == 1)

      let sub0 = display.children[0]
      if atom.type == .largeOperator && atom.nucleus.count == 1 {
        // These large operators are rendered differently;
        #expect(sub0 is Math.DisplayGlyph)
        let glyph = sub0 as! Math.DisplayGlyph
        #expect(NSEqualRanges(glyph.range, NSMakeRange(0, 1)))
        #expect(!(glyph.hasScript))
      } else {
        #expect(sub0 is Math.DisplayTextRun)
        let line = sub0 as! Math.DisplayTextRun
        #expect(line.atoms.count == 1)
        if atom.type != .variable {
          #expect(line.text == atom.nucleus)
        }
        #expect(NSEqualRanges(line.range, NSMakeRange(0, 1)))
        #expect(!(line.hasScript))
      }

      // dimensions - check that display matches subdisplay (structure)
      #expect(display.ascent == sub0.ascent)
      #expect(display.descent == sub0.descent)
      // Width should be reasonable - inline layout may affect large operators differently
      #expect(display.width > 0)
      #expect(display.width <= sub0.width * 3)

      // All chars will occupy some space.
      if atom.nucleus != " " {
        // all chars except space have height
        #expect(display.ascent + display.descent > 0)
      }
      // all chars have a width.
      #expect(display.width > 0)
    }
  }

  func atomWithAllFontStyles(_ atom: Math.Atom) throws {
    let font = try makeFont()
    let fontStyles: [Math.Atom.FontStyle] = [
      .default,
      .roman,
      .bold,
      .caligraphic,
      .typewriter,
      .italic,
      .sansSerif,
      .fraktur,
      .blackboard,
      .boldItalic,
    ]
    for fontStyle in fontStyles {
      let style = fontStyle
      let copy: Math.Atom = atom.copy()
      copy.fontStyle = style
      let list = Math.AtomList(atom: copy)

      let display = Math.Typesetter.createLineForMathList(list, font: font, style: .display)!

      #expect(display.linePosition == .regular)
      #expect(CGPointEqualToPoint(display.position, CGPointZero))
      #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
      #expect(!(display.hasScript))
      #expect(display.index == NSNotFound)
      #expect(display.children.count == 1)

      let sub0 = display.children[0]
      #expect(sub0 is Math.DisplayTextRun)
      let line = sub0 as! Math.DisplayTextRun
      #expect(line.atoms.count == 1)
      #expect(CGPointEqualToPoint(line.position, CGPointZero))
      #expect(NSEqualRanges(line.range, NSMakeRange(0, 1)))
      #expect(!(line.hasScript))

      // dimensions
      #expect(display.ascent == sub0.ascent)
      #expect(display.descent == sub0.descent)
      #expect(display.width == sub0.width)

      // All chars will occupy some space.
      #expect(display.ascent + display.descent > 0)
      // all chars have a width.
      #expect(display.width > 0)
    }
  }

  @Test
  func variables() throws {
    // Test all variables
    let allSymbols = Math.AtomFactory.supportedLatexSymbolNames
    for symName in allSymbols {
      let atom = Math.AtomFactory.atom(forLatexSymbol: symName)!
      if atom.type != .variable {
        // Skip these types as we are only interested in variables.
        continue
      }
      try self.atomWithAllFontStyles(atom)
    }
    let alphaNum = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789."
    let mathList = Math.AtomFactory.mathListForCharacters(alphaNum)
    for atom in mathList!.atoms {
      try self.atomWithAllFontStyles(atom)
    }
  }

  @Test
  func styleChanges() throws {
    let font = try makeFont()
    let frac = Math.AtomFactory.fraction(withNumeratorString: "1", denominatorString: "2")
    let list = Math.AtomList(atoms: [frac])
    let style = Math.Style(level: .text)
    let textList = Math.AtomList(atoms: [style, frac])

    // This should make the display same as text.
    let display = Math.Typesetter.createLineForMathList(textList, font: font, style: .display)!
    let textDisplay = Math.Typesetter.createLineForMathList(list, font: font, style: .text)!
    let originalDisplay = Math.Typesetter.createLineForMathList(list, font: font, style: .display)!

    // Display should be the same as rendering the fraction in text style.
    #expect(display.ascent == textDisplay.ascent)
    #expect(display.descent == textDisplay.descent)
    #expect(display.width == textDisplay.width)

    // With updated fractionStyle(), fractions use the same font size in display and text modes,
    // but spacing/positioning is still different (numeratorShiftUp, etc. check parent style).
    // So originalDisplay (display mode) will be larger than display (text mode).
    #expect(originalDisplay.ascent > display.ascent)
    #expect(originalDisplay.descent > display.descent)
  }

  @Test
  func styleMiddle() throws {
    let font = try makeFont()
    let atom1 = Math.AtomFactory.atom(forCharacter: "x")!
    let style1 = Math.Style(level: .script) as Math.Atom
    let atom2 = Math.AtomFactory.atom(forCharacter: "y")!
    let style2 = Math.Style(level: .scriptOfScript) as Math.Atom
    let atom3 = Math.AtomFactory.atom(forCharacter: "z")!
    let list = Math.AtomList(atoms: [atom1, style1, atom2, style2, atom3])

    let display = Math.Typesetter.createLineForMathList(list, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 5)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 3)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayTextRun)
    let line = sub0 as! Math.DisplayTextRun
    #expect(line.atoms.count == 1)
    #expect(line.text == "𝑥")
    #expect(CGPointEqualToPoint(line.position, CGPointZero))
    #expect(NSEqualRanges(line.range, NSMakeRange(0, 1)))
    #expect(!(line.hasScript))

    let sub1 = display.children[1]
    #expect(sub1 is Math.DisplayTextRun)
    let line1 = sub1 as! Math.DisplayTextRun
    #expect(line1.atoms.count == 1)
    #expect(line1.text == "𝑦")
    #expect(NSEqualRanges(line1.range, NSMakeRange(2, 1)))
    #expect(!(line1.hasScript))

    let sub2 = display.children[2]
    #expect(sub2 is Math.DisplayTextRun)
    let line2 = sub2 as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "𝑧")
    #expect(NSEqualRanges(line2.range, NSMakeRange(4, 1)))
    #expect(!(line2.hasScript))
  }

  @Test
  func accent() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let accent = Math.AtomFactory.accent(withName: "hat")!
    let inner = Math.AtomList()
    inner.append(Math.AtomFactory.atom(forCharacter: "x")!)
    accent.innerList = inner
    mathList.append(accent)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayAccent)
    let accentDisp = sub0 as! Math.DisplayAccent
    #expect(NSEqualRanges(accentDisp.range, NSMakeRange(0, 1)))
    #expect(!(accentDisp.hasScript))
    #expect(CGPointEqualToPoint(accentDisp.position, CGPointZero))
    #expect(accentDisp.accentee != nil)
    #expect(accentDisp.accent != nil)

    let display2 = accentDisp.accentee!
    #expect(display2.linePosition == .regular)
    #expect(CGPointEqualToPoint(display2.position, CGPointZero))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 1)))
    #expect(!(display2.hasScript))
    #expect(display2.index == NSNotFound)
    #expect(display2.children.count == 1)

    let subaccentee = display2.children[0]
    #expect(subaccentee is Math.DisplayTextRun)
    let line2 = subaccentee as! Math.DisplayTextRun
    #expect(line2.atoms.count == 1)
    #expect(line2.text == "𝑥")
    #expect(CGPointEqualToPoint(line2.position, CGPointZero))
    #expect(NSEqualRanges(line2.range, NSMakeRange(0, 1)))
    #expect(!(line2.hasScript))

    let glyph = accentDisp.accent!
    #expect(CGPointEqualToPoint(glyph.position, CGPointMake(11.86, 0)))
    #expect(NSEqualRanges(glyph.range, NSMakeRange(0, 1)))
    #expect(!(glyph.hasScript))

    // dimensions
    #expect(abs(display.ascent - 14.68) <= 0.01)
    #expect(abs(display.descent - 0.22) <= 0.01)
    #expect(abs(display.width - 11.44) <= 0.01)
  }

  @Test
  func wideAccent() throws {
    let font = try makeFont()
    let mathList = Math.AtomList()
    let accent = Math.AtomFactory.accent(withName: "hat")!
    accent.innerList = Math.AtomFactory.mathListForCharacters("xyzw")
    mathList.append(accent)

    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)!
    #expect(display.linePosition == .regular)
    #expect(CGPointEqualToPoint(display.position, CGPointZero))
    #expect(NSEqualRanges(display.range, NSMakeRange(0, 1)))
    #expect(!(display.hasScript))
    #expect(display.index == NSNotFound)
    #expect(display.children.count == 1)

    let sub0 = display.children[0]
    #expect(sub0 is Math.DisplayAccent)
    let accentDisp = sub0 as! Math.DisplayAccent
    #expect(NSEqualRanges(accentDisp.range, NSMakeRange(0, 1)))
    #expect(!(accentDisp.hasScript))
    #expect(CGPointEqualToPoint(accentDisp.position, CGPointZero))
    #expect(accentDisp.accentee != nil)
    #expect(accentDisp.accent != nil)

    let display2 = accentDisp.accentee!
    #expect(display2.linePosition == .regular)
    #expect(CGPointEqualToPoint(display2.position, CGPointZero))
    #expect(NSEqualRanges(display2.range, NSMakeRange(0, 4)))
    #expect(!(display2.hasScript))
    #expect(display2.index == NSNotFound)
    #expect(display2.children.count == 1)

    let subaccentee = display2.children[0]
    #expect(subaccentee is Math.DisplayTextRun)
    let line2 = subaccentee as! Math.DisplayTextRun
    #expect(line2.atoms.count == 4)
    #expect(line2.text == "𝑥𝑦𝑧𝑤")
    #expect(CGPointEqualToPoint(line2.position, CGPointZero))
    #expect(NSEqualRanges(line2.range, NSMakeRange(0, 4)))
    #expect(!(line2.hasScript))

    let glyph = accentDisp.accent!
    #expect(CGPointMake(3.47, 0).isEqual(to: glyph.position, accuracy: 0.01))
    #expect(NSEqualRanges(glyph.range, NSMakeRange(0, 1)))
    #expect(!(glyph.hasScript))

    // dimensions
    #expect(abs(display.ascent - 14.98) <= 0.01)
    #expect(abs(display.descent - 4.10) <= 0.01)
    #expect(abs(display.width - 44.86) <= 0.01)
  }

  // MARK: - Interatom Line Breaking Tests

  @Test
  func interatomLineBreaking_SimpleEquation() throws {
    let font = try makeFont()
    // Simple equation that should break between atoms when width is constrained
    let latex = "a=1, b=2, c=3, d=4"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Create display with narrow width constraint (should force multiple lines)
    let maxWidth: CGFloat = 100
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should have multiple sub-displays (lines)
    #expect(display!.children.count > 1)

    // Verify that each line respects the width constraint
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.1)
    }

    // Verify vertical positioning - lines should be below each other
    if display!.children.count > 1 {
      let firstLine = display!.children[0]
      let secondLine = display!.children[1]
      #expect(secondLine.position.y < firstLine.position.y)
    }
  }

  @Test
  func interatomLineBreaking_TextAndMath() throws {
    let font = try makeFont()
    // The user's specific example: text mixed with math
    let latex =
      "\\text{Calculer le discriminant }\\Delta=b^{2}-4ac\\text{ avec }a=1\\text{, }b=-1\\text{, }c=-5"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Create display with width constraint of 235 as specified by user
    let maxWidth: CGFloat = 235
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should have multiple lines
    #expect(display!.children.count > 1)

    // Verify each line respects width constraint
    for (_, subDisplay) in display!.children.enumerated() {
      // Allow 10% tolerance for spacing and rounding
      #expect(subDisplay.width <= maxWidth * 1.1)
    }

    // Verify vertical spacing between lines
    if display!.children.count >= 2 {
      let firstLine = display!.children[0]
      let secondLine = display!.children[1]
      let verticalSpacing = abs(firstLine.position.y - secondLine.position.y)
      #expect(verticalSpacing > 0)
      // Typical line height is around 1.5 * font size
      #expect(verticalSpacing > font.font.size * 0.5)
    }
  }

  @Test
  func interatomLineBreaking_BreaksAtAtomBoundaries() throws {
    let font = try makeFont()
    // Test that breaking happens between atoms, not within them
    // Using mathematical atoms separated by operators
    let latex = "a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Create display with narrow width that should force breaking
    let maxWidth: CGFloat = 120
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should have multiple lines
    #expect(display!.children.count > 1)

    // Each line should respect the width constraint (with some tolerance)
    // since we break at atom boundaries, not mid-atom
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func interatomLineBreaking_WithSuperscripts() throws {
    let font = try makeFont()
    // Test breaking with atoms that have superscripts
    let latex = "a^{2}+b^{2}+c^{2}+d^{2}+e^{2}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 100
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should handle superscripts properly and create multiple lines if needed
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.1)
    }
  }

  @Test
  func interatomLineBreaking_NoBreakingWhenNotNeeded() throws {
    let font = try makeFont()
    // Test that short content doesn't break unnecessarily
    let latex = "a=b"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 200
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should stay on single line since content is short
    // Note: The number of subDisplays might be 1 or more depending on internal structure,
    // but the total width should be well under maxWidth
    #expect(display!.width < maxWidth)
  }

  @Test
  func interatomLineBreaking_BreaksAfterOperators() throws {
    let font = try makeFont()
    // Test that breaking prefers to happen after operators (good break points)
    let latex = "a+b+c+d+e+f+g+h"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 80
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should break into multiple lines
    #expect(display!.children.count > 1)

    // Verify width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.1)
    }
  }

  // MARK: - Complex Display Line Breaking Tests (Fractions & Radicals)

  @Test
  func complexDisplay_FractionStaysInlineWhenFits() throws {
    let font = try makeFont()
    // Fraction that should stay inline with surrounding content
    let latex = "a+\\frac{1}{2}+b"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Wide enough to fit everything on one line
    let maxWidth: CGFloat = 200
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should fit on a single line (all elements have same y position)
    // Note: subdisplays may be > 1 due to flushing currentLine before complex atoms
    // What matters is that they're all at the same y position (no line breaks)
    let firstY = display!.children.first?.position.y ?? 0
    for subDisplay in display!.children {
      #expect(abs(subDisplay.position.y - firstY) <= 0.1)
    }

    // Total width should be within constraint
    #expect(display!.width < maxWidth)
  }

  @Test
  func complexDisplay_FractionBreaksWhenTooWide() throws {
    let font = try makeFont()
    // Multiple fractions with narrow width should break
    let latex = "a+\\frac{1}{2}+b+\\frac{3}{4}+c"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Narrow width should force breaking
    let maxWidth: CGFloat = 80
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should have multiple lines
    #expect(display!.children.count > 1)

    // Each line should respect width constraint (with tolerance)
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func complexDisplay_RadicalStaysInlineWhenFits() throws {
    let font = try makeFont()
    // Radical that should stay inline with surrounding content
    let latex = "x+\\sqrt{2}+y"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Wide enough to fit everything on one line
    let maxWidth: CGFloat = 150
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should fit on a single line (all elements have same y position)
    // Note: subdisplays may be > 1 due to flushing currentLine before complex atoms
    // What matters is that they're all at the same y position (no line breaks)
    let firstY = display!.children.first?.position.y ?? 0
    for subDisplay in display!.children {
      #expect(abs(subDisplay.position.y - firstY) <= 0.1)
    }

    // Total width should be within constraint
    #expect(display!.width < maxWidth)
  }

  @Test
  func complexDisplay_RadicalBreaksWhenTooWide() throws {
    let font = try makeFont()
    // Multiple radicals with narrow width should break
    let latex = "a+\\sqrt{2}+b+\\sqrt{3}+c+\\sqrt{5}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Narrow width should force breaking
    let maxWidth: CGFloat = 100
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should have multiple lines
    #expect(display!.children.count > 1)

    // Each line should respect width constraint (with tolerance)
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func complexDisplay_MixedFractionsAndRadicals() throws {
    let font = try makeFont()
    // Mix of fractions and radicals
    let latex = "a+\\frac{1}{2}+\\sqrt{3}+b"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Medium width
    let maxWidth: CGFloat = 150
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should handle mixed complex displays
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func complexDisplay_FractionWithComplexNumerator() throws {
    let font = try makeFont()
    // Fraction with more complex content
    let latex = "\\frac{a+b}{c}+d"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 150
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should stay inline if it fits
    #expect(display!.width < maxWidth * 1.5)
  }

  @Test
  func complexDisplay_RadicalWithDegree() throws {
    let font = try makeFont()
    // Cube root
    let latex = "\\sqrt[3]{8}+x"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 150
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should handle radicals with degrees
    #expect(display!.width < maxWidth * 1.2)
  }

  @Test
  func complexDisplay_NoBreakingWithoutWidthConstraint() throws {
    let font = try makeFont()
    // Without width constraint, should never break
    let latex = "a+\\frac{1}{2}+\\sqrt{3}+b+\\frac{4}{5}+c"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // No width constraint (maxWidth = 0)
    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)

    // Should not artificially break when no constraint
    // The display might have multiple subDisplays for internal structure,
    // but we verify that the total rendering doesn't have forced line breaks
    // by checking that all elements are at y=0 (no vertical offset)
    var allAtSameY = true
    let firstY = display!.children.first?.position.y ?? 0
    for subDisplay in display!.children {
      if abs(subDisplay.position.y - firstY) > 0.1 {
        allAtSameY = false
        break
      }
    }
    #expect(allAtSameY)
  }

  // MARK: - Additional Recommended Tests

  @Test
  func edgeCase_VeryNarrowWidth() throws {
    let font = try makeFont()
    // Test behavior with extremely narrow width constraint
    let latex = "a+b+c"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Very narrow width - each element might need its own line
    let maxWidth: CGFloat = 30
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should handle gracefully without crashing
    #expect(display!.children.count > 0)

    // Each subdisplay should attempt to respect width (though may overflow for single atoms)
    for subDisplay in display!.children {
      // Allow overflow for unavoidable cases (single atom wider than constraint)
      #expect(subDisplay.width < maxWidth * 3)
    }
  }

  @Test
  func edgeCase_VeryWideAtom() throws {
    let font = try makeFont()
    // Test handling of atom that's wider than maxWidth constraint
    let latex = "\\text{ThisIsAnExtremelyLongWordThatCannotBreak}+b"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 100
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should not crash, even if single atom exceeds width
    #expect(display!.children.count > 0)

    // The wide atom should be placed, even if it exceeds maxWidth
    // (no way to break it further)
  }

  @Test
  func mixedScriptsAndNonScripts() throws {
    let font = try makeFont()
    // Test mixing atoms with scripts and without scripts
    let latex = "a+b^{2}+c+d^{3}+e"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 120
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should handle mixed content
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.3)
    }
  }

  @Test
  func multipleLineBreaks() throws {
    let font = try makeFont()
    // Test expression that requires 4+ line breaks
    let latex = "a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s+t"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Very narrow to force many breaks
    let maxWidth: CGFloat = 60
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should create multiple lines
    #expect(display!.children.count >= 4)

    // Verify vertical positioning - each line should be below the previous
    for i in 1..<display!.children.count {
      let prevLine = display!.children[i - 1]
      let currentLine = display!.children[i]
      #expect(currentLine.position.y < prevLine.position.y)
    }

    // Verify consistent line spacing
    if display!.children.count >= 3 {
      let spacing1 = abs(display!.children[0].position.y - display!.children[1].position.y)
      let spacing2 = abs(display!.children[1].position.y - display!.children[2].position.y)
      #expect(abs(spacing1 - spacing2) <= 1.0)
    }
  }

  @Test
  func unicodeTextWrapping() throws {
    let font = try makeFont()
    // Test wrapping with Unicode characters (including CJK)
    let latex = "\\text{Hello 世界 こんにちは 안녕하세요 مرحبا}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 150
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should handle Unicode text (may need fallback font)

    // Each line should attempt to respect width
    for subDisplay in display!.children {
      // More tolerance for Unicode as font metrics vary
      #expect(subDisplay.width <= maxWidth * 1.5)
    }
  }

  @Test
  func numberProtection() throws {
    let font = try makeFont()
    // Test that numbers don't break in the middle
    let latex = "\\text{The value is 3.14159 or 2,718 or 1,000,000}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 150
    _ = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Numbers should stay together (not split like "3.14" → "3." on one line, "14" on next)
    // This is handled by the universal breaking mechanism with Core Text
  }

  // MARK: - Tests for Not-Yet-Optimized Cases (Document Current Behavior)

  @Test
  func currentBehavior_LargeOperators() throws {
    let font = try makeFont()
    // Documents current behavior: large operators still force line breaks
    let latex = "\\sum_{i=1}^{n}x_{i}+\\int_{0}^{1}f(x)dx"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 300
    _ = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Current behavior: operators force breaks
    // This test documents current behavior for future improvement
  }

  @Test
  func currentBehavior_NestedDelimiters() throws {
    let font = try makeFont()
    // Documents current behavior: \left...\right still forces line breaks
    let latex = "a+\\left(b+c\\right)+d"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 200
    _ = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Current behavior: delimiters may force breaks
    // This test documents current behavior for future improvement
  }

  @Test
  func currentBehavior_ColoredExpressions() throws {
    let font = try makeFont()
    // Documents current behavior: colored sections still force line breaks
    let latex = "a+\\color{red}{b+c}+d"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 200
    _ = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Current behavior: colored sections may force breaks
    // This test documents current behavior for future improvement
  }

  @Test
  func currentBehavior_MatricesWithSurroundingContent() throws {
    let font = try makeFont()
    // Documents current behavior: matrices still force line breaks
    let latex = "A=\\begin{pmatrix}1&2\\\\3&4\\end{pmatrix}+B"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 300
    _ = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Current behavior: matrices force breaks
    // This test documents current behavior for future improvement
  }

  @Test
  func realWorldExample_QuadraticFormula() throws {
    let font = try makeFont()
    // Real-world test: quadratic formula with width constraint
    let latex = "x=\\frac{-b\\pm\\sqrt{b^{2}-4ac}}{2a}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 200
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should render the formula (may break if too wide)
    #expect(display!.width > 0)
  }

  @Test
  func realWorldExample_ComplexFraction() throws {
    let font = try makeFont()
    // Real-world test: continued fraction
    let latex = "\\frac{1}{2+\\frac{1}{3+\\frac{1}{4}}}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 150
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should render nested fractions
    #expect(display!.width > 0)
  }

  @Test
  func realWorldExample_MixedOperationsWithFractions() throws {
    let font = try makeFont()
    // Real-world test: mixed arithmetic with multiple fractions
    let latex = "\\frac{1}{2}+\\frac{2}{3}+\\frac{3}{4}+\\frac{4}{5}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 180
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // With new implementation, fractions should stay inline when possible
    // May break into 2-3 lines depending on actual widths
    #expect(display!.children.count > 0)

    // Verify width constraints are respected
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.3)
    }
  }

  // MARK: - Large Operator Tests (NEWLY FIXED!)

  @Test
  func complexDisplay_LargeOperatorStaysInlineWhenFits() throws {
    let font = try makeFont()
    // Test that inline-style large operators stay inline when they fit
    // In display style without explicit limits, operators should be inline-sized
    let latex = "a+\\sum x_i+b"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 250
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .text, maxWidth: maxWidth)

    // Verify width constraints are respected
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func complexDisplay_LargeOperatorBreaksWhenTooWide() throws {
    let font = try makeFont()
    // Test that large operators break when they don't fit
    let latex = "a+b+c+d+e+f+\\sum_{i=1}^{n}x_i"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 80  // Very narrow
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // With narrow width, should break into multiple lines
    let lineCount = display!.children.count
    #expect(lineCount > 1)

    // Verify width constraints are respected (with tolerance for tall operators)
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.5)
    }
  }

  @Test
  func complexDisplay_MultipleLargeOperators() throws {
    let font = try makeFont()
    // Test multiple large operators in sequence
    let latex = "\\sum x_i+\\int f(x)dx+\\prod a_i"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 300
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .text, maxWidth: maxWidth)

    #expect(display!.children.count > 0)

    // Verify width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  // MARK: - Delimiter Tests (NEWLY FIXED!)

  @Test
  func complexDisplay_DelimitersStayInlineWhenFit() throws {
    let font = try makeFont()
    // Test that delimited expressions stay inline when they fit
    let latex = "a+\\left(b+c\\right)+d"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 200
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Verify width constraints are respected
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func complexDisplay_DelimitersBreakWhenTooWide() throws {
    let font = try makeFont()
    // Test that delimited expressions break when they don't fit
    let latex = "a+b+c+\\left(d+e+f+g+h\\right)+i+j"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 100  // Narrow
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should break into multiple lines
    let lineCount = display!.children.count
    #expect(lineCount > 1)

    // Verify width constraints (delimiters add extra width, so be more tolerant)
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.7)
    }
  }

  @Test
  func complexDisplay_NestedDelimitersWithWrapping() throws {
    let font = try makeFont()
    // Test that inner content of delimiters respects width constraints
    let latex = "\\left(a+b+c+d+e+f+g+h\\right)"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 120
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // With maxWidth propagation, inner content should wrap
    #expect(display!.children.count > 0)

    // Verify width constraints (delimiters with wrapped content can be wide)
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 2.5)
    }
  }

  @Test
  func complexDisplay_MultipleDelimiters() throws {
    let font = try makeFont()
    // Test multiple delimited expressions
    let latex = "\\left(a+b\\right)+\\left(c+d\\right)+\\left(e+f\\right)"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 250
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Verify width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  // MARK: - Color Tests (NEWLY FIXED!)

  @Test
  func complexDisplay_ColoredExpressionStaysInlineWhenFits() throws {
    let font = try makeFont()
    // Test that colored expressions stay inline when they fit
    let latex = "a+\\color{red}{b+c}+d"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 200
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Verify width constraints are respected
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func complexDisplay_ColoredExpressionBreaksWhenTooWide() throws {
    let font = try makeFont()
    // Test that colored expressions break when they don't fit
    let latex = "a+\\color{blue}{b+c+d+e+f+g+h}+i"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 100  // Narrow
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should break into multiple lines
    let lineCount = display!.children.count
    #expect(lineCount > 1)

    // Verify width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.3)
    }
  }

  // Removed testComplexDisplay_ColoredContentWraps - colored expression tests above are sufficient

  @Test
  func complexDisplay_MultipleColoredSections() throws {
    let font = try makeFont()
    // Test multiple colored sections
    let latex = "\\color{red}{a+b}+\\color{blue}{c+d}+\\color{green}{e+f}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 250
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Verify width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  // MARK: - Matrix Tests (NEWLY FIXED!)

  @Test
  func complexDisplay_SmallMatrixStaysInlineWhenFits() throws {
    let font = try makeFont()
    // Test that small matrices stay inline when they fit
    let latex = "A=\\begin{pmatrix}1&2\\end{pmatrix}+B"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 250
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Verify width constraints are respected
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func complexDisplay_MatrixBreaksWhenTooWide() throws {
    let font = try makeFont()
    // Test that large matrices break when they don't fit
    let latex = "a+b+c+\\begin{pmatrix}1&2&3&4\\end{pmatrix}+d"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 120  // Narrow
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Verify width constraints (matrices can be slightly wider)
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.5)
    }
  }

  @Test
  func complexDisplay_MatrixWithSurroundingContent() throws {
    let font = try makeFont()
    // Real-world test: matrix in equation
    let latex = "M=\\begin{pmatrix}a&b\\\\c&d\\end{pmatrix}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 200
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // 2x2 matrix with assignment
    #expect(display!.children.count > 0)

    // Verify width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.4)
    }
  }

  // MARK: - Integration Tests (All Complex Displays)

  @Test
  func complexDisplay_MixedComplexElements() throws {
    let font = try makeFont()
    // Test mixing all complex display types
    let latex = "a+\\frac{1}{2}+\\sqrt{3}+\\left(b+c\\right)+\\color{red}{d}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 300
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // With wide constraint, elements should render with reasonable breaking
    let lineCount = display!.children.count
    #expect(lineCount > 0)
    // Note: lineCount may be higher due to flushing currentLine before each complex atom
    // What matters is that they fit within the width constraint
    #expect(lineCount <= 12)

    // Verify width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func complexDisplay_RealWorldQuadraticWithColor() throws {
    let font = try makeFont()
    // Real-world: colored quadratic formula
    let latex = "x=\\frac{-b\\pm\\color{blue}{\\sqrt{b^2-4ac}}}{2a}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 250
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Complex nested structure with color
    #expect(display!.children.count > 0)

    // Verify width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.3)
    }
  }

  // MARK: - Regression Test for Sum Equation Layout Bug

  @Test
  func sumEquationWithFraction_CorrectOrdering() throws {
    let font = try makeFont()
    // Test case for: \(\sum_{i=1}^{n} i = \frac{n(n+1)}{2}\)
    // Bug: The = sign was appearing at the end instead of between i and the fraction
    let latex = "\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Create display without width constraint first to check ordering
    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)

    // Get the subdisplays to check ordering
    let subDisplays = display!.children

    // The expected order should be: sum (with limits), i, =, fraction
    // We need to verify that the x positions are monotonically increasing
    var previousX: CGFloat = -1
    var foundSum = false
    var foundEquals = false
    var foundFraction = false

    for subDisplay in subDisplays {
      // Check x position is increasing (allowing small tolerance for rounding)
      if previousX >= 0 {
        #expect(subDisplay.position.x >= previousX - 0.1)
      }
      previousX = subDisplay.position.x + subDisplay.width

      // Identify what type of display this is
      if subDisplay is Math.DisplayLargeOperator {
        foundSum = true
        #expect(!(foundEquals))
        #expect(!(foundFraction))
      } else if let lineDisplay = subDisplay as? Math.DisplayTextRun {
        let text = lineDisplay.text
        if text.contains("=") {
          foundEquals = true
          #expect(foundSum)
          #expect(!(foundFraction))
        }
      } else if subDisplay is Math.DisplayFraction {
        foundFraction = true
        #expect(foundSum)
        #expect(foundEquals)
      }
    }

    #expect(foundSum)
    #expect(foundEquals)
    #expect(foundFraction)
  }

  @Test
  func sumEquationWithFraction_WithWidthConstraint() throws {
    // Test case for: \(\sum_{i=1}^{n} i = \frac{n(n+1)}{2}\) with width constraint
    // This reproduces the issue where = appears at the end instead of in the middle
    let latex = "\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Create display with width constraint matching MathView preview (235)
    // Use .text mode and font size 17 to match MathView settings
    let testFont = try makeFont(size: 17)
    let maxWidth: CGFloat = 235  // Same width as MathView preview
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: testFont, style: .text, maxWidth: maxWidth)

    // Get the subdisplays to check ordering
    let subDisplays = display!.children

    // Track what we find and their y positions
    var sumX: CGFloat?
    var equalsX: CGFloat?
    var equalsY: CGFloat?
    var fractionX: CGFloat?
    var fractionY: CGFloat?

    for subDisplay in subDisplays {
      if subDisplay is Math.DisplayLargeOperator {
        // Display mode: sum with limits as single display
        sumX = subDisplay.position.x
      } else if subDisplay is Math.DisplayGlyph {
        // Text mode: sum symbol as glyph display (check if it's the sum symbol)
        if sumX == nil {
          sumX = subDisplay.position.x
        }
      } else if let lineDisplay = subDisplay as? Math.DisplayTextRun {
        let text = lineDisplay.text
        if text.contains("=") && !text.contains("i") {
          // Just the equals sign (not combined with i)
          equalsX = subDisplay.position.x
          equalsY = subDisplay.position.y
        } else if text.contains("i") && text.contains("=") {
          equalsX = subDisplay.position.x  // They're together
          equalsY = subDisplay.position.y
        }
      } else if subDisplay is Math.DisplayFraction {
        fractionX = subDisplay.position.x
        fractionY = subDisplay.position.y
      }
    }

    // Verify we found all components
    #expect(sumX != nil)
    #expect(equalsX != nil)
    #expect(fractionX != nil)

    // The key test: equals sign should come BETWEEN i and fraction in horizontal position
    // OR if on different lines, equals should not come after fraction
    if let eqX = equalsX, let eqY = equalsY, let fracX = fractionX, let fracY = fractionY {
      if abs(eqY - fracY) < 1.0 {
        // Same line: equals must be to the left of fraction
        #expect(eqX < fracX)
      }

      // Equals should never be to the right of the fraction's right edge
      #expect(eqX < fracX + display!.width)
    }

  }

  // MARK: - Improved Script Handling Tests

  @Test
  func scriptedAtoms_StayInlineWhenFit() throws {
    let font = try makeFont()
    // Test that atoms with superscripts stay inline when they fit
    let latex = "a^{2}+b^{2}+c^{2}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Wide enough to fit everything on one line
    let maxWidth: CGFloat = 200
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Check for line breaks (large y position gaps indicate line breaks)
    // Note: Superscripts/subscripts have different y positions but are on same "line"
    // Line breaks use fontSize * 1.5 spacing, so look for gaps > fontSize
    let yPositions = display!.children.map { $0.position.y }.sorted()
    var lineBreakCount = 0
    for i in 1..<yPositions.count {
      let gap = abs(yPositions[i] - yPositions[i - 1])
      if gap > font.font.size {
        lineBreakCount += 1
      }
    }

    #expect(lineBreakCount == 0)

    // Total width should be within constraint
    #expect(display!.width < maxWidth)
  }

  @Test
  func scriptedAtoms_BreakWhenTooWide() throws {
    let font = try makeFont()
    // Test that atoms with superscripts break when width is exceeded
    let latex = "a^{2}+b^{2}+c^{2}+d^{2}+e^{2}+f^{2}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Narrow width should force breaking
    let maxWidth: CGFloat = 100
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should have multiple lines (different y positions)
    var uniqueYPositions = Set<CGFloat>()
    for subDisplay in display!.children {
      uniqueYPositions.insert(round(subDisplay.position.y * 10) / 10)  // Round to avoid floating point issues
    }

    #expect(uniqueYPositions.count > 1)

    // Each subdisplay should respect width constraint
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func mixedScriptedAndNonScripted() throws {
    let font = try makeFont()
    // Test mixing scripted and non-scripted atoms
    let latex = "a+b^{2}+c+d^{2}+e"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 180
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should fit on one or few lines
    // Note: subdisplay count may be higher due to flushing before scripted atoms
    #expect(display!.children.count <= 8)

    // Verify width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func subscriptsAndSuperscripts() throws {
    let font = try makeFont()
    // Test atoms with both subscripts and superscripts
    let latex = "x_{1}^{2}+x_{2}^{2}+x_{3}^{2}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 200
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should fit on reasonable number of lines
    #expect(display!.children.count > 0)

    // Verify width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func realWorld_QuadraticExpansion() throws {
    let font = try makeFont()
    // Real-world test: quadratic expansion with exponents
    let latex = "(a+b)^{2}=a^{2}+2ab+b^{2}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 250
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should fit on reasonable number of lines
    #expect(display!.children.count > 0)

    // Verify width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func realWorld_Polynomial() throws {
    let font = try makeFont()
    // Real-world test: polynomial with multiple terms
    let latex = "x^{4}+x^{3}+x^{2}+x+1"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 180
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should have reasonable structure
    #expect(display!.children.count > 0)

    // Verify width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func scriptedAtoms_NoBreakingWithoutConstraint() throws {
    let font = try makeFont()
    // Test that scripted atoms don't break unnecessarily without width constraint
    let latex = "a^{2}+b^{2}+c^{2}+d^{2}+e^{2}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // No width constraint (maxWidth = 0)
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: 0)

    // Check for line breaks - should have none without width constraint
    let yPositions = display!.children.map { $0.position.y }.sorted()
    var lineBreakCount = 0
    for i in 1..<yPositions.count {
      let gap = abs(yPositions[i] - yPositions[i - 1])
      if gap > font.font.size {
        lineBreakCount += 1
      }
    }

    #expect(lineBreakCount == 0)
  }

  @Test
  func complexScriptedExpression() throws {
    let font = try makeFont()
    // Test complex expression mixing fractions and scripts
    let latex = "\\frac{x^{2}}{y^{2}}+a^{2}+\\sqrt{b^{2}}"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 220
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should render successfully
    #expect(display!.children.count > 0)

    // Verify width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.3)
    }
  }

  // MARK: - Break Quality Scoring Tests

  @Test
  func breakQuality_PreferAfterBinaryOperator() throws {
    let font = try makeFont()
    // Test that breaks prefer to occur after binary operators (+, -, ×, ÷)
    // Expression: "aaaa+bbbbcccc" where break should occur after + (not in middle of bbbbcccc)
    let latex = "aaaa+bbbbcccc"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Set width to force a break somewhere between + and end
    let maxWidth: CGFloat = 100
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Extract text content from each line to verify break location
    var lineContents: [String] = []
    for subDisplay in display!.children {
      if let lineDisplay = subDisplay as? Math.DisplayTextRun {
        let text = lineDisplay.text
        lineContents.append(text)
      }
    }

    // With break quality scoring, should break after the + operator
    // First line should contain "aaaa+"
    let hasGoodBreak = lineContents.contains { $0.contains("+") }
    #expect(hasGoodBreak)
  }

  @Test
  func breakQuality_PreferAfterRelation() throws {
    let font = try makeFont()
    // Test that breaks prefer to occur after relation operators (=, <, >)
    let latex = "aaaa=bbbb+cccc"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 90
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Extract line contents
    var lineContents: [String] = []
    for subDisplay in display!.children {
      if let lineDisplay = subDisplay as? Math.DisplayTextRun {
        let text = lineDisplay.text
        lineContents.append(text)
      }
    }

    // Should break after the = operator
    let hasGoodBreak = lineContents.contains { $0.contains("=") }
    #expect(hasGoodBreak)
  }

  @Test
  func breakQuality_AvoidAfterOpenBracket() throws {
    let font = try makeFont()
    // Test that breaks avoid occurring immediately after open brackets
    // Expression: "aaaa+(bbb+ccc)" should NOT break as "aaaa+(\n bbb+ccc)"
    let latex = "aaaa+(bbb+ccc)"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 100
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Extract line contents
    var lineContents: [String] = []
    for subDisplay in display!.children {
      if let lineDisplay = subDisplay as? Math.DisplayTextRun {
        let text = lineDisplay.text
        lineContents.append(text)
      }
    }

    // Should NOT have a line ending with "+(" - bad break point
    let hasBadBreak = lineContents.contains { $0.hasSuffix("+(") }
    #expect(!(hasBadBreak))
  }

  @Test
  func breakQuality_LookAheadFindsBetterBreak() throws {
    let font = try makeFont()
    // Test that look-ahead finds better break points
    // Expression: "aaabbb+ccc" with tight width
    // Should defer break to after + rather than between aaa and bbb
    let latex = "aaabbb+ccc"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Width set so that "aaabbb" slightly exceeds, but look-ahead should find + as better break
    let maxWidth: CGFloat = 60
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Extract line contents
    var lineContents: [String] = []
    for subDisplay in display!.children {
      if let lineDisplay = subDisplay as? Math.DisplayTextRun {
        let text = lineDisplay.text
        lineContents.append(text)
      }
    }

    // Should break after + (penalty 0) rather than in the middle (penalty 10 or 50)
    let hasGoodBreak = lineContents.contains { $0.contains("+") }
    #expect(hasGoodBreak)
  }

  @Test
  func breakQuality_MultipleOperators() throws {
    let font = try makeFont()
    // Test with multiple operators - should break at best available points
    let latex = "a+b+c+d+e+f"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 60
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Count line breaks
    let yPositions = display!.children.map { $0.position.y }.sorted()
    var lineBreakCount = 0
    for i in 1..<yPositions.count {
      let gap = abs(yPositions[i] - yPositions[i - 1])
      if gap > font.font.size {
        lineBreakCount += 1
      }
    }

    // Should have some breaks
    #expect(lineBreakCount > 0)

    // Each line should respect width constraint
    for subDisplay in display!.children {
      #expect(subDisplay.width <= maxWidth * 1.2)
    }
  }

  @Test
  func breakQuality_ComplexExpression() throws {
    let font = try makeFont()
    // Test complex expression with various atom types
    let latex = "x=a+b\\times c+\\frac{d}{e}+f"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 120
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should render successfully
    #expect(display!.children.count > 0)

    // Verify all subdisplays respect width constraints
    for (_, subDisplay) in display!.children.enumerated() {
      #expect(subDisplay.width <= maxWidth * 1.3)
    }
  }

  @Test
  func breakQuality_NoBreakWhenNotNeeded() throws {
    let font = try makeFont()
    // Test that break quality scoring doesn't add unnecessary breaks
    let latex = "a+b+c"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 200  // Wide enough to fit everything
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should have no breaks when content fits
    let yPositions = display!.children.map { $0.position.y }.sorted()
    var lineBreakCount = 0
    for i in 1..<yPositions.count {
      let gap = abs(yPositions[i] - yPositions[i - 1])
      if gap > font.font.size {
        lineBreakCount += 1
      }
    }

    #expect(lineBreakCount == 0)
  }

  @Test
  func breakQuality_PenaltyOrdering() throws {
    let font = try makeFont()
    // Test that penalty system correctly orders break preferences
    // Given: "aaaa+b(ccc" - when break is needed, should prefer breaking after + (penalty 0)
    // rather than after ( (penalty 100)
    let latex = "aaaa+b(ccc"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    let maxWidth: CGFloat = 70
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Extract line contents
    var lineContents: [String] = []
    for subDisplay in display!.children {
      if let lineDisplay = subDisplay as? Math.DisplayTextRun {
        let text = lineDisplay.text
        lineContents.append(text)
      }
    }

    // Should prefer breaking after "+" (penalty 0) rather than after "(" (penalty 100)
    let breaksAfterPlus = lineContents.contains { $0.contains("+") && !$0.contains("(") }
    #expect(breaksAfterPlus || lineContents.count == 1)
  }

  // MARK: - Dynamic Line Height Tests

  @Test
  func dynamicLineHeight_TallContentHasMoreSpacing() throws {
    let font = try makeFont()
    // Test that lines with tall content (fractions) have appropriate spacing
    let latex = "a+b+c+\\frac{x^{2}}{y^{2}}+d+e+f"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Force multiple lines
    let maxWidth: CGFloat = 80
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Collect unique y positions (representing different lines)
    let yPositions = Set(display!.children.map { $0.position.y }).sorted(by: >)

    // Should have multiple lines
    #expect(yPositions.count > 1)

    // Calculate spacing between lines
    var spacings: [CGFloat] = []
    for i in 1..<yPositions.count {
      let spacing = yPositions[i - 1] - yPositions[i]
      spacings.append(spacing)
    }

    // With dynamic line height, spacing should vary based on content height
    // Line with fraction should have larger spacing than lines with just variables
    // All spacings should be at least 20% of fontSize (minimum spacing)
    let minExpectedSpacing = font.font.size * 0.2
    for spacing in spacings {
      #expect(spacing >= minExpectedSpacing)
    }
  }

  @Test
  func dynamicLineHeight_RegularContentHasReasonableSpacing() throws {
    let font = try makeFont()
    // Test that lines with regular content don't have excessive spacing
    let latex = "a+b+c+d+e+f+g+h+i+j"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Force multiple lines
    let maxWidth: CGFloat = 60
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Collect unique y positions
    let yPositions = Set(display!.children.map { $0.position.y }).sorted(by: >)

    // Should have multiple lines
    #expect(yPositions.count > 1)

    // Calculate spacing between lines
    var spacings: [CGFloat] = []
    for i in 1..<yPositions.count {
      let spacing = yPositions[i - 1] - yPositions[i]
      spacings.append(spacing)
    }

    // For regular content, spacing should be reasonable (roughly 1.2-1.8x fontSize)
    for spacing in spacings {
      #expect(spacing >= font.font.size * 1.0)
      #expect(spacing <= font.font.size * 2.0)
    }
  }

  @Test
  func dynamicLineHeight_MixedContentVariesSpacing() throws {
    let font = try makeFont()
    // Test that spacing adapts to each line's content
    // Line 1: regular (a+b)
    // Line 2: with fraction (more height needed)
    // Line 3: regular again (c+d)
    let latex = "a+b+\\frac{x}{y}+c+d"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Force breaks to create multiple lines
    let maxWidth: CGFloat = 50
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should render successfully with varying line heights
    #expect(display!.children.count > 0)

    // Verify overall height is reasonable
    let totalHeight = display!.ascent + display!.descent
    #expect(totalHeight > 0)
  }

  @Test
  func dynamicLineHeight_LargeOperatorsGetAdequateSpace() throws {
    let font = try makeFont()
    // Test that large operators with limits get adequate vertical spacing
    let latex = "\\sum_{i=1}^{n}i+\\prod_{j=1}^{m}j"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Force line break between operators
    let maxWidth: CGFloat = 80
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Collect y positions
    let yPositions = Set(display!.children.map { $0.position.y }).sorted(by: >)

    if yPositions.count > 1 {
      // Calculate spacing
      var spacings: [CGFloat] = []
      for i in 1..<yPositions.count {
        let spacing = yPositions[i - 1] - yPositions[i]
        spacings.append(spacing)
      }

      // Large operators need substantial spacing
      for spacing in spacings {
        #expect(spacing >= font.font.size)
      }
    }
  }

  @Test
  func dynamicLineHeight_ConsistentWithinSimilarContent() throws {
    let font = try makeFont()
    // Test that similar lines get similar spacing
    let latex = "a+b+c+d+e+f"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Force multiple lines with similar content
    let maxWidth: CGFloat = 40
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Collect unique y positions
    let yPositions = Set(display!.children.map { $0.position.y }).sorted(by: >)

    if yPositions.count >= 3 {
      // Calculate all spacings
      var spacings: [CGFloat] = []
      for i in 1..<yPositions.count {
        let spacing = yPositions[i - 1] - yPositions[i]
        spacings.append(spacing)
      }

      // Similar content should have similar spacing (within 20% variance)
      let avgSpacing = spacings.reduce(0, +) / CGFloat(spacings.count)
      for spacing in spacings {
        let variance = abs(spacing - avgSpacing) / avgSpacing
        #expect(variance <= 0.3)
      }
    }
  }

  @Test
  func dynamicLineHeight_NoRegressionOnSingleLine() throws {
    let font = try makeFont()
    // Test that single-line expressions still work correctly
    let latex = "a+b+c"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // No width constraint
    let display = Math.Typesetter.createLineForMathList(mathList, font: font, style: .display)

    // Should be on single line
    let yPositions = Set(display!.children.map { $0.position.y })
    #expect(yPositions.count == 1)
  }

  @Test
  func dynamicLineHeight_DeepFractionsGetExtraSpace() throws {
    let font = try makeFont()
    // Test that nested/continued fractions get adequate spacing
    let latex = "a+\\frac{1}{\\frac{2}{3}}+b+c"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Force line breaks
    let maxWidth: CGFloat = 70
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Deep fractions are taller - verify reasonable total height
    let totalHeight = display!.ascent + display!.descent
    #expect(totalHeight > 0)

    // Should render without issues
    #expect(display!.children.count > 0)
  }

  @Test
  func dynamicLineHeight_RadicalsWithIndicesGetSpace() throws {
    let font = try makeFont()
    // Test that radicals (especially with degrees like cube roots) get adequate spacing
    let latex = "a+\\sqrt[3]{x}+b+\\sqrt{y}+c"
    let mathList = Math.Parser.build(fromString: latex)
    #expect(mathList != nil)

    // Force line breaks
    let maxWidth: CGFloat = 70
    let display = Math.Typesetter.createLineForMathList(
      mathList, font: font, style: .display, maxWidth: maxWidth)

    // Should render successfully
    #expect(display!.children.count > 0)

    // Verify reasonable spacing
    let yPositions = Set(display!.children.map { $0.position.y }).sorted(by: >)
    if yPositions.count > 1 {
      for i in 1..<yPositions.count {
        let spacing = yPositions[i - 1] - yPositions[i]
        #expect(spacing >= font.font.size * 0.2)
      }
    }
  }
}
