//
//  MTMathAtomFactory.swift
//  MathRenderSwift
//
//  Created by Mike Griebling on 2022-12-31.
//

import Foundation

public class MTMathAtomFactory {
    
    public static let aliases = [
        "lnot" : "neg",
        "land" : "wedge",
        "lor" : "vee",
        "ne" : "neq",
        "le" : "leq",
        "ge" : "geq",
        "lbrace" : "{",
        "rbrace" : "}",
        "Vert" : "|",
        "gets" : "leftarrow",
        "to" : "rightarrow",
        "iff" : "Longleftrightarrow",
        "AA" : "angstrom"
    ]
    
    public static let delimiters = [
        "." : "", // . means no delimiter
        "(" : "(",
        ")" : ")",
        "[" : "[",
        "]" : "]",
        "<" : "\u{2329}",
        ">" : "\u{232A}",
        "/" : "/",
        "\\" : "\\",
        "|" : "|",
        "lgroup" : "\u{27EE}",
        "rgroup" : "\u{27EF}",
        "||" : "\u{2016}",
        "Vert" : "\u{2016}",
        "vert" : "|",
        "uparrow" : "\u{2191}",
        "downarrow" : "\u{2193}",
        "updownarrow" : "\u{2195}",
        "Uparrow" : "\u{21D1}",
        "Downarrow" : "\u{21D3}",
        "Updownarrow" : "\u{21D5}",
        "backslash" : "\\",
        "rangle" : "\u{232A}",
        "langle" : "\u{2329}",
        "rbrace" : "}",
        "}" : "}",
        "{" : "{",
        "lbrace" : "{",
        "lceil" : "\u{2308}",
        "rceil" : "\u{2309}",
        "lfloor" : "\u{230A}",
        "rfloor" : "\u{230B}"
    ]
    
    var _delimValueToName: [String: String]? = nil
    public var delimValueToName: [String: String] {
        if _delimValueToName == nil {
            var output = [String: String]()
            
            for (key, value) in Self.delimiters {
                if let existingValue = output[value] {
                    if key.count > existingValue.count {
                        continue
                    } else if key.count == existingValue.count {
                        if key.compare(existingValue) == .orderedDescending {
                            continue
                        }
                    }
                }
                
                output[value] = key
            }
            _delimValueToName = output
        }
        return _delimValueToName!
    }
    
    public static let accents = [
        "grave" :  "\u{0300}",
        "acute" :  "\u{0301}",
        "hat" :  "\u{0302}",  // In our implementation hat and widehat behave the same.
        "tilde" :  "\u{0303}", // In our implementation tilde and widetilde behave the same.
        "bar" :  "\u{0304}",
        "breve" :  "\u{0306}",
        "dot" :  "\u{0307}",
        "ddot" :  "\u{0308}",
        "check" :  "\u{030C}",
        "vec" :  "\u{20D7}",
        "widehat" :  "\u{0302}",
        "widetilde" :  "\u{0303}"
    ]
    
    static var _accentValueToName: [String: String]? = nil
    public static var accentValueToName: [String: String] {
        if _accentValueToName == nil {
            var output = [String: String]()

            for (key, value) in Self.accents {
                if let existingValue = output[value] {
                    if key.count > existingValue.count {
                        continue
                    } else if key.count == existingValue.count {
                        if key.compare(existingValue) == .orderedDescending {
                            continue
                        }
                    }
                }
                output[value] = key
            }
            _accentValueToName = output
        }
        return _accentValueToName!
    }
    
