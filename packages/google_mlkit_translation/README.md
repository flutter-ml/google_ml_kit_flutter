# Google's ML Kit On-Device Translation for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_ml_kit)](https://pub.dev/packages/google_ml_kit)

A Flutter plugin to use [Google's ML Kit On-Device Translation](https://developers.google.com/ml-kit/language/translation).

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin).

## Usage

#### Create an instance of translator

```dart
final TranslateLanguage sourceLanguage;
final TranslateLanguage targetLanguage;

final onDeviceTranslator = OnDeviceTranslator(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage);
```

#### Process text

```dart
final String response = await onDeviceTranslator.translateText(text);
```

#### Release resources with `close()`

```dart
onDeviceTranslator.close();
```

### Managing remote models

#### Create an instance of model manager

```dart
final modelManager = OnDeviceTranslatorModelManager();
```

#### Check if model is downloaded

```dart
final bool response = await modelManager.isModelDownloaded(TranslateLanguage.english);
```
#### Download model

```dart
final bool response = await modelManager.downloadModel(TranslateLanguage.english);
```
#### Delete model

```dart
final String bool = await modelManager.deleteModel(TranslateLanguage.english);
```

## Example app

Look at this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit/example) to see the plugin in action.

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
