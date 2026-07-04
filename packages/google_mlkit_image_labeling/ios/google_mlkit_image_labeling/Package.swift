// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-image-labeling",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-image-labeling",
            targets: ["google_mlkit_image_labeling"])
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
        .package(
            url: "https://github.com/arrrrny/google-mlkit-swiftpm",
            revision: "617e67690b277b7d2063c2e4f367bd0155ee79c0"
        ),
    ],
    targets: [
        .target(
            name: "google_mlkit_image_labeling",
            dependencies: [
                .product(name: "MLKitImageLabeling", package: "google-mlkit-swiftpm"),
                .product(name: "MLKitImageLabelingCustom", package: "google-mlkit-swiftpm"),
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_image_labeling"
        )
    ]
)
