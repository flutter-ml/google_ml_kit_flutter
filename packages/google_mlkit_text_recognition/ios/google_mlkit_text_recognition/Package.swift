// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_text_recognition",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-text-recognition",
            targets: ["google_mlkit_text_recognition"]
        ),
    ],
    dependencies: [
        .package(path: "../../../google_mlkit_commons/ios/google_mlkit_commons"),
    ],
    targets: [
        .target(
            name: "google_mlkit_text_recognition",
            dependencies: [
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
            ],
            path: "Sources/google_mlkit_text_recognition",
            publicHeadersPath: "include/google_mlkit_text_recognition",
            cSettings: [
                .headerSearchPath("include/google_mlkit_text_recognition")
            ]
        ),
    ]
)
