// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-entity-extraction",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-entity-extraction",
            targets: ["google_mlkit_entity_extraction"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            exact: "9.0.2"
        )
    ],
    targets: [
        .target(
            name: "google_mlkit_entity_extraction",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "MLKitEntityExtraction", package: "google-mlkit-swiftpm")
            ],
            path: "Sources/google_mlkit_entity_extraction"
        )
    ]
)
