// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_entity_extraction",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-entity-extraction",
            targets: ["google_mlkit_entity_extraction"]
        ),
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
    ],
    targets: [
        .target(
            name: "google_mlkit_entity_extraction",
            dependencies: [
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_entity_extraction",
            publicHeadersPath: "include/google_mlkit_entity_extraction",
            cSettings: [
                .headerSearchPath("include/google_mlkit_entity_extraction")
            ]
        ),
    ]
)
