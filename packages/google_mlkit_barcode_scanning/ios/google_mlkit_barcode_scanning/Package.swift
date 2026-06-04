// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// This Package.swift provides Swift Package Manager support for google_mlkit_barcode_scanning.
// See: https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors

import PackageDescription

let package = Package(
  name: "google_mlkit_barcode_scanning",
  platforms: [
	.iOS("15.5")
  ],
  products: [
	.library(
	  name: "google_mlkit_barcode_scanning",
	  targets: ["google_mlkit_barcode_scanning"])
  ],
  dependencies: [
	.package(
	  url: "https://github.com/d-date/google-mlkit-swiftpm",
	  from: "9.0.0"
	)
  ],
  targets: [
	.target(
	  name: "google_mlkit_barcode_scanning",
	  dependencies: [
	    .product(name: "MLKitBarcodeScanning", package: "GoogleMLKitSwiftPM"),
	    .product(name: "MLImage", package: "GoogleMLKitSwiftPM"),
	    .product(name: "MLKitVision", package: "GoogleMLKitSwiftPM"),
	    .product(name: "Common", package: "GoogleMLKitSwiftPM"),
	  ],
	  path: "../Classes"
	)
  ]
)
