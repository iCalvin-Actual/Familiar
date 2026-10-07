// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Familiar",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Familiar",
            targets: ["Familiar"]
        ),
    ],
    targets: [
        .target(
            name: "Familiar",
            resources: [
                // Declaring resources is what creates `Bundle.module`.
                // Also ships Licenses/FFL.txt, which has to travel with the fonts.
                .process("Resources/Fonts"),
                // Images.xcassets, plus loose image files flattened into the
                // bundle root. See `Icon.Symbol` and `URL.familiarImages`.
                .process("Resources/Images"),
                // Colors.xcassets. See `Swatch.catalog`.
                .process("Resources/Colors"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .testTarget(
            name: "FamiliarTests",
            dependencies: ["Familiar"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
