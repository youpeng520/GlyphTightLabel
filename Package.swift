// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "GlyphTightLabel",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "GlyphTightLabel",
            targets: ["GlyphTightLabel"]
        ),
    ],
    targets: [
        .target(
            name: "GlyphTightLabel",
            path: "Sources/GlyphTightLabel"
        ),
    ]
)
