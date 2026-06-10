// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-genai-image-description",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-genai-image-description",
            targets: ["google_mlkit_genai_image_description"])
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "google_mlkit_genai_image_description",
            path: "Sources/google_mlkit_genai_image_description"
        )
    ]
)