    public static var supportedLatexSymbols: [String: MTMathAtom] = [
        "square" : MTMathAtomFactory.placeholder(),
        
         // Greek characters
        "alpha" : MTMathAtom(type: .variable, value: "\u{03B1}"),
        "beta" : MTMathAtom(type: .variable, value: "\u{03B2}"),
        "gamma" : MTMathAtom(type: .variable, value: "\u{03B3}"),
        "delta" : MTMathAtom(type: .variable, value: "\u{03B4}"),
        "varepsilon" : MTMathAtom(type: .variable, value: "\u{03B5}"),
        "zeta" : MTMathAtom(type: .variable, value: "\u{03B6}"),
        "eta" : MTMathAtom(type: .variable, value: "\u{03B7}"),
        "theta" : MTMathAtom(type: .variable, value: "\u{03B8}"),
        "iota" : MTMathAtom(type: .variable, value: "\u{03B9}"),
        "kappa" : MTMathAtom(type: .variable, value: "\u{03BA}"),
        "lambda" : MTMathAtom(type: .variable, value: "\u{03BB}"),
        "mu" : MTMathAtom(type: .variable, value: "\u{03BC}"),
        "nu" : MTMathAtom(type: .variable, value: "\u{03BD}"),
        "xi" : MTMathAtom(type: .variable, value: "\u{03BE}"),
        "omicron" : MTMathAtom(type: .variable, value: "\u{03BF}"),
        "pi" : MTMathAtom(type: .variable, value: "\u{03C0}"),
        "rho" : MTMathAtom(type: .variable, value: "\u{03C1}"),
        "varsigma" : MTMathAtom(type: .variable, value: "\u{03C1}"),
        "sigma" : MTMathAtom(type: .variable, value: "\u{03C3}"),
        "tau" : MTMathAtom(type: .variable, value: "\u{03C4}"),
        "upsilon" : MTMathAtom(type: .variable, value: "\u{03C5}"),
        "varphi" : MTMathAtom(type: .variable, value: "\u{03C6}"),
        "chi" : MTMathAtom(type: .variable, value: "\u{03C7}"),
        "psi" : MTMathAtom(type: .variable, value: "\u{03C8}"),
        "omega" : MTMathAtom(type: .variable, value: "\u{03C9}"),
        // We mark the following greek chars as ordinary so that we don't try
        // to automatically italicize them as we do with variables.
        // These characters fall outside the rules of italicization that we have defined.
        "epsilon" : MTMathAtom(type: .ordinary, value: "\u{0001D716}"),
        "vartheta" : MTMathAtom(type: .ordinary, value: "\u{0001D717}"),
        "phi" : MTMathAtom(type: .ordinary, value: "\u{0001D719}"),
        "varrho" : MTMathAtom(type: .ordinary, value: "\u{0001D71A}"),
        "varpi" : MTMathAtom(type: .ordinary, value: "\u{0001D71B}"),

        // Capital greek characters
        "Gamma" : MTMathAtom(type: .variable, value: "\u{0393}"),
        "Delta" : MTMathAtom(type: .variable, value: "\u{0394}"),
        "Theta" : MTMathAtom(type: .variable, value: "\u{0398}"),
        "Lambda" : MTMathAtom(type: .variable, value: "\u{039B}"),
        "Xi" : MTMathAtom(type: .variable, value: "\u{039E}"),
        "Pi" : MTMathAtom(type: .variable, value: "\u{03A0}"),
        "Sigma" : MTMathAtom(type: .variable, value: "\u{03A3}"),
        "Upsilon" : MTMathAtom(type: .variable, value: "\u{03A5}"),
        "Phi" : MTMathAtom(type: .variable, value: "\u{03A6}"),
        "Psi" : MTMathAtom(type: .variable, value: "\u{03A8}"),
        "Omega" : MTMathAtom(type: .variable, value: "\u{03A9}"),

        // Open
        "lceil" : MTMathAtom(type: .open, value: "\u{2308}"),
        "lfloor" : MTMathAtom(type: .open, value: "\u{230A}"),
        "langle" : MTMathAtom(type: .open, value: "\u{27E8}"),
        "lgroup" : MTMathAtom(type: .open, value: "\u{27EE}"),

        // Close
        "rceil" : MTMathAtom(type: .close, value: "\u{2309}"),
        "rfloor" : MTMathAtom(type: .close, value: "\u{230B}"),
        "rangle" : MTMathAtom(type: .close, value: "\u{27E9}"),
        "rgroup" : MTMathAtom(type: .close, value: "\u{27EF}"),

        // Arrows
        "leftarrow" : MTMathAtom(type: .relation, value: "\u{2190}"),
        "uparrow" : MTMathAtom(type: .relation, value: "\u{2191}"),
        "rightarrow" : MTMathAtom(type: .relation, value: "\u{2192}"),
        "downarrow" : MTMathAtom(type: .relation, value: "\u{2193}"),
        "leftrightarrow" : MTMathAtom(type: .relation, value: "\u{2194}"),
        "updownarrow" : MTMathAtom(type: .relation, value: "\u{2195}"),
        "nwarrow" : MTMathAtom(type: .relation, value: "\u{2196}"),
        "nearrow" : MTMathAtom(type: .relation, value: "\u{2197}"),
        "searrow" : MTMathAtom(type: .relation, value: "\u{2198}"),
        "swarrow" : MTMathAtom(type: .relation, value: "\u{2199}"),
        "mapsto" : MTMathAtom(type: .relation, value: "\u{21A6}"),
        "Leftarrow" : MTMathAtom(type: .relation, value: "\u{21D0}"),
        "Uparrow" : MTMathAtom(type: .relation, value: "\u{21D1}"),
        "Rightarrow" : MTMathAtom(type: .relation, value: "\u{21D2}"),
        "Downarrow" : MTMathAtom(type: .relation, value: "\u{21D3}"),
        "Leftrightarrow" : MTMathAtom(type: .relation, value: "\u{21D4}"),
        "Updownarrow" : MTMathAtom(type: .relation, value: "\u{21D5}"),
        "longleftarrow" : MTMathAtom(type: .relation, value: "\u{27F5}"),
        "longrightarrow" : MTMathAtom(type: .relation, value: "\u{27F6}"),
        "longleftrightarrow" : MTMathAtom(type: .relation, value: "\u{27F7}"),
        "Longleftarrow" : MTMathAtom(type: .relation, value: "\u{27F8}"),
        "Longrightarrow" : MTMathAtom(type: .relation, value: "\u{27F9}"),
        "Longleftrightarrow" : MTMathAtom(type: .relation, value: "\u{27FA}"),


        // Relations
        "leq" : MTMathAtom(type: .relation, value: UnicodeSymbol.lessEqual),
        "geq" : MTMathAtom(type: .relation, value: UnicodeSymbol.greaterEqual),
        "neq" : MTMathAtom(type: .relation, value: UnicodeSymbol.notEqual),
        "in" : MTMathAtom(type: .relation, value: "\u{2208}"),
        "notin" : MTMathAtom(type: .relation, value: "\u{2209}"),
        "ni" : MTMathAtom(type: .relation, value: "\u{220B}"),
        "propto" : MTMathAtom(type: .relation, value: "\u{221D}"),
        "mid" : MTMathAtom(type: .relation, value: "\u{2223}"),
        "parallel" : MTMathAtom(type: .relation, value: "\u{2225}"),
        "sim" : MTMathAtom(type: .relation, value: "\u{223C}"),
        "simeq" : MTMathAtom(type: .relation, value: "\u{2243}"),
        "cong" : MTMathAtom(type: .relation, value: "\u{2245}"),
        "approx" : MTMathAtom(type: .relation, value: "\u{2248}"),
        "asymp" : MTMathAtom(type: .relation, value: "\u{224D}"),
        "doteq" : MTMathAtom(type: .relation, value: "\u{2250}"),
        "equiv" : MTMathAtom(type: .relation, value: "\u{2261}"),
        "gg" : MTMathAtom(type: .relation, value: "\u{226A}"),
        "ll" : MTMathAtom(type: .relation, value: "\u{226B}"),
        "prec" : MTMathAtom(type: .relation, value: "\u{227A}"),
        "succ" : MTMathAtom(type: .relation, value: "\u{227B}"),
        "subset" : MTMathAtom(type: .relation, value: "\u{2282}"),
        "supset" : MTMathAtom(type: .relation, value: "\u{2283}"),
        "subseteq" : MTMathAtom(type: .relation, value: "\u{2286}"),
        "supseteq" : MTMathAtom(type: .relation, value: "\u{2287}"),
        "sqsubset" : MTMathAtom(type: .relation, value: "\u{228F}"),
        "sqsupset" : MTMathAtom(type: .relation, value: "\u{2290}"),
        "sqsubseteq" : MTMathAtom(type: .relation, value: "\u{2291}"),
        "sqsupseteq" : MTMathAtom(type: .relation, value: "\u{2292}"),
        "models" : MTMathAtom(type: .relation, value: "\u{22A7}"),
        "perp" : MTMathAtom(type: .relation, value: "\u{27C2}"),

        // operators
        "times" : MTMathAtomFactory.times(),
        "div"   : MTMathAtomFactory.divide(),
        "pm"    : MTMathAtom(type: .binaryOperator, value: "\u{00B1}"),
        "dagger" : MTMathAtom(type: .binaryOperator, value: "\u{2020}"),
        "ddagger" : MTMathAtom(type: .binaryOperator, value: "\u{2021}"),
        "mp"    : MTMathAtom(type: .binaryOperator, value: "\u{2213}"),
        "setminus" : MTMathAtom(type: .binaryOperator, value: "\u{2216}"),
        "ast"   : MTMathAtom(type: .binaryOperator, value: "\u{2217}"),
        "circ"  : MTMathAtom(type: .binaryOperator, value: "\u{2218}"),
        "bullet" : MTMathAtom(type: .binaryOperator, value: "\u{2219}"),
        "wedge" : MTMathAtom(type: .binaryOperator, value: "\u{2227}"),
        "vee" : MTMathAtom(type: .binaryOperator, value: "\u{2228}"),
        "cap" : MTMathAtom(type: .binaryOperator, value: "\u{2229}"),
        "cup" : MTMathAtom(type: .binaryOperator, value: "\u{222A}"),
        "wr" : MTMathAtom(type: .binaryOperator, value: "\u{2240}"),
        "uplus" : MTMathAtom(type: .binaryOperator, value: "\u{228E}"),
        "sqcap" : MTMathAtom(type: .binaryOperator, value: "\u{2293}"),
        "sqcup" : MTMathAtom(type: .binaryOperator, value: "\u{2294}"),
        "oplus" : MTMathAtom(type: .binaryOperator, value: "\u{2295}"),
        "ominus" : MTMathAtom(type: .binaryOperator, value: "\u{2296}"),
        "otimes" : MTMathAtom(type: .binaryOperator, value: "\u{2297}"),
        "oslash" : MTMathAtom(type: .binaryOperator, value: "\u{2298}"),
        "odot" : MTMathAtom(type: .binaryOperator, value: "\u{2299}"),
        "star"  : MTMathAtom(type: .binaryOperator, value: "\u{22C6}"),
        "cdot"  : MTMathAtom(type: .binaryOperator, value: "\u{22C5}"),
        "amalg" : MTMathAtom(type: .binaryOperator, value: "\u{2A3F}"),

        // No limit operators
        "log" : MTMathAtomFactory.operatorWithName( "log", limits: false),
        "lg" : MTMathAtomFactory.operatorWithName( "lg", limits: false),
        "ln" : MTMathAtomFactory.operatorWithName( "ln", limits: false),
        "sin" : MTMathAtomFactory.operatorWithName( "sin", limits: false),
        "arcsin" : MTMathAtomFactory.operatorWithName( "arcsin", limits: false),
        "sinh" : MTMathAtomFactory.operatorWithName( "sinh", limits: false),
        "cos" : MTMathAtomFactory.operatorWithName( "cos", limits: false),
        "arccos" : MTMathAtomFactory.operatorWithName( "arccos", limits: false),
        "cosh" : MTMathAtomFactory.operatorWithName( "cosh", limits: false),
        "tan" : MTMathAtomFactory.operatorWithName( "tan", limits: false),
        "arctan" : MTMathAtomFactory.operatorWithName( "arctan", limits: false),
        "tanh" : MTMathAtomFactory.operatorWithName( "tanh", limits: false),
        "cot" : MTMathAtomFactory.operatorWithName( "cot", limits: false),
        "coth" : MTMathAtomFactory.operatorWithName( "coth", limits: false),
        "sec" : MTMathAtomFactory.operatorWithName( "sec", limits: false),
        "csc" : MTMathAtomFactory.operatorWithName( "csc", limits: false),
        "arg" : MTMathAtomFactory.operatorWithName( "arg", limits: false),
        "ker" : MTMathAtomFactory.operatorWithName( "ker", limits: false),
        "dim" : MTMathAtomFactory.operatorWithName( "dim", limits: false),
        "hom" : MTMathAtomFactory.operatorWithName( "hom", limits: false),
        "exp" : MTMathAtomFactory.operatorWithName( "exp", limits: false),
        "deg" : MTMathAtomFactory.operatorWithName( "deg", limits: false),

        // Limit operators
        "lim" : MTMathAtomFactory.operatorWithName( "lim", limits: true),
        "limsup" : MTMathAtomFactory.operatorWithName( "lim sup", limits: true),
        "liminf" : MTMathAtomFactory.operatorWithName( "lim inf", limits: true),
        "max" : MTMathAtomFactory.operatorWithName( "max", limits: true),
        "min" : MTMathAtomFactory.operatorWithName( "min", limits: true),
        "sup" : MTMathAtomFactory.operatorWithName( "sup", limits: true),
        "inf" : MTMathAtomFactory.operatorWithName( "inf", limits: true),
        "det" : MTMathAtomFactory.operatorWithName( "det", limits: true),
        "Pr" : MTMathAtomFactory.operatorWithName( "Pr", limits: true),
        "gcd" : MTMathAtomFactory.operatorWithName( "gcd", limits: true),

        // Large operators
        "prod" : MTMathAtomFactory.operatorWithName( "\u{220F}", limits: true),
        "coprod" : MTMathAtomFactory.operatorWithName( "\u{2210}", limits: true),
        "sum" : MTMathAtomFactory.operatorWithName( "\u{2211}", limits: true),
        "int" : MTMathAtomFactory.operatorWithName( "\u{222B}", limits: false),
        "oint" : MTMathAtomFactory.operatorWithName( "\u{222E}", limits: false),
        "bigwedge" : MTMathAtomFactory.operatorWithName( "\u{22C0}", limits: true),
        "bigvee" : MTMathAtomFactory.operatorWithName( "\u{22C1}", limits: true),
        "bigcap" : MTMathAtomFactory.operatorWithName( "\u{22C2}", limits: true),
        "bigcup" : MTMathAtomFactory.operatorWithName( "\u{22C3}", limits: true),
        "bigodot" : MTMathAtomFactory.operatorWithName( "\u{2A00}", limits: true),
        "bigoplus" : MTMathAtomFactory.operatorWithName( "\u{2A01}", limits: true),
        "bigotimes" : MTMathAtomFactory.operatorWithName( "\u{2A02}", limits: true),
        "biguplus" : MTMathAtomFactory.operatorWithName( "\u{2A04}", limits: true),
        "bigsqcup" : MTMathAtomFactory.operatorWithName( "\u{2A06}", limits: true),

        // Latex command characters
        "{" : MTMathAtom(type: .open, value: "{"),
        "}" : MTMathAtom(type: .close, value: "}"),
        "$" : MTMathAtom(type: .ordinary, value: "{"),
        "&" : MTMathAtom(type: .ordinary, value: "&"),
        "#" : MTMathAtom(type: .ordinary, value: "#"),
        "%" : MTMathAtom(type: .ordinary, value: "%"),
        "_" : MTMathAtom(type: .ordinary, value: "_"),
        " " : MTMathAtom(type: .ordinary, value: " "),
        "backslash" : MTMathAtom(type: .ordinary, value: "\\"),

        // Punctuation
        // Note: \colon is different from : which is a relation
        "colon" : MTMathAtom(type: .punctuation, value: ":"),
        "cdotp" : MTMathAtom(type: .punctuation, value: "\u{00B7}"),

        // Other symbols
        "degree" : MTMathAtom(type: .ordinary, value: "\u{00B0}"),
        "neg" : MTMathAtom(type: .ordinary, value: "\u{00AC}"),
        "angstrom" : MTMathAtom(type: .ordinary, value: "\u{00C5}"),
        "|" : MTMathAtom(type: .ordinary, value: "\u{2016}"),
        "vert" : MTMathAtom(type: .ordinary, value: "|"),
        "ldots" : MTMathAtom(type: .ordinary, value: "\u{2026}"),
        "prime" : MTMathAtom(type: .ordinary, value: "\u{2032}"),
        "hbar" : MTMathAtom(type: .ordinary, value: "\u{210F}"),
        "Im" : MTMathAtom(type: .ordinary, value: "\u{2111}"),
        "ell" : MTMathAtom(type: .ordinary, value: "\u{2113}"),
        "wp" : MTMathAtom(type: .ordinary, value: "\u{2118}"),
        "Re" : MTMathAtom(type: .ordinary, value: "\u{211C}"),
        "mho" : MTMathAtom(type: .ordinary, value: "\u{2127}"),
        "aleph" : MTMathAtom(type: .ordinary, value: "\u{2135}"),
        "forall" : MTMathAtom(type: .ordinary, value: "\u{2200}"),
        "exists" : MTMathAtom(type: .ordinary, value: "\u{2203}"),
        "emptyset" : MTMathAtom(type: .ordinary, value: "\u{2205}"),
        "nabla" : MTMathAtom(type: .ordinary, value: "\u{2207}"),
        "infty" : MTMathAtom(type: .ordinary, value: "\u{221E}"),
        "angle" : MTMathAtom(type: .ordinary, value: "\u{2220}"),
        "top" : MTMathAtom(type: .ordinary, value: "\u{22A4}"),
        "bot" : MTMathAtom(type: .ordinary, value: "\u{22A5}"),
        "vdots" : MTMathAtom(type: .ordinary, value: "\u{22EE}"),
        "cdots" : MTMathAtom(type: .ordinary, value: "\u{22EF}"),
        "ddots" : MTMathAtom(type: .ordinary, value: "\u{22F1}"),
        "triangle" : MTMathAtom(type: .ordinary, value: "\u{25B3}"),
        "imath" : MTMathAtom(type: .ordinary, value: "\u{0001D6A4}"),
        "jmath" : MTMathAtom(type: .ordinary, value: "\u{0001D6A5}"),
        "partial" : MTMathAtom(type: .ordinary, value: "\u{0001D715}"),

        // Spacing
        "," : MTMathSpace(space: 3),
        ">" : MTMathSpace(space: 4),
        ";" : MTMathSpace(space: 5),
        "!" : MTMathSpace(space: -3),
        "quad" : MTMathSpace(space: 18),  // quad = 1em = 18mu
        "qquad" : MTMathSpace(space: 36), // qquad = 2em

        // Style
        "displaystyle" : MTMathStyle(style: .display),
        "textstyle" : MTMathStyle(style: .text),
        "scriptstyle" : MTMathStyle(style: .script),
        "scriptscriptstyle" : MTMathStyle(style: .scriptOfScript),
    ]
    
