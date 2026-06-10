// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-text-recognition",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-text-recognition",
            targets: ["google_mlkit_text_recognition"])
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
            name: "google_mlkit_text_recognition",
            dependencies: [
                .product(name: "MLKitTextRecognition", package: "google-mlkit-swiftpm"),
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_text_recognition"
        )
    ]
)
