# Google's ML Kit Entity Extraction API for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_entity_extraction)](https://pub.dev/packages/google_mlkit_entity_extraction)

A Flutter plugin to use [Google's ML Kit Entity Extractor API](https://developers.google.com/ml-kit/language/entity-extraction) to recognize specific entities within static text.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

## Usage

### Entity Extraction

#### Create an instance of `EntityExtractor`

```dart
final entityExtractor = EntityExtractor(language: EntityExtractorOptions.english);
```

#### Process text

```dart
final List<EntityAnnotation> annotations = await entityExtractor.extractEntities(text);

for (final annotation in annotations) {
}
```

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
