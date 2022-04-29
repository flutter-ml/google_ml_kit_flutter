# Google's ML Kit for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_ml_kit)](https://pub.dev/packages/google_ml_kit)

Google's ML Kit for Flutter is a set of [Flutter plugins](https://flutter.io/platform-plugins/) that enable [Flutter](https://flutter.dev) apps to use [Google's standalone ML Kit](https://developers.google.com/ml-kit).

In versions `0.7.3` and earlier all features were included in a single plugin, but a lot of developers started to get issues with the size of their apps, because even though they only needed a single feature, the plugin included all the resources for the rest of the features, that increased the size of the app significantly.

Since version `0.8.0` we have split the plugin in multiple plugins to allow developers to use only what they need. `google_ml_kit` now is an umbrella plugin including all of the plugins. Start using or migrate to the new plugins to use only what you need. Go to each plugin to read about their requirements. If you find issues report and contribute with your pull requests.

## Features

### Vision APIs

| Feature                                                                                       | Plugin | Android | iOS |
|-----------------------------------------------------------------------------------------------|--------|---------|-----|
|[Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning)               | [google\_mlkit\_barcode\_scanning](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_barcode_scanning)                | ✅ | ✅ |
|[Face Detection](https://developers.google.com/ml-kit/vision/face-detection)                   | [google\_mlkit\_face\_detection](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_face_detection)                    | ✅ | ✅ |
|[Image Labeling](https://developers.google.com/ml-kit/vision/image-labeling)                   | [google\_mlkit\_image\_labeling](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_image_labeling)                    | ✅ | ✅ |
|[Object Detection and Tracking](https://developers.google.com/ml-kit/vision/object-detection)  | [google\_mlkit\_object\_detection](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_object_detection)                | ✅ | ✅ |
|[Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition)               | [google\_mlkit\_text\_recognition](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_text_recognition)                | ✅ | ✅ |
|[Text Recognition V2](https://developers.google.com/ml-kit/vision/text-recognition/v2)         | [google\_mlkit\_text\_recognition](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_text_recognition)                | ✅ | ✅ |
|[Digital Ink Recognition](https://developers.google.com/ml-kit/vision/digital-ink-recognition) | [google\_mlkit\_digital\_ink\_recognition](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_digital_ink_recognition) | ✅ | ✅ |
|[Pose Detection](https://developers.google.com/ml-kit/vision/pose-detection)                   | [google\_mlkit\_pose\_detection](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_pose_detection)                    | ✅ | ✅ |
|[Selfie Segmentation](https://developers.google.com/ml-kit/vision/selfie-segmentation)         | [google\_mlkit\_selfie\_segmentation](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_selfie_segmentation)          | ✅ | ✅ |

### Natural Language APIs

| Feature                                                                                       | Plugin | Android | iOS |
|-----------------------------------------------------------------------------------------------|--------|---------|-----|
|[Language Identification](https://developers.google.com/ml-kit/language/identification)        | [google\_mlkit\_language\_id](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_language_id)                | ✅ | ✅ |
|[On-Device Translation](https://developers.google.com/ml-kit/language/translation)             | [google\_mlkit\_translation](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_translation)                 | ✅ | ✅ |
|[Smart Reply](https://developers.google.com/ml-kit/language/smart-reply)                       | [google\_mlkit\_smart\_reply](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_smart_reply)                | ✅ | ✅ |
|[Entity Extraction](https://developers.google.com/ml-kit/language/entity-extraction)           | [google\_mlkit\_entity\_extraction](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_entity_extraction)    | ✅ | ✅ |

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin#requirements).

Go to the documentation of each plugin to learn how to use it.

## Example app

Find the example app [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
