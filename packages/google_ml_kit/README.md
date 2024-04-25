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

| Feature                                                                                        | Plugin                                                                                                                                                                                                                                                       | Android | iOS |
|------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|-----|
| [Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning)               | [google\_mlkit\_barcode\_scanning](https://pub.dev/packages/google_mlkit_barcode_scanning) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_barcode_scanning)](https://pub.dev/packages/google_mlkit_barcode_scanning)                              | ✅      | ✅  |
| [Face Detection](https://developers.google.com/ml-kit/vision/face-detection)                   | [google\_mlkit\_face\_detection](https://pub.dev/packages/google_mlkit_face_detection) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_face_detection)](https://pub.dev/packages/google_mlkit_face_detection)                                      | ✅      | ✅  |
| [Face Mesh Detection](https://developers.google.com/ml-kit/vision/face-mesh-detection)         | [google\_mlkit\_face\_mesh\_detection](https://pub.dev/packages/google_mlkit_face_mesh_detection) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_face_mesh_detection)](https://pub.dev/packages/google_mlkit_face_mesh_detection)                 | ✅      | ❌  |
| [Text Recognition V2](https://developers.google.com/ml-kit/vision/text-recognition/v2)         | [google\_mlkit\_text\_recognition](https://pub.dev/packages/google_mlkit_text_recognition) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_text_recognition)](https://pub.dev/packages/google_mlkit_text_recognition)                              | ✅      | ✅  |
| [Image Labeling](https://developers.google.com/ml-kit/vision/image-labeling)                   | [google\_mlkit\_image\_labeling](https://pub.dev/packages/google_mlkit_image_labeling) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_image_labeling)](https://pub.dev/packages/google_mlkit_image_labeling)                                      | ✅      | ✅  |
| [Object Detection and Tracking](https://developers.google.com/ml-kit/vision/object-detection)  | [google\_mlkit\_object\_detection](https://pub.dev/packages/google_mlkit_object_detection) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_object_detection)](https://pub.dev/packages/google_mlkit_object_detection)                              | ✅      | ✅  |
| [Digital Ink Recognition](https://developers.google.com/ml-kit/vision/digital-ink-recognition) | [google\_mlkit\_digital\_ink\_recognition](https://pub.dev/packages/google_mlkit_digital_ink_recognition) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_digital_ink_recognition)](https://pub.dev/packages/google_mlkit_digital_ink_recognition) | ✅      | ✅  |
| [Pose Detection](https://developers.google.com/ml-kit/vision/pose-detection)                   | [google\_mlkit\_pose\_detection](https://pub.dev/packages/google_mlkit_pose_detection) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_pose_detection)](https://pub.dev/packages/google_mlkit_pose_detection)                                      | ✅      | ✅  |
| [Selfie Segmentation](https://developers.google.com/ml-kit/vision/selfie-segmentation)         | [google\_mlkit\_selfie\_segmentation](https://pub.dev/packages/google_mlkit_selfie_segmentation) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_selfie_segmentation)](https://pub.dev/packages/google_mlkit_selfie_segmentation)                  | ✅      | ✅  |
| [Subject Segmentation](https://developers.google.com/ml-kit/vision/subject-segmentation)       | [google\_mlkit\_subject\_segemtation](https://pub.dev/packages/google_mlkit_subject_segemtation) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_subject_segemtation)](https://pub.dev/packages/google_mlkit_subject_segemtation)                  | ❌      | ❌  |
| [Document Scanner](https://developers.google.com/ml-kit/vision/doc-scanner)                    | [google\_mlkit\_document\_scanner](https://pub.dev/packages/google_mlkit_document_scanner) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_document_scanner)](https://pub.dev/packages/google_mlkit_document_scanner)                              | ✅      | ❌  |

### Natural Language APIs

| Feature                                                                                       | Plugin                                                                                                                                                                                                                              | Android | iOS |
|-----------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|-----|
|[Language Identification](https://developers.google.com/ml-kit/language/identification)        | [google\_mlkit\_language\_id](https://pub.dev/packages/google_mlkit_language_id) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_language_id)](https://pub.dev/packages/google_mlkit_language_id)                         | ✅      | ✅  |
|[On-Device Translation](https://developers.google.com/ml-kit/language/translation)             | [google\_mlkit\_translation](https://pub.dev/packages/google_mlkit_translation) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_translation)](https://pub.dev/packages/google_mlkit_translation)                          | ✅      | ✅  |
|[Smart Reply](https://developers.google.com/ml-kit/language/smart-reply)                       | [google\_mlkit\_smart\_reply](https://pub.dev/packages/google_mlkit_smart_reply) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_smart_reply)](https://pub.dev/packages/google_mlkit_smart_reply)                         | ✅      | ✅  |
|[Entity Extraction](https://developers.google.com/ml-kit/language/entity-extraction)           | [google\_mlkit\_entity\_extraction](https://pub.dev/packages/google_mlkit_entity_extraction) [![Pub Version](https://img.shields.io/pub/v/google_mlkit_entity_extraction)](https://pub.dev/packages/google_mlkit_entity_extraction) | ✅      | ✅  |

## Requirements

### iOS

- Minimum iOS Deployment Target: 12.0
- Xcode 15 or newer
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
$iOSVersion = '12.0'  # or newer version

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

Notice that the minimum `IPHONEOS_DEPLOYMENT_TARGET` is 12.0, you can set it to something newer but not older.

### Android

- minSdkVersion: 21
- targetSdkVersion: 33
- compileSdkVersion: 34

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
