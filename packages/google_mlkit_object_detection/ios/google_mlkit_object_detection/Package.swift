// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-object-detection",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-object-detection",
            targets: ["google_mlkit_object_detection"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            exact: "9.0.2"
        )
    ],
    targets: [
        .target(
            name: "google_mlkit_object_detection",
            dependencies: [
                .product(name: "MLKitObjectDetection", package: "google-mlkit-swiftpm"),
                .product(name: "MLKitObjectDetectionCustom", package: "google-mlkit-swiftpm"),
            ],
            path: "Sources/google_mlkit_object_detection"
        )
    ]
)
