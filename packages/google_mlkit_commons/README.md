# Google's ML Kit Commons for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_commons)](https://pub.dev/packages/google_mlkit_commons)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on GitHub](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin with common methods used in [google_ml_kit](https://github.com/flutter-ml/google_ml_kit_flutter).

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

All ML Kit iOS plugins use **Swift Package Manager (SwiftPM)** via [`d-date/google-mlkit-swiftpm`](https://github.com/d-date/google-mlkit-swiftpm) (`9.0.2`), which also supports Apple Silicon iOS Simulators out of the box.

1. **Linker Flags**: In Xcode, go to **Runner > Build Settings > Linking - General > Other Linker Flags** (`OTHER_LDFLAGS`) and add:
   - `-ObjC`
   - `-all_load`

2. **ML Kit Resource Bundles**: SwiftPM cannot bundle model files inside `.binaryTarget` frameworks into the main app bundle automatically. Download the required `.bundle` archives for the ML Kit plugins you use from the [`d-date/google-mlkit-swiftpm` v9.0.2 release](https://github.com/d-date/google-mlkit-swiftpm/releases/tag/9.0.2) and add them to your Xcode `Runner` target (**Build Phases > Copy Bundle Resources**). See [`packages/example/ios/download_mlkit_bundles.sh`](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/ios/download_mlkit_bundles.sh) for a ready-to-use download script.

### Android

- minSdkVersion: 21
- targetSdkVersion: 36
- compileSdkVersion: 36

**⚠️ Production Disclaimer:** Using this plugin in production is the responsibility of the developers consuming the plugin, not the authors. The authors provide this plugin as-is and are not responsible for any issues, failures, or compatibility problems that may arise from using this plugin in production environments.

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

From bitmap data:

```dart
final ui.Image image = await recorder.endRecording().toImage(width, height);
final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
final InputImage inputImage = InputImage.fromBitmap(
  bitmap: byteData!.buffer.asUint8List(),
  width: width,
  height: height,
  rotation: 0, // optional, defaults to 0, only used on Android
);
```

If you are using the [Camera plugin](https://pub.dev/packages/camera) make sure to configure your [CameraController](https://pub.dev/documentation/camera/latest/camera/CameraController-class.html) to only use `ImageFormatGroup.nv21` for Android and `ImageFormatGroup.bgra8888` for iOS.

> **Consuming image streams on Android:** Until [flutter/flutter#145961](https://github.com/flutter/flutter/issues/145961) is resolved, the default CameraX implementation in `camera` does not support `nv21` image streaming. To use camera image streams on Android, configure [`camera_android`](https://pub.dev/packages/camera_android) in your app.

Notice that the image rotation is computed in a different way for both iOS and Android. Image rotation is used in Android to convert the `InputImage` [from Dart to Kotlin](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/kotlin/com/google_mlkit_commons/InputImageConverter.kt), but it is not used in iOS to convert [from Dart to Swift](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/google_mlkit_commons/Sources/google_mlkit_commons/MLKVisionImage%2BFlutterPlugin.swift). However, image rotation and `camera.lensDirection` can be used in both platforms to [compensate x and y coordinates on a canvas](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart).

```dart
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter/services.dart';

final CameraDescription camera; // your camera instance
final controller = CameraController(
  camera,
  // Do NOT set it to ResolutionPreset.max because for some phones it does NOT work.
  ResolutionPreset.high,
  enableAudio: false,
  imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // for Android
          : ImageFormatGroup.bgra8888, // for iOS
);

final _orientations = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

InputImage? _inputImageFromCameraImage(CameraImage image) {
  // get image rotation
  // it is used in android to convert the InputImage from Dart to Kotlin
  // `rotation` is not used in iOS to convert the InputImage from Dart to Swift
  // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
  final sensorOrientation = camera.sensorOrientation;
  InputImageRotation? rotation;
  if (Platform.isIOS) {
    rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  } else if (Platform.isAndroid) {
    var rotationCompensation =
        _orientations[controller.value.deviceOrientation];
    if (rotationCompensation == null) return null;
    if (camera.lensDirection == CameraLensDirection.front) {
      // front-facing
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      // back-facing
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
    }
    rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
  }
  if (rotation == null) return null;

  // get image format
  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  // validate format depending on platform
  // supported formats:
  // * nv21, yv12, or yuv_420_888 for Android (note: 3-plane yuv_420_888/yv12 camera frames must be converted to single-buffer nv21; see camera_view.dart in the example app)
  // * bgra8888 (or yuv420) for iOS
  if (format == null ||
          (Platform.isAndroid && format != InputImageFormat.nv21) ||
          (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

  // since format is constrained to nv21 or bgra8888, both only have one plane
  if (image.planes.length != 1) return null;
  final plane = image.planes.first;

  // compose InputImage using bytes
  return InputImage.fromBytes(
    bytes: plane.bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation, // used only in Android
      format: format, // used in Android and iOS
      bytesPerRow: plane.bytesPerRow, // used only in iOS
    ),
  );
}

CameraImage image; // your image from camera/controller image stream
final inputImage = _inputImageFromCameraImage(image);
```

### Managing remote models (`ModelManager`)

Plugins that use downloadable remote models (`google_mlkit_digital_ink_recognition`, `google_mlkit_entity_extraction`, `google_mlkit_image_labeling`, `google_mlkit_object_detection`, and `google_mlkit_translation`) provide a model manager class that extends `ModelManager`:

```dart
// Check if a model is downloaded
final bool isDownloaded = await modelManager.isModelDownloaded(model);

// Download a model (set `isWifiRequired: false` to allow downloading over cellular on Android)
final bool isDownloaded = await modelManager.downloadModel(
  model,
  isWifiRequired: true, // optional, defaults to true (enforced on Android only)
);

// Delete a downloaded model
final bool isDeleted = await modelManager.deleteModel(model);
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non-trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
