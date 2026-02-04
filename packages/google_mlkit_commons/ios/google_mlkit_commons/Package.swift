// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_commons",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-commons",
            targets: ["google_mlkit_commons"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "google_mlkit_commons",
            dependencies: [],
            path: "Sources/google_mlkit_commons",
            publicHeadersPath: "include/google_mlkit_commons",
            cSettings: [
                .headerSearchPath("include/google_mlkit_commons")
            ]
        ),
    ]
)
