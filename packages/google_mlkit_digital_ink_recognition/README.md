# Google's ML Kit Digital Ink Recognition for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_digital_ink_recognition)](https://pub.dev/packages/google_mlkit_digital_ink_recognition)

A Flutter plugin to use [Google's ML Kit Digital Ink Recognition](https://developers.google.com/ml-kit/vision/digital-ink-recognition) to recognize handwritten text on a digital surface in hundreds of languages, as well as classify sketches.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

## Usage

### Digital Ink Recognition

#### Create an instance of `DigitalInkRecognizer`

```dart
final digitalInkRecognizer = DigitalInkRecognizer();
```

#### Process points

```dart
List<Offset> points; // an array with the points of the stroke
String modelCode; // BCP-47 Code from https://developers.google.com/ml-kit/vision/digital-ink-recognition/base-models?hl=en#text
final List<RecognitionCandidate> canditates = await digitalInkRecognizer.readText(points, modelCode);

for (final candidate in candidates) {
  final text = candidate.text;
  final score = candidate.score;
}
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
