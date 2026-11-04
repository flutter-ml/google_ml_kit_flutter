// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-genai-summarization",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-genai-summarization",
            targets: ["google_mlkit_genai_summarization"])
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "google_mlkit_genai_summarization",
            path: "Sources/google_mlkit_genai_summarization"
        )
    ]
)
