# Google Ml kit Plugin

[![Pub Version](https://img.shields.io/pub/v/google_ml_kit)](https://pub.dev/packages/google_ml_kit)

Flutter plugin to use [google's standalone ml kit](https://developers.google.com/ml-kit) for Android .

<img src="https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/screenshots/pose.png?raw=true" height=500 >   <img src="https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/screenshots/imagelabeling.png?raw=true" height=500> <img src="https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/screenshots/giff.gif" height=500><img src="https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/screenshots/barcode.png?raw=true" height=500>  <img src="https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/screenshots/text_detector.jpg?raw=true" height=500>

### Note
From version 0.2 the way to create instance of detectors has been changed.
Creating instance before version 0.2
```
final exampleDetector = GoogleMlKit.ExampleDetector
```
After 2.0
```
final exampleDetector = GoogleMlKit.vision.ExampleDetector
//Or 
final exampleDetector = GoogleMlKit.nlp.ExampleDetector
```
## Currently supported api's
### Vision
* [Pose Detection](https://developers.google.com/ml-kit/vision/pose-detection)
* [Digital Ink Recognition](https://developers.google.com/ml-kit/vision/digital-ink-recognition)
* [Image Labelling](https://developers.google.com/ml-kit/vision/image-labeling)
* [Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning)
* [Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition)

### NLP
* [Language Detection](https://developers.google.com/ml-kit/language/identification)
 

 ##### Please note - Currently image processing is working only with image files and not camera stream data (`fromBytes()`). Hope to fix this soon.

## Usage
Add this plugin as dependency in your pubspec.yaml.

- In your project-level build.gradle file, make sure to include Google's Maven repository in both your buildscript and allprojects sections(for all api's).
- The plugin has been written using bundled api models, this implies models will be bundled along with plugin and there is no need to implement any dependencies on your part and should work out of the box.
- If you wish to  reduce the apk size you may replace bundled model dependencies with model's provided within Google Play Service, to know more about this see the below links
  1. [Image Labeling](https://developers.google.com/ml-kit/vision/image-labeling/android)
  2. [Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning/android)

## Procedure to use vision api's
1. #### First Create an InputImage

Prepare Input Image(image you want to process)
```
import 'package:google_ml_kit/google_ml_kit.dart';

final inputImage = InputImage.fromFilePath(filePath);

// Or you can prepare image form
//final inputImage = InputImage.fromFile(file);

```
 
To know more about [formats of image](https://developer.android.com/reference/android/graphics/ImageFormat.html#NV21).

2. #### Create an instance of detector
```
final barcodeScanner = GoogleMlKit.vision.barcodeScanner();
final digitalInkRecogniser = GoogleMlKit.vision.digitalInkRecogniser();
```
3. #### Call `processImage()` or relevant function of the respective detector
4. #### Call `close()`

#### [An  example covering all the api's usage](example/lib)

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
Use the map to extract data. See this [example](example/lib/VisionDetectorViews/pose_detector_view.dart) to get better idea.

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

**To know more see this [example](example/lib/VisionDetectorViews/label_detector_view.dart)**

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
To know more see this [example](example/lib/VisionDetectorViews/barcode_scanner_view.dart)


## Text Recognition
**Calling `processImage()`** returns [RecognisedText]() object
```
final text = await textDetector.processImage(inputImage);
```

**To know more see this [example](example/lib/VisionDetectorViews/text_detector_view.dart)**

## Language Detection
1. Call `identifyLanguage(text)` to identify language of text.
2. Call `identifyPossibleLanguages(text)` to get a list of [IdentifiedLanguage](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/8b133accc450b69d63febb37499de79069bb55f1/lib/src/nlp/LanguageIdentifier.dart#L53) which contains all possible languages that are above the specified threshold. **Default is 0.5**.
3. To get info of the identified **BCP-47** tag use this [class](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/8b133accc450b69d63febb37499de79069bb55f1/lib/src/nlp/LanguageIdentifier.dart#L63).


## Contributing
Contributions are welcome.
In case of any problems open an issue.
Create a issue before opening a pull request for non trivial fixes.
In case of trivial fixes open a pull request directly.
## License
[MIT](https://choosealicense.com/licenses/mit/)

