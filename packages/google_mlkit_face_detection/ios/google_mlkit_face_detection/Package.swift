// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-face-detection",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-face-detection",
            targets: ["google_mlkit_face_detection"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            exact: "9.0.2"
        )
    ],
    targets: [
        .target(
            name: "google_mlkit_face_detection",
            dependencies: [
                .product(name: "MLKitFaceDetection", package: "google-mlkit-swiftpm"),
            ],
            path: "Sources/google_mlkit_face_detection"
        )
    ]
)
