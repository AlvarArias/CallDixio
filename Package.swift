// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CallDixio",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "CallDixio",
            targets: ["CallDixio"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CallDixio",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "CallDixioTests",
            dependencies: ["CallDixio"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
    ]
)
