// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_barcode_scanning",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-barcode-scanning",
            targets: ["google_mlkit_barcode_scanning"]
        ),
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
    ],
    targets: [
        .target(
            name: "google_mlkit_barcode_scanning",
            dependencies: [
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_barcode_scanning",
            publicHeadersPath: "include/google_mlkit_barcode_scanning",
            cSettings: [
                .headerSearchPath("include/google_mlkit_barcode_scanning")
            ]
        ),
    ]
)
