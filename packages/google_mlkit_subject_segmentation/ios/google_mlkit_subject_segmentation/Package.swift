// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_subject_segmentation",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "google-mlkit-subject-segmentation",
            targets: ["google_mlkit_subject_segmentation"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "google_mlkit_subject_segmentation",
            dependencies: [],
            path: "Sources/google_mlkit_subject_segmentation",
            publicHeadersPath: "include/google_mlkit_subject_segmentation",
            cSettings: [
                .headerSearchPath("include/google_mlkit_subject_segmentation")
            ]
        ),
    ]
)
