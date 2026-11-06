# Google's ML Kit for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_ml_kit)](https://pub.dev/packages/google_ml_kit)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on GitHub](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Google's ML Kit for Flutter is a set of [Flutter plugins](https://docs.flutter.dev/packages-and-plugins/using-packages) that enable [Flutter](https://flutter.dev) apps to use [Google's standalone ML Kit](https://developers.google.com/ml-kit).

> `google_ml_kit` is an umbrella plugin that groups the Vision, Natural Language, and GenAI plugins under a single package (`google_mlkit_document_scanner` and `google_mlkit_subject_segmentation` are standalone packages and must be added individually). By using `google_ml_kit` you will include all of its exported plugins and their respective dependencies, significantly increasing the size of your app. We recommend adding only the specific plugin(s) for the feature(s) you need rather than depending on `google_ml_kit`.
>
> DO NOT USE `google_ml_kit` in a production app; instead, depend directly on the individual plugin package(s) listed below.

Go to each plugin listed below to read about their documentation and requirements. If you find issues report and contribute with your pull requests.

## Features

### Vision APIs

| Feature                                                                                         | Plugin                                                                                                                                                                                                                                                   | Android | iOS |
| ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | --- |
| [Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning)                | [google_mlkit_barcode_scanning](https://pub.dev/packages/google_mlkit_barcode_scanning) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_barcode_scanning)](https://pub.dev/packages/google_mlkit_barcode_scanning)                             | ✅      | ✅  |
| [Face Detection](https://developers.google.com/ml-kit/vision/face-detection)                    | [google_mlkit_face_detection](https://pub.dev/packages/google_mlkit_face_detection) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_face_detection)](https://pub.dev/packages/google_mlkit_face_detection)                                     | ✅      | ✅  |
| [Face Mesh Detection (Beta)](https://developers.google.com/ml-kit/vision/face-mesh-detection)   | [google_mlkit_face_mesh_detection](https://pub.dev/packages/google_mlkit_face_mesh_detection) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_face_mesh_detection)](https://pub.dev/packages/google_mlkit_face_mesh_detection)                 | ✅      | ❌  |
| [Text Recognition v2](https://developers.google.com/ml-kit/vision/text-recognition/v2)          | [google_mlkit_text_recognition](https://pub.dev/packages/google_mlkit_text_recognition) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_text_recognition)](https://pub.dev/packages/google_mlkit_text_recognition)                             | ✅      | ✅  |
| [Image Labeling](https://developers.google.com/ml-kit/vision/image-labeling)                    | [google_mlkit_image_labeling](https://pub.dev/packages/google_mlkit_image_labeling) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_image_labeling)](https://pub.dev/packages/google_mlkit_image_labeling)                                     | ✅      | ✅  |
| [Object Detection and Tracking](https://developers.google.com/ml-kit/vision/object-detection)   | [google_mlkit_object_detection](https://pub.dev/packages/google_mlkit_object_detection) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_object_detection)](https://pub.dev/packages/google_mlkit_object_detection)                             | ✅      | ✅  |
| [Digital Ink Recognition](https://developers.google.com/ml-kit/vision/digital-ink-recognition)  | [google_mlkit_digital_ink_recognition](https://pub.dev/packages/google_mlkit_digital_ink_recognition) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_digital_ink_recognition)](https://pub.dev/packages/google_mlkit_digital_ink_recognition) | ✅      | ✅  |
| [Pose Detection (Beta)](https://developers.google.com/ml-kit/vision/pose-detection)             | [google_mlkit_pose_detection](https://pub.dev/packages/google_mlkit_pose_detection) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_pose_detection)](https://pub.dev/packages/google_mlkit_pose_detection)                                     | ✅      | ✅  |
| [Selfie Segmentation (Beta)](https://developers.google.com/ml-kit/vision/selfie-segmentation)   | [google_mlkit_selfie_segmentation](https://pub.dev/packages/google_mlkit_selfie_segmentation) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_selfie_segmentation)](https://pub.dev/packages/google_mlkit_selfie_segmentation)                 | ✅      | ✅  |
| [Subject Segmentation (Beta)](https://developers.google.com/ml-kit/vision/subject-segmentation) | [google_mlkit_subject_segmentation](https://pub.dev/packages/google_mlkit_subject_segmentation) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_subject_segmentation)](https://pub.dev/packages/google_mlkit_subject_segmentation)             | ✅      | ❌  |
| [Document Scanner (Beta)](https://developers.google.com/ml-kit/vision/doc-scanner)              | [google_mlkit_document_scanner](https://pub.dev/packages/google_mlkit_document_scanner) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_document_scanner)](https://pub.dev/packages/google_mlkit_document_scanner)                             | ✅      | ❌  |

### Natural Language APIs

| Feature                                                                                     | Plugin                                                                                                                                                                                                                           | Android | iOS |
| ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | --- |
| [Language Identification](https://developers.google.com/ml-kit/language/identification)     | [google_mlkit_language_id](https://pub.dev/packages/google_mlkit_language_id) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_language_id)](https://pub.dev/packages/google_mlkit_language_id)                         | ✅      | ✅  |
| [On-Device Translation](https://developers.google.com/ml-kit/language/translation)          | [google_mlkit_translation](https://pub.dev/packages/google_mlkit_translation) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_translation)](https://pub.dev/packages/google_mlkit_translation)                         | ✅      | ✅  |
| [Smart Reply](https://developers.google.com/ml-kit/language/smart-reply)                    | [google_mlkit_smart_reply](https://pub.dev/packages/google_mlkit_smart_reply) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_smart_reply)](https://pub.dev/packages/google_mlkit_smart_reply)                         | ✅      | ✅  |
| [Entity Extraction (Beta)](https://developers.google.com/ml-kit/language/entity-extraction) | [google_mlkit_entity_extraction](https://pub.dev/packages/google_mlkit_entity_extraction) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_entity_extraction)](https://pub.dev/packages/google_mlkit_entity_extraction) | ✅      | ✅  |

### GenAI APIs

> **⚠️ Important:** GenAI APIs are built on top of AICore and will not support all Android devices. These APIs require devices with AICore support. Please check device compatibility before using these features in production.
>
> **⚠️ Production Disclaimer:** Using GenAI plugins in production is the responsibility of the developers consuming the plugins, not the authors. The authors provide these plugins as-is and are not responsible for any issues, failures, or compatibility problems that may arise from using these plugins in production environments.

| Feature                                                                                     | Plugin                                                                                                                                                                                                                           | Android | iOS |
|---------------------------------------------------------------------------------------------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | --- |
| [Summarization (Beta)](https://developers.google.com/ml-kit/genai/summarization)          | [google_mlkit_genai_summarization](https://pub.dev/packages/google_mlkit_genai_summarization) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_genai_summarization)](https://pub.dev/packages/google_mlkit_genai_summarization) | ✅      | ❌  |
| [Proofreading (Beta)](https://developers.google.com/ml-kit/genai/proofreading)            | [google_mlkit_genai_proofreading](https://pub.dev/packages/google_mlkit_genai_proofreading) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_genai_proofreading)](https://pub.dev/packages/google_mlkit_genai_proofreading) | ✅      | ❌  |
| [Rewriting (Beta)](https://developers.google.com/ml-kit/genai/rewriting)                  | [google_mlkit_genai_rewriting](https://pub.dev/packages/google_mlkit_genai_rewriting) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_genai_rewriting)](https://pub.dev/packages/google_mlkit_genai_rewriting) | ✅      | ❌  |
| [Image Description (Beta)](https://developers.google.com/ml-kit/genai/image-description) | [google_mlkit_genai_image_description](https://pub.dev/packages/google_mlkit_genai_image_description) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_genai_image_description)](https://pub.dev/packages/google_mlkit_genai_image_description) | ✅      | ❌  |
| [Speech Recognition (Alpha)](https://developers.google.com/ml-kit/genai/speech-recognition) | [google_mlkit_genai_speech_recognition](https://pub.dev/packages/google_mlkit_genai_speech_recognition) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_genai_speech_recognition)](https://pub.dev/packages/google_mlkit_genai_speech_recognition) | ✅      | ❌  |
| [Prompt (Alpha)](https://developers.google.com/ml-kit/genai/prompt)                        | [google_mlkit_genai_prompt](https://pub.dev/packages/google_mlkit_genai_prompt) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_genai_prompt)](https://pub.dev/packages/google_mlkit_genai_prompt) | ✅      | ❌  |

### Common APIs

| Feature                                    | Plugin                                                                                                                                                                     | Android | iOS |
|--------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------| ------- | --- |
| Shared types (`InputImage`, `ModelManager`) | [google_mlkit_commons](https://pub.dev/packages/google_mlkit_commons) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_commons)](https://pub.dev/packages/google_mlkit_commons) | ✅      | ✅  |

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

All ML Kit iOS plugins use **Swift Package Manager (SwiftPM)** via [`d-date/google-mlkit-swiftpm`](https://github.com/d-date/google-mlkit-swiftpm) (`9.0.2`), which also supports Apple Silicon iOS Simulators out of the box.

1. **Linker Flags**: In Xcode, go to **Runner > Build Settings > Linking - General > Other Linker Flags** (`OTHER_LDFLAGS`) and add:
   - `-ObjC`
   - `-all_load`

2. **ML Kit Resource Bundles**: SwiftPM cannot bundle model files inside `.binaryTarget` frameworks into the main app bundle automatically. Download the required `.bundle` archives from the [`d-date/google-mlkit-swiftpm` v9.0.2 release](https://github.com/d-date/google-mlkit-swiftpm/releases/tag/9.0.2) and add them to your Xcode `Runner` target (**Build Phases > Copy Bundle Resources**). See [`packages/example/ios/download_mlkit_bundles.sh`](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/ios/download_mlkit_bundles.sh) for a ready-to-use download script.

### Android

- minSdkVersion: 21 (24 for `google_mlkit_subject_segmentation`, 26 for `google_mlkit_genai_*`)
- targetSdkVersion: 36
- compileSdkVersion: 36

**⚠️ Production Disclaimer:** Using these plugins in production is the responsibility of the developers consuming the plugins, not the authors. The authors provide these plugins as-is and are not responsible for any issues, failures, or compatibility problems that may arise from using these plugins in production environments.

## Migrating from ML Kit for Firebase to the new standalone ML Kit SDK

When migrating from ML Kit for Firebase to the new standalone ML Kit SDK read [this guide](https://developers.google.com/ml-kit/migration).

For Android details read [this](https://developers.google.com/ml-kit/migration/android).

For iOS details read [this](https://developers.google.com/ml-kit/migration/ios).

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

### Consuming image streams on Android

Until [flutter/flutter#145961](https://github.com/flutter/flutter/issues/145961) is resolved, the default CameraX implementation in the `camera` package doesn't support the required `nv21` image format. To use camera image streams on Android, manually add [`camera_android`](https://pub.dev/packages/camera_android) to your app's `pubspec.yaml`.

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non-trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
