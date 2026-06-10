// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-genai-proofreading",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-genai-proofreading",
            targets: ["google_mlkit_genai_proofreading"])
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "google_mlkit_genai_proofreading",
            path: "Sources/google_mlkit_genai_proofreading"
        )
    ]
)
