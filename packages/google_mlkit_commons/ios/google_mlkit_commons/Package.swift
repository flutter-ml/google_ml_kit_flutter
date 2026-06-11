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
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            from: "9.0.0"
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
                // specific module. MLKitObjectDetection is used here as a generic choice; the
                // unused xcframework has no material impact because any real app using Google
                // ML Kit will depend on at least one vision plugin that already brings it in.
                .product(name: "MLKitObjectDetection", package: "google-mlkit-swiftpm")
            ],
            path: "Sources/google_mlkit_commons"
        )
    ]
)
