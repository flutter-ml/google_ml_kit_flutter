// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-genai-image-description",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-genai-image-description",
            targets: ["google_mlkit_genai_image_description"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "google_mlkit_genai_image_description",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/google_mlkit_genai_image_description"
        )
    ]
)
