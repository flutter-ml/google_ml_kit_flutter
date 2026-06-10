// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-face-mesh-detection",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-face-mesh-detection",
            targets: ["google_mlkit_face_mesh_detection"])
    ],
    dependencies: [
        .package(path: "../google_mlkit_commons")
    ],
    targets: [
        .target(
            name: "google_mlkit_face_mesh_detection",
            dependencies: [
                .product(name: "google-mlkit-commons", package: "google-mlkit-commons")
            ],
            path: "Sources/google_mlkit_face_mesh_detection"
        )
    ]
)
