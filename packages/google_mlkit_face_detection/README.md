# Google's ML Kit Face Detection for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_face_detection)](https://pub.dev/packages/google_mlkit_face_detection)
[![analysis](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions/workflows/flutter.yml/badge.svg)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions)
[![Star on Github](https://img.shields.io/github/stars/bharat-biradar/Google-Ml-Kit-plugin.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit Face Detection](https://developers.google.com/ml-kit/vision/face-detection) to detect faces in an image, identify key facial features, and get the contours of detected faces.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

## Usage

### Face Detection

#### Create an instance of `InputImage`

Create an instance of `InputImage` as explained [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_commons#creating-an-inputimage).

```dart
final InputImage inputImage;
```

#### Create an instance of `FaceDetector`

```dart
final options = FaceDetectorOptions();
final faceDetector = FaceDetector(options: options);
```

#### Process image

```dart
final List<Face> faces = await faceDetector.processImage(inputImage);

for (Face face in faces) {
  final Rect boundingBox = face.boundingBox;

  final double? rotX = face.headEulerAngleX; // Head is tilted up and down rotX degrees
  final double? rotY = face.headEulerAngleY; // Head is rotated to the right rotY degrees
  final double? rotZ = face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

  // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
  // eyes, cheeks, and nose available):
  final FaceLandmark? leftEar = face.landmarks[FaceLandmarkType.leftEar];
  if (leftEar != null) {
    final Point<int> leftEarPos = leftEar.position;
  }

  // If classification was enabled with FaceDetectorOptions:
  if (face.smilingProbability != null) {
    final double? smileProb = face.smilingProbability;
  }

  // If face tracking was enabled with FaceDetectorOptions:
  if (face.trackingId != null) {
    final int? id = face.trackingId;
  }
}
```

#### Release resources with `close()`

```dart
faceDetector.close();
```

## Example app

Find the example app [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
