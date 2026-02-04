// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_document_scanner",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-document-scanner",
            targets: ["google_mlkit_document_scanner"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "google_mlkit_document_scanner",
            dependencies: [],
            path: "Sources/google_mlkit_document_scanner",
            publicHeadersPath: "include/google_mlkit_document_scanner",
            cSettings: [
                .headerSearchPath("include/google_mlkit_document_scanner")
            ]
        ),
    ]
)
