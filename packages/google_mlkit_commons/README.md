# google_mlkit_commons

[![Pub Version](https://img.shields.io/pub/v/google_mlkit_commons)](https://pub.dev/packages/google_mlkit_commons)
[![analysis](https://github.com/flutter-ml/google_ml_kit_flutter/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/flutter-ml/google_ml_kit_flutter/actions)
[![Star on Github](https://img.shields.io/github/stars/flutter-ml/google_ml_kit_flutter.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/flutter-ml/google_ml_kit_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin with common methods used in [google_ml_kit](https://github.com/flutter-ml/google_ml_kit_flutter).

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

#### Apple Silicon iOS Simulator (iOS 26+)

Google's `GoogleMLKit/*` pods only ship `arm64-iphoneos` and `x86_64-iphonesimulator` slices and exclude `arm64` from simulator builds. On Apple Silicon Macs running iOS 26+ simulators (where Rosetta 2 is no longer the default for the iOS Simulator) this makes `flutter run` fail with `Unable to find a destination matching the provided destination specifier`. Issue tracked upstream by Google: https://issuetracker.google.com/issues/178965151.

Until proper `arm64-iphonesimulator` slices are published, this plugin ships an **opt-in** Podfile helper that, on every build, relabels the arm64 slice's `LC_BUILD_VERSION.platform` to match the target you are building for — iOS Simulator for simulator builds, iOS for device builds (the same swap used by the well-known [`arm64-to-sim`](https://github.com/bogo/arm64-to-sim) tool). It also strips `EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64` from the generated xcconfigs.

To enable it, add two lines to your iOS `Podfile`:

```ruby
# Near the top, after `require ... podhelper ...`:
require File.expand_path(
  '.symlinks/plugins/google_mlkit_commons/ios/scripts/apple_silicon_simulator',
  __dir__,
)

post_install do |installer|
  # ...your existing post_install code...

  # Add this line at the end:
  mlkit_apple_silicon_simulator_patch(installer)
end
```

Then re-run `pod install`. The example app under `packages/example` is wired up this way.

Because the relabel runs per build and matches the target automatically, the same `pod install` works for **both** the simulator and physical devices — no manual revert is needed when you switch between them. The helper only touches the arm64 slice of the vendored ML Kit binaries inside `Pods/` and the `EXCLUDED_ARCHS` line in pod-generated xcconfigs. To fully revert, remove the two lines and reinstall the pods with `pod deintegrate && pod install` (a plain `pod install` re-adds the `EXCLUDED_ARCHS` line and removes the build phase, but does not restore the original platform label baked into the cached binaries by the last build).

### Android

- minSdkVersion: 21
- targetSdkVersion: 35
- compileSdkVersion: 35

**⚠️ Production Disclaimer:** Using this plugin in production is the responsibility of the developers consuming the plugin, not the authors. The authors provide this plugin as-is and are not responsible for any issues, failures, or compatibility problems that may arise from using this plugin in production environments.

## Usage

### Creating an `InputImage`

From path:

```dart
final inputImage = InputImage.fromFilePath(filePath);
```

From file:

```dart
final inputImage = InputImage.fromFile(file);
```

From bytes:

```dart
final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);
```

from bitmap data:

```dart
final ui.Image image = await recorder.endRecording().toImage(width, height);
final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
final InputImage inputImage = InputImage.fromBitmap(
  bitmap: byteData!.buffer.asUint8List(),
  width: width,
  height: height,
  rotation: 0, // optional, defaults to 0, only used on Android
);
```

If you are using the [Camera plugin](https://pub.dev/packages/camera) make sure to configure your [CameraController](https://pub.dev/documentation/camera/latest/camera/CameraController-class.html) to only use `ImageFormatGroup.nv21` for Android and `ImageFormatGroup.bgra8888` for iOS.

Notice that the image rotation is computed in a different way for both iOS and Android. Image rotation is used in Android to convert the `InputImage` [from Dart to Java](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java), but it is not used in iOS to convert [from Dart to Obj-C](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m). However, image rotation and `camera.lensDirection` can be used in both platforms to [compensate x and y coordinates on a canvas](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart).

```dart
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter/services.dart';

final camera; // your camera instance
final controller = CameraController(
  camera,
  ResolutionPreset.max,
  enableAudio: false,
  imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // for Android
          : ImageFormatGroup.bgra8888, // for iOS
);

final _orientations = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

InputImage? _inputImageFromCameraImage(CameraImage image) {
  // get image rotation
  // it is used in android to convert the InputImage from Dart to Java
  // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
  // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
  final camera = _cameras[_cameraIndex];
  final sensorOrientation = camera.sensorOrientation;
  InputImageRotation? rotation;
  if (Platform.isIOS) {
    rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  } else if (Platform.isAndroid) {
    var rotationCompensation =
        _orientations[_controller!.value.deviceOrientation];
    if (rotationCompensation == null) return null;
    if (camera.lensDirection == CameraLensDirection.front) {
      // front-facing
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      // back-facing
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
    }
    rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
  }
  if (rotation == null) return null;

  // get image format
  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  // validate format depending on platform
  // only supported formats:
  // * nv21 for Android
  // * bgra8888 for iOS
  if (format == null ||
          (Platform.isAndroid && format != InputImageFormat.nv21) ||
          (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

  // since format is constraint to nv21 or bgra8888, both only have one plane
  if (image.planes.length != 1) return null;
  final plane = image.planes.first;

  // compose InputImage using bytes
  return InputImage.fromBytes(
    bytes: plane.bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation, // used only in Android
      format: format, // used only in iOS
      bytesPerRow: plane.bytesPerRow, // used only in iOS
    ),
  );
}

CameraImage image; // your image from camera/controller image stream
final inputImage = _inputImageFromCameraImage(image);
```

## Example app

Find the example app [here](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/flutter-ml/google_ml_kit_flutter/pulls) directly.
