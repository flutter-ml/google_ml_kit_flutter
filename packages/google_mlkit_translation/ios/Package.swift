// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// This Package.swift provides Swift Package Manager support for google_mlkit_translation.
// See: https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors

import PackageDescription

let package = Package(
  name: "google_mlkit_translation",
  platforms: [
    .iOS("15.5")
  ],
  products: [
    .library(
      name: "google_mlkit_translation",
      targets: ["google_mlkit_translation"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/d-date/google-mlkit-swiftpm",
      from: "9.0.0"
    )
  ],
  targets: [
    .target(
      name: "google_mlkit_translation",
      dependencies: [
        .product(name: "MLKitTranslate", package: "GoogleMLKitSwiftPM"),
        .product(name: "MLKitNaturalLanguage", package: "GoogleMLKitSwiftPM"),
        .product(name: "MLKitXenoCommon", package: "GoogleMLKitSwiftPM"),
        .product(name: "MLKitCommon", package: "GoogleMLKitSwiftPM"),
        .product(name: "GoogleToolboxForMac", package: "GoogleMLKitSwiftPM"),
        .product(name: "Common", package: "GoogleMLKitSwiftPM"),
      ],
      path: "Classes"
    )
  ]
)
