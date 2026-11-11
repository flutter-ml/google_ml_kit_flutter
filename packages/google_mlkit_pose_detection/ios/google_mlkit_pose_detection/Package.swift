// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-pose-detection",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-pose-detection",
            targets: ["google_mlkit_pose_detection"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            exact: "9.0.3"
        )
    ],
    targets: [
        .target(
            name: "google_mlkit_pose_detection",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "MLKitPoseDetection", package: "google-mlkit-swiftpm"),
                .product(name: "MLKitPoseDetectionAccurate", package: "google-mlkit-swiftpm")
            ],
            path: "Sources/google_mlkit_pose_detection"
        )
    ]
)
