# Google's ML Kit On-Device Translation for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_translation)](https://pub.dev/packages/google_mlkit_translation)

A Flutter plugin to use [Google's ML Kit On-Device Translation](https://developers.google.com/ml-kit/language/translation) to dynamically translate text between more than 50 languages.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

### Usage guidelines for ML Kit on-device translation

In order to use Google's on-device Translation API in your application, you need to comply with the following guidelines. These guidelines may change from time to time, and without prior notice from Google. Your continued use of the on-device Translation API is contingent upon your adherence to these guidelines. If you're uncomfortable with any of these branding guidelines, discontinue your use of the API and [contact Google](https://developers.google.com/ml-kit/community) with your concerns. See more about the usage guidelines [here](https://developers.google.com/ml-kit/language/translation/translation-terms).

### Supported languages

ML Kit can translate between the following [languages](https://developers.google.com/ml-kit/language/translation/translation-language-support).

## Usage

### On-Device Translation

#### Create an instance of `OnDeviceTranslator`

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

Downloading model always return false, models are downloaded if needed when translating.

```dart
final bool response = await modelManager.downloadModel(TranslateLanguage.english);
```

#### Delete model

```dart
final bool response = await modelManager.deleteModel(TranslateLanguage.english);
```

## Example app

Find the example app [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example).


## Contributing
                         
Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
