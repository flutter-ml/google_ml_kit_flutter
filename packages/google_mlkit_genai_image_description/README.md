# Google's ML Kit GenAI Image Description for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_genai_image_description)](https://pub.dev/packages/google_mlkit_genai_image_description)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit GenAI Image Description API](https://developers.google.com/ml-kit/genai/image-description) to generate descriptions for images.

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

### Image Description

#### Create an instance of `ImageDescriber`

```dart
final imageDescriber = ImageDescriber();
```

#### Check feature status

```dart
final status = await imageDescriber.checkFeatureStatus();
if (status == FeatureStatus.downloadable) {
  await imageDescriber.downloadFeature(
    onDownloadCompleted: () {
      // Start image description
    },
  );
} else if (status == FeatureStatus.available) {
  // Start image description
}
```

#### Process image

```dart
final imageData = {
  'type': 'file',
  'path': '/path/to/image.jpg',
};
final description = await imageDescriber.runInference(imageData);
print('Description: $description');
```

#### Release resources with `close()`

```dart
imageDescriber.close();
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
