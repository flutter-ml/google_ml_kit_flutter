// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-subject-segmentation",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-subject-segmentation",
            targets: ["google_mlkit_subject_segmentation"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),

    ],
    targets: [
        .target(
            name: "google_mlkit_subject_segmentation",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/google_mlkit_subject_segmentation"
        )
    ]
)
