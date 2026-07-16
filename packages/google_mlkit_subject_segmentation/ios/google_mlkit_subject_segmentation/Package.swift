// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "google-mlkit-subject-segmentation",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(
            name: "google-mlkit-subject-segmentation",
            targets: ["google_mlkit_subject_segmentation"])
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "google_mlkit_subject_segmentation",
            path: "Sources/google_mlkit_subject_segmentation"
        )
    ]
)
