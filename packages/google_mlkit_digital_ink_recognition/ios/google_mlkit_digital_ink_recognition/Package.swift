// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-digital-ink-recognition",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-digital-ink-recognition",
            targets: ["google_mlkit_digital_ink_recognition"])
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons")
    ],
    targets: [
        .target(
            name: "google_mlkit_digital_ink_recognition",
            dependencies: [
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons")
            ],
            path: "Sources/google_mlkit_digital_ink_recognition"
        )
    ]
)
