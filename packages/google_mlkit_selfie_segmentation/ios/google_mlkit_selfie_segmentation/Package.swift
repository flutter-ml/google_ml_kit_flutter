// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_selfie_segmentation",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-selfie-segmentation",
            targets: ["google_mlkit_selfie_segmentation"]
        ),
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
    ],
    targets: [
        .target(
            name: "google_mlkit_selfie_segmentation",
            dependencies: [
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_selfie_segmentation",
            publicHeadersPath: "include/google_mlkit_selfie_segmentation",
            cSettings: [
                .headerSearchPath("include/google_mlkit_selfie_segmentation")
            ]
        ),
    ]
)
