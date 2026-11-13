## 1.0.3

* Bump `google-mlkit-swiftpm` to `9.0.3` to resolve dependency conflicts with `firebase-ios-sdk` 13 (issue #919).
* Update `Package.resolved` to pin `d-date/google-mlkit-swiftpm` `9.0.3`.

## 1.0.2

* Add `FlutterFramework` dependency to the Swift package manifest for Flutter Swift Package Manager compatibility (issue #916).
* Bump Android Gradle Plugin (AGP) classpath to 9.1.0 to remove vulnerable transitive `netty` dependency from the build classpath.

## 1.0.1

* Lower the minimum iOS deployment target in the Swift package manifest from 15.5 to 15.0, matching the upstream ML Kit SPM package, so the plugin builds with the default `flutter create` deployment target (15.0).
* Remove `@objc` attributes from `GenericModelManager` and `VisionImage.visionImage(from:)` to avoid duplicate Objective-C runtime declarations across plugins.

## 1.0.0

* Migrate iOS plugin from CocoaPods to Swift Package Manager (`d-date/google-mlkit-swiftpm` `9.0.2`).
* Fix iOS model download never completing in `GenericModelManager`.
* Update documentation and package description.

## 0.13.0

* Migrate Android plugin build to AGP built-in Kotlin support (`compilerOptions`)
* Bump minimum Flutter SDK constraint to >=3.44.0 and Dart SDK to ^3.12.0

## 0.12.0

* Migrate Android implementation from Java to Kotlin.
* Migrate iOS implementation from Objective-C to Swift.
* Optimize InputImage conversion and enhance image format validation.
* Bump Android compileSdk to 36 for AGP 9 compatibility.
* Enable support for Apple Silicon simulator on iOS 26+.

## 0.11.1

* Update Android native library `com.google.mlkit:vision-common` to 17.3.0
* Update iOS native library `MLKitVision` to 10.0.0

## 0.11.0

* Increase android sdk compile version to 35
* Updates Java compatibility version to 11

## 0.10.0

* Add support for bitmap data with `InputImage.fromBitmap()` constructor.

## 0.9.0

* Update README.

## 0.8.1

* Handle NullPointer Exception in `InputImageConverter.java`
* Fix warnings

## 0.7.2

* Widened image format support for Android
* Improve documentation for image formats

## 0.7.1

* Update README.

## 0.7.0

* Update SDK constraint.

## 0.6.1

* Fix: Update build.gradle, support AGP 8.
* Update README.

## 0.5.0

* Update README: Improve Image rotation for Android.

## 0.4.0

* __BREAKING:__ Update InputImage.
* __BREAKING:__ Rename InputImageData -> InputImageMetadata.
* __BREAKING:__ Remove InputImagePlaneMetadata.
* Only support nv21 for Android and bgra8888 for iOS.

## 0.3.0

* Update dependencies.

## 0.2.0

* Fix: InputImage from file path.

## 0.1.0

* Update iOS dependencies.
* Update documentation.

## 0.0.1+1

* Update readme and example.

## 0.0.1

* Initial release.
