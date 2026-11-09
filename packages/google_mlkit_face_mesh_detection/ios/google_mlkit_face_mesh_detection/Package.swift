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
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "google_mlkit_face_mesh_detection",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/google_mlkit_face_mesh_detection"
        )
    ]
)
