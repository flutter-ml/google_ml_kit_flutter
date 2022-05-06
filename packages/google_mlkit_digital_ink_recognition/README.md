# Google's ML Kit Digital Ink Recognition for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_digital_ink_recognition)](https://pub.dev/packages/google_mlkit_digital_ink_recognition)
[![analysis](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions/workflows/flutter.yml/badge.svg)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions)
[![Star on Github](https://img.shields.io/github/stars/bharat-biradar/Google-Ml-Kit-plugin.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit Digital Ink Recognition](https://developers.google.com/ml-kit/vision/digital-ink-recognition) to recognize handwritten text on a digital surface in hundreds of languages, as well as classify sketches.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

## Usage

### Digital Ink Recognition

#### Create an instance of `DigitalInkRecognizer`

```dart
String languageCode; // BCP-47 Code from https://developers.google.com/ml-kit/vision/digital-ink-recognition/base-models?hl=en#text
final digitalInkRecognizer = DigitalInkRecognizer(languageCode: languageCode);
```

#### Process ink

```dart
final p1 = StrokePoint(x: x1, y: y1, t: DateTime.now().millisecondsSinceEpoch); // make sure that `t` is a long
final p2 = StrokePoint(x: x1, y: y1, t: DateTime.now().millisecondsSinceEpoch); // make sure that `t` is a long

Stroke stroke1 = Stroke(); // it contains all of the StrokePoint
stroke1.point = [p1, p2, ...]

Ink ink = Ink(); // it contains all of the Stroke
ink.strokes = [stroke1, stroke2, ...];

final List<RecognitionCandidate> candidates = await digitalInkRecognizer.recognize(ink);

for (final candidate in candidates) {
  final text = candidate.text;
  final score = candidate.score;
}
```

Make sure you download the language model before processing any `Ink`.

To improve the accuracy of text recognition you can set an writing area and pre-context. More details [here](https://developers.google.cn/ml-kit/vision/digital-ink-recognition/ios#tips-to-improve-text-recognition-accuracy).

```dart
String preContext;
double width;
double height;
final context = DigitalInkRecognitionContext(
  preContext: preContext,
  writingArea: WritingArea(width: width, height: height),
);

final List<RecognitionCandidate> candidates = await digitalInkRecognizer.recognize(ink, context: context);

```

#### Release resources with `close()`

```dart
digitalInkRecognizer.close();
```

### Managing remote models

#### Create an instance of model manager

```dart
final modelManager = DigitalInkRecognizerModelManager();
```

#### Check if model is downloaded

```dart
final bool response = await modelManager.isModelDownloaded(model);
```

#### Download model

```dart
final bool response = await modelManager.downloadModel(model);
```

#### Delete model

```dart
final bool response = await modelManager.deleteModel(model);
```

## Example app

Find the example app [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
