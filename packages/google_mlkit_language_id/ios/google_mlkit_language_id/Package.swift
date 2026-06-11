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
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
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
                // Note: The `package` value uses the DIRECTORY name ("google_mlkit_commons"), not the
                // Package.swift `name` field ("google-mlkit-commons"). For local path dependencies, SPM
                // derives the package identity from the directory name, not the `name` field.
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_language_id"
        )
    ]
)
