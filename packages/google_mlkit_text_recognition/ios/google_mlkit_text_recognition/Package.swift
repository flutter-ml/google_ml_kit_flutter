// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-text-recognition",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-text-recognition",
            targets: ["google_mlkit_text_recognition"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            exact: "9.0.2"
        )
    ],
    targets: [
        .target(
            name: "google_mlkit_text_recognition",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "MLKitTextRecognition", package: "google-mlkit-swiftpm")
            ],
            path: "Sources/google_mlkit_text_recognition"
        )
    ]
)