    var _textToLatexSymbolName: [String: String]? = nil
    public var textToLatexSymbolName: [String: String] {
        get {
            if self._textToLatexSymbolName == nil {
                var output = [String: String]()
                for (key, atom) in Self.supportedLatexSymbols {
                    if atom.nucleus.count == 0 {
                        continue
                    }
                    if let existingText = output[atom.nucleus] {
                        // If there are 2 key for the same symbol, choose one deterministically.
                        if key.count > existingText.count {
                            // Keep the shorter command
                            continue
                        } else if key.count == existingText.count {
                            // If the length is the same, keep the alphabetically first
                            if key.compare(existingText) == .orderedDescending {
                                continue
                            }
                        }
                    }
                    output[atom.nucleus] = key
                }
                self._textToLatexSymbolName = output
            }
            return self._textToLatexSymbolName!
        }
        set {
            self._textToLatexSymbolName = newValue
        }
    }
    
    public static let sharedInstance = MTMathAtomFactory()
    
    static let fontStyles : [String: MTFontStyle] = [
        "mathnormal" : .defaultStyle,
        "mathrm": .roman,
        "textrm": .roman,
        "rm": .roman,
        "mathbf": .bold,
        "bf": .bold,
        "textbf": .bold,
        "mathcal": .caligraphic,
        "cal": .caligraphic,
        "mathtt": .typewriter,
        "texttt": .typewriter,
        "mathit": .italic,
        "textit": .italic,
        "mit": .italic,
        "mathsf": .sansSerif,
        "textsf": .sansSerif,
        "mathfrak": .fraktur,
        "frak": .fraktur,
        "mathbb": .blackboard,
        "mathbfit": .boldItalic,
        "bm": .boldItalic,
        "text": .roman,
    ]
    
