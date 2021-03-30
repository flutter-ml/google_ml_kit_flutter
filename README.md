# Google Ml kit Plugin

[![Pub Version](https://img.shields.io/pub/v/google_ml_kit)](https://pub.dev/packages/google_ml_kit)

Flutter plugin to use [google's standalone ml kit](https://developers.google.com/ml-kit) for Android .

<img src="https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/screenshots/pose.png?raw=true" height=500 >   <img src="https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/screenshots/imagelabeling.png?raw=true" height=500> <img src="https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/screenshots/giff.gif" height=500><img src="https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/screenshots/barcode.png?raw=true" height=500>  <img src="https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/screenshots/text_detector.jpg?raw=true" height=500>

## Currently supported api's
* [Pose Detection](https://developers.google.com/ml-kit/vision/pose-detection)
* [Digital Ink Recognition](https://developers.google.com/ml-kit/vision/digital-ink-recognition)
* [Image Labelling](https://developers.google.com/ml-kit/vision/image-labeling)
* [Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning)
* [Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition)
- Support for other api's will be shortly added
 
>Please note - Currently detection is working only with image files and not camera stream data. Hope to fix this soon.

## Usage
Add this plugin as dependency in your pubspec.yaml.

- In your project-level build.gradle file, make sure to include Google's Maven repository in both your buildscript and allprojects sections(for all api's).
- The plugin has been written using bundled api models, this implies models will be bundled along with plugin and there is no need to implement any dependencies on your part and should work out of the box.
- If you wish to  reduce the apk size you may replace bundled model dependencies with model's provided within Google Play Service, to know more about this see the below links
  1. [Image Labeling](https://developers.google.com/ml-kit/vision/image-labeling/android)
  2. [Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning/android)

## First Create an InputImage

Prepare Input Image(image you want to process)
```
import 'package:google_ml_kit/google_ml_kit.dart';

final inputImage = InputImage.fromFilePath(filePath);

// Or you can prepare image form
//final inputImage = InputImage.fromFile(file);

// final inputImageData = InputImageData(
//     size: size of image,
//     rotation: roatation degree(0,90,180,270 supported),
//     inputImageFormat:InputImageFormat.NV21 (default format of image);
//         
//
// var inputImage = InputImage.fromBytes(
//     bytes: await pickedFile.readAsBytes(), 
//     inputImageData: inputImageData);
```
 
To know more about [formats of image](https://developer.android.com/reference/android/graphics/ImageFormat.html#NV21).

## Create an instance of detector
## Call `processImage()` to obtain the result
## Call `close()`

#### [An  example covering all the api's usage](example/lib)

## Digital Ink reognition
**Read to know how to imlpement [Digital Ink Recognition](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/digital_ink_recogniser.md)**
## Pose Detection

- *Googgle Play service model is not available for this api' so no extra implementation**

- **Create [`PoseDetectorOptions`]()**
```
final options = PoseDetectorOptions(
        poseDetectionModel: PoseDetectionModel.BasePoseDetector,
        selectionType : LandmarkSelectionType.all,
        poseLandmarks:(list of poseaLndmarks you want); 
//or PoseDetectionModel.AccuratePoseDetector to use accurate pose detector
        
```
- **Obtain [`PoseDetector`] instance.**

**Note**: To obtain default poseDetector no options need to be specied. It gives all available landmarks using BasePoseDetector Model.

**The same implies to other detectors as well**
```
PoseDetector poseDetector = GoogleMlKit.instance
                               .poseDetector([PoseDetectorOptions options]);
```
- Call `processImage(InputImage inputImage)` to obtain the result.
It returns 
>Map<int,[PoseLandMark]()>
```
final landMarksMap = await poseDetector.processImage(inputImage);
```
Use the map to extract data. See this [example](example/lib/DetectorViews/pose_detector_view.dart) to get better idea.

## Image Labeling
**In plugin's build.gradle. For latest version check [Image Labeling](https://developers.google.com/ml-kit/vision/image-labeling/)**
```
dependencies {
       // ...
// Use this dependency to use dynamically downloaded model in Google Play Service
      implementation 'com.google.android.gms:play-services-mlkit-image-labeling:16.0.0'
    }
```
If you choose google service way.In **app level buil.gradle add**

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
**Obtain [`ImageLabeler`]() instance.**
```
ImageLabeler imageLabeler = GoogleMlKit.instance.imageLabeler([options]);
```
**call `processImage()`**
It returns List<[ImageLabel]()>
```
final labels = await imageLabeler.processImage(inputImage);
```

**To know more see this [example](example/lib/DetectorViews/label_detector_view.dart.dart)**

## Barcode Scanner
**In you app-level build.gradle. For latest version check [Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning)**
```
dependencies {
      // ...
// Use this dependency to use the dynamically downloaded model in Google Play Services
      implementation 'com.google.android.gms:play-services-mlkit-barcode-scanning:16.1.2'
    }
```
**Obtain [`BarcodeScanner`]() instance.**
```
BarcodeScanner barcodeScanner = GoogleMlKit.instance
                                           .barcodeScanner(
                                           formats:(List of BarcodeFormats);

```
Supported [BarcodeFormat](https://developers.google.com/android/reference/com/google/mlkit/vision/barcode/Barcode.BarcodeFormat)s .Access them using 

>Barcode.FORMAT_Default

>Barcode.FORMAT_Code_128

etc..

**call `processImage()`**
It returns List<[Barcode]()>
```
final result = await barcodeScanner.processImage(inputImage);
```
To know more see this [example](example/lib/DetectorViews/barcode_scanner_view.dart)

## Contributing
In case of any errors open an issue.

## Text Recognition
**In plugin's build.gradle. For latest version check [Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition/)**

**Obtain [`TextDetector`]() instance.**
```
TextDetector textDetector = GoogleMlKit.instance.textDetector();
```
**call `processImage()`**
It returns [RecognisedText]() object
```
final text = await textDetector.processImage(inputImage);
```

**To know more see this [example](example/lib/DetectorViews/text_detector_view.dart)**

## License
[MIT](https://choosealicense.com/licenses/mit/)

