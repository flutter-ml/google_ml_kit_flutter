// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-smart-reply",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "google-mlkit-smart-reply",
            targets: ["google_mlkit_smart_reply"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/d-date/google-mlkit-swiftpm",
            exact: "9.0.2"
        )
    ],
    targets: [
        .target(
            name: "google_mlkit_smart_reply",
            dependencies: [
                .product(name: "MLKitSmartReply", package: "google-mlkit-swiftpm")
            ],
            path: "Sources/google_mlkit_smart_reply"
        )
    ]
)
