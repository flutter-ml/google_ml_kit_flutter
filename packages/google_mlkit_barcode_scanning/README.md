# Google's ML Kit Barcode Scanning for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_barcode_scanning)](https://pub.dev/packages/google_mlkit_barcode_scanning)
[![analysis](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions/workflows/flutter.yml/badge.svg)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions)
[![Star on Github](https://img.shields.io/github/stars/bharat-biradar/Google-Ml-Kit-plugin.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning) to read data encoded using most standard barcode formats.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

## Usage

### Barcode scanning

#### Create an instance of `InputImage`

Create an instance of `InputImage` as explained [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_commons#creating-an-inputimage).

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

Find the example app [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
