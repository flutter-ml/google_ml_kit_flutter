// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_genai_prompt",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-genai-prompt",
            targets: ["google_mlkit_genai_prompt"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "google_mlkit_genai_prompt",
            dependencies: [],
            path: "Sources/google_mlkit_genai_prompt",
            publicHeadersPath: "include/google_mlkit_genai_prompt",
            cSettings: [
                .headerSearchPath("include/google_mlkit_genai_prompt")
            ]
        ),
    ]
)
