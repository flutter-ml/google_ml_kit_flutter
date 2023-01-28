# Google's ML Kit Object Detection and Tracking for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_object_detection)](https://pub.dev/packages/google_mlkit_object_detection)
[![analysis](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions/workflows/flutter.yml/badge.svg)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions)
[![Star on Github](https://img.shields.io/github/stars/bharat-biradar/Google-Ml-Kit-plugin.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit Object Detection and Tracking](https://developers.google.com/ml-kit/vision/object-detection) to detect and track objects in an image or live camera feed.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

### Firebase dependency for remote models

[Object Detection and Tracking](https://developers.google.com/ml-kit/vision/object-detection) can be used with both Base Models and [Custom Models](https://developers.google.com/ml-kit/custom-models). Base models are bundled with the app, and custom Models can either be bundled with the app or downloaded from [Firebase](https://firebase.google.com/).

If you wish to use remote models hosted in Firebase, you must first enable the feature in iOS. Please see the additional setup instructions [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master#firebase-dependency-custom-models).

To add Firebase to your project follow these steps:

- [Android](https://firebase.google.com/docs/android/setup)
- [iOS](https://firebase.google.com/docs/ios/setup)

## Usage

### Object Detection and Tracking

#### Create an instance of `InputImage`

Create an instance of `InputImage` as explained [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_commons#creating-an-inputimage).

```dart
final InputImage inputImage;
```

#### Create an instance of `ObjectDetector`

```dart
// Use DetectionMode.stream when processing camera feed.
// Use DetectionMode.single when processing a single image.
final mode = DetectionMode.stream or DetectionMode.single;

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

for(DetectedObject detectedObject in objects){
  final rect = detectedObject.boundingBox;
  final trackingId = detectedObject.trackingId;

  for(Label label in detectedObject.labels){
    print('${label.text} ${label.confidence}');
  }
}
```

#### Release resources with `close()`

```dart
objectDetector.close();
```

### Load local custom model

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

Future<String> _getModel(String assetPath) async {
  if (io.Platform.isAndroid) {
    return 'flutter_assets/$assetPath';
  }
  final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
  await io.Directory(dirname(path)).create(recursive: true);
  final file = io.File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(assetPath);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
  return file.path;
}
```

Create an instance of [ImageLabeler]:

```dart
final modelPath = await _getModel('assets/ml/object_labeler.tflite');
final options = LocalObjectDetectorOptions(
  modelPath: modelPath,
  classifyObjects: true,
  multipleObjects: true,
  mode: DetectionMode.stream,
);
final objectDetector = ObjectDetector(options: options);
```

### Managing remote models

#### Create an instance of model manager

```dart
final modelManager = FirebaseObjectDetectorModelManager();
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

Find the example app [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
