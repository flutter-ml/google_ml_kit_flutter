// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-language-id",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-language-id",
            targets: ["google_mlkit_language_id"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            exact: "9.0.2"
        )
    ],
    targets: [
        .target(
            name: "google_mlkit_language_id",
            dependencies: [
                .product(name: "MLKitLanguageID", package: "google-mlkit-swiftpm")
            ],
            path: "Sources/google_mlkit_language_id"
        )
    ]
)
