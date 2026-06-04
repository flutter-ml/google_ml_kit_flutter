// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// This Package.swift provides Swift Package Manager support for google_mlkit_smart_reply.
// See: https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors

import PackageDescription

let package = Package(
  name: "google_mlkit_smart_reply",
  platforms: [
    .iOS("15.5")
  ],
  products: [
    .library(
      name: "google_mlkit_smart_reply",
      targets: ["google_mlkit_smart_reply"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/d-date/google-mlkit-swiftpm",
      from: "9.0.0"
    )
  ],
  targets: [
    .target(
      name: "google_mlkit_smart_reply",
      dependencies: [
        .product(name: "MLKitSmartReply", package: "GoogleMLKitSwiftPM"),
        .product(name: "MLKitLanguageID", package: "GoogleMLKitSwiftPM"),
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
