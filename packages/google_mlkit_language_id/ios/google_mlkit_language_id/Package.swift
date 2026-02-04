// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_language_id",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-language-id",
            targets: ["google_mlkit_language_id"]
        ),
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
    ],
    targets: [
        .target(
            name: "google_mlkit_language_id",
            dependencies: [
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_language_id",
            publicHeadersPath: "include/google_mlkit_language_id",
            cSettings: [
                .headerSearchPath("include/google_mlkit_language_id")
            ]
        ),
    ]
)
