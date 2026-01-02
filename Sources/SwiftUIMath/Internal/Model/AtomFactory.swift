import Foundation

extension Math {
  enum AtomFactory {
    static let aliases: [String: String] = [
      "lnot": "neg",
      "land": "wedge",
      "lor": "vee",
      "ne": "neq",
      "le": "leq",
      "ge": "geq",
      "lbrace": "{",
      "rbrace": "}",
      "Vert": "|",
      "gets": "leftarrow",
      "to": "rightarrow",
      "iff": "Longleftrightarrow",
      "AA": "angstrom",
    ]

    static let delimiters: [String: String] = [
      ".": "",  // . means no delimiter
      "(": "(",
      ")": ")",
      "[": "[",
      "]": "]",
      "<": "\u{2329}",
      ">": "\u{232A}",
      "/": "/",
      "\\": "\\",
      "|": "|",
      "lgroup": "\u{27EE}",
      "rgroup": "\u{27EF}",
      "||": "\u{2016}",
      "Vert": "\u{2016}",
      "vert": "|",
      "uparrow": "\u{2191}",
      "downarrow": "\u{2193}",
      "updownarrow": "\u{2195}",
      "Uparrow": "\u{21D1}",
      "Downarrow": "\u{21D3}",
      "Updownarrow": "\u{21D5}",
      "backslash": "\\",
      "rangle": "\u{232A}",
      "langle": "\u{2329}",
      "rbrace": "}",
      "}": "}",
      "{": "{",
      "lbrace": "{",
      "lceil": "\u{2308}",
      "rceil": "\u{2309}",
      "lfloor": "\u{230A}",
      "rfloor": "\u{230B}",
    ]

