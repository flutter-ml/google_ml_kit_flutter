# Google's ML Kit Entity Extraction API for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_entity_extraction)](https://pub.dev/packages/google_mlkit_entity_extraction)
[![analysis](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions/workflows/flutter.yml/badge.svg)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/actions)
[![Star on Github](https://img.shields.io/github/stars/bharat-biradar/Google-Ml-Kit-plugin.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/bharat-biradar/Google-Ml-Kit-plugin)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit Entity Extractor API](https://developers.google.com/ml-kit/language/entity-extraction) to recognize specific entities within static text.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

### Supported languages

Entity extraction supports the following languages:

- Arabic
- Portuguese
- English (US, UK)
- Dutch
- French
- German
- Italian
- Japanese
- Korean
- Polish
- Russian
- Chinese (Simplified, Traditional)
- Spanish
- Thai
- Turkish

## Usage

### Entity Extraction

#### Create an instance of `EntityExtractor`

```dart
final entityExtractor = EntityExtractor(language: EntityExtractorLanguage.english);
```

#### Process text

```dart
final List<EntityAnnotation> annotations = await entityExtractor.annotateText(text);

for (final annotation in annotations) {
  annotation.start;
  annotation.end;
  annotation.text;
  for (final entity in annotation.entities) {
    entity.type;
    entity.rawValue;
  }
}
```

Make sure you download the language model before annotating any text.

#### Release resources with `close()`

```dart
entityExtractor.close();
```

### Managing remote models

#### Create an instance of model manager

```dart
final modelManager = EntityExtractorModelManager();
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