    public static func fontStyleWithName(_ fontName:String) -> MTFontStyle? {
        return fontStyles[fontName]
    }
    
    public static func fontNameForStyle(_ fontStyle:MTFontStyle) -> String {
        switch fontStyle {
            case .defaultStyle:
                return "mathnormal";

            case .roman:
                return "mathrm";

            case .bold:
                return "mathbf";

            case .fraktur:
                return "mathfrak";

            case .caligraphic:
                return "mathcal";

            case .italic:
                return "mathit";

            case .sansSerif:
                return "mathsf";

            case .blackboard:
                return "mathbb";

            case .typewriter:
                return "mathtt";

            case .boldItalic:
                return "bm";
        }
    }
    
    // Return an atom for times sign \times or *
    public static func times() -> MTMathAtom {
        return MTMathAtom(type: .binaryOperator, value: UnicodeSymbol.multiplication)
    }
    
    // Return an atom for division sign \div or /
    public static func divide() -> MTMathAtom {
        return MTMathAtom(type: .binaryOperator, value: UnicodeSymbol.division)
    }
    
    // Return an atom aka placeholder square
    public static func placeholder() -> MTMathAtom {
        return MTMathAtom(type: .placeholder, value: UnicodeSymbol.whiteSquare)
    }
    
    public static func placeholderFraction() -> MTFraction {
        let frac = MTFraction()
        
        frac.numerator = MTMathList()
        frac.numerator?.add(placeholder())
        frac.denominator = MTMathList()
        frac.denominator?.add(placeholder())
        
        return frac
    }
    
