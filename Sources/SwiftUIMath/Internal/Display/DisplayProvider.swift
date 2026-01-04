import Foundation

extension Math {
  final class DisplayProvider: Sendable {
    private struct Cache {
      struct Key: Hashable {
        let latex: String
        let font: Font
        let style: TypesettingStyle
        let proposedWidth: CGFloat
      }

      let atomList = NSCache<NSString, AtomList>()
      let displayNode = NSCache<KeyBox<Key>, DisplayNode>()
    }

    static let shared = DisplayProvider()

    private let cache = ReadWriteLockIsolated<Cache>(Cache())

    func sizeThatFits(
      proposedWidth width: CGFloat,
      latex: String,
      font: Font,
      style: TypesettingStyle
    ) -> CGSize {
      display(
        for: latex,
        font: font,
        style: style,
        proposedWidth: width
      )?.bounds.size ?? .zero
    }

    func display(
      for latex: String,
      font: Font,
      style: TypesettingStyle,
      proposedWidth: CGFloat
    ) -> DisplayNode? {
      cache.withValue { cache in
        let roundedWidth = proposedWidth.halfPointRounded()
        let key = KeyBox(
          Cache.Key(
            latex: latex,
            font: font,
            style: style,
            proposedWidth: roundedWidth
          )
        )

        if let displayNode = cache.displayNode.object(forKey: key) {
          return displayNode
        }

        guard
          let atomList = atomList(for: latex, cache: &cache),
          let displayNode = Typesetter.createLineForMathList(
            atomList,
            font: .init(font: font),
            style: .init(style),
            maxWidth: roundedWidth
          )
        else {
          return nil
        }

        cache.displayNode.setObject(displayNode, forKey: key)

        if displayNode.width != roundedWidth {
          // Cache the measured width to avoid a miss between layout and draw passes
          let secondaryKey = KeyBox(
            Cache.Key(
              latex: latex,
              font: font,
              style: style,
              proposedWidth: displayNode.width.halfPointRounded()
            )
          )
          cache.displayNode.setObject(displayNode, forKey: secondaryKey)
        }

        return displayNode
      }
    }

    private func atomList(for latex: String, cache: inout Cache) -> AtomList? {
      if let atomList = cache.atomList.object(forKey: latex as NSString) {
        return atomList
      }

      guard let atomList = Parser.build(fromString: latex) else {
        return nil
      }

      cache.atomList.setObject(atomList, forKey: latex as NSString)
      return atomList
    }
  }
}

extension Math.Style.Level {
  fileprivate init(_ typesettingStyle: Math.TypesettingStyle) {
    switch typesettingStyle {
    case .display:
      self = .display
    case .text:
      self = .text
    }
  }
}

extension CGFloat {
  fileprivate func halfPointRounded() -> CGFloat {
    guard self > 0 else { return 0 }
    return (self * 2).rounded() / 2
  }
}
