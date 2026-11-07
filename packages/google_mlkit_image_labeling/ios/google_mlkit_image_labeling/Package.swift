// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-image-labeling",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-image-labeling",
            targets: ["google_mlkit_image_labeling"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            exact: "9.0.2"
        )
    ],
    targets: [
        .target(
            name: "google_mlkit_image_labeling",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "MLKitImageLabeling", package: "google-mlkit-swiftpm"),
                .product(name: "MLKitImageLabelingCustom", package: "google-mlkit-swiftpm")
            ],
            path: "Sources/google_mlkit_image_labeling"
        )
    ]
)