    public static func placeholderSquareRoot() -> MTRadical {
        let rad = MTRadical()
        
        rad.radicand = MTMathList()
        rad.radicand?.add(placeholder())
        
        return rad
    }
    
    public static func placeholderRadical() -> MTRadical {
        let rad = MTRadical()
        
        rad.radicand = MTMathList()
        rad.degree = MTMathList()
        
        rad.radicand?.add(placeholder())
        rad.degree?.add(placeholder())
        
        return rad
    }
    
    /** Gets the atom with the right type for the given character. If an atom
     cannot be determined for a given character this returns nil.
     This function follows latex conventions for assigning types to the atoms.
     The following characters are not supported and will return nil:
     - Any non-ascii character.
     - Any control character or spaces (< 0x21)
     - Latex control chars: $ % # & ~ '
     - Chars with special meaning in latex: ^ _ { } \
     All other characters will have a non-nil atom returned.
     */
    public static func atom(forCharacter ch: Character) -> MTMathAtom? {
        let chStr = String(ch)
        switch chStr {
            case "\\u{0410}"..."\\u{044F}":
                return MTMathAtom(type: .ordinary, value: chStr)
            case _ where ch.utf32Char < 0x0021 || ch.utf32Char > 0x007E:
                return nil
            case "$", "%", "#", "&", "~", "\'", "^", "_", "{", "}", "\\":
                return nil
            case "(", "[":
                return MTMathAtom(type: .open, value: chStr)
            case ")", "]", "!", "?":
                return MTMathAtom(type: .close, value: chStr)
            case ",", ";":
                return MTMathAtom(type: .punctuation, value: chStr)
            case "=", ">", "<":
                return MTMathAtom(type: .relation, value: chStr)
            case ":":
                // Math colon is ratio. Regular colon is \colon
                return MTMathAtom(type: .relation, value: "\u{2236}")
            case "-":
                return MTMathAtom(type: .binaryOperator, value: "\u{2212}")
            case "+", "*":
                return MTMathAtom(type: .binaryOperator, value: chStr)
            case ".", "0"..."9":
                return MTMathAtom(type: .number, value: chStr)
            case "a"..."z", "A"..."Z":
                return MTMathAtom(type: .variable, value: chStr)
            case "\"", "/", "@", "`", "|":
                return MTMathAtom(type: .ordinary, value: chStr)
            default:
                assertionFailure("Unknown ASCII character '\(ch)'. Should have been handled earlier.")
                return nil
        }
    }
    
