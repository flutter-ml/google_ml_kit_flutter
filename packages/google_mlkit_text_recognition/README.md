# Google's ML Kit Text Recognition for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_text_recognition)](https://pub.dev/packages/google_mlkit_text_recognition)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on GitHub](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition/v2) to recognize text in any Chinese, Devanagari, Japanese, Korean and Latin character set.

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/flutter-ml/google_ml_kit_flutter/issues):

- [Google's ML Kit](https://developers.google.com/ml-kit) was built only for mobile platforms: iOS and Android apps. Web or any other platform is not supported, you can request support for those platforms to Google in [their repo](https://github.com/googlesamples/mlkit/issues).

- This plugin is not sponsored or maintained by Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) are developers excited about Machine Learning that wanted to expose Google's native APIs to Flutter.

- Google's ML Kit APIs are only developed natively for iOS and Android. This plugin uses Flutter Platform Channels as explained [here](https://docs.flutter.dev/platform-integration/platform-channels).

  Messages are passed between the client (the app/plugin) and host (platform) using platform channels as illustrated in this diagram:

  <p align="center" width="100%">
    <img src="https://docs.flutter.dev/assets/images/docs/PlatformChannels.png">
  </p>

  Messages and responses are passed asynchronously, to ensure the user interface remains responsive. To read more about platform channels go [here](https://docs.flutter.dev/platform-integration/platform-channels).

  Because this plugin uses platform channels, no Machine Learning processing is done in Flutter/Dart, all the calls are passed to the native platform using `MethodChannel` in Android and `FlutterMethodChannel` in iOS, and executed using Google's native APIs. Think of this plugin as a bridge between your app and Google's native ML Kit APIs. This plugin only passes the call to the native API and the processing is done by Google's API. It is important that you understand this concept when it comes to debugging errors for your ML model and/or app.

- Since the plugin uses platform channels, you may encounter issues with the native API. Before submitting a new issue, identify the source of the issue. You can run both iOS and/or Android native [example apps by Google](https://github.com/googlesamples/mlkit) and make sure that the issue is not reproducible with their native examples. If you can reproduce the issue in their apps then report the issue to Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) do not have access to the source code of their native APIs, so you need to report the issue to them. If you find that their example apps are okay and still you have an issue using this plugin, then look at our [closed and open issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues). If you cannot find anything that can help you then report the issue and provide enough details. Be patient, someone from the community will eventually help you.

## Requirements

### iOS

- Minimum iOS Deployment Target: 15.0
- Xcode 15.3.0 or newer
- Swift 5.9 (Swift Package Manager)
- ML Kit does not support 32-bit architectures (i386 and armv7). ML Kit does support 64-bit architectures (x86_64 and arm64). Check this [list](https://developer.apple.com/support/required-device-capabilities/) to see if your device has the required device capabilities. More info [here](https://developers.google.com/ml-kit/migration/ios).

#### Swift Package Manager Setup

This plugin uses **Swift Package Manager (SwiftPM)** via [`d-date/google-mlkit-swiftpm`](https://github.com/d-date/google-mlkit-swiftpm) (`9.0.2`), which also supports Apple Silicon iOS Simulators out of the box.

1. **Linker Flags**: In Xcode, go to **Runner > Build Settings > Linking - General > Other Linker Flags** (`OTHER_LDFLAGS`) and add:
   - `-ObjC`
   - `-all_load`

2. **ML Kit Resource Bundle**: SwiftPM cannot bundle model files inside `.binaryTarget` frameworks into the main app bundle automatically. Download `LatinOCRResources.bundle` from the [`d-date/google-mlkit-swiftpm` v9.0.2 release](https://github.com/d-date/google-mlkit-swiftpm/releases/tag/9.0.2) and add it to your Xcode `Runner` target (**Build Phases > Copy Bundle Resources**). See [`packages/example/ios/download_mlkit_bundles.sh`](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/ios/download_mlkit_bundles.sh) for an example download script.

### Android

- minSdkVersion: 21
- targetSdkVersion: 36
- compileSdkVersion: 36

**⚠️ Production Disclaimer:** Using this plugin in production is the responsibility of the developers consuming the plugin, not the authors. The authors provide this plugin as-is and are not responsible for any issues, failures, or compatibility problems that may arise from using this plugin in production environments.

### Supported languages

The ML Kit Text Recognition API can recognize text in any Chinese, Devanagari, Japanese, Korean and Latin character set. Supported languages can be found [here](https://developers.google.com/ml-kit/vision/text-recognition/v2/languages).

**Platform note:** on **iOS** only the Latin character set is currently supported; on **Android** all five scripts are available (the non-Latin ones as optional dependencies, see below).

## Usage

### Text Recognition

#### Adding language package dependencies

For the **iOS** platform, only the base script recognition library (`MLKitTextRecognition`, Latin character set) is included via Swift Package Manager. Ensure `LatinOCRResources.bundle` is added to your Xcode `Runner` target's **Copy Bundle Resources** phase.

Recognizing other scripts on iOS (Chinese, Devanagari, Japanese, Korean) is **not supported yet**: if you request one of them, the plugin gracefully falls back to the Latin recognizer (it never crashes, but non-Latin text is not recognized). Per-script support on iOS is planned to be offered via separate add-on packages.

For the **Android** platform, by default this package only bundles Latin character recognition. If you need to recognize other scripts on Android, add the required dependency to your `android/app/build.gradle` (or `android/app/build.gradle.kts`) file:

Groovy (`build.gradle`):

```groovy
dependencies {
    // Add language package you need to use
    implementation 'com.google.mlkit:text-recognition-chinese:16.0.1'
    implementation 'com.google.mlkit:text-recognition-devanagari:16.0.1'
    implementation 'com.google.mlkit:text-recognition-japanese:16.0.1'
    implementation 'com.google.mlkit:text-recognition-korean:16.0.1'
}
```

Kotlin DSL (`build.gradle.kts`):

```kotlin
dependencies {
    // Add language package you need to use
    implementation("com.google.mlkit:text-recognition-chinese:16.0.1")
    implementation("com.google.mlkit:text-recognition-devanagari:16.0.1")
    implementation("com.google.mlkit:text-recognition-japanese:16.0.1")
    implementation("com.google.mlkit:text-recognition-korean:16.0.1")
}
```

#### Create an instance of `InputImage`

Create an instance of `InputImage` as explained [here](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons#creating-an-inputimage).

```dart
final InputImage inputImage;
```

#### Create an instance of `TextRecognizer`

```dart
// Available scripts: latin, chinese, devanagiri, japanese, korean
final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
```

#### Process image

```dart
final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

String text = recognizedText.text;
for (TextBlock block in recognizedText.blocks) {
  final Rect rect = block.boundingBox;
  final List<Point<int>> cornerPoints = block.cornerPoints;
  final String text = block.text;
  final List<String> languages = block.recognizedLanguages;

  for (TextLine line in block.lines) {
    // Same getters as TextBlock, plus confidence and angle (Android only; null on iOS)
    final double? confidence = line.confidence;
    final double? angle = line.angle;
    for (TextElement element in line.elements) {
      // Same getters as TextLine
      for (TextSymbol symbol in element.symbols) {
        // Same getters as TextElement (Android only; empty on iOS)
      }
    }
  }
}
```

#### Release resources with `close()`

```dart
textRecognizer.close();
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non-trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
