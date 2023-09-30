//
//  MathTexParser.swift
//
//
//  Created by Peter Tang on 22/9/2023.
//

import Foundation
// import Antlr4
// import TexParser
import Patterns
import SwiftPEG

internal class MathTexParser {
    // func parse(input: String) {
    //     let iStream = ANTLRInputStream(input)
    //     let lexer = TeXLexer(iStream)
    //     let tokenStream = CommonTokenStream(lexer)
    //     if let parser = try? TeXParser(tokenStream), let _ = try? parser.prog() {
    //     }
    // }
    
    typealias RangesAndProperties = [(range: ClosedRange<UInt32>, property: Substring)]

    func unicodeParse(fromDataFile text: String) -> RangesAndProperties {
        let hexNumber = Capture(name: "hexNumber", hexDigit+)
        let hexRange = hexNumber • ".." • hexNumber / hexNumber
        let rangeAndProperty = Line.Start() • hexRange • Skip() • "; " • Capture(name: "property", Skip()) • " "

        return try! Parser(search: rangeAndProperty).matches(in: text).map { match in
            let propertyName = text[match[one: "property"]!]
            let oneOrTwoNumbers = match[multiple: "hexNumber"].map { UInt32(text[$0], radix: 16)! }
            let range = oneOrTwoNumbers.first! ... oneOrTwoNumbers.last!
            return (range, propertyName)
        }
    }
    func texParseWithPatterns(fromDataFile text: String) -> RangesAndProperties {
        // I might need a syntax tree as an output instead of just a list.
        return []
    }
    func markdownParseWithSwiftPEG(fromDataFile text: String) {
        let markdownSyntax = #"""
            raw_text = ~"[^\n]+"
            bold_text = ("**" raw_text "**") / ("__" raw_text "__")
            text = (bold_text / raw_text)

            h1 = "# " text
            h2 = "## " text
            h3 = "### " text
            h4 = "#### " text
            h5 = "##### " text
            h6 = "######" text
            header = (h6 / h5 / h4 / h3 / h2 / h1)

            ordered_list = (~"[0~9]+\. " text ~"\n")+

            unordered_list = (~"[-*+] " text ~"\n")+

            link = "[" raw_text "]" "(" raw_text ")"

            image = "![" raw_text "]" "(" raw_text ")"

            paragraph = (header / text)?
            doc = (paragraph ~"\n\n")* paragraph
        """#

        // Initialize the parser
        let markdownParser: SwiftPEG.Grammar = Grammar(rules: markdownSyntax)
        // Get the AST root node from the parser with the name of the rule you defined in the syntax.
        guard let ast: Node = markdownParser.parse(for: text, with: "doc") else { return }
        // Then do what ever you like with the AST

        // Or your can use the simplified AST which only contains node with named rule
        let simplifiedAst: SwiftPEG.SimplifiedNode? = simplify(for: ast)
    }
}

