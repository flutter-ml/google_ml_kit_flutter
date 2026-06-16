SPM migration guide

This repository has migrated iOS packaging for plugin source to Swift Package Manager (SPM).

What changed
- All plugin-level CocoaPods podspecs under `packages/*/ios/*.podspec` have been disabled. Attempting to install the plugin via CocoaPods will print a clear error directing you to this document.
- Each plugin that provides iOS native code exposes an SPM package under `packages/<plugin>/ios/<package>/Package.swift`.

How to consume the plugins with SPM (app authors)
1. In Xcode open your app project.
2. File → Add Packages…
3. Paste the repository URL (your local path or remote URL) and select the version you want. Example: `https://github.com/d-date/google-mlkit-swiftpm` is used as the canonical upstream package for ML Kit binaries.
4. Add the ML Kit products you need (for example `MLKitBarcodeScanning`, `MLKitTextRecognition`, etc.) to your app target.
5. If you need to reference the plugin packages included in this repository directly (local development), add a local package with the path to the package folder, for example `packages/google_mlkit_barcode_scanning/ios/google_mlkit_barcode_scanning` and `packages/google_mlkit_commons/ios/google_mlkit_commons`.

Notes for plugin maintainers / local development
- Each plugin's SPM package is located at `packages/<plugin>/ios/<package>/Package.swift` (e.g. `packages/google_mlkit_barcode_scanning/ios/google_mlkit_barcode_scanning/Package.swift`).
- When adding local SPM dependencies, SPM determines package identity from the folder name of the package directory. Use the directory name exactly when referencing a local package path.
- If a plugin previously required adding language-specific ML Kit pods (e.g. for text recognition), use the ML Kit SwiftPM package and add the language-specific ML Kit SPM products instead.
- For Firebase-hosted models: add Firebase SDK packages via SPM (for example `FirebaseCore`, `FirebaseRemoteConfig` or the specific Firebase products you need) and the ML Kit Link-Firebase product (if provided by the ML Kit SPM package). The plugin uses `#if canImport(MLKitLinkFirebase)` to detect Firebase support at compile time.

Apple Silicon iOS Simulator (iOS 26+)
- The historical CocoaPods workaround that relabeled binary slices is irrelevant for SPM. If you encounter arm64 simulator issues, ensure Xcode and ML Kit SPM artifacts are up to date. As a temporary development workaround you can adjust target-level excluded architectures in your Xcode project settings.

If you need help migrating a specific app or example project to SPM, open an issue with the target project and I will provide step-by-step instructions for that case.

