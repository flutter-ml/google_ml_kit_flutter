# Google's ML Kit Flutter Plugin

[![Pub Version](https://img.shields.io/pub/v/google_ml_kit)](https://pub.dev/packages/google_ml_kit)

A Flutter plugin to use [Google's standalone ML Kit](https://developers.google.com/ml-kit) for Android and iOS.

## Features

### Vision

| Feature                                                                                       | Android | iOS |
|-----------------------------------------------------------------------------------------------|---------|-----|
|[Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition)               | ✅      | ✅  |
|[Face Detection](https://developers.google.com/ml-kit/vision/face-detection)                   | ✅      | ✅  |
|[Pose Detection](https://developers.google.com/ml-kit/vision/pose-detection)                   | ✅      | yet |
|[Selfie Segmentation](https://developers.google.com/ml-kit/vision/selfie-segmentation)         | yet     | yet |
|[Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning)               | ✅      | ✅  |
|[Image Labelling](https://developers.google.com/ml-kit/vision/image-labeling)                  | ✅      | ✅  |
|[Object Detection and Tracking](https://developers.google.com/ml-kit/vision/object-detection)  | yet     | yet |
|[Digital Ink Recognition](https://developers.google.com/ml-kit/vision/digital-ink-recognition) | ✅      | yet |

### Natural Language

| Feature                                                                                       | Android | iOS |
|-----------------------------------------------------------------------------------------------|---------|-----|
|[Language Identification](https://developers.google.com/ml-kit/language/identification)        | ✅      | yet |
|[On-Device Translation](https://developers.google.com/ml-kit/language/translation)             | ✅      | yet |
|[Smart Reply](https://developers.google.com/ml-kit/language/smart-reply)                       | ✅     | yet |
|[Entity Extraction](https://developers.google.com/ml-kit/language/entity-extraction)           | ✅      | yet |

## Requirements

iOS:

- Minimum iOS Deployment Target: 12.0
- Xcode 12 or newer
- Swift 5

Android:

- minSdkVersion: 21
- targetSdkVersion: 29

## Usage

Add this plugin as dependency in your pubspec.yaml.

- In your project-level build.gradle file, make sure to include Google's Maven repository in both your buildscript and allprojects sections(for all api's).
- The plugin has been written using bundled api models, this implies models will be bundled along with plugin and there is no need to implement any dependencies on your part and should work out of the box.

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

From CameraImage (if you are using the camera plugin):

```dart
final camera; // your camera instance
final WriteBuffer allBytes = WriteBuffer();
for (Plane plane in cameraImage.planes) {
  allBytes.putUint8List(plane.bytes);
}
final bytes = allBytes.done().buffer.asUint8List();

final Size imageSize = Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

InputImageRotation imageRotation = InputImageRotation.Rotation_0deg;
switch (camera.sensorOrientation) {
  case 0:
    imageRotation = InputImageRotation.Rotation_0deg;
    break;
  case 90:
    imageRotation = InputImageRotation.Rotation_90deg;
    break;
  case 180:
    imageRotation = InputImageRotation.Rotation_180deg;
    break;
  case 270:
    imageRotation = InputImageRotation.Rotation_270deg;
    break;
}

final inputImageData = InputImageData(
  size: imageSize,
  imageRotation: imageRotation,
);

final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
```

#### 2. Create an instance of detector

```dart
// vision
final barcodeScanner = GoogleMlKit.vision.barcodeScanner();
final digitalInkRecogniser = GoogleMlKit.vision.digitalInkRecogniser();
final faceDetector = GoogleMlKit.vision.faceDetector();
final imageLabeler = GoogleMlKit.vision.imageLabeler();
final poseDetector = GoogleMlKit.vision.poseDetector();
final textDetector = GoogleMlKit.vision.textDetector();

// nl
final entityExtractor = GoogleMlKit.nlp.entityExtractor();
final entityModelManager = GoogleMlKit.nlp.entityModelManager();
final languageIdentifier = GoogleMlKit.nlp.languageIdentifier();
final onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator();
final translateLanguageModelManager = GoogleMlKit.nlp.translateLanguageModelManager();
final smartReply = GoogleMlKit.nlp.smartReply();
```

#### 3. Call the corresponding method

```dart
// vision
final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
final String text = await digitalInkRecogniser.readText(point, modelTag);
final List<Face> faces = await faceDetector.processImage(inputImage);
final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
final Map<int, PoseLandmark> poseLandmarks = await poseDetector.processImage(inputImage);
final RecognisedText recognisedText = await textDetector.processImage(inputImage);

// nl
final List<EntityAnnotation> entities = await entityExtractor.extractEntities(text, filters, locale, timezone);
final bool response = await entityModelManager.downloadModel(modelTag);
final String response = await entityModelManager.isModelDownloaded(modelTag);
final String response = await entityModelManager.deleteModel(modelTag);
final List<String> availableModels = await entityModelManager.getAvailableModels();
final String response = await languageIdentifier.identifyLanguage(text);
final List<IdentifiedLanguage> response = await languageIdentifier.identifyPossibleLanguages(text);
final String response = await onDeviceTranslator.translateText(text);
final bool response = await translateLanguageModelManager.downloadModel(modelTag);
final String response = await translateLanguageModelManager.isModelDownloaded(modelTag);
final String response = await translateLanguageModelManager.deleteModel(modelTag);
final List<String> availableModels = await translateLanguageModelManager.getAvailableModels();
final List<SmartReplySuggestion> suggestions = await smartReply.suggestReplies();
// add conversations for suggestions
smartReply.addConversationForLocalUser(text);
smartReply.addConversationForRemoteUser(text, userID);
```

#### 4. Extract data from response.

a. Extract barcodes.

```dart
for (Barcode barcode in barcodes) {
  final BarcodeType type = barcode.type;
  final Rect boundingBox = barcode.info.boundingBox;
  final String displayValue = barcode.info.displayValue;
  final String rawValue = barcode.info.rawValue;

  // See API reference for complete list of supported types
  switch (type) {
    case BarcodeType.TYPE_WIFI:
      BarcodeWifi barcodeWifi = barcode.info;
      break;
    case BarcodeValueType.TYPE_URL:
      BarcodeUrl barcodeUrl = barcode.info;
      break;
  }
}
```

b. Extract faces.

```dart
for (Face face in faces) {
  final Rect boundingBox = face.boundingBox;

  final double rotY = face.headEulerAngleY; // Head is rotated to the right rotY degrees
  final double rotZ = face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

  // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
  // eyes, cheeks, and nose available):
  final FaceLandmark leftEar = face.getLandmark(FaceLandmarkType.leftEar);
  if (leftEar != null) {
    final Point<double> leftEarPos = leftEar.position;
  }

  // If classification was enabled with FaceDetectorOptions:
  if (face.smilingProbability != null) {
    final double smileProb = face.smilingProbability;
  }

  // If face tracking was enabled with FaceDetectorOptions:
  if (face.trackingId != null) {
    final int id = face.trackingId;
  }
}
```

c. Extract labels.

```dart
for (ImageLabel label in labels) {
  final String text = label.text;
  final int index = label.index;
  final double confidence = label.confidence;
}
```

d. Extract text.

```dart
String text = recognisedText.text;
for (TextBlock block in recognisedText.blocks) {
  final Rect rect = block.rect;
  final List<Offset> cornerPoints = block.cornerPoints;
  final String text = block.text;
  final List<String> languages = block.recognizedLanguages;

  for (TextLine line in block.lines) {
    // Same getters as TextBlock
    for (TextElement element in line.elements) {
      // Same getters as TextBlock
    }
  }
}
```
e. Extract Suggestions

```dart
//status implications
//1 = Language Not Supported
//2 = Can't determine a reply
//3 = Successfully generated 1-3 replies
int status = result['status'];

List<SmartReplySuggestion> suggestions = result['suggestions'];
```

#### 5. Release resources with `close()`.

```dart
// vision
barcodeScanner.close();
digitalInkRecogniser.close();
faceDetector.close();
imageLabeler.close();
poseDetector.close();
textDetector.close();

// nl
entityExtractor.close();
languageIdentifier.close();
onDeviceTranslator.close();
smartReply.close();
```
Look at this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/example) for better understanding.
## Known issues

### Android

To reduce the apk size read more about it in issue [#26](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues/26).

### iOS

If you are using this plugin in your app and any other plugin that requieres Firebase, there is a known issues you will encounter a dependency error when running `pod install`. To read more about it go to issue [#27](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues/27).

## Contributing

Contributions are welcome.
In case of any problems open an issue.
Create a issue before opening a pull request for non trivial fixes.
In case of trivial fixes open a pull request directly.

## License

[MIT](https://choosealicense.com/licenses/mit/)
