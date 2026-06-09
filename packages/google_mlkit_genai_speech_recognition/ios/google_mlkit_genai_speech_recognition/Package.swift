// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "google-mlkit-genai-speech-recognition",
  platforms: [
    .iOS("15.0")
  ],
  products: [
    .library(
      name: "google-mlkit-genai-speech-recognition",
      targets: ["google_mlkit_genai_speech_recognition"])
  ],
  dependencies: [

  ],
  targets: [
    .target(
      name: "google_mlkit_genai_speech_recognition",
      path: "Sources/google_mlkit_genai_speech_recognition"
    )
  ]
)
