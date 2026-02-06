# Google's ML Kit GenAI Proofreading for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_genai_proofreading)](https://pub.dev/packages/google_mlkit_genai_proofreading)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit GenAI Proofreading API](https://developers.google.com/ml-kit/genai/proofreading) to check grammar and spelling.

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/flutter-ml/google_ml_kit_flutter/issues):

- [Google's ML Kit](https://developers.google.com/ml-kit) was build only for mobile platforms: iOS and Android apps. Web or any other platform is not supported, you can request support for those platform to Google in [their repo](https://github.com/googlesamples/mlkit/issues).

- This plugin is not sponsored or maintained by Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) are developers excited about Machine Learning that wanted to expose Google's native APIs to Flutter.

- Google's ML Kit APIs are only developed natively for iOS and Android. This plugin uses Flutter Platform Channels as explained [here](https://docs.flutter.dev/development/platform-integration/platform-channels).

## Requirements

### Android

- minSdkVersion: 26
- targetSdkVersion: 35
- compileSdkVersion: 35

**⚠️ Important:** This API is built on top of AICore and will not support all Android devices. It requires devices with AICore support. Please check device compatibility before using this feature in production.

**⚠️ Production Disclaimer:** Using this plugin in production is the responsibility of the developers consuming the plugin, not the authors. The authors provide this plugin as-is and are not responsible for any issues, failures, or compatibility problems that may arise from using this plugin in production environments.

**Note:** This API is currently only available on Android. iOS support may be added in the future.

## Usage

### Proofreading

#### Create an instance of `Proofreader`

```dart
final proofreader = Proofreader(
  inputType: ProofreadingInputType.keyboard,
  language: ProofreadingLanguage.english,
);
```

#### Check feature status

```dart
final status = await proofreader.checkFeatureStatus();
if (status == FeatureStatus.downloadable) {
  await proofreader.downloadFeature(
    onDownloadCompleted: () {
      // Start proofreading
    },
  );
} else if (status == FeatureStatus.available) {
  // Start proofreading
}
```

#### Process text

```dart
final text = "The praject is compleet but needs too be reviewd";
final results = await proofreader.runInference(text);
for (final result in results) {
  print('Corrected: ${result.text} (confidence: ${result.confidence})');
}
```

#### Release resources with `close()`

```dart
proofreader.close();
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
