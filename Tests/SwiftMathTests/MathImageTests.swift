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
final class DelimiterSizingRenderTests: XCTestCase {
    func saveImage(fileName: String, pngData: Data) -> URL {
        let imageFileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("delimiter-\(fileName).png"))
        try? pngData.write(to: imageFileURL, options: [.atomicWrite])
        print("Saved image: \(imageFileURL.path)")
        return imageFileURL
    }

    /// Visual render test for \big, \Big, \bigg, \Bigg delimiter sizing
    /// This test generates images to verify delimiters render at correct sizes
    func testBigDelimiterRendering() throws {
        // Use unique names to avoid case-insensitive filesystem issues
        let testCases: [(name: String, latex: String)] = [
            // Compare all four sizes with parentheses - outer should be larger, inner smaller
            ("01_sizes_comparison", #"\Bigg( \bigg( \Big( \big( x \big) \Big) \bigg) \Bigg)"#),

            // Each size individually with fraction content (use 1,2,3,4 prefix for size level)
            ("02_size1_big_parens", #"\big( \frac{a}{b} \big)"#),
            ("03_size2_Big_parens", #"\Big( \frac{a}{b} \Big)"#),
            ("04_size3_bigg_parens", #"\bigg( \frac{a}{b} \bigg)"#),
            ("05_size4_Bigg_parens", #"\Bigg( \frac{a}{b} \Bigg)"#),

            // Standalone delimiters without content - pure size test
            ("06_standalone_sizes", #"\big( \quad \Big( \quad \bigg( \quad \Bigg("#),

            // Mixed in expression
            ("07_mixed_expression", #"f\big(g(x)\big) = \Big(\sum_{i=1}^n x_i\Big)"#),

            // With brackets - outer larger, inner smaller
            ("08_brackets", #"\Bigg[ \bigg[ \Big[ \big[ x \big] \Big] \bigg] \Bigg]"#),

            // Comparison with \left \right (auto-sizing)
            ("09_left_right_vs_Big", #"\left( \frac{a}{b} \right) \quad \Big( \frac{a}{b} \Big)"#),

            // Vertical bars
            ("10_vertical_bars", #"\big| \Big| \bigg| \Bigg| x \Bigg| \bigg| \Big| \big|"#),

            // Nested \left \right - should auto-grow with content (display style)
            ("11_nested_left_right", #"\left( \left( \left( \left( x \right) \right) \right) \right)"#),

            // Nested \left \right with actual growing content
            ("12_nested_growing_content", #"\left( a + \left( b + \left( c + \left( d \right) \right) \right) \right)"#),

            // Compare: manual sizing vs auto-sizing for same nesting (outer=larger)
            ("13_manual_vs_auto_nested", #"\Bigg(\bigg(\Big(\big( x \big)\Big)\bigg)\Bigg) \quad \left(\left(\left(\left( x \right)\right)\right)\right)"#),

            // Nested fractions - \left \right should grow to fit
            ("14_nested_fractions_auto", #"\left( \frac{a}{\left( \frac{b}{\left( \frac{c}{d} \right)} \right)} \right)"#),

            // Same with manual sizing
            ("15_nested_fractions_manual", #"\Bigg( \frac{a}{\Big( \frac{b}{\big( \frac{c}{d} \big)} \Big)} \Bigg)"#),
        ]

        var savedPaths: [URL] = []

        for (name, latex) in testCases {
            let result = SwiftMathImageResult.useMathImage(
                latex: latex,
                font: .latinModernFont,
                fontSize: 30
            )

            if let error = result.error {
                XCTFail("Failed to render '\(name)': \(error.localizedDescription)")
                continue
            }

            guard let image = result.image, let imageData = image.pngData() else {
                XCTFail("No image generated for '\(name)'")
                continue
            }

            let path = saveImage(fileName: name, pngData: imageData)
            savedPaths.append(path)
        }

        print("\n=== Delimiter Sizing Render Test Results ===")
        print("Generated \(savedPaths.count) test images in: \(NSTemporaryDirectory())")
        print("Image files:")
        for path in savedPaths {
            print("  - \(path.lastPathComponent)")
        }
        print("============================================\n")

        XCTAssertEqual(savedPaths.count, testCases.count, "All test cases should generate images")
    }
}

final class SymbolRenderTests: XCTestCase {
    func saveImage(fileName: String, pngData: Data) -> URL {
        let imageFileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("symbol-\(fileName).png"))
        try? pngData.write(to: imageFileURL, options: [.atomicWrite])
        print("Saved image: \(imageFileURL.path)")
        return imageFileURL
    }

    /// Visual render test for Priority 1 symbols added in PR #61
    func testPriority1SymbolRendering() throws {
        let testCases: [(name: String, latex: String)] = [
            // Greek variants (varkappa supported, digamma not in Latin Modern Math font)
            ("01_greek_varkappa", #"\varkappa"#),

            // Arrows
            ("02_arrows", #"\longmapsto \quad \hookrightarrow \quad \hookleftarrow"#),

            // Slanted inequalities
            ("03_slanted_ineq", #"a \leqslant b \leqslant c \quad x \geqslant y \geqslant z"#),

            // Precedence relations
            ("04_precedence", #"a \preceq b \quad c \succeq d"#),

            // Turnstile relations
            ("05_turnstiles", #"A \vdash B \quad C \dashv D \quad E \bowtie F"#),

            // Binary operators
            ("06_diamond", #"A \diamond B \diamond C"#),

            // Hebrew letters
            ("07_hebrew", #"\aleph \quad \beth \quad \gimel \quad \daleth"#),

            // Miscellaneous
            ("08_misc", #"\varnothing \quad \Box \quad \measuredangle"#),

            // Combined expression (without digamma)
            ("09_combined", #"\varkappa \hookrightarrow \varnothing \quad a \leqslant b \preceq c"#),

            // In context with other math
            ("10_in_context", #"f: A \longmapsto B, \quad x \leqslant y \implies \Box P"#),
        ]

        var savedPaths: [URL] = []

        for (name, latex) in testCases {
            let result = SwiftMathImageResult.useMathImage(
                latex: latex,
                font: .latinModernFont,
                fontSize: 30
            )

            if let error = result.error {
                XCTFail("Failed to render '\(name)': \(error.localizedDescription)")
                continue
            }

            guard let image = result.image, let imageData = image.pngData() else {
                XCTFail("No image generated for '\(name)'")
                continue
            }

            let path = saveImage(fileName: name, pngData: imageData)
            savedPaths.append(path)
        }

        print("\n=== Priority 1 Symbol Render Test Results ===")
        print("Generated \(savedPaths.count) test images in: \(NSTemporaryDirectory())")
        print("Image files:")
        for path in savedPaths {
            print("  - \(path.lastPathComponent)")
        }
        print("==============================================\n")

        XCTAssertEqual(savedPaths.count, testCases.count, "All test cases should generate images")
    }

    /// Visual render test for negated relation symbols
    func testNegatedRelationRendering() throws {
        let testCases: [(name: String, latex: String)] = [
            // Inequality negations
            ("11_ineq_negations", #"a \nless b \quad c \ngtr d \quad x \nleq y \quad z \ngeq w"#),
            ("12_slant_negations", #"a \nleqslant b \quad c \ngeqslant d"#),
            ("13_neq_variants", #"a \lneq b \quad c \gneq d \quad x \lneqq y \quad z \gneqq w"#),
            ("14_sim_negations", #"a \lnsim b \quad c \gnsim d \quad x \lnapprox y \quad z \gnapprox w"#),

            // Ordering negations
            ("15_ordering_neg", #"a \nprec b \quad c \nsucc d \quad x \npreceq y \quad z \nsucceq w"#),
            ("16_prec_variants", #"a \precneqq b \quad c \succneqq d"#),
            ("17_prec_sim", #"a \precnsim b \quad c \succnsim d \quad x \precnapprox y \quad z \succnapprox w"#),

            // Similarity/congruence negations
            ("18_sim_cong", #"a \nsim b \quad c \ncong d"#),
            ("19_mid_parallel", #"a \nmid b \quad c \nshortmid d \quad x \nparallel y \quad z \nshortparallel w"#),

            // Set relation negations
            ("20_set_neg", #"A \nsubseteq B \quad C \nsupseteq D"#),
            ("21_set_neq", #"A \subsetneq B \quad C \supsetneq D \quad X \subsetneqq Y \quad Z \supsetneqq W"#),
            ("22_set_var", #"A \varsubsetneq B \quad C \varsupsetneq D"#),
            ("23_notni", #"a \notni b \quad c \nni d"#),

            // Triangle negations
            ("24_triangle", #"A \ntriangleleft B \quad C \ntriangleright D \quad X \ntrianglelefteq Y \quad Z \ntrianglerighteq W"#),

            // Turnstile negations
            ("25_turnstile_neg", #"A \nvdash B \quad C \nvDash D \quad X \nVdash Y \quad Z \nVDash W"#),

            // Square subset negations
            ("26_sq_subset", #"A \nsqsubseteq B \quad C \nsqsupseteq D"#),

            // Combined expression
            ("27_combined", #"x \nless y \nleq z \quad A \nsubseteq B \ntriangleleft C"#),

            // In context with positive relations
            ("28_with_positive", #"a \leq b \quad \text{but} \quad c \nleq d"#),
        ]

        var savedPaths: [URL] = []

        for (name, latex) in testCases {
            let result = SwiftMathImageResult.useMathImage(
                latex: latex,
                font: .latinModernFont,
                fontSize: 30
            )

            if let error = result.error {
                XCTFail("Failed to render '\(name)': \(error.localizedDescription)")
                continue
            }

            guard let image = result.image, let imageData = image.pngData() else {
                XCTFail("No image generated for '\(name)'")
                continue
            }

            let path = saveImage(fileName: name, pngData: imageData)
            savedPaths.append(path)
        }

        print("\n=== Negated Relation Render Test Results ===")
        print("Generated \(savedPaths.count) test images in: \(NSTemporaryDirectory())")
        print("Image files:")
        for path in savedPaths {
            print("  - \(path.lastPathComponent)")
        }
        print("=============================================\n")

        XCTAssertEqual(savedPaths.count, testCases.count, "All test cases should generate images")
    }
}

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

// MARK: - EXAMPLES.md Image Generation Tests

/// Generates PNG images for EXAMPLES.md examples that are missing images
/// Run this test to regenerate all example images in the img/ directory
final class ExamplesImageGenerationTests: XCTestCase {

    let font = MathFont.latinModernFont
    let fontSize: CGFloat = 20.0

    /// Get the path to the project's img/ directory
    private func imgDirectory() -> URL? {
        // Navigate from test bundle to project root
        let testBundle = Bundle(for: type(of: self))
        guard let bundlePath = testBundle.bundlePath.components(separatedBy: ".build").first else {
            // Fallback: use current directory
            let currentPath = FileManager.default.currentDirectoryPath
            return URL(fileURLWithPath: currentPath).appendingPathComponent("img")
        }
        return URL(fileURLWithPath: bundlePath).appendingPathComponent("img")
    }

    private func saveImageToProject(named name: String, mode: String, pngData: Data) -> Bool {
        guard let imgDir = imgDirectory() else {
            print("Could not determine img directory")
            return false
        }

        // Ensure directory exists
        try? FileManager.default.createDirectory(at: imgDir, withIntermediateDirectories: true)

        let filename = "\(name)-\(mode).png"
        let fileURL = imgDir.appendingPathComponent(filename)

        do {
            try pngData.write(to: fileURL)
            print("Saved: \(fileURL.path)")
            return true
        } catch {
            print("Failed to save \(filename): \(error)")
            return false
        }
    }

    /// Generate both light and dark mode images for each example
    func testGenerateExampleImages() throws {
        // Examples from EXAMPLES.md that need images
        let examples: [(name: String, latex: String)] = [
            // Dirac Notation
            ("dirac", #"\bra{\psi} \ket{\phi} = \braket{\psi}{\phi}"#),

            // Custom Operators
            ("operatorname", #"\operatorname{argmax}_{x \in \mathbb{R}} f(x) = \operatorname*{lim}_{n \to \infty} a_n"#),

            // Manual Delimiter Sizing
            ("delimiter", #"\Bigg( \bigg( \Big( \big( x \big) \Big) \bigg) \Bigg)"#),

            // Bold Greek Symbols
            ("boldsymbol", #"\boldsymbol{\alpha} + \boldsymbol{\beta} = \boldsymbol{\gamma}"#),

            // Additional Trigonometric Functions
            ("trighyp", #"\arcsinh x + \arccosh y = \arctanh z"#),
        ]

        var successCount = 0
        var failureCount = 0

        for (name, latex) in examples {
            // Generate light mode image (black text)
            let lightResult = SwiftMathImageResult.useMathImage(
                latex: latex,
                font: font,
                fontSize: fontSize,
                textColor: MTColor.black
            )

            if let error = lightResult.error {
                print("Failed to render '\(name)' (light): \(error.localizedDescription)")
                failureCount += 1
                continue
            }

            guard let lightImage = lightResult.image, let lightData = lightImage.pngData() else {
                print("No image generated for '\(name)' (light)")
                failureCount += 1
                continue
            }

            // Generate dark mode image (white text)
            let darkResult = SwiftMathImageResult.useMathImage(
                latex: latex,
                font: font,
                fontSize: fontSize,
                textColor: MTColor.white
            )

            if let error = darkResult.error {
                print("Failed to render '\(name)' (dark): \(error.localizedDescription)")
                failureCount += 1
                continue
            }

            guard let darkImage = darkResult.image, let darkData = darkImage.pngData() else {
                print("No image generated for '\(name)' (dark)")
                failureCount += 1
                continue
            }

            // Save both images
            if saveImageToProject(named: name, mode: "light", pngData: lightData) &&
               saveImageToProject(named: name, mode: "dark", pngData: darkData) {
                successCount += 1
            } else {
                failureCount += 1
            }
        }

        print("\n=== Example Image Generation Results ===")
        print("Successfully generated: \(successCount * 2) images (\(successCount) examples)")
        print("Failed: \(failureCount)")
        if let imgDir = imgDirectory() {
            print("Output directory: \(imgDir.path)")
        }
        print("========================================\n")

        XCTAssertEqual(failureCount, 0, "All examples should generate successfully")
    }
}