    /** Returns a `MTMathList` with one atom per character in the given string. This function
     does not do any LaTeX conversion or interpretation. It simply uses `atomForCharacter` to
     convert the characters to atoms. Any character that cannot be converted is ignored. */
    public static func atomList(for string: String) -> MTMathList {
        let list = MTMathList()
        
        for character in string {
            if let newAtom = atom(forCharacter: character) {
                list.add(newAtom)
            }
        }
        
        return list
    }
    
    /** Returns an atom with the right type for a given latex symbol (e.g. theta)
     If the latex symbol is unknown this will return nil. This supports LaTeX aliases as well.
     */
    public static func atom(forLatexSymbol name: String) -> MTMathAtom? {
        var name = name
        
        if let canonicalName = aliases[name] {
            name = canonicalName
        }
        
        if let atom = supportedLatexSymbols[name] {
            if name == "int" { return MTMathAtomFactory.operatorWithName( "\u{222B}", limits: false) }
            if name == "sum" { return MTMathAtomFactory.operatorWithName( "\u{2211}", limits: true) }
            return atom
        }
        
        return nil
    }
    
    /** Finds the name of the LaTeX symbol name for the given atom. This function is a reverse
     of the above function. If no latex symbol name corresponds to the atom, then this returns `nil`
     If nucleus of the atom is empty, then this will return `nil`.
     @note: This is not an exact reverse of the above in the case of aliases. If an LaTeX alias
     points to a given symbol, then this function will return the original symbol name and not the
     alias.
     @note: This function does not convert MathSpaces to latex command names either.
     */
    public static func latexSymbolName(for atom: MTMathAtom) -> String? {
        if atom.nucleus.count == 0 {
            return nil
        }
        
        return sharedInstance.textToLatexSymbolName[atom.nucleus]
    }
    
