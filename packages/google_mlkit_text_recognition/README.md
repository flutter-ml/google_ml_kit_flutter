# Google's ML Kit Text Recognition for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_text_recognition)](https://pub.dev/packages/google_mlkit_text_recognition)

A Flutter plugin to use [Google's ML Kit Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition/v2).

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

## Usage

### Text Recognition

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

Look at this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example) to see the plugin in action.

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
