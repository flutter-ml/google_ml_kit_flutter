# Google's ML Kit Barcode Scanning for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_barcode_scanning)](https://pub.dev/packages/google_mlkit_barcode_scanning)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/flutter.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning) to read data encoded using most standard barcode formats.

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/flutter-ml/google_ml_kit_flutter/issues):

- [Google's ML Kit](https://developers.google.com/ml-kit) was build only for mobile platforms: iOS and Android apps.

- This plugin is not sponsor or maintained by Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) are developers excited about machine learning that wanted to expose Google's native APIs to Flutter.

- Google's ML Kit APIs are ony developed natively for iOS and Android. This plugin uses Flutter Platform Channels as explained [here](https://docs.flutter.dev/development/platform-integration/platform-channels).

  Messages are passed between the client (the app/plugin) and host (platform) using platform channels as illustrated in this diagram:

  <p align="center" width="100%">
    <img src="https://docs.flutter.dev/assets/images/docs/PlatformChannels.png"> 
  </p>

  Messages and responses are passed asynchronously, to ensure the user interface remains responsive. To read more about platform channels go [here](https://docs.flutter.dev/development/platform-integration/platform-channels).

  Because this plugin uses platform channels, no Machine Learning processing is done in Flutter/Dart, all the calls are passed to the native platform using `MethodChannel` in Android and `FlutterMethodChannel` in iOS, and executed using the Google's native APIs. Think of this plugin as a bridge between your app and Google's native ML Kit APIs. This plugin only passes the call to the native API and the processing is done by Google's API. It is important that you understand this concept when it comes to debugging errors for your ML model and/or app.

- Since the plugin uses platform channels, you may encounter issues with the native API. Before submitting a new issue, identify the source of the issue. You can run both iOS and/or Android native [example apps by Google](https://github.com/googlesamples/mlkit) and make sure that the issue is not reproducible with their native examples. If you can reproduce the issue in their apps then report the issue to Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) do not have access to the source code of their native APIs, so you need to report the issue to them. If you find that their example apps are okay and still you have an issue using this plugin, then look at our [closed and open issues](https://github.com/googlesamples/mlkit/issues). If you cannot find anything that can help you then report the issue and provide enough details. Be patient, someone from the community will eventually help you.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/flutter-ml/google_ml_kit_flutter#requirements).

## Usage

### Barcode scanning

#### Create an instance of `InputImage`

Create an instance of `InputImage` as explained [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/google_mlkit_commons#creating-an-inputimage).

```dart
final InputImage inputImage;
```

#### Create an instance of `BarcodeScanner`

```dart
final List<BarcodeFormat> formats = [BarcodeFormat.all, ...];
final barcodeScanner = BarcodeScanner(formats: formats);
```

#### Process image

```dart
final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);

for (Barcode barcode in barcodes) {
  final BarcodeType type = barcode.type;
  final Rect boundingBox = barcode.boundingBox;
  final String displayValue = barcode.displayValue;
  final String rawValue = barcode.rawValue;

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

#### Release resources with `close()`

```dart
barcodeScanner.close();
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/google_ml_kit/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
