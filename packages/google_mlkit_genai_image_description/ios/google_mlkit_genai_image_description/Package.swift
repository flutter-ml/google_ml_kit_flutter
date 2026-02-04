// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_genai_image_description",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-genai-image-description",
            targets: ["google_mlkit_genai_image_description"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "google_mlkit_genai_image_description",
            dependencies: [],
            path: "Sources/google_mlkit_genai_image_description",
            publicHeadersPath: "include/google_mlkit_genai_image_description",
            cSettings: [
                .headerSearchPath("include/google_mlkit_genai_image_description")
            ]
        ),
    ]
)
