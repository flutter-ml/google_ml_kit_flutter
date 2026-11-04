// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-entity-extraction",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-entity-extraction",
            targets: ["google_mlkit_entity_extraction"])
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
        .package(
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            exact: "9.0.2"
        )
    ],
    targets: [
        .target(
            name: "google_mlkit_entity_extraction",
            dependencies: [
                .product(name: "MLKitEntityExtraction", package: "google-mlkit-swiftpm"),
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons")
            ],
            path: "Sources/google_mlkit_entity_extraction"
        )
    ]
)
