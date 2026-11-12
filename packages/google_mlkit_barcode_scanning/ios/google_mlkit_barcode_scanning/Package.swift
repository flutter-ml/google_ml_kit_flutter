// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-barcode-scanning",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-barcode-scanning",
            targets: ["google_mlkit_barcode_scanning"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            exact: "9.0.3"
        )
    ],
    targets: [
        .target(
            name: "google_mlkit_barcode_scanning",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "MLKitBarcodeScanning", package: "google-mlkit-swiftpm")
            ],
            path: "Sources/google_mlkit_barcode_scanning"
        )
    ]
)
