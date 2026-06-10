// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-document-scanner",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-document-scanner",
            targets: ["google_mlkit_document_scanner"])
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "google_mlkit_document_scanner",
            path: "Sources/google_mlkit_document_scanner"
        )
    ]
)
