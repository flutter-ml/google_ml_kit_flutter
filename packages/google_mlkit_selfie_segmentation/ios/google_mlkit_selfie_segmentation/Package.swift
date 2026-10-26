// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-selfie-segmentation",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-selfie-segmentation",
            targets: ["google_mlkit_selfie_segmentation"])
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
        .package(
            url: "https://github.com/mdata-group/google-mlkit-swiftpm",
            exact: "9.0.0-simfix2"
        )
    ],
    targets: [
        .target(
            name: "google_mlkit_selfie_segmentation",
            dependencies: [
                .product(name: "MLKitSegmentationSelfie", package: "google-mlkit-swiftpm"),
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons")
            ],
            path: "Sources/google_mlkit_selfie_segmentation"
        )
    ]
)
