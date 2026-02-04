// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_genai_proofreading",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-genai-proofreading",
            targets: ["google_mlkit_genai_proofreading"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "google_mlkit_genai_proofreading",
            dependencies: [],
            path: "Sources/google_mlkit_genai_proofreading",
            publicHeadersPath: "include/google_mlkit_genai_proofreading",
            cSettings: [
                .headerSearchPath("include/google_mlkit_genai_proofreading")
            ]
        ),
    ]
)