    /** Define a latex symbol for rendering. This function allows defining custom symbols that are
     not already present in the default set, or override existing symbols with new meaning.
     e.g. to define a symbol for "lcm" one can call:
     `[MTMathAtomFactory addLatexSymbol:@"lcm" value:[MTMathAtomFactory operatorWithName:@"lcm" limits: false)]` */
    
    public static func add(latexSymbol name: String, value: MTMathAtom) {
        supportedLatexSymbols[name] = value
        sharedInstance.textToLatexSymbolName[value.nucleus] = name
    }
    
    /** Returns a large opertor for the given name. If limits is true, limits are set up on
     the operator and displayed differently. */
    public static func operatorWithName(_ name: String, limits: Bool) -> MTLargeOperator {
        return MTLargeOperator(value: name, limits: limits)
    }
    
    /** Returns an accent with the given name. The name of the accent is the LaTeX name
     such as `grave`, `hat` etc. If the name is not a recognized accent name, this
     returns nil. The `innerList` of the returned `MTAccent` is nil.
     */
    public static func accent(withName name: String) -> MTAccent? {
        if let accentValue = accents[name] {
            return MTAccent(value: accentValue)
        }
        return nil
    }
    
    /** Returns the accent name for the given accent. This is the reverse of the above
     function. */
    public static func accentName(_ accent: MTAccent) -> String? {
        return accentValueToName[accent.nucleus]
    }
    
    /** Creates a new boundary atom for the given delimiter name. If the delimiter name
     is not recognized it returns nil. A delimiter name can be a single character such
     as '(' or a latex command such as 'uparrow'.
     @note In order to distinguish between the delimiter '|' and the delimiter '\|' the delimiter '\|'
     the has been renamed to '||'.
     */
    public static func boundary(forDelimiter name: String) -> MTMathAtom? {
        if let delimValue = Self.delimiters[name] {
            return MTMathAtom(type: .boundary, value: delimValue)
        }
        return nil
    }
    
    /** Returns the delimiter name for a boundary atom. This is a reverse of the above function.
     If the atom is not a boundary atom or if the delimiter value is unknown this returns `nil`.
     @note This is not an exact reverse of the above function. Some delimiters have two names (e.g.
     `<` and `langle`) and this function always returns the shorter name.
     */
    public static func getDelimiterName(of boundary: MTMathAtom) -> String? {
        if boundary.type != .boundary {
            return nil
        }
        return Self.sharedInstance.delimValueToName[boundary.nucleus]
    }
    
    /** Returns a fraction with the given numerator and denominator. */
    public static func fraction(withNumerator num: MTMathList, denominator denom: MTMathList) -> MTFraction {
        let frac = MTFraction()
        
        frac.numerator = num
        frac.denominator = denom
        
        return frac
    }
    
    /** Simplification of above function when numerator and denominator are simple strings.
     This function uses `mathListForCharacters` to convert the strings to `MTMathList`s. */
    public static func fraction(withNumeratorString numStr: String, denominatorString denomStr: String) -> MTFraction {
        let num = Self.atomList(for: numStr)
        let denom = Self.atomList(for: denomStr)
        
        return Self.fraction(withNumerator: num, denominator: denom)
    }
    
