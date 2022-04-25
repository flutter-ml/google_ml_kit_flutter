# Google's ML Kit Language Identification for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_language_id)](https://pub.dev/packages/google_mlkit_language_id)

A Flutter plugin to use [Google's ML Kit Language Identification](https://developers.google.com/ml-kit/language/identification) to determine the language of a string of text.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

### Supported languages

Language identification supports the following [languages](https://developers.google.com/ml-kit/language/identification/langid-support).

## Usage

### Language Identification

#### Create an instance of `LanguageIdentifier`

```dart
final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
```

#### Process text

```dart
final String response = await languageIdentifier.identifyLanguage(text);

final List<IdentifiedLanguage> possibleLanguages = await languageIdentifier.identifyPossibleLanguages(text);
```

#### Release resources with `close()`

```dart
imageLabeler.close();
```

## Example app

Find the example app [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
