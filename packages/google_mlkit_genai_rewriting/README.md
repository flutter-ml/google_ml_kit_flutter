# Google's ML Kit GenAI Rewriting for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_genai_rewriting)](https://pub.dev/packages/google_mlkit_genai_rewriting)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit GenAI Rewriting API](https://developers.google.com/ml-kit/genai/rewriting) to rewrite text in different styles.

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/flutter-ml/google_ml_kit_flutter/issues):

- [Google's ML Kit](https://developers.google.com/ml-kit) was build only for mobile platforms: iOS and Android apps. Web or any other platform is not supported, you can request support for those platform to Google in [their repo](https://github.com/googlesamples/mlkit/issues).

- This plugin is not sponsored or maintained by Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) are developers excited about Machine Learning that wanted to expose Google's native APIs to Flutter.

- Google's ML Kit APIs are only developed natively for iOS and Android. This plugin uses Flutter Platform Channels as explained [here](https://docs.flutter.dev/development/platform-integration/platform-channels).

## Requirements

### Android

- minSdkVersion: 26
- targetSdkVersion: 35
- compileSdkVersion: 35

**Note:** This API is currently only available on Android. iOS support may be added in the future.

## Usage

### Rewriting

#### Create an instance of `Rewriter`

```dart
final rewriter = Rewriter(
  outputType: RewritingOutputType.formal,
  language: RewritingLanguage.english,
);
```

#### Check feature status

```dart
final status = await rewriter.checkFeatureStatus();
if (status == FeatureStatus.downloadable) {
  await rewriter.downloadFeature(
    onDownloadCompleted: () {
      // Start rewriting
    },
  );
} else if (status == FeatureStatus.available) {
  // Start rewriting
}
```

#### Process text

```dart
final text = "Your text here...";
final rewritten = await rewriter.runInference(text);
print('Rewritten: $rewritten');
```

#### Release resources with `close()`

```dart
rewriter.close();
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
