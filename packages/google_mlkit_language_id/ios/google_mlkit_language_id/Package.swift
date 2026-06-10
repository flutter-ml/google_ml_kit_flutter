// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-language-id",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-language-id",
            targets: ["google_mlkit_language_id"])
    ],
    dependencies: [
        .package(path: "../google_mlkit_commons"),
        .package(
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            from: "9.0.0"
        ),
    ],
    targets: [
        .target(
            name: "google_mlkit_language_id",
            dependencies: [
                .product(name: "MLKitLanguageID", package: "google-mlkit-swiftpm"),
                .product(name: "google-mlkit-commons", package: "google-mlkit-commons"),
            ],
            path: "Sources/google_mlkit_language_id"
        )
    ]
)
