# Google's ML Kit Entity Extraction for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_entity_extraction)](https://pub.dev/packages/google_mlkit_entity_extraction)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on GitHub](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

> **_NOTE: This feature is still in Beta. Stay tuned for updates on [Google's website](https://developers.google.com/ml-kit/language/entity-extraction)._**

A Flutter plugin to use [Google's ML Kit Entity Extraction API](https://developers.google.com/ml-kit/language/entity-extraction) to recognize specific entities within static text.

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/flutter-ml/google_ml_kit_flutter/issues):

- [Google's ML Kit](https://developers.google.com/ml-kit) was built only for mobile platforms: iOS and Android apps. Web or any other platform is not supported, you can request support for those platforms to Google in [their repo](https://github.com/googlesamples/mlkit/issues).

- This plugin is not sponsored or maintained by Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) are developers excited about Machine Learning that wanted to expose Google's native APIs to Flutter.

- Google's ML Kit APIs are only developed natively for iOS and Android. This plugin uses Flutter Platform Channels as explained [here](https://docs.flutter.dev/platform-integration/platform-channels).

  Messages are passed between the client (the app/plugin) and host (platform) using platform channels as illustrated in this diagram:

  <p align="center" width="100%">
    <img src="https://docs.flutter.dev/assets/images/docs/PlatformChannels.png">
  </p>

  Messages and responses are passed asynchronously, to ensure the user interface remains responsive. To read more about platform channels go [here](https://docs.flutter.dev/platform-integration/platform-channels).

  Because this plugin uses platform channels, no Machine Learning processing is done in Flutter/Dart, all the calls are passed to the native platform using `MethodChannel` in Android and `FlutterMethodChannel` in iOS, and executed using Google's native APIs. Think of this plugin as a bridge between your app and Google's native ML Kit APIs. This plugin only passes the call to the native API and the processing is done by Google's API. It is important that you understand this concept when it comes to debugging errors for your ML model and/or app.

- Since the plugin uses platform channels, you may encounter issues with the native API. Before submitting a new issue, identify the source of the issue. You can run both iOS and/or Android native [example apps by Google](https://github.com/googlesamples/mlkit) and make sure that the issue is not reproducible with their native examples. If you can reproduce the issue in their apps then report the issue to Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) do not have access to the source code of their native APIs, so you need to report the issue to them. If you find that their example apps are okay and still you have an issue using this plugin, then look at our [closed and open issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues). If you cannot find anything that can help you then report the issue and provide enough details. Be patient, someone from the community will eventually help you.

## Requirements

### iOS

- Minimum iOS Deployment Target: 15.0
- Xcode 15.3.0 or newer
- Swift 5.9 (Swift Package Manager)
- ML Kit does not support 32-bit architectures (i386 and armv7). ML Kit does support 64-bit architectures (x86_64 and arm64). Check this [list](https://developer.apple.com/support/required-device-capabilities/) to see if your device has the required device capabilities. More info [here](https://developers.google.com/ml-kit/migration/ios).

#### Swift Package Manager Setup

This plugin uses **Swift Package Manager (SwiftPM)** via [`d-date/google-mlkit-swiftpm`](https://github.com/d-date/google-mlkit-swiftpm) (`9.0.2`), which also supports Apple Silicon iOS Simulators out of the box.

1. **Linker Flags**: In Xcode, go to **Runner > Build Settings > Linking - General > Other Linker Flags** (`OTHER_LDFLAGS`) and add:
   - `-ObjC`
   - `-all_load`

### Android

- minSdkVersion: 21
- targetSdkVersion: 36
- compileSdkVersion: 36

**⚠️ Production Disclaimer:** Using this plugin in production is the responsibility of the developers consuming the plugin, not the authors. The authors provide this plugin as-is and are not responsible for any issues, failures, or compatibility problems that may arise from using this plugin in production environments.

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
final List<EntityAnnotation> annotations = await entityExtractor.annotateText(
  text,
  // Optional parameters:
  // entityTypesFilter: [EntityType.dateTime, EntityType.money],
  // preferredLocale: 'en-US',
  // referenceTime: DateTime.now().millisecondsSinceEpoch,
  // referenceTimeZone: 'UTC',
);

for (final annotation in annotations) {
  annotation.start;
  annotation.end;
  annotation.text;
  for (final entity in annotation.entities) {
    entity.type;
    entity.rawValue;
    switch (entity.type) {
      case EntityType.dateTime:
        final dateTimeEntity = entity as DateTimeEntity;
        dateTimeEntity.dateTimeGranularity;
        dateTimeEntity.timestamp;
        break;
      case EntityType.flightNumber:
        final flightNumberEntity = entity as FlightNumberEntity;
        flightNumberEntity.airlineCode;
        flightNumberEntity.flightNumber;
        break;
      case EntityType.money:
        final moneyEntity = entity as MoneyEntity;
        moneyEntity.fractionPart;
        moneyEntity.integerPart;
        moneyEntity.unnormalizedCurrency;
        break;
      // Also available: IbanEntity, IsbnEntity, PaymentCardEntity, TrackingNumberEntity
      default:
        break;
    }
  }
}
```

Note: `annotateText()` automatically downloads the language model if it is not already on the device (`downloadModelIfNeeded()`). You can also pre-download, check, or delete language models explicitly using `EntityExtractorModelManager` (see below).

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
final bool response = await modelManager.isModelDownloaded(EntityExtractorLanguage.english.name);
```

#### Download model

```dart
final bool response = await modelManager.downloadModel(
  EntityExtractorLanguage.english.name,
  isWifiRequired: true, // optional, defaults to true (enforced on Android only)
);
```

#### Delete model

```dart
final bool response = await modelManager.deleteModel(EntityExtractorLanguage.english.name);
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non-trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
