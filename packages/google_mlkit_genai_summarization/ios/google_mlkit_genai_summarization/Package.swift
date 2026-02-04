// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_genai_summarization",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-genai-summarization",
            targets: ["google_mlkit_genai_summarization"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "google_mlkit_genai_summarization",
            dependencies: [],
            path: "Sources/google_mlkit_genai_summarization",
            publicHeadersPath: "include/google_mlkit_genai_summarization",
            cSettings: [
                .headerSearchPath("include/google_mlkit_genai_summarization")
            ]
        ),
    ]
)
