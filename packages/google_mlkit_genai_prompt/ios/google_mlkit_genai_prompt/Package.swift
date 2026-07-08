// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "google_mlkit_genai_prompt",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(name: "google-mlkit-genai-prompt", targets: ["google_mlkit_genai_prompt"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "google_mlkit_genai_prompt",
            dependencies: [],
            path: "Sources/google_mlkit_genai_prompt"
        )
    ]
)
