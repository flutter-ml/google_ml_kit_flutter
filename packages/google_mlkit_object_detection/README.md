# Google's ML Kit Object Detection and Tracking for Flutter

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_object_detection)](https://pub.dev/packages/google_mlkit_object_detection)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/flutter.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to use [Google's ML Kit Object Detection and Tracking](https://developers.google.com/ml-kit/vision/object-detection) to detect and track objects in an image or live camera feed.

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/flutter-ml/google_ml_kit_flutter/issues):

- [Google's ML Kit](https://developers.google.com/ml-kit) was build only for mobile platforms: iOS and Android apps.

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
- Xcode 13.2.1 or newer
- Swift 5
- ML Kit does not support 32-bit architectures (i386 and armv7). ML Kit does support 64-bit architectures (x86_64 and arm64). Check this [list](https://developer.apple.com/support/required-device-capabilities/) to see if your device has the required device capabilities. More info [here](https://developers.google.com/ml-kit/migration/ios).

Since ML Kit does not support 32-bit architectures (i386 and armv7), you need to exclude armv7 architectures in Xcode in order to run `flutter build ios` or `flutter build ipa`. More info [here](https://developers.google.com/ml-kit/migration/ios).

Go to Project > Runner > Building Settings > Excluded Architectures > Any SDK > armv7

<p align="center" width="100%">
  <img src="https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/resources/build_settings_01.png">
</p>

Your Podfile should look like this:

```ruby
platform :ios, '12.0'  # or newer version

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
- compileSdkVersion: 33

## Usage

### Create an instance of `InputImage`

Create an instance of `InputImage` as explained [here](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons#creating-an-inputimage).

```dart
final InputImage inputImage;
```

### Create an instance of `ObjectDetector`

```dart
// Use DetectionMode.stream when processing camera feed.
// Use DetectionMode.single when processing a single image.
final mode = DetectionMode.stream or DetectionMode.single;

// Options to configure the detector while using with base model.
final options = ObjectDetectorOptions(...);

// Options to configure the detector while using a local custom model.
final options = LocalObjectDetectorOptions(...);

// Options to configure the detector while using a Firebase model.
final options = FirebaseObjectDetectorOptions(...);

final objectDetector = ObjectDetector(options: options);
```

### Process image

```dart
final List<DetectedObject> objects = await objectDetector.processImage(inputImage);

for(DetectedObject detectedObject in objects){
  final rect = detectedObject.boundingBox;
  final trackingId = detectedObject.trackingId;

  for(Label label in detectedObject.labels){
    print('${label.text} ${label.confidence}');
  }
}
```

### Release resources with `close()`

```dart
objectDetector.close();
```

## Models

Object Detection and Tracking can be used with either the Base Model or a [Custom Model](https://developers.google.com/ml-kit/custom-models). The base model is the default model bundled in the SDK, and a custom model can either be bundled with the app as an asset or downloaded from [Firebase](https://firebase.google.com/).

### Base model

To use the base model:

```dart
final options = ObjectDetectorOptions(
  mode: DetectionMode.stream,
  classifyObjects: classifyObjects,
  multipleObjects: multipleObjects,
);
final objectDetector = ObjectDetector(options: options);
```

### Local custom model

Before using a [custom model](https://developers.google.com/ml-kit/custom-models) make sure you read and understand the ML Kit's compatibility requirements for TensorFlow Lite models [here](https://developers.google.com/ml-kit/custom-models#model-compatibility). To learn how to create a custom model that is compatible with ML Kit go [here](https://github.com/flutter-ml/mlkit-custom-model).

To use a local custom model add the [tflite model](https://www.tensorflow.org/lite) to your `pubspec.yaml`:

```yaml
assets:
- assets/ml/
```

Add this method:

```dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getModelPath(String asset) async {
  final path = '${(await getApplicationSupportDirectory()).path}/$asset';
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file.writeAsBytes(byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
  return file.path;
}
```

Create an instance of [ImageLabeler]:

```dart
final modelPath = await getModelPath('assets/ml/object_labeler.tflite');
final options = LocalObjectDetectorOptions(
  mode: DetectionMode.stream,
  modelPath: modelPath,
  classifyObjects: classifyObjects,
  multipleObjects: classifyObjects,
);
final objectDetector = ObjectDetector(options: options);
```

#### Android Additional Setup

Add the following to your app's build.gradle file to ensure Gradle doesn't compress the model file when building the app:

```groovy
android {
    // ...
    aaptOptions {
        noCompress "tflite"
        // or noCompress "lite"
    }
}
```

### Firebase model

Google's standalone ML Kit library does **NOT** have any direct dependency with Firebase. As designed by Google, you do NOT need to include Firebase in your project in order to use ML Kit. However, to use a remote model hosted in Firebase, you must setup Firebase in your project following these steps:

- [Android](https://firebase.google.com/docs/android/setup)
- [iOS](https://firebase.google.com/docs/ios/setup)

#### iOS Additional Setup

Additionally, for iOS you have to update your app's Podfile.

First, include `GoogleMLKit/LinkFirebase` and `Firebase` in your Podfile:

```ruby
platform :ios, '12.0'

...

# Enable firebase-hosted models #
pod 'GoogleMLKit/LinkFirebase'
pod 'Firebase'
```

Next, add the preprocessor flag to enable the firebase remote models at compile time. To do that, update your existing `build_configurations` loop in the `post_install` step with the following:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    ... # Here are some configurations automatically generated by flutter

    target.build_configurations.each do |config|
      # Enable firebase-hosted ML models
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'MLKIT_FIREBASE_MODELS=1',
      ]
    end
  end
end
```

#### Usage

To use a Firebase model:

```dart
final options = FirebaseObjectDetectorOptions(
  mode: DetectionMode.stream,
  modelName: modelName,
  classifyObjects: classifyObjects,
  multipleObjects: classifyObjects,
);
final objectDetector = ObjectDetector(options: options);
```

#### Managing Firebase models

Create an instance of model manager

```dart
final modelManager = FirebaseObjectDetectorModelManager();
```

To check if a model is downloaded:

```dart
final bool response = await modelManager.isModelDownloaded(modelName);
```

To download a model:

```dart
final bool response = await modelManager.downloadModel(modelName);
```

To delete a model:

```dart
final bool response = await modelManager.deleteModel(modelName);
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
