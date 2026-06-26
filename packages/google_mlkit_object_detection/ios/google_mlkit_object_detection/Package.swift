// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-object-detection",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-object-detection",
            targets: ["google_mlkit_object_detection"])
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
        .package(
            url: "https://github.com/arrrrny/google-mlkit-swiftpm",
            from: "9.0.0-1"
        ),
    ],
    targets: [
        .target(
            name: "google_mlkit_object_detection",
            dependencies: [
                .product(name: "MLKitObjectDetection", package: "google-mlkit-swiftpm"),
                .product(name: "MLKitObjectDetectionCustom", package: "google-mlkit-swiftpm"),
                // Note: The `package` value uses the DIRECTORY name ("google_mlkit_commons"), not the
                // Package.swift `name` field ("google-mlkit-commons"). For local path dependencies, SPM
                // derives the package identity from the directory name, not the `name` field.
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_object_detection"
        )
    ]
)
