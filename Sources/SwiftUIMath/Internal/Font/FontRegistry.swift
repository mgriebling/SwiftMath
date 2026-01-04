@preconcurrency import CoreGraphics
@preconcurrency import CoreText
import Foundation

extension Math {
  final class FontRegistry: Sendable {
    private struct Cache {
      var graphicsFonts: [Font.Name: CGFont] = [:]
      var tables: [Font.Name: FontTable] = [:]
      let fonts = NSCache<KeyBox<Font>, CTFont>()
    }

    static let shared = FontRegistry()

    private let cache = ReadWriteLockIsolated<Cache>(Cache())

    func graphicsFont(named name: Font.Name) -> CGFont? {
      cache.withValue { cache in
        if let graphicsFont = cache.graphicsFonts[name] {
          return graphicsFont
        }

        guard let (graphicsFont, _) = registerGraphicsFont(named: name, cache: &cache) else {
          return nil
        }

        return graphicsFont
      }
    }

    func table(named name: Font.Name) -> FontTable? {
      cache.withValue { cache in
        if let table = cache.tables[name] {
          return table
        }

        guard let (_, table) = registerGraphicsFont(named: name, cache: &cache) else {
          return nil
        }

        return table
      }
    }

    func font(named name: Font.Name, size: CGFloat) -> CTFont? {
      cache.withValue { cache in
        let key = KeyBox(Font(name: name, size: size))

        if let font = cache.fonts.object(forKey: key) {
          return font
        }

        guard
          let graphicsFont = cache.graphicsFonts[name]
            ?? registerGraphicsFont(named: name, cache: &cache)?.0
        else {
          return nil
        }

        let font = CTFontCreateWithGraphicsFont(graphicsFont, size, nil, nil)
        cache.fonts.setObject(font, forKey: key)

        return font
      }
    }

    private func registerGraphicsFont(
      named name: Font.Name,
      cache: inout Cache
    ) -> (CGFont, FontTable)? {
      guard let graphicsFont = CGFont.named(name), let table = FontTable.named(name) else {
        return nil
      }

      guard CTFontManagerRegisterGraphicsFont(graphicsFont, nil) else {
        return nil
      }

      cache.graphicsFonts[name] = graphicsFont
      cache.tables[name] = table

      return (graphicsFont, table)
    }
  }
}

extension CGFont {
  fileprivate static func named(_ name: Math.Font.Name) -> CGFont? {
    guard
      let bundleURL = Bundle.module.url(forResource: "mathFonts", withExtension: "bundle"),
      let url = Bundle(url: bundleURL)?.url(forResource: name.rawValue, withExtension: "otf"),
      let data = try? Data(contentsOf: url),
      let dataProvider = CGDataProvider(data: data as CFData)
    else {
      return nil
    }

    return CGFont(dataProvider)
  }
}

extension Math.FontTable {
  fileprivate static func named(_ name: Math.Font.Name) -> Math.FontTable? {
    guard
      let bundleURL = Bundle.module.url(forResource: "mathFonts", withExtension: "bundle"),
      let url = Bundle(url: bundleURL)?.url(forResource: name.rawValue, withExtension: "plist"),
      let data = try? Data(contentsOf: url)
    else {
      return nil
    }

    return try? PropertyListDecoder().decode(Math.FontTable.self, from: data)
  }
}
