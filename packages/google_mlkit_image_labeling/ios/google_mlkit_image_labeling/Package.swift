// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_image_labeling",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-image-labeling",
            targets: ["google_mlkit_image_labeling"]
        ),
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
    ],
    targets: [
        .target(
            name: "google_mlkit_image_labeling",
            dependencies: [
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_image_labeling",
            publicHeadersPath: "include/google_mlkit_image_labeling",
            cSettings: [
                .headerSearchPath("include/google_mlkit_image_labeling")
            ]
        ),
    ]
)
