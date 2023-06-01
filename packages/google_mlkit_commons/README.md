# google\_mlkit\_commons

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_commons)](https://pub.dev/packages/google_mlkit_commons)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/flutter.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin with common methods used in [google\_ml\_kit](https://github.com/flutter-ml/google_ml_kit_flutter).

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

### Creating an `InputImage`

From path:

```dart
final inputImage = InputImage.fromFilePath(filePath);
```

From file:

```dart
final inputImage = InputImage.fromFile(file);
```

From bytes:

```dart
final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);
```

If you are using the [Camera plugin](https://pub.dev/packages/camera)) make sure to configure your [CameraController](https://pub.dev/documentation/camera/latest/camera/CameraController-class.html) to only use `nv21` for Android and `bgra8888` for iOS.

```dart
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

final camera; // your camera instance
final controller = CameraController(
  camera,
  ResolutionPreset.max,
  enableAudio: false,
  imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // for Android
          : ImageFormatGroup.bgra8888, // for iOS
);

InputImage? _inputImageFromCameraImage(CameraImage image) {
  // get camera rotation
  final camera = cameras[_cameraIndex];
  final rotation =
  InputImageRotationValue.fromRawValue(camera.sensorOrientation);
  if (rotation == null) return null;

  // get image format
  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  // validate format depending on platform
  // only supported formats:
  // * nv21 for Android
  // * bgra8888 for iOS
  if (format == null ||
          (Platform.isAndroid && format != InputImageFormat.nv21) ||
          (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

  // since format is constraint to nv21 or bgra8888, both only have one plane
  if (image.planes.length != 1) return null;
  final plane = image.planes.first;

  // compose InputImage using bytes
  return InputImage.fromBytes(
    bytes: plane.bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation, // used only in Android
      format: format, // used only in iOS
      bytesPerRow: plane.bytesPerRow, // used only in iOS
    ),
  );
}

CameraImage image; // your image from camera/controller image stream
final inputImage = _inputImageFromCameraImage(image);
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
