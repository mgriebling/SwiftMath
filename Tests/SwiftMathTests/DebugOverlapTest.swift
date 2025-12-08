//
//  Test file to understand the overlap issue
//

import XCTest
@testable import SwiftMath

class DebugOverlapTest: XCTestCase {
    func testDebugOverlap() {
        let label = MTMathUILabel()
        label.latex = "y=x^{2}+3x+4x+9x+8x+8+\\sqrt{\\dfrac{3x^{2}+5x}{\\cos x}}"
        label.font = MTFontManager.fontManager.defaultFont
        label.preferredMaxLayoutWidth = 200
        
        let size = label.intrinsicContentSize
        label.frame = CGRect(origin: .zero, size: size)
        
        #if os(macOS)
        label.layout()
        #else
        label.layoutSubviews()
        #endif
        
        if let displayList = label.displayList {
            print("\n=== Display List Analysis ===")
            print("Total displays: \(displayList.subDisplays.count)")
            
            for (index, display) in displayList.subDisplays.enumerated() {
                let minY = display.position.y - display.ascent
                let maxY = display.position.y + display.descent
                print("\nDisplay \(index):")
                print("  Type: \(type(of: display))")
                print("  Position: (\(display.position.x), \(display.position.y))")
                print("  Ascent: \(display.ascent), Descent: \(display.descent)")
                print("  Width: \(display.width)")
                print("  Y range: [\(minY), \(maxY)]")
                
                if index > 0 {
                    let prevDisplay = displayList.subDisplays[index - 1]
                    let prevMaxY = prevDisplay.position.y + prevDisplay.descent
                    let gap = prevMaxY - maxY
                    print("  Gap from previous: \(gap) (negative = overlap)")
                }
            }
        }
    }
}
