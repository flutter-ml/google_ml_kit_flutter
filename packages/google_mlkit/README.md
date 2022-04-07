# Google's ML Kit for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit)](https://pub.dev/packages/google_mlkit)

Google's ML Kit for Flutter is a set of [Flutter plugins](https://flutter.io/platform-plugins/) that enable [Flutter](https://flutter.dev) apps to use [Google's standalone ML Kit](https://developers.google.com/ml-kit).

In versions `0.7.3` and earlier all features were included in a single plugin, but a lot of developers started to get issues with the size of their app, because even though they needed a single feature, the plugin included all the resources for the rest of the features, that increased the size of the app significantly.

In recent versions we have split the plugin in multiple plugins to allow developers to use only what they need. Start using or migrate to the new plugins. If you find issues report and contribute with your pull requests.

## Features

### Vision APIs

| Feature                                                                                       | Plugin | Android | iOS |
|-----------------------------------------------------------------------------------------------|--------|---------|-----|
|[Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning)               | [google\_ml\_kit\_barcode\_scanning](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_barcode_scanning)                | ✅ | ✅ |
|[Face Detection](https://developers.google.com/ml-kit/vision/face-detection)                   | [google\_ml\_kit\_face\_detection](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_face_detection)                    | ✅ | ✅ |
|[Image Labeling](https://developers.google.com/ml-kit/vision/image-labeling)                   | [google\_ml\_kit\_image\_labeling](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_image_labeling)                    | ✅ | ✅ |
|[Object Detection and Tracking](https://developers.google.com/ml-kit/vision/object-detection)  | [google\_ml\_kit\_object\_detection](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_object_detection)                | ✅ | ✅ |
|[Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition)               | [google\_ml\_kit\_text\_recognition](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_text_recognition)                | ✅ | ✅ |
|[Text Recognition V2](https://developers.google.com/ml-kit/vision/text-recognition/v2)         | [google\_ml\_kit\_text\_recognition](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_text_recognition)                | ✅ | ✅ |
|[Digital Ink Recognition](https://developers.google.com/ml-kit/vision/digital-ink-recognition) | [google\_ml\_kit\_digital\_ink\_recognition](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_digital_ink_recognition) | ✅ | ✅ |
|[Pose Detection](https://developers.google.com/ml-kit/vision/pose-detection)                   | [google\_ml\_kit\_pose\_detection](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_pose_detection)                    | ✅ | ✅ |
|[Selfie Segmentation](https://developers.google.com/ml-kit/vision/selfie-segmentation)         | [google\_ml\_kit\_selfie\_segmentation](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_selfie_segmentation)          | yet | yet |

### Natural Language APIs

| Feature                                                                                       | Plugin | Android | iOS |
|-----------------------------------------------------------------------------------------------|--------|---------|-----|
|[Language Identification](https://developers.google.com/ml-kit/language/identification)        | [google\_ml\_kit\_language\_id](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_language_id)                | ✅ | ✅ |
|[On-Device Translation](https://developers.google.com/ml-kit/language/translation)             | [google\_ml\_kit\_translation](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_translation)                 | ✅ | yet |
|[Smart Reply](https://developers.google.com/ml-kit/language/smart-reply)                       | [google\_ml\_kit\_smart\_reply](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_smart_reply)                | ✅ | yet |
|[Entity Extraction](https://developers.google.com/ml-kit/language/entity-extraction)           | [google\_ml\_kit\_entity\_extraction](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_entity_extraction)    | ✅ | ✅ |

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin).

Go to the documentation of each plugin to learn how to use it.

## Example app

Look at this [example](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit/example) to see the plugin in action.

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
