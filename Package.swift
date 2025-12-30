// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swiftui-math",
    defaultLocalization: "en",
    platforms: [.iOS("11.0"), .macOS("12.0")],
    products: [
        .library(
            name: "SwiftUIMath",
            targets: ["SwiftUIMath"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftUIMath",
            dependencies: [],
            resources: [
                .copy("mathFonts.bundle")
            ]),
        .testTarget(
            name: "SwiftUIMathTests",
            dependencies: ["SwiftUIMath"]),
    ]
)
