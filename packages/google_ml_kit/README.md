# Google's ML Kit Flutter Plugin

[![Pub Version](https://img.shields.io/pub/v/google_ml_kit)](https://pub.dev/packages/google_ml_kit)

A Flutter plugin to use [Google's standalone ML Kit](https://developers.google.com/ml-kit) for Android and iOS.

## Features

### Vision

| Feature                                                                                       | Android | iOS |
|-----------------------------------------------------------------------------------------------|---------|-----|
|[Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition)               | ✅      | ✅  |
|[Face Detection](https://developers.google.com/ml-kit/vision/face-detection)                   | ✅      | ✅  |
|[Pose Detection](https://developers.google.com/ml-kit/vision/pose-detection)                   | ✅      | ✅  |
|[Selfie Segmentation](https://developers.google.com/ml-kit/vision/selfie-segmentation)         | yet     | yet |
|[Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning)               | ✅      | ✅  |
|[Image Labelling](https://developers.google.com/ml-kit/vision/image-labeling)                  | ✅      | ✅  |
|[Object Detection and Tracking](https://developers.google.com/ml-kit/vision/object-detection)  | ✅      | yet |
|[Digital Ink Recognition](https://developers.google.com/ml-kit/vision/digital-ink-recognition) | ✅      | ✅  |
|[Text Detector V2](https://developers.google.com/ml-kit/vision/text-recognition/v2)            | ✅      | yet |
|[Text Recognition V2](https://developers.google.com/ml-kit/vision/text-recognition/v2)         | ✅      | yet |

### Natural Language

| Feature                                                                                       | Android | iOS |
|-----------------------------------------------------------------------------------------------|---------|-----|
|[Language Identification](https://developers.google.com/ml-kit/language/identification)        | ✅      | ✅  |
|[On-Device Translation](https://developers.google.com/ml-kit/language/translation)             | ✅      | yet |
|[Smart Reply](https://developers.google.com/ml-kit/language/smart-reply)                       | ✅      | yet |
|[Entity Extraction](https://developers.google.com/ml-kit/language/entity-extraction)           | ✅      | yet |

## Requirements

### iOS

- Minimum iOS Deployment Target: 10.0
- Xcode 12 or newer
- Swift 5
- ML Kit only supports 64-bit architectures (x86_64 and arm64). Check this [list](https://developer.apple.com/support/required-device-capabilities/) to see if your device has the required device capabilities.

Since ML Kit does not support 32-bit architectures (i386 and armv7) ([Read mode](https://developers.google.com/ml-kit/migration/ios)), you need to exclude amrv7 architectures in Xcode in order to run `flutter build ios` or `flutter build ipa`.

Go to Project > Runner > Building Settings > Excluded Architectures > Any SDK > armv7

![](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/ima/build_settings_01.png)

Then your Podfile should look like this:

```
# add this line:
$iOSVersion = '10.0'

post_install do |installer|
  # add these lines:
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=*]"] = "armv7"
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iOSVersion
  end
  
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # add these lines:
    target.build_configurations.each do |config|
      if Gem::Version.new($iOSVersion) > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iOSVersion
      end
    end
    
  end
end
```

Notice that the minimum `IPHONEOS_DEPLOYMENT_TARGET` is 10.0, you can set it to something newer but not older.

### Android

- minSdkVersion: 21
- targetSdkVersion: 29

## Usage

Add this plugin as dependency in your pubspec.yaml.

- In your project-level build.gradle file, make sure to include Google's Maven repository in both your buildscript and allprojects sections(for all api's).
- All API's except `Image Labeling`, `Face Detection` and `Barcode Scanning` use bundled models, hence others should work out of the box.
- For API's using unbundled models, configure your application to download the model to your device automatically from play store by adding the following to your app's `AndroidManifest.xml`, if not configured the respective models will be downloaded when the API's are invoked for the first time. 

  ```xml
  <meta-data
          android:name="com.google.mlkit.vision.DEPENDENCIES"
          android:value="ica" />
      <!-- To use multiple models: android:value="ica,model2,model3" -->
  ```
  
  Use these options:
  
  - **ica** - `Image Labeling`
  - **ocr** - `Barcode Scanning`
  - **face** -`Face Detection`

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
// vision
final barcodeScanner = GoogleMlKit.vision.barcodeScanner();
final digitalInkRecogniser = GoogleMlKit.vision.digitalInkRecogniser();
final faceDetector = GoogleMlKit.vision.faceDetector();
final imageLabeler = GoogleMlKit.vision.imageLabeler();
final poseDetector = GoogleMlKit.vision.poseDetector();
final textDetector = GoogleMlKit.vision.textDetector();
final objectDetector = GoogleMlKit.vision.objectDetector(CustomObjectDetectorOptions or ObjectDetectorOptions);

// nl
final entityExtractor = GoogleMlKit.nlp.entityExtractor();
final languageIdentifier = GoogleMlKit.nlp.languageIdentifier();
final onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator();
final smartReply = GoogleMlKit.nlp.smartReply();

// managing models
final translateLanguageModelManager = GoogleMlKit.nlp.translateLanguageModelManager();
final entityModelManager = GoogleMlKit.nlp.entityModelManager();
final remoteModelManager = GoogleMlKit.vision.remoteModelManager();
```

#### 3. Call the corresponding method

```dart
// vision
final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
final List<RecognitionCandidate> canditates = await digitalInkRecogniser.readText(points, languageTag);
final List<Face> faces = await faceDetector.processImage(inputImage);
final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
final List<Pose> poses = await poseDetector.processImage(inputImage);
final RecognisedText recognisedText = await textDetector.processImage(inputImage);
final List<DetectedObject> objects = await objectDetector.processImage(inputImage);

// nl
final List<EntityAnnotation> entities = await entityExtractor.extractEntities(text, filters, locale, timezone);
final bool response = await entityModelManager.downloadModel(modelTag);
final String response = await entityModelManager.isModelDownloaded(modelTag);
final String response = await entityModelManager.deleteModel(modelTag);
final List<String> availableModels = await entityModelManager.getAvailableModels();
try {
  final String response = await languageIdentifier.identifyLanguage(text);
} on PlatformException catch (pe) {
  if (pe.code == languageIdentifier.errorCodeNoLanguageIdentified) {
    // no language detected
  }
  // other plugin error
}
try {
  final List<IdentifiedLanguage> response = await languageIdentifier.identifyPossibleLanguages(text);
} on PlatformException catch (pe) {
  if (pe.code == languageIdentifier.errorCodeNoLanguageIdentified) {
    // no language detected
  }
  // other plugin error
}
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
  final Rect boundingBox = barcode.value.boundingBox;
  final String displayValue = barcode.value.displayValue;
  final String rawValue = barcode.value.rawValue;

  // See API reference for complete list of supported types
  switch (type) {
    case BarcodeType.wifi:
      BarcodeWifi barcodeWifi = barcode.value;
      break;
    case BarcodeValueType.url:
      BarcodeUrl barcodeUrl = barcode.value;
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

e. Pose detection

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

f. Digital Ink Recognition

```dart
for (final candidate in candidates) {
  final text = candidate.text;
  final score = candidate.score;
}
```

g. Extract Suggestions

```dart
//status implications
//1 = Language Not Supported
//2 = Can't determine a reply
//3 = Successfully generated 1-3 replies
int status = result['status'];

List<SmartReplySuggestion> suggestions = result['suggestions'];
```

h. Extract Objects

```dart
for(DetectedObject detectedObject in _objects){
  final rect = detectedObject.getBoundinBox();
  final trackingId = detectedObject.getTrackingId();

  for(Label label in detectedObject.getLabels()){
    print('${label.getText()} ${label.getConfidence()}');
  }
}
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
objectDetector.close();

// nl
entityExtractor.close();
languageIdentifier.close();
onDeviceTranslator.close();
smartReply.close();
```

#### Example app

Look at this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/example) to see the plugin in action.

## Migrating from ML Kit for Firebase

When Migrating from ML Kit for Firebase read [this guide](https://developers.google.com/ml-kit/migration). For Android details read [this](https://developers.google.com/ml-kit/migration/android). For iOS details read [this](https://developers.google.com/ml-kit/migration/ios).

## Known issues

### Android

To reduce the apk size read more about it in issue [#26](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues/26). Also look at [this](https://developers.google.com/ml-kit/tips/reduce-app-size).

### iOS

If you are using this plugin in your app and any other plugin that requires Firebase, there is a known issues you will encounter a dependency error when running `pod install`. To read more about it go to issue [#27](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues/27).

## Contributing

Contributions are welcome.
In case of any problems open an issue.
Create a issue before opening a pull request for non trivial fixes.
In case of trivial fixes open a pull request directly.

## License

[MIT](https://choosealicense.com/licenses/mit/)
