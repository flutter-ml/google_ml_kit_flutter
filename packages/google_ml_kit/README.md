# Google's ML Kit for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_ml_kit)](https://pub.dev/packages/google_ml_kit)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Google's ML Kit for Flutter is a set of [Flutter plugins](https://flutter.io/platform-plugins/) that enable [Flutter](https://flutter.dev) apps to use [Google's standalone ML Kit](https://developers.google.com/ml-kit).

> `google_ml_kit` is an umbrella plugin that includes all the features listed below, it groups all the plugins under a single one. By using `google_ml_kit` you will include all the plugins listed below and their respective dependencies, therefore significantly increasing the size of your app. We recommend instead to add only the plugin for the feature you want to consume rather than including `google_ml_kit` in your yaml.
>
> DO NOT USE `google_ml_kit` in a production app instead use only the plugin(s) for the features listed bellow.

Go to each plugin listed bellow to read about their documentation and requirements. If you find issues report and contribute with your pull requests.

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

## Requirements

### iOS

- Minimum iOS Deployment Target: 15.5
- Xcode 15.3.0 or newer
- Swift 5
- ML Kit does not support 32-bit architectures (i386 and armv7). ML Kit does support 64-bit architectures (x86_64 and arm64). Check this [list](https://developer.apple.com/support/required-device-capabilities/) to see if your device has the required device capabilities. More info [here](https://developers.google.com/ml-kit/migration/ios).

Since ML Kit does not support 32-bit architectures (i386 and armv7), you need to exclude armv7 architectures in Xcode in order to run `flutter build ios` or `flutter build ipa`. More info [here](https://developers.google.com/ml-kit/migration/ios).

Go to Project > Runner > Building Settings > Excluded Architectures > Any SDK > armv7

<p align="center" width="100%">
  <img src="https://raw.githubusercontent.com/flutter-ml/google_ml_kit_flutter/master/resources/build_settings_01.png">
</p>

Your Podfile should look like this:

```ruby
platform :ios, '15.5'  # or newer version

...

# add this line:
$iOSVersion = '15.5'  # or newer version

post_install do |installer|
  # add these lines:
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=*]"] = "armv7"
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iOSVersion
  end

  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    # add these lines:
    target.build_configurations.each do |config|
      if Gem::Version.new($iOSVersion) > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iOSVersion
      end
    end

  end
end
```

Notice that the minimum `IPHONEOS_DEPLOYMENT_TARGET` is 15.5, you can set it to something newer but not older.

### Android

- minSdkVersion: 21
- targetSdkVersion: 35
- compileSdkVersion: 35

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
