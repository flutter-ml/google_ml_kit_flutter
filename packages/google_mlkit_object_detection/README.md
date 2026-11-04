# Google's ML Kit Object Detection and Tracking for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_object_detection)](https://pub.dev/packages/google_mlkit_object_detection)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on GitHub](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit Object Detection and Tracking](https://developers.google.com/ml-kit/vision/object-detection) to detect and track objects in an image or live camera feed.

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

- Minimum iOS Deployment Target: 15.5
- Xcode 15.3.0 or newer
- Swift 5.9 (Swift Package Manager)
- ML Kit does not support 32-bit architectures (i386 and armv7). ML Kit does support 64-bit architectures (x86_64 and arm64). Check this [list](https://developer.apple.com/support/required-device-capabilities/) to see if your device has the required device capabilities. More info [here](https://developers.google.com/ml-kit/migration/ios).

#### Swift Package Manager Setup

This plugin uses **Swift Package Manager (SwiftPM)** via [`d-date/google-mlkit-swiftpm`](https://github.com/d-date/google-mlkit-swiftpm) (`9.0.2`), which also supports Apple Silicon iOS Simulators out of the box.

1. **Linker Flags**: In Xcode, go to **Runner > Build Settings > Linking - General > Other Linker Flags** (`OTHER_LDFLAGS`) and add:
   - `-ObjC`
   - `-all_load`

2. **ML Kit Resource Bundles**: SwiftPM cannot bundle model files inside `.binaryTarget` frameworks into the main app bundle automatically. Download `MLKitObjectDetectionResources.bundle` and `MLKitObjectDetectionCommonResources.bundle` from the [`d-date/google-mlkit-swiftpm` v9.0.2 release](https://github.com/d-date/google-mlkit-swiftpm/releases/tag/9.0.2) and add them to your Xcode `Runner` target (**Build Phases > Copy Bundle Resources**). See [`packages/example/ios/download_mlkit_bundles.sh`](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/ios/download_mlkit_bundles.sh) for an example download script.

### Android

- minSdkVersion: 21
- targetSdkVersion: 36
- compileSdkVersion: 36

**⚠️ Production Disclaimer:** Using this plugin in production is the responsibility of the developers consuming the plugin, not the authors. The authors provide this plugin as-is and are not responsible for any issues, failures, or compatibility problems that may arise from using this plugin in production environments.

## Usage

### Object Detection and Tracking

#### Create an instance of `InputImage`

Create an instance of `InputImage` as explained [here](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons#creating-an-inputimage).

```dart
final InputImage inputImage;
```

#### Create an instance of `ObjectDetector`

```dart
// Use DetectionMode.stream when processing camera feed.
// Use DetectionMode.single when processing a single image.
final mode = DetectionMode.stream; // or DetectionMode.single

// Options to configure the detector while using with base model.
final options = ObjectDetectorOptions(...);

// Options to configure the detector while using a local custom model.
final options = LocalObjectDetectorOptions(...);

// Options to configure the detector while using a Firebase model.
final options = FirebaseObjectDetectorOptions(...);

final objectDetector = ObjectDetector(options: options);
```

#### Process image

```dart
final List<DetectedObject> objects = await objectDetector.processImage(inputImage);

for (DetectedObject detectedObject in objects) {
  final rect = detectedObject.boundingBox;
  final trackingId = detectedObject.trackingId;

  for (Label label in detectedObject.labels) {
    print('${label.index} ${label.text} ${label.confidence}');
  }
}
```

#### Release resources with `close()`

```dart
objectDetector.close();
```

## Models

Object Detection and Tracking can be used with either the Base Model or a [Custom Model](https://developers.google.com/ml-kit/custom-models). The base model is the default model bundled in the SDK, and a custom model can either be bundled with the app as an asset or downloaded from [Firebase](https://firebase.google.com/).

### Base model

To use the base model:

```dart
final options = ObjectDetectorOptions(
  mode: DetectionMode.stream,
  classifyObjects: classifyObjects,
  multipleObjects: multipleObjects,
);
final objectDetector = ObjectDetector(options: options);
```

### Local custom model

Before using a [custom model](https://developers.google.com/ml-kit/custom-models) make sure you read and understand the ML Kit's compatibility requirements for TensorFlow Lite models [here](https://developers.google.com/ml-kit/custom-models#model-compatibility). To learn how to create a custom model that is compatible with ML Kit go [here](https://github.com/flutter-ml/mlkit-custom-model).

To use a local custom model add the [tflite model](https://www.tensorflow.org/lite) to your `pubspec.yaml`:

```yaml
assets:
  - assets/ml/
```

Add this method:

```dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getModelPath(String asset) async {
  final path = '${(await getApplicationSupportDirectory()).path}/$asset';
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file.writeAsBytes(byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
  return file.path;
}
```

Create an instance of `ObjectDetector`:

```dart
final modelPath = await getModelPath('assets/ml/object_labeler.tflite');
final options = LocalObjectDetectorOptions(
  mode: DetectionMode.stream,
  modelPath: modelPath,
  classifyObjects: classifyObjects,
  multipleObjects: multipleObjects,
  confidenceThreshold: 0.5, // optional, defaults to 0.5
  maximumLabelsPerObject: 10, // optional, defaults to 10
);
final objectDetector = ObjectDetector(options: options);
```

#### Android Additional Setup

Add the following to your app's `android/app/build.gradle` (or `android/app/build.gradle.kts`) file to ensure Gradle doesn't compress the model file when building the app:

Groovy (`build.gradle`):

```groovy
android {
    // ...
    androidResources {
        noCompress "tflite"
        // or noCompress "lite"
    }
}
```

Kotlin DSL (`build.gradle.kts`):

```kotlin
android {
    // ...
    androidResources {
        noCompress += "tflite"
        // or noCompress += "lite"
    }
}
```

### Firebase model

Google's standalone ML Kit library does **NOT** have any direct dependency with Firebase. As designed by Google, you do NOT need to include Firebase in your project in order to use ML Kit. However, to use a remote model hosted in Firebase, you must set up Firebase in your project following these steps:

- [Android](https://firebase.google.com/docs/android/setup)
- [iOS](https://firebase.google.com/docs/ios/setup)

#### iOS Additional Setup

**Note:** The iOS implementation uses Swift’s `#if canImport(MLKitLinkFirebase)` to conditionally enable Firebase-hosted model code. Because the Swift Package Manager distribution ([`d-date/google-mlkit-swiftpm`](https://github.com/d-date/google-mlkit-swiftpm)) does not currently expose an `MLKitLinkFirebase` product, the plugin compiles without Firebase remote model support by default on iOS and returns an error (`ERROR_MISSING_MLKIT_FIREBASE_MODELS`) when `FirebaseObjectDetectorOptions` is used unless `MLKitLinkFirebase` is linked into the build.

#### Usage

To use a Firebase model, make sure you download the remote model first using `FirebaseObjectDetectorModelManager().downloadModel(modelName)` (calling `processImage()` before the model is downloaded returns a `"Model has not been downloaded yet"` error):

```dart
final options = FirebaseObjectDetectorOptions(
  mode: DetectionMode.stream,
  modelName: modelName,
  classifyObjects: classifyObjects,
  multipleObjects: multipleObjects,
  confidenceThreshold: 0.5, // optional, defaults to 0.5
  maximumLabelsPerObject: 10, // optional, defaults to 10
);
final objectDetector = ObjectDetector(options: options);
```

#### Managing Firebase models

Create an instance of model manager:

```dart
final modelManager = FirebaseObjectDetectorModelManager();
```

To check if a model is downloaded:

```dart
final bool response = await modelManager.isModelDownloaded(modelName);
```

To download a model:

```dart
final bool response = await modelManager.downloadModel(
  modelName,
  isWifiRequired: true, // optional, defaults to true (enforced on Android only)
);
```

To delete a model:

```dart
final bool response = await modelManager.deleteModel(modelName);
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non-trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
