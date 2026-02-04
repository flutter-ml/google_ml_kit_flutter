// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_translation",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-translation",
            targets: ["google_mlkit_translation"]
        ),
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
    ],
    targets: [
        .target(
            name: "google_mlkit_translation",
            dependencies: [
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_translation",
            publicHeadersPath: "include/google_mlkit_translation",
            cSettings: [
                .headerSearchPath("include/google_mlkit_translation")
            ]
        ),
    ]
)
