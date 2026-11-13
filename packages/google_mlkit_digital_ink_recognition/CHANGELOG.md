## 1.0.3

* Bump `google-mlkit-swiftpm` to `9.0.3` to resolve dependency conflicts with `firebase-ios-sdk` 13 (issue #919).
* Update `Package.resolved` to pin `d-date/google-mlkit-swiftpm` `9.0.3`.
* Update `google_mlkit_commons` dependency to `^1.0.3`.

## 1.0.2

* Add `FlutterFramework` dependency to the Swift package manifest for Flutter Swift Package Manager compatibility (issue #916).
* Bump Android Gradle Plugin (AGP) classpath to 9.1.0 to remove vulnerable transitive `netty` dependency from the build classpath.
* Update `google_mlkit_commons` dependency to `^1.0.2`.

## 1.0.1

* Fix iOS build for apps installing the plugin from pub.dev: the Swift package manifest no longer references `google_mlkit_commons` via a relative path that does not exist in the published layout (issue #912). The small shared helpers are now bundled directly with the plugin, and no `google_mlkit_commons` Swift package dependency is required.
* Note: apps using Swift Package Manager for plugins must set their iOS deployment target to at least 15.0.
* Update `google_mlkit_commons` dependency to `^1.0.1`.

## 1.0.0

* Migrate iOS plugin from CocoaPods to Swift Package Manager (`d-date/google-mlkit-swiftpm` `9.0.2`).
* Fix iOS digital ink recognition score handling when the model omits scores.
* Update `google_mlkit_commons` dependency to `^1.0.0`.
* Update documentation.

## 0.16.1

* Update `google_mlkit_commons` dependency to `^0.13.0`.

## 0.16.0

* Fix method channel name
* Migrate Android plugin build to AGP built-in Kotlin support (`compilerOptions`)
* Bump minimum Flutter SDK constraint to >=3.44.0 and Dart SDK to ^3.12.0

## 0.15.0

* Migrate Android implementation from Java to Kotlin.
* Migrate iOS implementation from Objective-C to Swift.
* Bump Android compileSdk to 36 for AGP 9 compatibility.
* Enable support for Apple Silicon simulator on iOS 26+.

## 0.14.2

* Update Android native library `com.google.mlkit:digital-ink-recognition` to 19.0.0
* Update iOS native library `GoogleMLKit/DigitalInkRecognition` to 9.0.0

## 0.14.1

* Increase android sdk compile version to 35
* Updates Java compatibility version to 11
* Update dependencies.

## 0.13.0

* Update dependencies.
* Update README.

## 0.12.1

* Update dependencies.

## 0.12.0

* Update dependencies.
* Update README.
* Set `platform :ios, '15.5'` in Podfile.

## 0.11.1

* Update README.

## 0.11.0

* Update dependencies.
* Update SDK constraint.

## 0.10.0

* Fix: Update build.gradle, support AGP 8.
* Update README.

## 0.9.0

* Update README.
* Update dependencies.

## 0.8.0

* Update dependencies.

## 0.7.0

* Update dependencies.

## 0.6.0

* Update dependencies.

## 0.5.0

* Update dependencies.

## 0.4.0

* Add `DigitalInkRecognitionContext`.
* Add `WritingArea`.
* Update README.

## 0.3.0

* Allow multiple instances in native layer.
* Update README.

## 0.2.1

* Update `DigitalInkRecognizer` constructor.
* Update README.

## 0.2.0

* Fix: return after closing detector in iOS.
* Allow multiple strokes.

## 0.1.0

* Update documentation.

## 0.0.2

* Fix: Close detector.
* Update documentation.

## 0.0.1+1

* Update readme and example.

## 0.0.1

* Initial release.
