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
|[Smart Reply](https://developers.google.com/ml-kit/language/smart-reply)                       | yet     | yet |
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
- If you wish to  reduce the apk size you may replace bundled model dependencies with model's provided within Google Play Service, to know more about this see the below links
  1. [Image Labeling](https://developers.google.com/ml-kit/vision/image-labeling/android)
  2. [Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning/android)

## Procedure to use vision api's

#### 1. First Create an InputImage

Prepare Input Image (image you want to process)

```
import 'package:google_ml_kit/google_ml_kit.dart';

// From path
final inputImage = InputImage.fromFilePath(filePath);

// From file
final inputImage = InputImage.fromFile(file);

// From CameraImage (if you are using the camera plugin)
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
 
To know more about [formats of image](https://developer.android.com/reference/android/graphics/ImageFormat.html).

#### 2. Create an instance of detector

```
final barcodeScanner = GoogleMlKit.vision.barcodeScanner();
final digitalInkRecogniser = GoogleMlKit.vision.digitalInkRecogniser();
```

#### 3. Call `processImage()` or relevant function of the respective detector

#### 4. Call `close()`

## Digital Ink recognition

**Read to know how to imlpement [Digital Ink Recognition](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/digital_ink_recogniser.md)**

## Pose Detection

- *Google Play service model is not available for this api' so no extra implementation**

- **Create [`PoseDetectorOptions`]()**

```
final options = PoseDetectorOptions(
        poseDetectionModel: PoseDetectionModel.BasePoseDetector,
        selectionType : LandmarkSelectionType.all,
        poseLandmarks:(list of poseaLndmarks you want); 
//or PoseDetectionModel.AccuratePoseDetector to use accurate pose detector
        
```

**Note**: To obtain default poseDetector no options need to be specied. It gives all available landmarks using BasePoseDetector Model.

**The same implies to other detectors as well**
- Calling `processImage(InputImage inputImage)` returns **Map<int,[PoseLandMark]()>**

```
final landMarksMap = await poseDetector.processImage(inputImage);
```
Use the map to extract data. See this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/example/lib/VisionDetectorViews/pose_detector_view.dart) to get better idea.

## Image Labeling

If you choose google service way. In your  **app level buil.gradle add.**

```
<application ...>
        ...
      <meta-data
          android:name="com.google.mlkit.vision.DEPENDENCIES"
          android:value="ica" />
      <!-- To use multiple models: android:value="ica,model2,model3" -->
      </application>
```
**The same implies for all other models as well**

**Create `ImageLabelerOptions`**. This uses [google's base model](https://developers.google.com/ml-kit/vision/image-labeling/label-map)
```
final options =ImageLabelerOptions( confidenceThreshold = confidenceThreshold);
// Default =0.5
//lies between 0.0 to 1.0
        
```
To use custom **tflite** models
```
CustomImageLabelerOptions options = CustomImageLabelerOptions(
        customModel: CustomTrainedModel.asset 
       (or CustomTrainedModel.file),// To use files stored in device
        customModelPath: "file path");
```
To use **autoMl vision models** models
```
final options = AutoMlImageLabelerOptions(
      customTrainedModel: CustomTrainedModel.asset 
       (or CustomTrainedModel.file), 
      customModelPath:);
```

**calling `processImage()`** returns List<[ImageLabel]()>
```
final labels = await imageLabeler.processImage(inputImage);
```

**To know more see this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/example/lib/VisionDetectorViews/label_detector_view.dart)**

## Barcode Scanner

**Obtain [`BarcodeScanner`]() instance.**
```
BarcodeScanner barcodeScanner = GoogleMlKit.instance
                                           .barcodeScanner(
                                           formats:(List of BarcodeFormats);

```
Supported [BarcodeFormats](https://developers.google.com/android/reference/com/google/mlkit/vision/barcode/Barcode.BarcodeFormat). To use a specific format use  

>Barcode.FORMAT_Default

>Barcode.FORMAT_Code_128

etc..

**call `processImage()`**
It returns List<[Barcode]()>
```
final result = await barcodeScanner.processImage(inputImage);
```

**To know more see this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/example/lib/VisionDetectorViews/barcode_scanner_view.dart)**

## Text Recognition

**Calling `processImage()`** returns [RecognisedText]() object
```
final text = await textDetector.processImage(inputImage);
```

**To know more see this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/example/lib/VisionDetectorViews/text_detector_view.dart)**

## Face Detection

**To know more see this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/example/lib/VisionDetectorViews/face_detector_view.dart)**

## Language Detection

1. Call `identifyLanguage(text)` to identify language of text.
2. Call `identifyPossibleLanguages(text)` to get a list of [IdentifiedLanguage](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/8b133accc450b69d63febb37499de79069bb55f1/lib/src/nlp/LanguageIdentifier.dart#L53) which contains all possible languages that are above the specified threshold. **Default is 0.5**.
3. To get info of the identified **BCP-47** tag use this [class](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/8b133accc450b69d63febb37499de79069bb55f1/lib/src/nlp/LanguageIdentifier.dart#L63).

**To know more see this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/example/lib/NlpDetectorViews/language_identifier_view.dart).**

### On-Device Translator
  1. Create `OnDeviceTranslator` object.
  ```
  final _onDeviceTranslator = GoogleMlKit.nlp
      .onDeviceTranslator(sourceLanguage: TranslateLanguage.ENGLISH, 
      targetLanguage: TranslateLanguage.SPANISH);
  ```
  2. Call `_onDeviceTranslator.translateText(text)` to translate text.
  >Note: Make sure the models are downloaded before calling translatetext()

#### Managing translate language models explicitly
1. Create `TranslateLanguageModelManager` instance.
```
final _languageModelManager = GoogleMlKit.nlp.translateLanguageModelManager();
```
2. Call `_languageModelManager.downloadModel(TranslateLanguage.ENGLISH)` to download a model.
3. Call `_languageModelManager.deleteModel(TranslateLanguage.ENGLISH)` to delete a model.
4.  Call `_languageModelManager.isModelDownloaded(TranslateLanguage.ENGLISH)` to to check whether a model is downloaded.
5. Call `_languageModelManager.getAvailableModels()` to get a list of all downloaded models.

**To know more see this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/example/lib/NlpDetectorViews/language_translator_view.dart).**

### Entity Extraction

1. Create `EntityExtractor` object.
```
final _entityExtractor = GoogleMlKit.nlp.entityExtractor(EntityExtractorOptions.ENGLISH,);
```
2. Call `_entityExtractor.extractEntities(text)` to obatin `List<EntityAnnotation>`.
3. Configuring custom parameters for extracting entities.
```
extractEntities(String text,
      {List<int>? filters, String? localeLangauge, String? timeZone});

// filters: [Entity.TYPE_ADDRESS,Entity.TYPE_DATE_TIME]
// locale: BCP-47 tag for the locale language
// timezone: String for timezone ex:- `America/Los_Angeles`
```
4. To gain infromation from individual entities refer to [orginal api](https://developers.google.com/android/reference/com/google/mlkit/nl/entityextraction/package-summary). Same methods are applied here as well.
5. Manage models same as `TranslateLanguageModelManager` does but use 
`EntityModelManager` instead.
*To know more see this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/example/lib/NlpDetectorViews/entity_extraction_view.dart).**

## Contributing

Contributions are welcome.
In case of any problems open an issue.
Create a issue before opening a pull request for non trivial fixes.
In case of trivial fixes open a pull request directly.

## License

[MIT](https://choosealicense.com/licenses/mit/)

