# Google's ML Kit Text Recognition for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_text_recognition)](https://pub.dev/packages/google_mlkit_text_recognition)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/flutter.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition/v2) to recognize text in any Chinese, Devanagari, Japanese, Korean and Latin character set.

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/flutter-ml/google_ml_kit_flutter/issues):

- [Google's ML Kit](https://developers.google.com/ml-kit) was build only for mobile platforms: iOS and Android apps.

- This plugin is not sponsor or maintained by Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) are developers excited about machine learning that wanted to expose Google's native APIs to Flutter.

- Google's ML Kit APIs are ony developed natively for iOS and Android. This plugin uses Flutter Platform Channels as explained [here](https://docs.flutter.dev/development/platform-integration/platform-channels).

  Messages are passed between the client (the app/plugin) and host (platform) using platform channels as illustrated in this diagram:

  <p align="center" width="100%">
    <img src="https://docs.flutter.dev/assets/images/docs/PlatformChannels.png"> 
  </p>

  Messages and responses are passed asynchronously, to ensure the user interface remains responsive. To read more about platform channels go [here](https://docs.flutter.dev/development/platform-integration/platform-channels).

  Because this plugin uses platform channels, no Machine Learning processing is done in Flutter/Dart, all the calls are passed to the native platform using `MethodChannel` in Android and `FlutterMethodChannel` in iOS, and executed using the Google's native APIs. Think of this plugin as a bridge between your app and Google's native ML Kit APIs. This plugin only passes the call to the native API and the processing is done by Google's API. It is important that you understand this concept when it comes to debugging errors for your ML model and/or app.

- Since the plugin uses platform channels, you may encounter issues with the native API. Before submitting a new issue, identify the source of the issue. You can run both iOS and/or Android native [example apps by Google](https://github.com/googlesamples/mlkit) and make sure that the issue is not reproducible with their native examples. If you can reproduce the issue in their apps then report the issue to Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) do not have access to the source code of their native APIs, so you need to report the issue to them. If you find that their example apps are okay and still you have an issue using this plugin, then look at our [closed and open issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues). If you cannot find anything that can help you then report the issue and provide enough details. Be patient, someone from the community will eventually help you.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/flutter-ml/google_ml_kit_flutter#requirements).

### Supported languages

The ML Kit Text Recognition API can recognize text in any Chinese, Devanagari, Japanese, Korean and Latin character set. Supported languages can be found [here](https://developers.google.com/ml-kit/vision/text-recognition/v2/languages).

## Usage

### Text Recognition

### Adding language package dependencies

By default, this package only supports recognition of Latin characters. If you need to recognize other languages, you need to manually add dependencies

For the iOS platform add to the `ios/Podfile` file:

```ruby
# Add language package you need to use
pod 'GoogleMLKit/TextRecognitionChinese', '~> 4.0.0'
pod 'GoogleMLKit/TextRecognitionDevanagari', '~> 4.0.0'
pod 'GoogleMLKit/TextRecognitionJapanese', '~> 4.0.0'
pod 'GoogleMLKit/TextRecognitionKorean', '~> 4.0.0'
```

For the Android platform add to the `android/app/build.gradle` file:

```gradle
dependencies {
    // Add language package you need to use
    implementation 'com.google.mlkit:text-recognition-chinese:16.0.0-beta6'
    implementation 'com.google.mlkit:text-recognition-devanagari:16.0.0-beta6'
    implementation 'com.google.mlkit:text-recognition-japanese:16.0.0-beta6'
    implementation 'com.google.mlkit:text-recognition-korean:16.0.0-beta6'
}
```

#### Create an instance of `InputImage`

Create an instance of `InputImage` as explained [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/google_mlkit_commons#creating-an-inputimage).

```dart
final InputImage inputImage;
```

#### Create an instance of `TextRecognizer`

```dart
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
    // Same getters as TextBlock
    for (TextElement element in line.elements) {
      // Same getters as TextBlock
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
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
