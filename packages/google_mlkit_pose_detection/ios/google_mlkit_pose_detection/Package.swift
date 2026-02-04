// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_pose_detection",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-pose-detection",
            targets: ["google_mlkit_pose_detection"]
        ),
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
    ],
    targets: [
        .target(
            name: "google_mlkit_pose_detection",
            dependencies: [
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_pose_detection",
            publicHeadersPath: "include/google_mlkit_pose_detection",
            cSettings: [
                .headerSearchPath("include/google_mlkit_pose_detection")
            ]
        ),
    ]
)
