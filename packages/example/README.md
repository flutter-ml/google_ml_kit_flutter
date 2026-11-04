# google_ml_kit example app

Demonstrates how to use the google_mlkit plugins.

This example app is not production code, its purpose is to demonstrate some of the functionality of all the plugins found [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master). If you find any issue with it feel free to contribute. Pull requests are always welcome.

## iOS Configuration

To run the iOS example app, you need to configure your Apple Developer Team and Product Bundle Identifier:

1. Copy the example configuration file [`Local.xcconfig.example`](ios/Flutter/Local.xcconfig.example):
   ```bash
   cp ios/Flutter/Local.xcconfig.example ios/Flutter/Local.xcconfig
   ```
   *(Note: `Local.xcconfig` is gitignored and will not be committed to the repository)*

2. Open the newly created `Local.xcconfig` and update the following settings:
   * `DEVELOPMENT_TEAM`: Set this to your Apple Developer Team ID (found in your [Apple Developer Account](https://developer.apple.com/account)).
   * `PRODUCT_BUNDLE_IDENTIFIER`: Set this to your unique bundle identifier.

> [!WARNING]
> Do not modify `DEVELOPMENT_TEAM` or `PRODUCT_BUNDLE_IDENTIFIER` directly within the Xcode project settings, and do not commit any changes to the project files regarding these variables. Use only the `Local.xcconfig` file for these configurations, as it is gitignored and ensures personal credentials/identifiers are not checked into the repository.

### ML Kit resource bundles (required for iOS)

The iOS build uses ML Kit through Swift Package Manager (see
[`d-date/google-mlkit-swiftpm`](https://github.com/d-date/google-mlkit-swiftpm)).
SwiftPM cannot ship the model files inside the frameworks, so the resource
bundles are downloaded separately and are **not committed** (they are gitignored).

Before building for iOS, download them once:

```bash
cd ios
./download_mlkit_bundles.sh        # defaults to ML Kit 9.0.2
```

Run it again after cloning a fresh copy or after the ML Kit version changes.

## Android Configuration

- **Minimum SDK**: `android/app/build.gradle.kts` sets `minSdk = 26` (and `compileSdk = 36` / `targetSdk = 36`) because the example app includes the `google_mlkit_genai_*` plugins, which require Android API level 26+.
- **Camera image streaming**: `pubspec.yaml` includes [`camera_android`](https://pub.dev/packages/camera_android) alongside `camera` so that `ImageFormatGroup.nv21` camera streams work on Android until [flutter/flutter#145961](https://github.com/flutter/flutter/issues/145961) is resolved.

## Integration Tests

An integration test suite in [`integration_test/ml_kit_integration_test.dart`](integration_test/ml_kit_integration_test.dart) exercises each plugin's native code path on a device or emulator/simulator using bundled sample images:

```bash
# Optional on Android: pre-grant camera permission so the system dialog does not block the test run
adb shell pm grant com.google.ml.kit.flutter.example android.permission.CAMERA

flutter test integration_test/ml_kit_integration_test.dart
```

## Getting Started with Flutter

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
