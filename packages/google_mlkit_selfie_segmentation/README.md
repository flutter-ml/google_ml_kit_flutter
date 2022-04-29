# Google's ML Kit Selfie Segmentation  for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_selfie_segmentation)](https://pub.dev/packages/google_mlkit_selfie_segmentation)

A Flutter plugin to use [Google's ML Kit Selfie Segmentation  API](https://developers.google.com/ml-kit/vision/selfie-segmentation) to easily separate the background from users within a scene and focus on what matters.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

## Usage

### Selfie Segmenter

#### Create an instance of `InputImage`

Create an instance of `InputImage` as explained [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_commons#creating-an-inputimage).

```dart
final InputImage inputImage;
```

#### Create an instance of `SelfieSegmenter`

```dart
final segmenter = SelfieSegmenter(
  mode: SegmenterMode.stream,
  enableRawSizeMask: true,
);
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

Find the example app [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
