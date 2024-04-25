# Google's ML Kit On-Device Translation for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_translation)](https://pub.dev/packages/google_mlkit_translation)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit On-Device Translation](https://developers.google.com/ml-kit/language/translation) to dynamically translate text between more than 50 languages.

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/flutter-ml/google_ml_kit_flutter/issues):

- [Google's ML Kit](https://developers.google.com/ml-kit) was build only for mobile platforms: iOS and Android apps. Web or any other platform is not supported, you can request support for those platform to Google in [their repo](https://github.com/googlesamples/mlkit/issues).

- This plugin is not sponsored or maintained by Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) are developers excited about Machine Learning that wanted to expose Google's native APIs to Flutter.

- Google's ML Kit APIs are only developed natively for iOS and Android. This plugin uses Flutter Platform Channels as explained [here](https://docs.flutter.dev/development/platform-integration/platform-channels).

  Messages are passed between the client (the app/plugin) and host (platform) using platform channels as illustrated in this diagram:

  <p align="center" width="100%">
    <img src="https://docs.flutter.dev/assets/images/docs/PlatformChannels.png"> 
  </p>

  Messages and responses are passed asynchronously, to ensure the user interface remains responsive. To read more about platform channels go [here](https://docs.flutter.dev/development/platform-integration/platform-channels).

  Because this plugin uses platform channels, no Machine Learning processing is done in Flutter/Dart, all the calls are passed to the native platform using `MethodChannel` in Android and `FlutterMethodChannel` in iOS, and executed using Google's native APIs. Think of this plugin as a bridge between your app and Google's native ML Kit APIs. This plugin only passes the call to the native API and the processing is done by Google's API. It is important that you understand this concept when it comes to debugging errors for your ML model and/or app.

- Since the plugin uses platform channels, you may encounter issues with the native API. Before submitting a new issue, identify the source of the issue. You can run both iOS and/or Android native [example apps by Google](https://github.com/googlesamples/mlkit) and make sure that the issue is not reproducible with their native examples. If you can reproduce the issue in their apps then report the issue to Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) do not have access to the source code of their native APIs, so you need to report the issue to them. If you find that their example apps are okay and still you have an issue using this plugin, then look at our [closed and open issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues). If you cannot find anything that can help you then report the issue and provide enough details. Be patient, someone from the community will eventually help you.

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

### Usage guidelines for ML Kit on-device translation

In order to use Google's on-device Translation API in your application, you need to comply with the following guidelines. These guidelines may change from time to time, and without prior notice from Google. Your continued use of the on-device Translation API is contingent upon your adherence to these guidelines. If you're uncomfortable with any of these branding guidelines, discontinue your use of the API and [contact Google](https://developers.google.com/ml-kit/community) with your concerns. See more about the usage guidelines [here](https://developers.google.com/ml-kit/language/translation/translation-terms).

### Supported languages

ML Kit can translate between the following [languages](https://developers.google.com/ml-kit/language/translation/translation-language-support).

## Usage

### On-Device Translation

#### Create an instance of `OnDeviceTranslator`

```dart
final TranslateLanguage sourceLanguage;
final TranslateLanguage targetLanguage;

final onDeviceTranslator = OnDeviceTranslator(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage);
```

#### Process text

```dart
final String response = await onDeviceTranslator.translateText(text);
```

Make sure you download both source and target language models before translating any text.

#### Release resources with `close()`

```dart
onDeviceTranslator.close();
```

### Managing remote models

#### Create an instance of model manager

```dart
final modelManager = OnDeviceTranslatorModelManager();
```

#### Check if model is downloaded

```dart
final bool response = await modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);
```

#### Download model

```dart
final bool response = await modelManager.downloadModel(TranslateLanguage.english.bcpCode);
```

#### Delete model

```dart
final bool response = await modelManager.deleteModel(TranslateLanguage.english.bcpCode);
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing
                         
Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
