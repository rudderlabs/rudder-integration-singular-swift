// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "RudderSingular",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(
            name: "RudderSingular",
            targets: ["RudderSingular"]
        )
    ],
    dependencies: [
        .package(name: "Singular", url: "https://github.com/singular-labs/Singular-iOS-SDK", "11.0.4"..<"11.0.5"),
        .package(name: "Rudder", url: "https://github.com/rudderlabs/rudder-sdk-ios", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "RudderSingular",
            dependencies: [
                .product(name: "Singular", package: "Singular"),
                .product(name: "Rudder", package: "Rudder"),
            ],
            path: "Sources",
            sources: ["Classes/"]
        )
    ]
)
