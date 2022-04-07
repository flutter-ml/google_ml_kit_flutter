# Google's ML Kit Pose Detection for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_ml_kit)](https://pub.dev/packages/google_ml_kit)

A Flutter plugin to use [Google's ML Kit Pose Detection](https://developers.google.com/ml-kit/vision/pose-detection).

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin).

## Usage

#### 1. Create an InputImage

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
final camera; // your camera instance
final WriteBuffer allBytes = WriteBuffer();
for (Plane plane in cameraImage.planes) {
  allBytes.putUint8List(plane.bytes);
}
final bytes = allBytes.done().buffer.asUint8List();

final Size imageSize = Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

final InputImageRotation imageRotation =
    InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
        InputImageRotation.Rotation_0deg;

final InputImageFormat inputImageFormat =
    InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
        InputImageFormat.NV21;

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

#### 2. Create an instance of detector

```dart
final poseDetector = PoseDetector();
```

#### 3. Process image

```dart
final List<Pose> poses = await poseDetector.processImage(inputImage);
```

#### 4. Extract data from response

```dart
for (Pose pose in poses) {
  // to access all landmarks
  pose.landmarks.forEach((_, landmark) {
    final type = landmark.type;
    final x = landmark.x;
    final y = landmark.y;
  }
  
  // to access specific landmarks
  final landmark = pose.landmarks[PoseLandmarkType.nose];
}
```

#### 5. Release resources with `close()`

```dart
poseDetector.close();
```

## Example app

Look at this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit/example) to see the plugin in action.

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
