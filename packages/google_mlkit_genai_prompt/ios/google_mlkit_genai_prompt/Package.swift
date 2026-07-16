// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-genai-prompt",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-genai-prompt",
            targets: ["google_mlkit_genai_prompt"])
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "google_mlkit_genai_prompt",
            path: "Sources/google_mlkit_genai_prompt"
        )
    ]
)
