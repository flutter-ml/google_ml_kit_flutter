// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-translation",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-translation",
            targets: ["google_mlkit_translation"])
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
            name: "google_mlkit_translation",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "MLKitTranslate", package: "google-mlkit-swiftpm")
            ],
            path: "Sources/google_mlkit_translation"
        )
    ]
)
