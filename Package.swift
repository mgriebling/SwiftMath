// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swiftui-math",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .tvOS(.v17),
    .watchOS(.v10),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "SwiftUIMath", targets: ["SwiftUIMath"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "SwiftUIMath",
      dependencies: [],
      resources: [.copy("mathFonts.bundle")]
    ),
    .testTarget(
      name: "SwiftUIMathTests",
      dependencies: ["SwiftUIMath"]
    ),
  ]
)
