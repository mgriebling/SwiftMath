import Foundation

extension Math {
  struct Table: Codable, Sendable {
    struct Assembly: Codable, Sendable {
      struct Part: Codable, Sendable {
        let advance: Int
        let endConnector: Int
        let extender: Bool
        let glyph: String
        let startConnector: Int
      }

      let italic: Int
      let parts: [Part]
    }

    private enum CodingKeys: String, CodingKey {
      case version
      case accents
      case constants
      case italic
      case hVariants = "h_variants"
      case vVariants = "v_variants"
      case vAssembly = "v_assembly"
    }

    let version: String

    let accents: [String: Int]
    let constants: [String: Int]
    let italic: [String: Int]

    let hVariants: [String: [String]]
    let vVariants: [String: [String]]

    let vAssembly: [String: Assembly]
  }
}
