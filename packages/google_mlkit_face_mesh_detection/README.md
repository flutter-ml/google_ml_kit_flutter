# Google's ML Kit Face Mesh Detection for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_face_mesh_detection)](https://pub.dev/packages/google_mlkit_face_mesh_detection)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

> **_NOTE: This feature is still in Beta, and it is only available for Android. Stay tune for updates in [Google's website](https://developers.google.com/ml-kit/vision/face-mesh-detection) and request the feature [here](https://github.com/googlesamples/mlkit/issues)._**

A Flutter plugin to use [Google's ML Kit Face Mesh Detection](https://developers.google.com/ml-kit/vision/face-mesh-detection) for face mesh detection, you can generate in real-time a high accuracy [face mesh](https://developers.google.com/ml-kit/vision/face-mesh-detection/concepts) of 468 3D points for selfie-like images.

Faces should be within ~2 meters (~7 feet) of the camera, so that the faces are sufficiently large for optimal face mesh recognition. In general, the larger the face, the better the face mesh recognition.

If you want to detect faces further than ~2 meters (~7 feet) away from the camera, please see [google_mlkit_face_detection](https://pub.dev/packages/google_mlkit_face_detection).

Note that the face should be facing the camera with at least half of the face visible. Any large object between the face and the camera may result in lower accuracy.

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/flutter-ml/google_ml_kit_flutter/issues):

- [Google's ML Kit](https://developers.google.com/ml-kit) was build only for mobile platforms: iOS and Android apps. Web or any other platform is not supported, you can request support for those platform to Google in [their repo](https://github.com/googlesamples/mlkit/issues).

- This plugin is not sponsored or maintained by Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) are developers excited about Machine Learning that wanted to expose Google's native APIs to Flutter.

- Google's ML Kit APIs are only developed natively for iOS and Android. This plugin uses Flutter Platform Channels as explained [here](https://docs.flutter.dev/development/platform-integration/platform-channels).

  Messages are passed between the client (the app/plugin) and host (platform) using platform channels as illustrated in this diagram:

  <p align="center" width="100%">
    <img src="https://docs.flutter.dev/assets/images/docs/PlatformChannels.png"> 
  </p>

  Messages and responses are passed asynchronously, to ensure the user interface remains responsive. To read more about platform channels go [here](https://docs.flutter.dev/development/platform-integration/platform-channels).

  Because this plugin uses platform channels, no Machine Learning processing is done in Flutter/Dart, all the calls are passed to the native platform using `MethodChannel` in Android and `FlutterMethodChannel` in iOS, and executed using Google's native APIs. Think of this plugin as a bridge between your app and Google's native ML Kit APIs. This plugin only passes the call to the native API and the processing is done by Google's API. It is important that you understand this concept when it comes to debugging errors for your ML model and/or app.

- Since the plugin uses platform channels, you may encounter issues with the native API. Before submitting a new issue, identify the source of the issue. You can run both iOS and/or Android native [example apps by Google](https://github.com/googlesamples/mlkit) and make sure that the issue is not reproducible with their native examples. If you can reproduce the issue in their apps then report the issue to Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) do not have access to the source code of their native APIs, so you need to report the issue to them. If you find that their example apps are okay and still you have an issue using this plugin, then look at our [closed and open issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues). If you cannot find anything that can help you then report the issue and provide enough details. Be patient, someone from the community will eventually help you.

## Requirements

### iOS

This feature is still in Beta, and it is only available for Android. Stay tune for updates in [Google's website](https://developers.google.com/ml-kit/vision/face-mesh-detection) and request the feature [here](https://github.com/googlesamples/mlkit/issues).

### Android

- minSdkVersion: 21
- targetSdkVersion: 35
- compileSdkVersion: 35

## Usage

### Face Mesh Detection

#### Create an instance of `InputImage`

Create an instance of `InputImage` as explained [here](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons#creating-an-inputimage).

```dart
final InputImage inputImage;
```

#### Create an instance of `FaceMeshDetector`

```dart
final meshDetector = FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);
```

#### Process image

```dart
final List<FaceMesh> meshes = await meshDetector.processImage(inputImage);

for (FaceMesh mesh in meshes) {
  final boundingBox = mesh.boundingBox;
  final points = mesh.points;
  final triangles = mesh.triangles;
  final contour = mesh.contours[FaceMeshContourType.faceOval];
}
```

#### Release resources with `close()`

```dart
meshDetector.close();
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
