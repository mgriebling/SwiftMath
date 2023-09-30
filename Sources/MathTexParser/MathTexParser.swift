//
//  MathTexParser.swift
//
//
//  Created by Peter Tang on 22/9/2023.
//

import Foundation
import Antlr4
import TexParser

internal class MathTexParser {
    func parse(input: String) {
        let iStream = ANTLRInputStream(input)
        let lexer = TeXLexer(iStream)
        let tokenStream = CommonTokenStream(lexer)
        if let parser = try? TeXParser(tokenStream), let _ = try? parser.prog() {
        }
    }
}
