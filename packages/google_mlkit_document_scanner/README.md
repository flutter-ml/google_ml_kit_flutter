# Google's ML Kit Document scanner for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_document_scanner)](https://pub.dev/packages/google_mlkit_document_scanner)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

> ***NOTE: This feature is still in Beta, and it is only available for Android. Stay tune for updates in [Google's website](https://developers.google.com/ml-kit/vision/doc-scanner) and request the feature [here](https://github.com/googlesamples/mlkit/issues).***

A Flutter plugin to use [Google's ML Kit Document Scanner](https://developers.google.com/ml-kit/vision/doc-scanner) to digitize physical documents, which allows users to convert physical documents into digital formats. ML Kit's document scanner API provides a comprehensive solution with a high-quality, consistent UI flow across Android apps and devices. Once the document scanner flow is triggered from your app, users retain full control over the scanning process. They can optionally crop the scanned documents, apply filters, remove shadows or stains, and easily send the digitized files back to your app.

The UI flow, ML models and other large resources are delivered using Google Play services, which means:

- Low binary size impact (all ML models and large resources are downloaded centrally in Google Play services).
- No camera permission is required - the document scanner leverages the Google Play services' camera permission, and users are in control of which files to share back with your app.

Key capabilities
- High-quality and consistent user interface for digitizing physical documents.
- Automatic capture with document detection.
- Accurate edge detection for optimal crop results.
- Automatic rotation detection to show documents upright.
- No camera permission is needed from your app.
- Low apk binary size impact.

Customization

The document scanner API provides a high-quality fully fledged UI flow that is consistent across Android apps. However, there is also room to customize some aspects of the user experience
- Maximum number of pages 
- Gallery import 
- Editing functionalities

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

This feature is still in Beta, and it is only available for Android. Stay tune for updates in [Google's website](https://developers.google.com/ml-kit/vision/doc-scanner) and request the feature [here](https://github.com/googlesamples/mlkit/issues).

### Android

- minSdkVersion: 21
- targetSdkVersion: 33
- compileSdkVersion: 34

## Usage

### Document Scanner

#### Create an instance of `DocumentScannerOptions`

```dart 
DocumentScannerOptions documentOptions = DocumentScannerOptions(
  documentFormat: DocumentFormat.jpeg, // set output document format 
  mode: ScannerMode.filter, // to control what features are enabled 
  pageLimit: 1, // setting a limit to the number of pages scanned
  isGalleryImport: true, // importing from the photo gallery 
);
```

#### Create an instance of `DocumentScanner`

```dart
final documentScanner = DocumentScanner(option: documentOptions);
```

#### Start Scanner

The scanner returns objects for the scanned document. 

```dart
DocumentScanningResult result = await documentScanner.scanDocument();
final pdf = result.pdf; // A PDF object.
final images = result.images;  // A list with the paths to the images.
```

#### Release resources with `close()`

```dart
documentScanner.close();
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
