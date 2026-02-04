// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_genai_rewriting",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-genai-rewriting",
            targets: ["google_mlkit_genai_rewriting"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "google_mlkit_genai_rewriting",
            dependencies: [],
            path: "Sources/google_mlkit_genai_rewriting",
            publicHeadersPath: "include/google_mlkit_genai_rewriting",
            cSettings: [
                .headerSearchPath("include/google_mlkit_genai_rewriting")
            ]
        ),
    ]
)
