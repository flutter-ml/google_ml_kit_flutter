# Google's ML Kit for Flutter

Google's ML Kit for Flutter is a set of [Flutter plugins](https://flutter.io/platform-plugins/) that enable [Flutter](https://flutter.dev) apps to use [Google's standalone ML Kit](https://developers.google.com/ml-kit).

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
|[Selfie Segmentation](https://developers.google.com/ml-kit/vision/selfie-segmentation)         | [google\_mlkit\_selfie\_segmentation](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_selfie_segmentation)          | yet | yet |

### Natural Language APIs

| Feature                                                                                       | Plugin | Android | iOS |
|-----------------------------------------------------------------------------------------------|--------|---------|-----|
|[Language Identification](https://developers.google.com/ml-kit/language/identification)        | [google\_mlkit\_language\_id](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_language_id)                | ✅ | ✅ |
|[On-Device Translation](https://developers.google.com/ml-kit/language/translation)             | [google\_mlkit\_translation](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_translation)                 | ✅ | ✅ |
|[Smart Reply](https://developers.google.com/ml-kit/language/smart-reply)                       | [google\_mlkit\_smart\_reply](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_smart_reply)                | ✅ | ✅ |
|[Entity Extraction](https://developers.google.com/ml-kit/language/entity-extraction)           | [google\_mlkit\_entity\_extraction](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_entity_extraction)    | ✅ | ✅ |

## Requirements

### iOS

- Minimum iOS Deployment Target: 10.0
- Xcode 13 or newer
- Swift 5
- ML Kit only supports 64-bit architectures (x86_64 and arm64). Check this [list](https://developer.apple.com/support/required-device-capabilities/) to see if your device has the required device capabilities.

Since ML Kit does not support 32-bit architectures (i386 and armv7) ([Read mode](https://developers.google.com/ml-kit/migration/ios)), you need to exclude amrv7 architectures in Xcode in order to run `flutter build ios` or `flutter build ipa`.

Go to Project > Runner > Building Settings > Excluded Architectures > Any SDK > armv7

![](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/resources/build_settings_01.png)

Then your Podfile should look like this:

```
# add this line:
$iOSVersion = '10.0'

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

Notice that the minimum `IPHONEOS_DEPLOYMENT_TARGET` is 10.0, you can set it to something newer but not older.

### Android

- minSdkVersion: 21
- targetSdkVersion: 29

## Migrating from ML Kit for Firebase

When Migrating from ML Kit for Firebase read [this guide](https://developers.google.com/ml-kit/migration). For Android details read [this](https://developers.google.com/ml-kit/migration/android). For iOS details read [this](https://developers.google.com/ml-kit/migration/ios).

## Example app

Find the example app [here](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
