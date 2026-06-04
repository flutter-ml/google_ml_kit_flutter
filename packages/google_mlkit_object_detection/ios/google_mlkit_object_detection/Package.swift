// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// This Package.swift provides Swift Package Manager support for google_mlkit_object_detection.
// See: https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors

import PackageDescription

let package = Package(
  name: "google_mlkit_object_detection",
  platforms: [
	.iOS("15.5")
  ],
  products: [
	.library(
	  name: "google_mlkit_object_detection",
	  targets: ["google_mlkit_object_detection"])
  ],
  dependencies: [
	.package(
	  url: "https://github.com/d-date/google-mlkit-swiftpm",
	  from: "9.0.0"
	)
  ],
  targets: [
	.target(
	  name: "google_mlkit_object_detection",
	  dependencies: [
	    .product(name: "MLKitObjectDetection", package: "google-mlkit-swiftpm"),
	    .product(name: "MLKitObjectDetectionCommon", package: "google-mlkit-swiftpm"),
	    .product(name: "MLImage", package: "google-mlkit-swiftpm"),
	    .product(name: "MLKitVision", package: "google-mlkit-swiftpm"),
	    .product(name: "Common", package: "google-mlkit-swiftpm"),
	  ],
	  path: "../Classes"
	)
  ]
)