    static let delimValueToName: [String: String] = {
      var output = [String: String]()
      for (key, value) in delimiters {
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
      return output
    }()

    static let accents: [String: String] = [
      "grave": "\u{0300}",
      "acute": "\u{0301}",
      "hat": "\u{0302}",  // In our implementation hat and widehat behave the same.
      "tilde": "\u{0303}",  // In our implementation tilde and widetilde behave the same.
      "bar": "\u{0304}",
      "breve": "\u{0306}",
      "dot": "\u{0307}",
      "ddot": "\u{0308}",
      "check": "\u{030C}",
      "vec": "\u{20D7}",
      "widehat": "\u{0302}",
      "widetilde": "\u{0303}",
    ]

    static let accentValueToName: [String: String] = {
      var output = [String: String]()
      for (key, value) in accents {
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
      return output
    }()

    static var supportedLatexSymbolNames: [String] {
      supportedLatexSymbols.withValue { Array($0.keys) }
    }

    private static let supportedLatexSymbols = ReadWriteLockIsolated<[String: Atom]>([
      "square": placeholder(),

      // Greek characters
      "alpha": Atom(type: .variable, nucleus: "\u{03B1}"),
      "beta": Atom(type: .variable, nucleus: "\u{03B2}"),
      "gamma": Atom(type: .variable, nucleus: "\u{03B3}"),
      "delta": Atom(type: .variable, nucleus: "\u{03B4}"),
      "varepsilon": Atom(type: .variable, nucleus: "\u{03B5}"),
      "zeta": Atom(type: .variable, nucleus: "\u{03B6}"),
      "eta": Atom(type: .variable, nucleus: "\u{03B7}"),
      "theta": Atom(type: .variable, nucleus: "\u{03B8}"),
      "iota": Atom(type: .variable, nucleus: "\u{03B9}"),
      "kappa": Atom(type: .variable, nucleus: "\u{03BA}"),
      "lambda": Atom(type: .variable, nucleus: "\u{03BB}"),
      "mu": Atom(type: .variable, nucleus: "\u{03BC}"),
      "nu": Atom(type: .variable, nucleus: "\u{03BD}"),
      "xi": Atom(type: .variable, nucleus: "\u{03BE}"),
      "omicron": Atom(type: .variable, nucleus: "\u{03BF}"),
      "pi": Atom(type: .variable, nucleus: "\u{03C0}"),
      "rho": Atom(type: .variable, nucleus: "\u{03C1}"),
      "varsigma": Atom(type: .variable, nucleus: "\u{03C1}"),
      "sigma": Atom(type: .variable, nucleus: "\u{03C3}"),
      "tau": Atom(type: .variable, nucleus: "\u{03C4}"),
      "upsilon": Atom(type: .variable, nucleus: "\u{03C5}"),
      "varphi": Atom(type: .variable, nucleus: "\u{03C6}"),
      "chi": Atom(type: .variable, nucleus: "\u{03C7}"),
      "psi": Atom(type: .variable, nucleus: "\u{03C8}"),
      "omega": Atom(type: .variable, nucleus: "\u{03C9}"),
      // We mark the following greek chars as ordinary so that we don't try
      // to automatically italicize them as we do with variables.
      // These characters fall outside the rules of italicization that we have defined.
      "epsilon": Atom(type: .ordinary, nucleus: "\u{1D716}"),
      "vartheta": Atom(type: .ordinary, nucleus: "\u{1D717}"),
      "phi": Atom(type: .ordinary, nucleus: "\u{1D719}"),
      "varrho": Atom(type: .ordinary, nucleus: "\u{1D71A}"),
      "varpi": Atom(type: .ordinary, nucleus: "\u{1D71B}"),

      // Capital greek characters
      "Gamma": Atom(type: .variable, nucleus: "\u{0393}"),
      "Delta": Atom(type: .variable, nucleus: "\u{0394}"),
      "Theta": Atom(type: .variable, nucleus: "\u{0398}"),
      "Lambda": Atom(type: .variable, nucleus: "\u{039B}"),
      "Xi": Atom(type: .variable, nucleus: "\u{039E}"),
      "Pi": Atom(type: .variable, nucleus: "\u{03A0}"),
      "Sigma": Atom(type: .variable, nucleus: "\u{03A3}"),
      "Upsilon": Atom(type: .variable, nucleus: "\u{03A5}"),
      "Phi": Atom(type: .variable, nucleus: "\u{03A6}"),
      "Psi": Atom(type: .variable, nucleus: "\u{03A8}"),
      "Omega": Atom(type: .variable, nucleus: "\u{03A9}"),

      // Open
      "lceil": Atom(type: .open, nucleus: "\u{2308}"),
      "lfloor": Atom(type: .open, nucleus: "\u{230A}"),
      "langle": Atom(type: .open, nucleus: "\u{27E8}"),
      "lgroup": Atom(type: .open, nucleus: "\u{27EE}"),

      // Close
      "rceil": Atom(type: .close, nucleus: "\u{2309}"),
      "rfloor": Atom(type: .close, nucleus: "\u{230B}"),
      "rangle": Atom(type: .close, nucleus: "\u{27E9}"),
      "rgroup": Atom(type: .close, nucleus: "\u{27EF}"),

      // Arrows
      "leftarrow": Atom(type: .relation, nucleus: "\u{2190}"),
      "uparrow": Atom(type: .relation, nucleus: "\u{2191}"),
      "rightarrow": Atom(type: .relation, nucleus: "\u{2192}"),
      "downarrow": Atom(type: .relation, nucleus: "\u{2193}"),
      "leftrightarrow": Atom(type: .relation, nucleus: "\u{2194}"),
      "updownarrow": Atom(type: .relation, nucleus: "\u{2195}"),
      "nwarrow": Atom(type: .relation, nucleus: "\u{2196}"),
      "nearrow": Atom(type: .relation, nucleus: "\u{2197}"),
      "searrow": Atom(type: .relation, nucleus: "\u{2198}"),
      "swarrow": Atom(type: .relation, nucleus: "\u{2199}"),
      "mapsto": Atom(type: .relation, nucleus: "\u{21A6}"),
      "Leftarrow": Atom(type: .relation, nucleus: "\u{21D0}"),
      "Uparrow": Atom(type: .relation, nucleus: "\u{21D1}"),
      "Rightarrow": Atom(type: .relation, nucleus: "\u{21D2}"),
      "Downarrow": Atom(type: .relation, nucleus: "\u{21D3}"),
      "Leftrightarrow": Atom(type: .relation, nucleus: "\u{21D4}"),
      "Updownarrow": Atom(type: .relation, nucleus: "\u{21D5}"),
      "longleftarrow": Atom(type: .relation, nucleus: "\u{27F5}"),
      "longrightarrow": Atom(type: .relation, nucleus: "\u{27F6}"),
      "longleftrightarrow": Atom(type: .relation, nucleus: "\u{27F7}"),
      "Longleftarrow": Atom(type: .relation, nucleus: "\u{27F8}"),
      "Longrightarrow": Atom(type: .relation, nucleus: "\u{27F9}"),
      "Longleftrightarrow": Atom(type: .relation, nucleus: "\u{27FA}"),

      // Relations
      "leq": Atom(type: .relation, nucleus: .lessEqual),
      "geq": Atom(type: .relation, nucleus: .greaterEqual),
      "neq": Atom(type: .relation, nucleus: .notEqual),
      "in": Atom(type: .relation, nucleus: "\u{2208}"),
      "notin": Atom(type: .relation, nucleus: "\u{2209}"),
      "ni": Atom(type: .relation, nucleus: "\u{220B}"),
      "propto": Atom(type: .relation, nucleus: "\u{221D}"),
      "mid": Atom(type: .relation, nucleus: "\u{2223}"),
      "parallel": Atom(type: .relation, nucleus: "\u{2225}"),
      "sim": Atom(type: .relation, nucleus: "\u{223C}"),
      "simeq": Atom(type: .relation, nucleus: "\u{2243}"),
      "cong": Atom(type: .relation, nucleus: "\u{2245}"),
      "approx": Atom(type: .relation, nucleus: "\u{2248}"),
      "asymp": Atom(type: .relation, nucleus: "\u{224D}"),
      "doteq": Atom(type: .relation, nucleus: "\u{2250}"),
      "equiv": Atom(type: .relation, nucleus: "\u{2261}"),
      "gg": Atom(type: .relation, nucleus: "\u{226B}"),
      "ll": Atom(type: .relation, nucleus: "\u{226A}"),
      "prec": Atom(type: .relation, nucleus: "\u{227A}"),
      "succ": Atom(type: .relation, nucleus: "\u{227B}"),
      "subset": Atom(type: .relation, nucleus: "\u{2282}"),
      "supset": Atom(type: .relation, nucleus: "\u{2283}"),
      "subseteq": Atom(type: .relation, nucleus: "\u{2286}"),
      "supseteq": Atom(type: .relation, nucleus: "\u{2287}"),
      "sqsubset": Atom(type: .relation, nucleus: "\u{228F}"),
      "sqsupset": Atom(type: .relation, nucleus: "\u{2290}"),
      "sqsubseteq": Atom(type: .relation, nucleus: "\u{2291}"),
      "sqsupseteq": Atom(type: .relation, nucleus: "\u{2292}"),
      "models": Atom(type: .relation, nucleus: "\u{22A7}"),
      "perp": Atom(type: .relation, nucleus: "\u{27C2}"),
      "implies": Atom(type: .relation, nucleus: "\u{27F9}"),

      // operators
      "times": times(),
      "div": divide(),
      "pm": Atom(type: .binaryOperator, nucleus: "\u{00B1}"),
      "dagger": Atom(type: .binaryOperator, nucleus: "\u{2020}"),
      "ddagger": Atom(type: .binaryOperator, nucleus: "\u{2021}"),
      "mp": Atom(type: .binaryOperator, nucleus: "\u{2213}"),
      "setminus": Atom(type: .binaryOperator, nucleus: "\u{2216}"),
      "ast": Atom(type: .binaryOperator, nucleus: "\u{2217}"),
      "circ": Atom(type: .binaryOperator, nucleus: "\u{2218}"),
      "bullet": Atom(type: .binaryOperator, nucleus: "\u{2219}"),
      "wedge": Atom(type: .binaryOperator, nucleus: "\u{2227}"),
      "vee": Atom(type: .binaryOperator, nucleus: "\u{2228}"),
      "cap": Atom(type: .binaryOperator, nucleus: "\u{2229}"),
      "cup": Atom(type: .binaryOperator, nucleus: "\u{222A}"),
      "wr": Atom(type: .binaryOperator, nucleus: "\u{2240}"),
      "uplus": Atom(type: .binaryOperator, nucleus: "\u{228E}"),
      "sqcap": Atom(type: .binaryOperator, nucleus: "\u{2293}"),
      "sqcup": Atom(type: .binaryOperator, nucleus: "\u{2294}"),
      "oplus": Atom(type: .binaryOperator, nucleus: "\u{2295}"),
      "ominus": Atom(type: .binaryOperator, nucleus: "\u{2296}"),
      "otimes": Atom(type: .binaryOperator, nucleus: "\u{2297}"),
      "oslash": Atom(type: .binaryOperator, nucleus: "\u{2298}"),
      "odot": Atom(type: .binaryOperator, nucleus: "\u{2299}"),
      "star": Atom(type: .binaryOperator, nucleus: "\u{22C6}"),
      "cdot": Atom(type: .binaryOperator, nucleus: "\u{22C5}"),
      "amalg": Atom(type: .binaryOperator, nucleus: "\u{2A3F}"),

      // No limit operators
      "log": operatorWithName("log", limits: false),
      "lg": operatorWithName("lg", limits: false),
      "ln": operatorWithName("ln", limits: false),
      "sin": operatorWithName("sin", limits: false),
      "arcsin": operatorWithName("arcsin", limits: false),
      "sinh": operatorWithName("sinh", limits: false),
      "cos": operatorWithName("cos", limits: false),
      "arccos": operatorWithName("arccos", limits: false),
      "cosh": operatorWithName("cosh", limits: false),
      "tan": operatorWithName("tan", limits: false),
      "arctan": operatorWithName("arctan", limits: false),
      "tanh": operatorWithName("tanh", limits: false),
      "cot": operatorWithName("cot", limits: false),
      "coth": operatorWithName("coth", limits: false),
      "sec": operatorWithName("sec", limits: false),
      "csc": operatorWithName("csc", limits: false),
      "arg": operatorWithName("arg", limits: false),
      "ker": operatorWithName("ker", limits: false),
      "dim": operatorWithName("dim", limits: false),
      "hom": operatorWithName("hom", limits: false),
      "exp": operatorWithName("exp", limits: false),
      "deg": operatorWithName("deg", limits: false),
      "mod": operatorWithName("mod", limits: false),

      // Limit operators
      "lim": operatorWithName("lim", limits: true),
      "limsup": operatorWithName("lim sup", limits: true),
      "liminf": operatorWithName("lim inf", limits: true),
      "max": operatorWithName("max", limits: true),
      "min": operatorWithName("min", limits: true),
      "sup": operatorWithName("sup", limits: true),
      "inf": operatorWithName("inf", limits: true),
      "det": operatorWithName("det", limits: true),
      "Pr": operatorWithName("Pr", limits: true),
      "gcd": operatorWithName("gcd", limits: true),

      // Large operators
      "prod": operatorWithName("\u{220F}", limits: true),
      "coprod": operatorWithName("\u{2210}", limits: true),
      "sum": operatorWithName("\u{2211}", limits: true),
      "int": operatorWithName("\u{222B}", limits: false),
      "iint": operatorWithName("\u{222C}", limits: false),
      "iiint": operatorWithName("\u{222D}", limits: false),
      "iiiint": operatorWithName("\u{2A0C}", limits: false),
      "oint": operatorWithName("\u{222E}", limits: false),
      "bigwedge": operatorWithName("\u{22C0}", limits: true),
      "bigvee": operatorWithName("\u{22C1}", limits: true),
      "bigcap": operatorWithName("\u{22C2}", limits: true),
      "bigcup": operatorWithName("\u{22C3}", limits: true),
      "bigodot": operatorWithName("\u{2A00}", limits: true),
      "bigoplus": operatorWithName("\u{2A01}", limits: true),
      "bigotimes": operatorWithName("\u{2A02}", limits: true),
      "biguplus": operatorWithName("\u{2A04}", limits: true),
      "bigsqcup": operatorWithName("\u{2A06}", limits: true),

      // Latex command characters
      "{": Atom(type: .open, nucleus: "{"),
      "}": Atom(type: .close, nucleus: "}"),
      "$": Atom(type: .ordinary, nucleus: "$"),
      "&": Atom(type: .ordinary, nucleus: "&"),
      "#": Atom(type: .ordinary, nucleus: "#"),
      "%": Atom(type: .ordinary, nucleus: "%"),
      "_": Atom(type: .ordinary, nucleus: "_"),
      " ": Atom(type: .ordinary, nucleus: " "),
      "backslash": Atom(type: .ordinary, nucleus: "\\"),

      // Punctuation
      // Note: \colon is different from : which is a relation
      "colon": Atom(type: .punctuation, nucleus: ":"),
      "cdotp": Atom(type: .punctuation, nucleus: "\u{00B7}"),

      // Other symbols
      "degree": Atom(type: .ordinary, nucleus: "\u{00B0}"),
      "neg": Atom(type: .ordinary, nucleus: "\u{00AC}"),
      "angstrom": Atom(type: .ordinary, nucleus: "\u{00C5}"),
      "aa": Atom(type: .ordinary, nucleus: "\u{00E5}"),
      "ae": Atom(type: .ordinary, nucleus: "\u{00E6}"),
      "o": Atom(type: .ordinary, nucleus: "\u{00F8}"),
      "oe": Atom(type: .ordinary, nucleus: "\u{0153}"),
      "ss": Atom(type: .ordinary, nucleus: "\u{00DF}"),
      "cc": Atom(type: .ordinary, nucleus: "\u{00E7}"),
      "CC": Atom(type: .ordinary, nucleus: "\u{00C7}"),
      "O": Atom(type: .ordinary, nucleus: "\u{00D8}"),
      "AE": Atom(type: .ordinary, nucleus: "\u{00C6}"),
      "OE": Atom(type: .ordinary, nucleus: "\u{0152}"),
      "|": Atom(type: .ordinary, nucleus: "\u{2016}"),
      "vert": Atom(type: .ordinary, nucleus: "|"),
      "ldots": Atom(type: .ordinary, nucleus: "\u{2026}"),
      "prime": Atom(type: .ordinary, nucleus: "\u{2032}"),
      "hbar": Atom(type: .ordinary, nucleus: "\u{210F}"),
      "lbar": Atom(type: .ordinary, nucleus: "\u{019B}"),
      "Im": Atom(type: .ordinary, nucleus: "\u{2111}"),
      "ell": Atom(type: .ordinary, nucleus: "\u{2113}"),
      "wp": Atom(type: .ordinary, nucleus: "\u{2118}"),
      "Re": Atom(type: .ordinary, nucleus: "\u{211C}"),
      "mho": Atom(type: .ordinary, nucleus: "\u{2127}"),
      "aleph": Atom(type: .ordinary, nucleus: "\u{2135}"),
      "forall": Atom(type: .ordinary, nucleus: "\u{2200}"),
      "exists": Atom(type: .ordinary, nucleus: "\u{2203}"),
      "nexists": Atom(type: .ordinary, nucleus: "\u{2204}"),
      "emptyset": Atom(type: .ordinary, nucleus: "\u{2205}"),
      "nabla": Atom(type: .ordinary, nucleus: "\u{2207}"),
      "infty": Atom(type: .ordinary, nucleus: "\u{221E}"),
      "angle": Atom(type: .ordinary, nucleus: "\u{2220}"),
      "top": Atom(type: .ordinary, nucleus: "\u{22A4}"),
      "bot": Atom(type: .ordinary, nucleus: "\u{22A5}"),
      "vdots": Atom(type: .ordinary, nucleus: "\u{22EE}"),
      "cdots": Atom(type: .ordinary, nucleus: "\u{22EF}"),
      "ddots": Atom(type: .ordinary, nucleus: "\u{22F1}"),
      "triangle": Atom(type: .ordinary, nucleus: "\u{25B3}"),
      "imath": Atom(type: .ordinary, nucleus: "\u{1D6A4}"),
      "jmath": Atom(type: .ordinary, nucleus: "\u{1D6A5}"),
      "upquote": Atom(type: .ordinary, nucleus: "\u{0027}"),
      "partial": Atom(type: .ordinary, nucleus: "\u{1D715}"),

      // Spacing
      ",": Space(amount: 3),
      ">": Space(amount: 4),
      ";": Space(amount: 5),
      "!": Space(amount: -3),
      "quad": Space(amount: 18),
      "qquad": Space(amount: 36),

      // Style
      "displaystyle": Style(level: .display),
      "textstyle": Style(level: .text),
      "scriptstyle": Style(level: .script),
      "scriptscriptstyle": Style(level: .scriptOfScript),
    ])

    static let supportedAccentedCharacters: [Character: (String, String)] = [
      "\u{00E1}": ("acute", "a"), "\u{00E9}": ("acute", "e"), "\u{00ED}": ("acute", "i"),
      "\u{00F3}": ("acute", "o"), "\u{00FA}": ("acute", "u"), "\u{00FD}": ("acute", "y"),
      "\u{00E0}": ("grave", "a"), "\u{00E8}": ("grave", "e"), "\u{00EC}": ("grave", "i"),
      "\u{00F2}": ("grave", "o"), "\u{00F9}": ("grave", "u"),
      "\u{00E2}": ("hat", "a"), "\u{00EA}": ("hat", "e"), "\u{00EE}": ("hat", "i"),
      "\u{00F4}": ("hat", "o"), "\u{00FB}": ("hat", "u"),
      "\u{00E4}": ("ddot", "a"), "\u{00EB}": ("ddot", "e"), "\u{00EF}": ("ddot", "i"),
      "\u{00F6}": ("ddot", "o"), "\u{00FC}": ("ddot", "u"), "\u{00FF}": ("ddot", "y"),
      "\u{00E3}": ("tilde", "a"), "\u{00F1}": ("tilde", "n"), "\u{00F5}": ("tilde", "o"),
      "\u{00E7}": ("cc", ""), "\u{00F8}": ("o", ""), "\u{00E5}": ("aa", ""), "\u{00E6}": ("ae", ""),
      "\u{0153}": ("oe", ""), "\u{00DF}": ("ss", ""),
      "\u{0027}": ("upquote", ""),
      "\u{00C1}": ("acute", "A"), "\u{00C9}": ("acute", "E"), "\u{00CD}": ("acute", "I"),
      "\u{00D3}": ("acute", "O"), "\u{00DA}": ("acute", "U"), "\u{00DD}": ("acute", "Y"),
      "\u{00C0}": ("grave", "A"), "\u{00C8}": ("grave", "E"), "\u{00CC}": ("grave", "I"),
      "\u{00D2}": ("grave", "O"), "\u{00D9}": ("grave", "U"),
      "\u{00C2}": ("hat", "A"), "\u{00CA}": ("hat", "E"), "\u{00CE}": ("hat", "I"),
      "\u{00D4}": ("hat", "O"), "\u{00DB}": ("hat", "U"),
      "\u{00C4}": ("ddot", "A"), "\u{00CB}": ("ddot", "E"), "\u{00CF}": ("ddot", "I"),
      "\u{00D6}": ("ddot", "O"), "\u{00DC}": ("ddot", "U"),
      "\u{00C3}": ("tilde", "A"), "\u{00D1}": ("tilde", "N"), "\u{00D5}": ("tilde", "O"),
      "\u{00C7}": ("CC", ""),
      "\u{00D8}": ("O", ""),
      "\u{00C5}": ("AA", ""),
      "\u{00C6}": ("AE", ""),
      "\u{0152}": ("OE", ""),
    ]

    private static let textToLatexSymbolName = ReadWriteLockIsolated<[String: String]?>(nil)

    private static let fontStyles: [String: Atom.FontStyle] = [
      "mathnormal": .default,
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

    private static let matrixEnvs: [String: [String]] = [
      "matrix": [],
      "pmatrix": ["(", ")"],
      "bmatrix": ["[", "]"],
      "Bmatrix": ["{", "}"],
      "vmatrix": ["vert", "vert"],
      "Vmatrix": ["Vert", "Vert"],
      "smallmatrix": [],
      "matrix*": [],
      "pmatrix*": ["(", ")"],
      "bmatrix*": ["[", "]"],
      "Bmatrix*": ["{", "}"],
      "vmatrix*": ["vert", "vert"],
      "Vmatrix*": ["Vert", "Vert"],
    ]

    static func fontStyle(named fontName: String) -> Atom.FontStyle? {
      fontStyles[fontName]
    }

    static func fontName(for style: Atom.FontStyle) -> String {
      switch style {
      case .default: return "mathnormal"
      case .roman: return "mathrm"
      case .bold: return "mathbf"
      case .fraktur: return "mathfrak"
      case .caligraphic: return "mathcal"
      case .italic: return "mathit"
      case .sansSerif: return "mathsf"
      case .blackboard: return "mathbb"
      case .typewriter: return "mathtt"
      case .boldItalic: return "bm"
      }
    }

    static func times() -> Atom {
      Atom(type: .binaryOperator, nucleus: .multiplication)
    }

    static func divide() -> Atom {
      Atom(type: .binaryOperator, nucleus: .division)
    }

    static func placeholder() -> Atom {
      Atom(type: .placeholder, nucleus: .whiteSquare)
    }

    static func placeholderFraction() -> Fraction {
      let frac = Fraction()
      frac.numerator = AtomList(atom: placeholder())
      frac.denominator = AtomList(atom: placeholder())
      return frac
    }

    static func placeholderSquareRoot() -> Radical {
      let rad = Radical()
      rad.radicand = AtomList(atom: placeholder())
      return rad
    }

    static func placeholderRadical() -> Radical {
      let rad = Radical()
      rad.radicand = AtomList(atom: placeholder())
      rad.degree = AtomList(atom: placeholder())
      return rad
    }

    static func atom(fromAccentedCharacter ch: Character) -> Atom? {
      if let symbol = supportedAccentedCharacters[ch] {
        if let atom = atom(forLatexSymbol: symbol.0) {
          return atom
        }

        if let accent = accent(withName: symbol.0) {
          let list = AtomList()
          let character = Array(symbol.1)[0]
          if let atom = atom(forCharacter: character) {
            list.append(atom)
          }
          accent.innerList = list
          return accent
        }
      }
      return nil
    }

    static func atom(forCharacter ch: Character) -> Atom? {
      let stringValue = String(ch)
      switch stringValue {
      case "\u{0410}"..."\u{044F}":
        return Atom(type: .ordinary, nucleus: stringValue)
      case _ where supportedAccentedCharacters.keys.contains(ch):
        return atom(fromAccentedCharacter: ch)
      case _ where ch.utf32 < 0x0021 || ch.utf32 > 0x007E:
        return nil
      case "$", "%", "#", "&", "~", "\'", "^", "_", "{", "}", "\\":
        return nil
      case "(", "[":
        return Atom(type: .open, nucleus: stringValue)
      case ")", "]", "!", "?":
        return Atom(type: .close, nucleus: stringValue)
      case ",", ";":
        return Atom(type: .punctuation, nucleus: stringValue)
      case "=", ">", "<":
        return Atom(type: .relation, nucleus: stringValue)
      case ":":
        return Atom(type: .relation, nucleus: "\u{2236}")
      case "-":
        return Atom(type: .binaryOperator, nucleus: "\u{2212}")
      case "+", "*":
        return Atom(type: .binaryOperator, nucleus: stringValue)
      case ".", "0"..."9":
        return Atom(type: .number, nucleus: stringValue)
      case "a"..."z", "A"..."Z":
        return Atom(type: .variable, nucleus: stringValue)
      case "\"", "/", "@", "`", "|":
        return Atom(type: .ordinary, nucleus: stringValue)
      default:
        assertionFailure("Unknown ASCII character '\(ch)'. Should have been handled earlier.")
        return nil
      }
    }

    static func atomList(for string: String) -> AtomList {
      let list = AtomList()
      for character in string {
        if let newAtom = atom(forCharacter: character) {
          list.append(newAtom)
        }
      }
      return list
    }

    static func atom(forLatexSymbol name: String) -> Atom? {
      let resolvedName = aliases[name] ?? name
      return supportedLatexSymbols.withValue { $0[resolvedName]?.copy() }
    }

    static func latexSymbolName(for atom: Atom) -> String? {
      guard !atom.nucleus.isEmpty else { return nil }
      return textToLatexSymbolNameValue()[atom.nucleus]
    }

    static func add(latexSymbol name: String, value: Atom) {
      let _ = textToLatexSymbolNameValue()
      supportedLatexSymbols.withValue { $0[name] = value }
      textToLatexSymbolName.withValue { map in
        guard !value.nucleus.isEmpty else { return }
        map?[value.nucleus] = name
      }
    }

    static func operatorWithName(_ name: String, limits: Bool) -> LargeOperator {
      let op = LargeOperator(limits: limits)
      op.nucleus = name
      return op
    }

    static func accent(withName name: String) -> Accent? {
      if let accentValue = accents[name] {
        return Accent(value: accentValue)
      }
      return nil
    }

    static func accentName(_ accent: Accent) -> String? {
      accentValueToName[accent.nucleus]
    }

    static func boundary(forDelimiter name: String) -> Atom? {
      if let delimValue = delimiters[name] {
        return Atom(type: .boundary, nucleus: delimValue)
      }
      return nil
    }

    static func delimiterName(of boundary: Atom) -> String? {
      guard boundary.type == .boundary else { return nil }
      return delimValueToName[boundary.nucleus]
    }

    static func fraction(withNumerator numerator: AtomList, denominator: AtomList) -> Fraction {
      let fraction = Fraction()
      fraction.numerator = numerator
      fraction.denominator = denominator
      return fraction
    }

    static func mathListForCharacters(_ chars: String) -> AtomList? {
      let list = AtomList()
      for ch in chars {
        if let atom = atom(forCharacter: ch) {
          list.append(atom)
        }
      }
      return list
    }

    static func fraction(
      withNumeratorString numerator: String, denominatorString denominator: String
    ) -> Fraction {
      let num = atomList(for: numerator)
      let denom = atomList(for: denominator)
      return fraction(withNumerator: num, denominator: denom)
    }

    static func table(
      withEnvironment env: String?,
      alignment: Table.ColumnAlignment? = nil,
      rows: [[AtomList]],
      error: inout ParserError?
    ) -> Atom? {
      let table = Table(environment: env ?? "")

      for i in 0..<rows.count {
        let row = rows[i]
        for j in 0..<row.count {
          table.setCell(row[j], forRow: i, column: j)
        }
      }

      if env == nil {
        table.interColumnSpacing = 0
        table.interRowAdditionalSpacing = 1
        for column in 0..<table.numberOfColumns {
          table.setAlignment(.left, forColumn: column)
        }
        return table
      } else if let env {
        if let delims = matrixEnvs[env] {
          table.environment = "matrix"

          let isSmallMatrix = (env == "smallmatrix")

          table.interRowAdditionalSpacing = 0
          table.interColumnSpacing = isSmallMatrix ? 6 : 18

          let style = Style(level: isSmallMatrix ? .script : .text)

          for i in 0..<table.cells.count {
            for j in 0..<table.cells[i].count {
              table.cells[i][j].insert(style, at: 0)
            }
          }

          if let alignment {
            for column in 0..<table.numberOfColumns {
              table.setAlignment(alignment, forColumn: column)
            }
          }

          if delims.count == 2 {
            let inner = Inner()
            inner.leftBoundary = boundary(forDelimiter: delims[0])
            inner.rightBoundary = boundary(forDelimiter: delims[1])
            inner.innerList = AtomList(atoms: [table])
            return inner
          } else {
            return table
          }
        } else if env == "eqalign" || env == "split" || env == "aligned" {
          if table.numberOfColumns != 2 {
            let message = "\(env) environment can only have 2 columns"
            if error == nil {
              error = ParserError(code: .invalidNumberOfColumns, message: message)
            }
            return nil
          }

          let spacer = Atom(type: .ordinary, nucleus: "")

          for i in 0..<table.cells.count {
            if table.cells[i].count >= 2 {
              table.cells[i][1].insert(spacer, at: 0)
            }
          }

          table.interRowAdditionalSpacing = 1
          table.interColumnSpacing = 0

          table.setAlignment(.right, forColumn: 0)
          table.setAlignment(.left, forColumn: 1)

          return table
        } else if env == "displaylines" || env == "gather" {
          if table.numberOfColumns != 1 {
            let message = "\(env) environment can only have 1 column"
            if error == nil {
              error = ParserError(code: .invalidNumberOfColumns, message: message)
            }
            return nil
          }

          table.interRowAdditionalSpacing = 1
          table.interColumnSpacing = 0

          table.setAlignment(.center, forColumn: 0)

          return table
        } else if env == "eqnarray" {
          if table.numberOfColumns != 3 {
            let message = "\(env) environment can only have 3 columns"
            if error == nil {
              error = ParserError(code: .invalidNumberOfColumns, message: message)
            }
            return nil
          }

          table.interRowAdditionalSpacing = 1
          table.interColumnSpacing = 18

          table.setAlignment(.right, forColumn: 0)
          table.setAlignment(.center, forColumn: 1)
          table.setAlignment(.left, forColumn: 2)

          return table
        } else if env == "cases" {
          if table.numberOfColumns != 1 && table.numberOfColumns != 2 {
            let message = "cases environment can have 1 or 2 columns"
            if error == nil {
              error = ParserError(code: .invalidNumberOfColumns, message: message)
            }
            return nil
          }

          table.interRowAdditionalSpacing = 0
          table.interColumnSpacing = 18

          table.setAlignment(.left, forColumn: 0)
          if table.numberOfColumns == 2 {
            table.setAlignment(.left, forColumn: 1)
          }

          let style = Style(level: .text)
          for i in 0..<table.cells.count {
            for j in 0..<table.cells[i].count {
              table.cells[i][j].insert(style, at: 0)
            }
          }

          let inner = Inner()
          inner.leftBoundary = boundary(forDelimiter: "{")
          inner.rightBoundary = boundary(forDelimiter: ".")
          let space = atom(forLatexSymbol: ",")!

          inner.innerList = AtomList(atoms: [space, table])

          return inner
        } else {
          let message = "Unknown environment \(env)"
          error = ParserError(code: .invalidEnvironment, message: message)
          return nil
        }
      }
      return nil
    }

    private static func textToLatexSymbolNameValue() -> [String: String] {
      textToLatexSymbolName.withValue { map in
        if let map {
          return map
        }

        let symbols = supportedLatexSymbols.withValue { $0 }
        var output = [String: String]()
        for (key, atom) in symbols {
          if atom.nucleus.isEmpty {
            continue
          }
          if let existingText = output[atom.nucleus] {
            if key.count > existingText.count {
              continue
            } else if key.count == existingText.count {
              if key.compare(existingText) == .orderedDescending {
                continue
              }
            }
          }
          output[atom.nucleus] = key
        }

        map = output
        return output
      }
    }
  }
}
