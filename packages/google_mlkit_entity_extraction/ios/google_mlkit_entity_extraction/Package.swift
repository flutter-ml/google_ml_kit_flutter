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
        .package(path: "../google_mlkit_commons")
    ],
    targets: [
        .target(
            name: "google_mlkit_entity_extraction",
            dependencies: [
                .product(name: "google-mlkit-commons", package: "google-mlkit-commons")
            ],
            path: "Sources/google_mlkit_entity_extraction"
        )
    ]
)
