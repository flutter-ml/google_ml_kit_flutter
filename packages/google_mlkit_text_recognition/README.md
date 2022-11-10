# Google's ML Kit Text Recognition for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_text_recognition)](https://pub.dev/packages/google_mlkit_text_recognition)
[![analysis](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions/workflows/flutter.yml/badge.svg)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions)
[![Star on Github](https://img.shields.io/github/stars/bharat-biradar/Google-Ml-Kit-plugin.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition/v2) to recognize text in any Chinese, Devanagari, Japanese, Korean and Latin character set.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

### Supported languages

The ML Kit Text Recognition API can recognize text in any Chinese, Devanagari, Japanese, Korean and Latin character set. Supported languages can be found [here](https://developers.google.com/ml-kit/vision/text-recognition/v2/languages).

## Usage

### Text Recognition

### Adding language package dependencies

By default, this package only supports recognition of Latin characters. If you need to recognize other languages, you need to manually add dependencies

For the iOS platform add to the `ios/Podfile` file:

```ruby
# Add language package you need to use
pod 'GoogleMLKit/TextRecognitionChinese', '~> 3.2.0'
pod 'GoogleMLKit/TextRecognitionDevanagari', '~> 3.2.0'
pod 'GoogleMLKit/TextRecognitionJapanese', '~> 3.2.0'
pod 'GoogleMLKit/TextRecognitionKorean', '~> 3.2.0'
```

For the Android platform add to the `andorid/app/build.gradle` file:

```gradle
dependencies {
    // Add language package you need to use
    implementation 'com.google.mlkit:text-recognition-chinese:16.0.0-beta5'
    implementation 'com.google.mlkit:text-recognition-devanagari:16.0.0-beta5'
    implementation 'com.google.mlkit:text-recognition-japanese:16.0.0-beta5'
    implementation 'com.google.mlkit:text-recognition-korean:16.0.0-beta5'
}
```

#### Create an instance of `InputImage`

Create an instance of `InputImage` as explained [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_commons#creating-an-inputimage).

```dart
final InputImage inputImage;
```

#### Create an instance of `TextRecognizer`

```dart
final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
```

#### Process image

```dart
final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

String text = recognizedText.text;
for (TextBlock block in recognizedText.blocks) {
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

#### Release resources with `close()`

```dart
textRecognizer.close();
```

## Example app

Find the example app [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
