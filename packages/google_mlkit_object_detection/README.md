# Google's ML Kit Object Detection and Tracking for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_object_detection)](https://pub.dev/packages/google_mlkit_object_detection)

A Flutter plugin to use [Google's ML Kit Object Detection and Tracking](https://developers.google.com/ml-kit/vision/object-detection).

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin).

### Firebase dependency

[Object Detection and Tracking](https://developers.google.com/ml-kit/vision/object-detection) could be used with both Base Models and [Custom Models](https://developers.google.com/ml-kit/custom-models). Base models are bundled with the app. Custom Models are downloaded from [Firebase](https://firebase.google.com/). Since both model options are handled in this plugin, that requires you to add Firebase to your project even if you are only using the Base Models. To add Firebase to your project follow these steps:

- [Android](https://firebase.google.com/docs/android/setup)
- [iOS](https://firebase.google.com/docs/ios/setup)

## Usage

#### Create an InputImage

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

#### Create an instance of detector

```dart
final objectDetector = ObjectDetector(options: CustomObjectDetectorOptions or ObjectDetectorOptions)
```

#### Process image

```dart
final List<DetectedObject> objects = await objectDetector.processImage(inputImage);

for(DetectedObject detectedObject in _objects){
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
final String bool = await modelManager.deleteModel(model);
```

## Example app

Look at this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit/example) to see the plugin in action.

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
