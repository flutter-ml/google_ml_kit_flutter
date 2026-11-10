// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-commons",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-commons",
            targets: ["google_mlkit_commons"])
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
            name: "google_mlkit_commons",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                // google-mlkit-swiftpm does not expose standalone MLKitVision or MLKitCommon
                // library products.
                .product(name: "MLKitBarcodeScanning", package: "google-mlkit-swiftpm")
            ],
            path: "Sources/google_mlkit_commons"
        )
    ]
)
