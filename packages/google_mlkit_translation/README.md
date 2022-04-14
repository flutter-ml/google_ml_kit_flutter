# Google's ML Kit On-Device Translation for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_translation)](https://pub.dev/packages/google_mlkit_translation)

A Flutter plugin to use [Google's ML Kit On-Device Translation](https://developers.google.com/ml-kit/language/translation).

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

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

```dart
final bool response = await modelManager.downloadModel(TranslateLanguage.english);
```
#### Delete model

```dart
final bool response = await modelManager.deleteModel(TranslateLanguage.english);
```

## Example app

Look at this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit/example) to see the plugin in action.


## :warning: on-device translation Restritions and Requirements
Google enforces API usage guidelines and restrictions on this service of which you are expected to comply with, namely - Attribution requirements and types of devices that this service can be used with. If you feel that these resrictions and requirements are invading, we encourage [letting Google know](https://developers.google.com/ml-kit/community).

See more about the usage guidelines [here](https://developers.google.com/ml-kit/language/translation/translation-terms).


## Contributing
                         
Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
