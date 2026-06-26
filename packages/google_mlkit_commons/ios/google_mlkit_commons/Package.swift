// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-commons",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-commons",
            targets: ["google_mlkit_commons"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/arrrrny/google-mlkit-swiftpm",
            from: "9.0.0-1"
        )
    ],
    targets: [
        .target(
            name: "google_mlkit_commons",
            dependencies: [
                // google-mlkit-swiftpm does not expose standalone MLKitVision or MLKitCommon
                // library products — they are only available as binary targets bundled inside
                // composite products (e.g. MLKitBarcodeScanning, MLKitFaceDetection, etc.).
                // All vision-family products include MLKitVision + MLKitCommon (via the Common
                // target), so we must pick one even though Commons itself does not use the
                // specific module. Since we already include MLKitBarcodeScanning as a product
                // dependency of google_mlkit_commons, this is a natural choice that avoids
                // pulling in unnecessary modules like MLKitVisionKit.
                .product(name: "MLKitBarcodeScanning", package: "google-mlkit-swiftpm")
            ],
            path: "Sources/google_mlkit_commons"
        )
    ]
)
