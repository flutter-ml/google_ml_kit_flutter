# Google's ML Kit Subject Segmentation for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_subject_segmentation)](https://pub.dev/packages/google_mlkit_subject_segmentation)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

> ***NOTE: This feature is still in Beta, and it is only available for Android. Stay tune for updates in [Google's website](https://developers.google.com/ml-kit/vision/subject-segmentation) and request the feature [here](https://github.com/googlesamples/mlkit/issues).***

A Flutter plugin to use [Google's ML Kit Subject Segmentation](https://developers.google.com/ml-kit/vision/subject-segmentation) to easily separate multiple subjects from the background in a picture, enabling use cases such as sticker creation, background swap, or adding cool effects to subjects.

Subjects are defined as the most prominent people, pets, or objects in the foreground of the image. If 2 subjects are very close or touching each other, they are considered a single subject.

Each pixel of the mask is assigned a float number that has a range between 0.0 and 1.0. The closer the number is to 1.0, the higher the confidence that the pixel represents a subject, and vice versa

On average the latency measured on Pixel 7 Pro is around 200 ms. This API currently only supports static images.

Key capabilities

- Multi-subject segmentation: provides masks and bitmaps for each individual subject, rather than a single mask and bitmap for all subjects combined.
- Subject recognition: subjects recognized are objects, pets, and humans.
- On-device processing: all processing is performed on the device, preserving user privacy and requiring no network connectivity.


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

This feature is still in Beta, and it is only available for Android. Stay tune for updates in [Google's website](https://developers.google.com/ml-kit/vision/subject-segmentation) and request the feature [here](https://github.com/googlesamples/mlkit/issues).

### Android

- minSdkVersion: 24
- targetSdkVersion: 33
- compileSdkVersion: 34

You can configure your app to automatically download the model to the device after your app is installed from the Play Store. To do so, add the following declaration to your app's AndroidManifest.xml file:

```xml
<application ...>
      ...
      <meta-data
          android:name="com.google.mlkit.vision.DEPENDENCIES"
          android:value="subject_segment" >
      <!-- To use multiple models: android:value="subject_segment,model2,model3" -->
</application>
```

## Usage

### Subject Segmentation

#### Create an instance of `InputImage`

Create an instance of `InputImage` as explained [here](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons#creating-an-inputimage).

```dart
final InputImage inputImage;
```

#### Create an instance of `SubjectSegmenter`

```dart
final options = SubjectSegmenterOptions();
final segmenter = SubjectSegmenter(options: options);
```

#### Process image

```dart
final mask = await segmenter.processImage(inputImage);
```

#### Release resources with `close()`

```dart
segmenter.close();
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
