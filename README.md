# Google's ML Kit for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_ml_kit)](https://pub.dev/packages/google_ml_kit)

Google's ML Kit for Flutter is a set of [Flutter plugins](https://flutter.io/platform-plugins/)
that enable [Flutter](https://flutter.dev) apps to use [Google's standalone ML Kit](https://developers.google.com/ml-kit).


## Features

### Vision

| Feature                                                                                       | Plugin | Android | iOS |
|-----------------------------------------------------------------------------------------------|--------|---------|-----|
|[Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition)               | [google\_ml\_kit\_text\_recognition](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit_text_recognition) | ✅      | ✅  |
|[Text Recognition V2](https://developers.google.com/ml-kit/vision/text-recognition/v2)         | [google\_ml\_kit\_text\_recognition](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit_text_recognition) | ✅      | ✅  |
|[Face Detection](https://developers.google.com/ml-kit/vision/face-detection)                   | [google\_ml\_kit\_face\_detection](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit_face_detection) | ✅      | ✅  |
|[Pose Detection](https://developers.google.com/ml-kit/vision/pose-detection)                   | [google\_ml\_kit\_pose\_detection](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit_pose_detection) | ✅      | ✅  |
|[Selfie Segmentation](https://developers.google.com/ml-kit/vision/selfie-segmentation)         | | yet     | yet |
|[Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning)               | [google\_ml\_kit\_barcode\_scanning](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit_barcode_scanning) | ✅      | ✅  |
|[Image Labelling](https://developers.google.com/ml-kit/vision/image-labeling)                  | [google\_ml\_kit\_image\_labeling](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit_image_labeling) | ✅      | ✅  |
|[Object Detection and Tracking](https://developers.google.com/ml-kit/vision/object-detection)  | [google\_ml\_kit\_object\_detection](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit_object_detection) | ✅      | ✅  |
|[Digital Ink Recognition](https://developers.google.com/ml-kit/vision/digital-ink-recognition) | [google\_ml\_kit\_ink\_recognition](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit_ink_recognition) | ✅      | ✅  |

### Natural Language

| Feature                                                                                       | Plugin | Android | iOS |
|-----------------------------------------------------------------------------------------------|--------|---------|-----|
|[Language Identification](https://developers.google.com/ml-kit/language/identification)        | [google\_ml\_kit\_language\_id](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_ml_kit_language_id) | ✅      | ✅  |
|[On-Device Translation](https://developers.google.com/ml-kit/language/translation)             | | ✅      | yet |
|[Smart Reply](https://developers.google.com/ml-kit/language/smart-reply)                       | | ✅      | yet |
|[Entity Extraction](https://developers.google.com/ml-kit/language/entity-extraction)           | | ✅      | yet |


## Requirements

### iOS

- Minimum iOS Deployment Target: 10.0
- Xcode 12 or newer
- Swift 5
- ML Kit only supports 64-bit architectures (x86_64 and arm64). Check this [list](https://developer.apple.com/support/required-device-capabilities/) to see if your device has the required device capabilities.

Since ML Kit does not support 32-bit architectures (i386 and armv7) ([Read mode](https://developers.google.com/ml-kit/migration/ios)), you need to exclude amrv7 architectures in Xcode in order to run `flutter build ios` or `flutter build ipa`.

Go to Project > Runner > Building Settings > Excluded Architectures > Any SDK > armv7

![](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/master/ima/build_settings_01.png)

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

## Known issues

### Android

To reduce the apk size read more about it in issue [#26](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues/26). Also look at [this](https://developers.google.com/ml-kit/tips/reduce-app-size).

### iOS

If you are using this plugin in your app and any other plugin that requires Firebase, there is a known issues you will encounter a dependency error when running `pod install`. To read more about it go to issue [#27](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues/27).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/bharat-biradar/Google-Ml-Kit-plugin/pulls) directly.
