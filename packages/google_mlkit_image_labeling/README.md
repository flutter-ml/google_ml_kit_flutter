# Google's ML Kit Image Labeling for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_image_labeling)](https://pub.dev/packages/google_mlkit_image_labeling)

A Flutter plugin to use [Google's ML Kit Image Labeling](https://developers.google.com/ml-kit/vision/image-labeling).

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

### Firebase dependency

[Image Labeling](https://developers.google.com/ml-kit/vision/image-labeling/) could be used with both Base Models and [Custom Models](https://developers.google.com/ml-kit/custom-models). Base models are bundled with the app. Custom Models are downloaded from [Firebase](https://firebase.google.com/). Since both model options are handled in this plugin, that requires you to add Firebase to your project even if you are only using the Base Models. To add Firebase to your project follow these steps:

- [Android](https://firebase.google.com/docs/android/setup)
- [iOS](https://firebase.google.com/docs/ios/setup)

## Usage

### Image Labeling

#### Create an instance of `InputImage`

Create an instance of `InputImage` as explained [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_commons#creating-an-inputimage).

```dart
final InputImage inputImage;
```

#### Create an instance of `ImageLabeler`

```dart
final ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.5);
final imageLabeler = ImageLabeler(options: options);
```

#### Process image

```dart
final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

for (ImageLabel label in labels) {
  final String text = label.text;
  final int index = label.index;
  final double confidence = label.confidence;
}
```

#### Release resources with `close()`

```dart
imageLabeler.close();
```

### Managing remote models

#### Create an instance of model manager

```dart
final modelManager = FirebaseImageLabelerModelManager();
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
final bool = await modelManager.deleteModel(model);
```

## Example app

Look at this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit/example) to see the plugin in action.

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