    /** Builds a table for a given environment with the given rows. Returns a `MTMathAtom` containing the
     table and any other atoms necessary for the given environment. Returns nil and sets error
     if the table could not be built.
     @param env The environment to use to build the table. If the env is nil, then the default table is built.
     @note The reason this function returns a `MTMathAtom` and not a `MTMathTable` is because some
     matrix environments are have builtin delimiters added to the table and hence are returned as inner atoms.
     */
    public static func table(withEnvironment env: String?, rows: [[MTMathList]], error:inout NSError?) -> MTMathAtom? {
        let table = MTMathTable(environment: env)
        
        for i in 0..<rows.count {
            let row = rows[i]
            for j in 0..<row.count {
                table.set(cell: row[j], forRow: i, column: j)
            }
        }
        
        let matrixEnvs = [
            "matrix": [],
            "pmatrix": ["(", ")"],
            "bmatrix": ["[", "]"],
            "Bmatrix": ["{", "}"],
            "vmatrix": ["vert", "vert"],
            "Vmatrix": ["Vert", "Vert"]
        ]
        
        if env == nil {
            table.interColumnSpacing = 0
            table.interRowAdditionalSpacing = 1
            for i in 0..<table.numColumns {
                table.set(alignment: .left, forColumn: i)
            }
            return table
        } else if let env = env {
            if let delims = matrixEnvs[env] {
                table.environment = "matrix"
                table.interRowAdditionalSpacing = 0
                table.interColumnSpacing = 18
                
                let style = MTMathStyle(style: .text)
                
                for i in 0..<table.cells.count {
                    for j in 0..<table.cells[i].count {
                        table.cells[i][j].insert(style, at: 0)
                    }
                }
                
                if delims.count == 2 {
                    let inner = MTInner()
                    inner.leftBoundary = Self.boundary(forDelimiter: delims[0])
                    inner.rightBoundary = Self.boundary(forDelimiter: delims[1])
                    inner.innerList = MTMathList(atoms: [table])
                    return inner
                } else {
                    return table
                }
            } else if env == "eqalign" || env == "split" || env == "aligned" {
                if table.numColumns != 2 {
                    let message = "\(env) environment can only have 2 columns"
                    if error == nil {
                        error = NSError(domain: MTParseError, code: MTParseErrors.invalidNumColumns.rawValue, userInfo: [NSLocalizedDescriptionKey:message])
                    }
                    return nil
                }
                
                let spacer = MTMathAtom(type: .ordinary, value: "")
                
                for i in 0..<table.cells.count {
                    if table.cells[i].count >= 1 {
                        table.cells[i][1].insert(spacer, at: 0)
                    }
                }
                
                table.interRowAdditionalSpacing = 1
                table.interColumnSpacing = 0
                
                table.set(alignment: .right, forColumn: 0)
                table.set(alignment: .left, forColumn: 1)
                
                return table
            } else if env == "displaylines" || env == "gather" {
                if table.numColumns != 1 {
                    let message = "\(env) environment can only have 1 column"
                    if error == nil {
                        error = NSError(domain: MTParseError, code: MTParseErrors.invalidNumColumns.rawValue, userInfo: [NSLocalizedDescriptionKey:message])
                    }
                    return nil
                }
                
                table.interRowAdditionalSpacing = 1
                table.interColumnSpacing = 0
                
                table.set(alignment: .center, forColumn: 0)
                
                return table
            } else if env == "eqnarray" {
                if table.numColumns != 3 {
                    let message = "\(env) environment can only have 3 columns"
                    if error == nil {
                        error = NSError(domain: MTParseError, code: MTParseErrors.invalidNumColumns.rawValue, userInfo: [NSLocalizedDescriptionKey:message])
                    }
                    return nil
                }
                
                table.interRowAdditionalSpacing = 1
                table.interColumnSpacing = 18
                
                table.set(alignment: .right, forColumn: 0)
                table.set(alignment: .center, forColumn: 1)
                table.set(alignment: .left, forColumn: 2)
                
                return table
            } else if env == "cases" {
                if table.numColumns != 2 {
                    let message = "cases environment can only have 2 columns"
                    if error == nil {
                        error = NSError(domain: MTParseError, code: MTParseErrors.invalidNumColumns.rawValue, userInfo: [NSLocalizedDescriptionKey:message])
                    }
                    return nil
                }
                
                table.interRowAdditionalSpacing = 0
                table.interColumnSpacing = 18
                
                table.set(alignment: .left, forColumn: 0)
                table.set(alignment: .left, forColumn: 1)
                
                let style = MTMathStyle(style: .text)
                
                
                for i in 0..<table.cells.count {
                    for j in 0..<table.cells[i].count {
                        table.cells[i][j].insert(style, at: 0)
                    }
                }
                
                let inner = MTInner()
                inner.leftBoundary = Self.boundary(forDelimiter: "{")
                inner.rightBoundary = Self.boundary(forDelimiter: ".")
                let space = Self.atom(forLatexSymbol: ",")!
                
                inner.innerList = MTMathList(atoms: [space, table])
                
                return inner
            } else {
                let message = "Unknown environment \(env)"
                error = NSError(domain: MTParseError, code: MTParseErrors.invalidEnv.rawValue, userInfo: [NSLocalizedDescriptionKey:message])
                return nil
            }
        }
        return nil
    }
}
