// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SP500IndexUpdates",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SP500IndexUpdates",
            targets: ["SP500IndexUpdates"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.9.0")
    ],
    targets: [
        .target(
            name: "SP500IndexUpdates",
            dependencies: [
                .product(
                    name: "Sparkle",
                    package: "Sparkle",
                    condition: .when(platforms: [.macOS])
                )
            ]
        )
    ]
)
