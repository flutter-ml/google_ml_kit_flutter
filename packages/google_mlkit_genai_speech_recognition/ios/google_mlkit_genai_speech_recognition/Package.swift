// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_genai_speech_recognition",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-genai-speech-recognition",
            targets: ["google_mlkit_genai_speech_recognition"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "google_mlkit_genai_speech_recognition",
            dependencies: [],
            path: "Sources/google_mlkit_genai_speech_recognition",
            publicHeadersPath: "include/google_mlkit_genai_speech_recognition",
            cSettings: [
                .headerSearchPath("include/google_mlkit_genai_speech_recognition")
            ]
        ),
    ]
)
