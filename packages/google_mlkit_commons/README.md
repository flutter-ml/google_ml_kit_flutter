# google\_mlkit\_commons

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_commons)](https://pub.dev/packages/google_mlkit_commons)
[![analysis](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions/workflows/flutter.yml/badge.svg)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions)
[![Star on Github](https://img.shields.io/github/stars/bharat-biradar/Google-Ml-Kit-plugin.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin with common methods used in [google\_ml\_kit](https://github.com/bharat-biradar/Google-Ml-Kit-plugin).

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

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
final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
```

From [CameraImage](https://pub.dev/documentation/camera/latest/camera/CameraImage-class.html) (if you are using the [Camera plugin](https://pub.dev/packages/camera)):

```dart
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

final camera; // your camera instance

final WriteBuffer allBytes = WriteBuffer();
for (final Plane plane in cameraImage.planes) {
  allBytes.putUint8List(plane.bytes);
}
final bytes = allBytes.done().buffer.asUint8List();

final Size imageSize = Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

final InputImageRotation imageRotation =
    InputImageRotationValue.fromRawValue(camera.sensorOrientation);

final InputImageFormat inputImageFormat =
    InputImageFormatValue.fromRawValue(cameraImage.format.raw);

final planeData = cameraImage.planes.map(
  (Plane plane) {
    return InputImagePlaneMetadata(
      bytesPerRow: plane.bytesPerRow,
      height: plane.height,
      width: plane.width,
    );
  },
).toList();

final inputImageData = InputImageData(
  size: imageSize,
  imageRotation: imageRotation,
  inputImageFormat: inputImageFormat,
  planeData: planeData,
);

final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
```

## Example app

Find the example app [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
