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
        .package(path: "../google_mlkit_commons"),
        .package(
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            from: "9.0.0"
        ),
    ],
    targets: [
        .target(
            name: "google_mlkit_object_detection",
            dependencies: [
                .product(name: "MLKitObjectDetection", package: "google-mlkit-swiftpm"),
                .product(name: "MLKitObjectDetectionCustom", package: "google-mlkit-swiftpm"),
                .product(name: "google-mlkit-commons", package: "google-mlkit-commons"),
            ],
            path: "Sources/google_mlkit_object_detection"
        )
    ]
)
