// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_smart_reply",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-smart-reply",
            targets: ["google_mlkit_smart_reply"]
        ),
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
    ],
    targets: [
        .target(
            name: "google_mlkit_smart_reply",
            dependencies: [
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_smart_reply",
            publicHeadersPath: "include/google_mlkit_smart_reply",
            cSettings: [
                .headerSearchPath("include/google_mlkit_smart_reply")
            ]
        ),
    ]
)
