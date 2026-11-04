# Google's ML Kit GenAI Speech Recognition for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_genai_speech_recognition)](https://pub.dev/packages/google_mlkit_genai_speech_recognition)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on GitHub](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

> **_NOTE: This feature is still in Alpha, and it is only available for Android. Stay tuned for updates on [Google's website](https://developers.google.com/ml-kit/genai/speech-recognition) and request the feature [here](https://github.com/googlesamples/mlkit/issues)._**

A Flutter plugin to use [Google's ML Kit GenAI Speech Recognition API](https://developers.google.com/ml-kit/genai/speech-recognition) to transcribe speech to text in real time.

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

This feature is still in Alpha, and it is only available for Android. Stay tuned for updates on [Google's website](https://developers.google.com/ml-kit/genai/speech-recognition) and request the feature [here](https://github.com/googlesamples/mlkit/issues).

### Android

- minSdkVersion: 26
- targetSdkVersion: 36
- compileSdkVersion: 36

**⚠️ Important:** This API is built on top of AICore and will not support all Android devices. It requires devices with AICore support. Please check device compatibility before using this feature in production.

**⚠️ Production Disclaimer:** Using this plugin in production is the responsibility of the developers consuming the plugin, not the authors. The authors provide this plugin as-is and are not responsible for any issues, failures, or compatibility problems that may arise from using this plugin in production environments.

## Usage

### Speech Recognition

#### Create an instance of `SpeechRecognizer`

```dart
final speechRecognizer = SpeechRecognizer();
```

#### Check feature status

```dart
final status = await speechRecognizer.checkStatus();
if (status == FeatureStatus.available) {
  // Start recognition
}
```

#### Start recognition

```dart
final stream = speechRecognizer.startRecognition();
stream.listen((text) {
  print('Recognized: $text');
});
```

#### Stop recognition

```dart
await speechRecognizer.stopRecognition();
```

> **⚠️ Implementation Status:** On Android, `checkStatus()` and `close()` are currently wired to the native `SpeechRecognition.getClient()` API, while `startRecognition()` and `stopRecognition()` are still work-in-progress and currently return `notImplemented`.

#### Release resources with `close()`

```dart
speechRecognizer.close();
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example). Note that the GenAI screens in the example app are currently placeholder views.

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non-trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
