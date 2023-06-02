# Google's ML Kit Digital Ink Recognition for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_digital_ink_recognition)](https://pub.dev/packages/google_mlkit_digital_ink_recognition)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/flutter.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit Digital Ink Recognition](https://developers.google.com/ml-kit/vision/digital-ink-recognition) to recognize handwritten text on a digital surface in hundreds of languages, as well as classify sketches.

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

## Usage

### Digital Ink Recognition

#### Create an instance of `DigitalInkRecognizer`

```dart
String languageCode; // BCP-47 Code from https://developers.google.com/ml-kit/vision/digital-ink-recognition/base-models?hl=en#text
final digitalInkRecognizer = DigitalInkRecognizer(languageCode: languageCode);
```

#### Process ink

```dart
final p1 = StrokePoint(x: x1, y: y1, t: DateTime.now().millisecondsSinceEpoch); // make sure that `t` is a long
final p2 = StrokePoint(x: x1, y: y1, t: DateTime.now().millisecondsSinceEpoch); // make sure that `t` is a long

Stroke stroke1 = Stroke(); // it contains all of the StrokePoint
stroke1.point = [p1, p2, ...]

Ink ink = Ink(); // it contains all of the Stroke
ink.strokes = [stroke1, stroke2, ...];

final List<RecognitionCandidate> candidates = await digitalInkRecognizer.recognize(ink);

for (final candidate in candidates) {
  final text = candidate.text;
  final score = candidate.score;
}
```

Make sure you download the language model before processing any `Ink`.

To improve the accuracy of text recognition you can set an writing area and pre-context. More details [here](https://developers.google.cn/ml-kit/vision/digital-ink-recognition/ios#tips-to-improve-text-recognition-accuracy).

```dart
String preContext;
double width;
double height;
final context = DigitalInkRecognitionContext(
  preContext: preContext,
  writingArea: WritingArea(width: width, height: height),
);

final List<RecognitionCandidate> candidates = await digitalInkRecognizer.recognize(ink, context: context);

```

#### Release resources with `close()`

```dart
digitalInkRecognizer.close();
```

### Managing remote models

#### Create an instance of model manager

```dart
final modelManager = DigitalInkRecognizerModelManager();
```

#### Check if model is downloaded

```dart
final bool response = await modelManager.isModelDownloaded(model);
```

#### Download model

```dart
final bool response = await modelManager.downloadModel(model);
```

#### Delete model

```dart
final bool response = await modelManager.deleteModel(model);
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
