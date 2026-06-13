// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-translation",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-translation",
            targets: ["google_mlkit_translation"])
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
        .package(
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            from: "9.0.0-1"
        ),
    ],
    targets: [
        .target(
            name: "google_mlkit_translation",
            dependencies: [
                .product(name: "MLKitTranslate", package: "google-mlkit-swiftpm"),
                // Note: The `package` value uses the DIRECTORY name ("google_mlkit_commons"), not the
                // Package.swift `name` field ("google-mlkit-commons"). For local path dependencies, SPM
                // derives the package identity from the directory name, not the `name` field.
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_translation"
        )
    ]
)
