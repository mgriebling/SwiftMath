//
//  MathImageTests.swift
//  
//
//  Created by Peter Tang on 18/9/2023.
//

import XCTest
@testable import SwiftMath

final class MathImageTests: XCTestCase {
    func safeImage(fileName: String, pngData: Data) {
        let imageFileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("image-\(fileName).png"))
        try? pngData.write(to: imageFileURL, options: [.atomicWrite])
        //print("\(#function) \(imageFileURL.path)")
    }
    func testMathImageScript() throws {
        let latex = Latex.samples.randomElement()!
        let mathfont = MathFont.allCases.randomElement()!
        let fontsize = CGFloat.random(in: 24 ... 36)
        let result = SwiftMathImageResult.useMathImage(latex: latex, font: mathfont, fontSize: fontsize)
        XCTAssertNil(result.error)
        XCTAssertNotNil(result.image)
        XCTAssertNotNil(result.layoutInfo)
        if result.error == nil, let image = result.image, let imageData = image.pngData() {
            safeImage(fileName: "test", pngData: imageData)
        }
    }
    func testSequentialMultipleImageScript() throws {
        var latex: String { Latex.samples.randomElement()! }
        var mathfont: MathFont { MathFont.allCases.randomElement()! }
        var fontsize: CGFloat { CGFloat.random(in: 20 ... 40) }
        for caseNumber in 0 ..< 20 {
            let result: SwiftMathImageResult
            switch caseNumber % 2 {
            case 0:
                result = SwiftMathImageResult.useMathImage(latex: latex, font: mathfont, fontSize: fontsize)
                XCTAssertNil(result.error)
                XCTAssertNotNil(result.image)
                XCTAssertNotNil(result.layoutInfo)
                if result.error == nil, let image = result.image, let imageData = image.pngData() {
                    safeImage(fileName: "\(caseNumber)", pngData: imageData)
                }
            default:
                result = SwiftMathImageResult.useMTMathImage(latex: latex, font: mathfont, fontSize: fontsize)
                XCTAssertNil(result.error)
                XCTAssertNotNil(result.image)
                if result.error == nil, let image = result.image, let imageData = image.pngData() {
                    safeImage(fileName: "\(caseNumber)", pngData: imageData)
                }
            }
        }
    }
    
    private let executionQueue = DispatchQueue(label: "com.swiftmath.mathbundle", attributes: .concurrent)
    private let executionGroup = DispatchGroup()
    
    let totalCases = 20
    var testCount = 0
    
    func testConcurrentMathImageScript() throws {
        var latex: String { Latex.samples.randomElement()! }
        var mathfont: MathFont { MathFont.allCases.randomElement()! }
        var size: CGFloat { CGFloat.random(in: 20 ... 40) }
        for caseNumber in 0 ..< totalCases {
            switch caseNumber % 2 {
            case 0:
                helperConcurrentMathImage(caseNumber, latex: latex, mathfont: mathfont, fontsize: size, in: executionGroup, on: executionQueue)
            default:
                helperConcurrentMTMathImage(caseNumber, latex: latex, mathfont: mathfont, fontsize: size, in: executionGroup, on: executionQueue)
            }
        }
        executionGroup.notify(queue: .main) { [weak self] in
            XCTAssertEqual(self?.testCount,self?.totalCases)
        }
        executionGroup.wait()
    }
    func helperConcurrentMathImage(_ count: Int, latex: String, mathfont: MathFont, fontsize: CGFloat, in group: DispatchGroup, on queue: DispatchQueue) {
        let workitem = DispatchWorkItem { [weak self] in
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: mathfont, fontSize: fontsize)
            XCTAssertNil(result.error)
            XCTAssertNotNil(result.image)
            XCTAssertNotNil(result.layoutInfo)
            if result.error == nil, let image = result.image, let imageData = image.pngData() {
                self?.safeImage(fileName: "\(count)", pngData: imageData)
            }
        }
        workitem.notify(queue: .main) { [weak self] in
            self?.testCount += 1
        }
        queue.async(group: group, execute: workitem)
    }
    func helperConcurrentMTMathImage(_ count: Int, latex: String, mathfont: MathFont, fontsize: CGFloat, in group: DispatchGroup, on queue: DispatchQueue) {
        let workitem = DispatchWorkItem { [weak self] in
            let result = SwiftMathImageResult.useMTMathImage(latex: latex, font: mathfont, fontSize: fontsize)
            XCTAssertNil(result.error)
            XCTAssertNotNil(result.image)
            if result.error == nil, let image = result.image, let imageData = image.pngData() {
                self?.safeImage(fileName: "\(count)", pngData: imageData)
            }
        }
        workitem.notify(queue: .main) { [weak self] in
            self?.testCount += 1
        }
        queue.async(group: group, execute: workitem)
    }
}
public struct SwiftMathImageResult {
    let error: NSError?
    let image: MTImage?
    let layoutInfo: MathImage.LayoutInfo?
}
extension SwiftMathImageResult {
    public static func useMTMathImage(latex: String, font: MathFont, fontSize: CGFloat, textColor: MTColor = MTColor.black) -> SwiftMathImageResult {
        let alignment = MTTextAlignment.left
        let formatter = MTMathImage(latex: latex, fontSize: fontSize - 1.0,
                                    textColor: textColor,
                                    labelMode: .text, textAlignment: alignment)
        formatter.font = font.mtfont(size: fontSize)
        let (error, image) = formatter.asImage()
        return SwiftMathImageResult(error: error, image: image, layoutInfo: nil)
    }
    public static func useMathImage(latex: String, font: MathFont, fontSize: CGFloat, textColor: MTColor = MTColor.black) -> SwiftMathImageResult {
        let alignment = MTTextAlignment.left
        var formatter = MathImage(latex: latex, fontSize: fontSize - 1.0,
                                  textColor: textColor,
                                  labelMode: .text, textAlignment: alignment)
        formatter.font = font
        let (error, image, layoutInfo) = formatter.asImage()
        return SwiftMathImageResult(error: error, image: image, layoutInfo: layoutInfo)
    }
}
#if os(macOS)
extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
    func pngData() -> Data? {
        tiffRepresentation?.bitmap?.png
    }
}
#endif
enum Latex {
    static let samples: [String] = [
        #"(a_1 + a_2)^2 = a_1^2 + 2a_1a_2 + a_2^2"#,
        #"x = \frac{-b \pm \sqrt{b^2-4ac}}{2a}"#,
        #"\sigma = \sqrt{\frac{1}{N}\sum_{i=1}^N (x_i - \mu)^2}"#,
        #"\neg(P\land Q) \iff (\neg P)\lor(\neg Q)"#,
        #"\cos(\theta + \varphi) = \cos(\theta)\cos(\varphi) - \sin(\theta)\sin(\varphi)"#,
        #"\lim_{x\to\infty}\left(1 + \frac{k}{x}\right)^x = e^k"#,
        #"f(x) = \int\limits_{-\infty}^\infty\hat f(\xi)\,e^{2 \pi i \xi x}\,\mathrm{d}\xi"#,
        #"{n \brace k} = \frac{1}{k!}\sum_{j=0}^k (-1)^{k-j}\binom{k}{j}(k-j)^n"#,
        #"\int_{-\infty}^{\infty} \! e^{-x^2} dx = \sqrt{\pi}"#,
        #"\frac{1}{n}\sum_{i=1}^{n}x_i \geq \sqrt[n]{\prod_{i=1}^{n}x_i}"#,
        #"\left(\sum_{k=1}^n a_k b_k \right)^2 \le \left(\sum_{k=1}^n a_k^2\right)\left(\sum_{k=1}^n b_k^2\right)"#,
        #"\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)"#,
        #"i\hbar\frac{\partial}{\partial t}\mathbf\Psi(\mathbf{x},t) = -\frac{\hbar}{2m}\nabla^2\mathbf\Psi(\mathbf{x},t) + V(\mathbf{x})\mathbf\Psi(\mathbf{x},t)"#,
        #"""
            \begin{gather}
            \dot{x} = \sigma(y-x) \\
            \dot{y} = \rho x - y - xz \\
            \dot{z} = -\beta z + xy"
            \end{gather}
        """#,
        #"""
            \vec \bf V_1 \times \vec \bf V_2 =  \begin{vmatrix}
            \hat \imath &\hat \jmath &\hat k \\
            \frac{\partial X}{\partial u} & \frac{\partial Y}{\partial u} & 0 \\
            \frac{\partial X}{\partial v} & \frac{\partial Y}{\partial v} & 0
            \end{vmatrix}
        """#,
        #"""
            \begin{eqalign}
            \nabla \cdot \vec{\bf E} & = \frac {\rho} {\varepsilon_0} \\
            \nabla \cdot \vec{\bf B} & = 0 \\
            \nabla \times \vec{\bf E} &= - \frac{\partial\vec{\bf B}}{\partial t} \\
            \nabla \times \vec{\bf B} & = \mu_0\vec{\bf J} + \mu_0\varepsilon_0 \frac{\partial\vec{\bf E}}{\partial t}
            \end{eqalign}
        """#,
        #"\log_b(x) = \frac{\log_a(x)}{\log_a(b)}"#,
        #"""
            \begin{pmatrix}
            a & b\\ c & d
            \end{pmatrix}
            \begin{pmatrix}
            \alpha & \beta \\ \gamma & \delta
            \end{pmatrix} =
            \begin{pmatrix}
            a\alpha + b\gamma & a\beta + b \delta \\
            c\alpha + d\gamma & c\beta + d \delta
            \end{pmatrix}
        """#,
        #"""
            \frak Q(\lambda,\hat{\lambda}) =
            -\frac{1}{2} \mathbb P(O \mid \lambda ) \sum_s \sum_m \sum_t \gamma_m^{(s)} (t) +\\
            \quad \left( \log(2 \pi ) + \log \left| \cal C_m^{(s)} \right| +
            \left( o_t - \hat{\mu}_m^{(s)} \right) ^T \cal C_m^{(s)-1} \right)
        """#
    ]
}

// MARK: - Delimiter Sizing Render Tests

final class DelimiterRenderTests: XCTestCase {

    private func saveImage(named name: String, pngData: Data) {
        let imageFileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("delimiter-\(name).png"))
        try? pngData.write(to: imageFileURL, options: [.atomicWrite])
        print("Saved: \(imageFileURL.path)")
    }

    /// Test rendering of all delimiter size variants
    func testDelimiterSizeRendering() throws {
        let testCases: [(String, String)] = [
            // Basic size comparison
            (#"( \big( \Big( \bigg( \Bigg("#, "size_comparison_parens"),
            (#") \big) \Big) \bigg) \Bigg)"#, "size_comparison_parens_close"),
            (#"[ \big[ \Big[ \bigg[ \Bigg["#, "size_comparison_brackets"),
            (#"\{ \big\{ \Big\{ \bigg\{ \Bigg\{"#, "size_comparison_braces"),
            (#"| \big| \Big| \bigg| \Bigg|"#, "size_comparison_pipes"),

            // Left/right variants
            (#"\bigl( x \bigr)"#, "bigl_bigr_parens"),
            (#"\Bigl[ x \Bigr]"#, "Bigl_Bigr_brackets"),
            (#"\biggl\{ x \biggr\}"#, "biggl_biggr_braces"),
            (#"\Biggl| x \Biggr|"#, "Biggl_Biggr_pipes"),

            // Middle variants
            (#"a \bigm| b"#, "bigm_pipe"),
            (#"a \Bigm| b \Biggm| c"#, "Bigm_Biggm_pipes"),

            // Practical usage with fractions
            (#"\bigl( \frac{a}{b} \bigr)"#, "bigl_frac"),
            (#"\Bigl( \frac{a}{b} \Bigr)"#, "Bigl_frac"),
            (#"\biggl( \frac{a}{b} \biggr)"#, "biggl_frac"),
            (#"\Biggl( \frac{a}{b} \Biggr)"#, "Biggl_frac"),

            // Mixed with auto-sized delimiters
            (#"\left( \frac{a}{b} \right) \quad \big( \frac{a}{b} \big)"#, "auto_vs_manual"),
        ]

        let font = MathFont.latinModernFont
        let fontSize: CGFloat = 24.0

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(name) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(name)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: name, pngData: imageData)
            }
        }
    }

    /// Test that delimiter sizes increase progressively
    func testDelimiterSizeProgression() throws {
        let font = MathFont.latinModernFont
        let fontSize: CGFloat = 24.0

        // Render each size and compare heights
        let sizeCommands = ["big", "Big", "bigg", "Bigg"]
        var previousHeight: CGFloat = 0

        for command in sizeCommands {
            let latex = "\\\(command)("
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \\\(command)( without error")
            XCTAssertNotNil(result.image, "Should produce image for \\\(command)(")

            if let layoutInfo = result.layoutInfo {
                let currentHeight = layoutInfo.ascent + layoutInfo.descent

                // Each size should be larger than the previous
                XCTAssertGreaterThan(currentHeight, previousHeight,
                    "\\\(command) height (\(currentHeight)) should be greater than previous (\(previousHeight))")
                previousHeight = currentHeight
            }

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: "progression_\(command)", pngData: imageData)
            }
        }
    }
}

// MARK: - Dirac Notation Render Tests

final class DiracRenderTests: XCTestCase {

    let font = MathFont.latinModernFont
    let fontSize: CGFloat = 20.0

    func saveImage(named name: String, pngData: Data) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SwiftMath_DiracTests_\(name).png")
        try? pngData.write(to: url)
    }

    func testBraRendering() throws {
        // Test \bra{psi} renders correctly
        let latex = "\\bra{\\psi}"
        let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

        XCTAssertNil(result.error, "Should render \\bra{\\psi} without error: \(result.error?.localizedDescription ?? "")")
        XCTAssertNotNil(result.image, "Should produce image for \\bra{\\psi}")

        if let image = result.image, let imageData = image.pngData() {
            saveImage(named: "bra_psi", pngData: imageData)
        }
    }

    func testKetRendering() throws {
        // Test \ket{psi} renders correctly
        let latex = "\\ket{\\psi}"
        let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

        XCTAssertNil(result.error, "Should render \\ket{\\psi} without error: \(result.error?.localizedDescription ?? "")")
        XCTAssertNotNil(result.image, "Should produce image for \\ket{\\psi}")

        if let image = result.image, let imageData = image.pngData() {
            saveImage(named: "ket_psi", pngData: imageData)
        }
    }

    func testBraketRendering() throws {
        // Test \braket{phi}{psi} renders correctly
        let latex = "\\braket{\\phi}{\\psi}"
        let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

        XCTAssertNil(result.error, "Should render \\braket{\\phi}{\\psi} without error: \(result.error?.localizedDescription ?? "")")
        XCTAssertNotNil(result.image, "Should produce image for \\braket{\\phi}{\\psi}")

        if let image = result.image, let imageData = image.pngData() {
            saveImage(named: "braket_phi_psi", pngData: imageData)
        }
    }

    func testDiracExpressionRendering() throws {
        // Test a complete quantum mechanics expression
        let testCases: [(String, String)] = [
            ("\\bra{0}", "bra_0"),
            ("\\ket{1}", "ket_1"),
            ("\\braket{0}{1}", "braket_01"),
            ("\\braket{n}{m}", "braket_nm"),
            ("H\\ket{\\psi}=E\\ket{\\psi}", "schrodinger"),
            ("\\bra{\\phi}A\\ket{\\psi}", "matrix_element"),
            ("\\sum_n\\ket{n}\\bra{n}=I", "completeness"),
        ]

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(latex) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(latex)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: name, pngData: imageData)
            }
        }
    }
}

// MARK: - Operatorname Render Tests

final class OperatornameRenderTests: XCTestCase {

    let font = MathFont.latinModernFont
    let fontSize: CGFloat = 20.0

    func saveImage(named name: String, pngData: Data) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SwiftMath_OperatornameTests_\(name).png")
        try? pngData.write(to: url)
    }

    func testOperatornameRendering() throws {
        // Test basic \operatorname{name} renders correctly
        let testCases: [(String, String)] = [
            ("\\operatorname{lcm}(a,b)", "lcm"),
            ("\\operatorname{sgn}(x)", "sgn"),
            ("\\operatorname{ord}(g)", "ord"),
            ("\\operatorname{Tr}(A)", "trace"),
            ("\\operatorname{rank}(M)", "rank"),
        ]

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(latex) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(latex)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: "basic_\(name)", pngData: imageData)
            }
        }
    }

    func testOperatornameStarRendering() throws {
        // Test \operatorname*{name} renders with limits above/below
        let testCases: [(String, String)] = [
            ("\\operatorname*{argmax}_{x \\in X} f(x)", "argmax"),
            ("\\operatorname*{argmin}_{x \\in X} f(x)", "argmin"),
            ("\\operatorname*{esssup}_{x \\in \\mathbb{R}} |f(x)|", "esssup"),
        ]

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(latex) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(latex)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: "star_\(name)", pngData: imageData)
            }
        }
    }

    func testOperatornameComparisonWithBuiltIn() throws {
        // Compare custom operatorname with built-in operators
        let testCases: [(String, String)] = [
            ("\\sin x + \\operatorname{mysin} x", "compare_sin"),
            ("\\lim_{n \\to \\infty} a_n = \\operatorname*{lim}_{n \\to \\infty} b_n", "compare_lim"),
        ]

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(latex) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(latex)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: name, pngData: imageData)
            }
        }
    }
}

// MARK: - Boldsymbol Render Tests

final class BoldsymbolRenderTests: XCTestCase {

    let font = MathFont.latinModernFont
    let fontSize: CGFloat = 20.0

    func saveImage(named name: String, pngData: Data) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SwiftMath_BoldsymbolTests_\(name).png")
        try? pngData.write(to: url)
    }

    func testBoldsymbolGreekRendering() throws {
        // Test \boldsymbol with Greek letters
        let testCases: [(String, String)] = [
            ("\\boldsymbol{\\alpha}", "alpha"),
            ("\\boldsymbol{\\beta}", "beta"),
            ("\\boldsymbol{\\gamma}", "gamma"),
            ("\\boldsymbol{\\Gamma}", "Gamma_upper"),
            ("\\boldsymbol{\\mu} + \\boldsymbol{\\sigma}", "mu_sigma"),
        ]

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(latex) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(latex)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: "greek_\(name)", pngData: imageData)
            }
        }
    }

    func testBoldsymbolComparisonWithMathbf() throws {
        // Compare \boldsymbol with \mathbf to show difference
        let testCases: [(String, String)] = [
            ("\\mathbf{x} \\text{ vs } \\boldsymbol{x}", "x_comparison"),
            ("\\mathbf{\\alpha} \\text{ vs } \\boldsymbol{\\alpha}", "alpha_comparison"),
            ("\\boldsymbol{\\nabla} f = \\mathbf{0}", "gradient"),
        ]

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(latex) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(latex)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: "compare_\(name)", pngData: imageData)
            }
        }
    }
}

// MARK: - Binary Operator Render Tests

final class BinaryOperatorRenderTests: XCTestCase {

    let font = MathFont.latinModernFont
    let fontSize: CGFloat = 20.0

    func saveImage(named name: String, pngData: Data) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SwiftMath_BinaryOpTests_\(name).png")
        try? pngData.write(to: url)
    }

    func testSemidirectProducts() throws {
        // Test semidirect product operators
        let testCases: [(String, String)] = [
            ("G \\ltimes H", "ltimes"),
            ("G \\rtimes H", "rtimes"),
            ("A \\bowtie B", "bowtie"),
        ]

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(latex) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(latex)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: name, pngData: imageData)
            }
        }
    }

    func testCircledAndBoxedOperators() throws {
        // Test circled and boxed operators
        let testCases: [(String, String)] = [
            ("a \\oplus b", "oplus"),
            ("a \\ominus b", "ominus"),
            ("a \\otimes b", "otimes"),
            ("a \\circledast b", "circledast"),
            ("a \\circledcirc b", "circledcirc"),
            ("a \\boxplus b", "boxplus"),
            ("a \\boxminus b", "boxminus"),
            ("a \\boxtimes b", "boxtimes"),
            ("a \\boxdot b", "boxdot"),
        ]

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(latex) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(latex)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: name, pngData: imageData)
            }
        }
    }

    func testLogicalOperators() throws {
        // Test logical operators
        let testCases: [(String, String)] = [
            ("p \\barwedge q", "barwedge"),
            ("p \\veebar q", "veebar"),
            ("p \\curlywedge q", "curlywedge"),
            ("p \\curlyvee q", "curlyvee"),
        ]

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(latex) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(latex)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: name, pngData: imageData)
            }
        }
    }
}

// MARK: - Corner Bracket Render Tests

final class CornerBracketRenderTests: XCTestCase {

    let font = MathFont.latinModernFont
    let fontSize: CGFloat = 20.0

    func saveImage(named name: String, pngData: Data) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SwiftMath_CornerBracketTests_\(name).png")
        try? pngData.write(to: url)
    }

    func testCornerBrackets() throws {
        // Test corner bracket delimiters
        let testCases: [(String, String)] = [
            ("\\left\\ulcorner x \\right\\urcorner", "upper_corners"),
            ("\\left\\llcorner x \\right\\lrcorner", "lower_corners"),
            ("\\left\\ulcorner \\text{quote} \\right\\urcorner", "quote_corners"),
        ]

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(latex) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(latex)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: name, pngData: imageData)
            }
        }
    }

    func testDoubleBrackets() throws {
        // Test double square brackets (semantic brackets)
        let testCases: [(String, String)] = [
            ("\\left\\llbracket x \\right\\rrbracket", "double_brackets"),
            ("\\left\\llbracket f(x) \\right\\rrbracket", "semantic_function"),
        ]

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(latex) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(latex)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: name, pngData: imageData)
            }
        }
    }
}

// MARK: - Trig Function Render Tests

final class TrigFunctionRenderTests: XCTestCase {

    let font = MathFont.latinModernFont
    let fontSize: CGFloat = 20.0

    func saveImage(named name: String, pngData: Data) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SwiftMath_TrigTests_\(name).png")
        try? pngData.write(to: url)
    }

    func testInverseTrigFunctions() throws {
        // Test inverse trig functions
        let testCases: [(String, String)] = [
            ("\\arccot x", "arccot"),
            ("\\arcsec x", "arcsec"),
            ("\\arccsc x", "arccsc"),
        ]

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(latex) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(latex)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: name, pngData: imageData)
            }
        }
    }

    func testHyperbolicFunctions() throws {
        // Test hyperbolic functions
        let testCases: [(String, String)] = [
            ("\\sech x", "sech"),
            ("\\csch x", "csch"),
            ("\\arcsinh x", "arcsinh"),
            ("\\arccosh x", "arccosh"),
            ("\\arctanh x", "arctanh"),
        ]

        for (latex, name) in testCases {
            let result = SwiftMathImageResult.useMathImage(latex: latex, font: font, fontSize: fontSize)

            XCTAssertNil(result.error, "Should render \(latex) without error: \(result.error?.localizedDescription ?? "")")
            XCTAssertNotNil(result.image, "Should produce image for \(latex)")

            if let image = result.image, let imageData = image.pngData() {
                saveImage(named: name, pngData: imageData)
            }
        }
    }
}
