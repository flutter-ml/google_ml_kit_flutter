# google_ml_kit example app

Demonstrates how to use the google_mlkit plugins.

This example app is not production code, its purpose is to demonstrate some of the functionality of all the plugins found [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master). If you find any issue with it fell free to contribute. Pull request are always welcome.

## iOS Configuration

To run the iOS example app, you need to configure your Apple Developer Team and Product Bundle Identifier:

1. Copy the example configuration file [Local.xcconfig.example](file:///Users/francisco.bernal/workspace/google_ml_kit_flutter/packages/example/ios/Flutter/Local.xcconfig.example):
   ```bash
   cp ios/Flutter/Local.xcconfig.example ios/Flutter/Local.xcconfig
   ```
   *(Note: `Local.xcconfig` is gitignored and will not be committed to the repository)*

2. Open the newly created `Local.xcconfig` and update the following settings:
   * `DEVELOPMENT_TEAM`: Set this to your Apple Developer Team ID (found in your [Apple Developer Account](https://developer.apple.com/account)).
   * `PRODUCT_BUNDLE_IDENTIFIER`: Set this to your unique bundle identifier.

> [!WARNING]
> Do not modify `DEVELOPMENT_TEAM` or `PRODUCT_BUNDLE_IDENTIFIER` directly within the Xcode project settings, and do not commit any changes to the project files regarding these variables. Use only the `Local.xcconfig` file for these configurations, as it is gitignored and ensures personal credentials/identifiers are not checked into the repository.

## Getting Started with Flutter

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
