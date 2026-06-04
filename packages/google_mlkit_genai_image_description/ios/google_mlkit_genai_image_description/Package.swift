// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// This Package.swift provides Swift Package Manager support for google_mlkit_genai_*.
// See: https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors

import PackageDescription

let package = Package(
  name: "google_mlkit_genai_image_description",
  platforms: [
    .iOS("15.5")
  ],
  products: [
    .library(
      name: "google_mlkit_genai_image_description",
      targets: ["google_mlkit_genai_image_description"])
  ],
  dependencies: [
    // No MLKit dependencies - iOS stub only, empty package is valid in SPM
  ],
  targets: [
    .target(
      name: "google_mlkit_genai_image_description",
      path: "../Classes"
    )
  ]
)
