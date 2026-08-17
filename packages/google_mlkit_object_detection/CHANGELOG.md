## 0.17.1

* Update `google_mlkit_commons` dependency to `^0.13.0`.

## 0.17.0

* Migrate Android plugin build to AGP built-in Kotlin support (`compilerOptions`)
* Bump minimum Flutter SDK constraint to >=3.44.0 and Dart SDK to ^3.12.0

## 0.16.0

* Migrate Android implementation from Java to Kotlin.
* Migrate iOS implementation from Objective-C to Swift.
* Bump Android compileSdk to 36 for AGP 9 compatibility.
* Enable support for Apple Silicon simulator on iOS 26+.

## 0.15.1

* Update Android native library `com.google.mlkit:object-detection` to 17.0.2
* Update Android native library `com.google.mlkit:object-detection-custom` to 17.0.2
* Update iOS native library `GoogleMLKit/ObjectDetection` to 9.0.0
* Update iOS native library `GoogleMLKit/ObjectDetectionCustom` to 9.0.0

## 0.15.0

* Increase android sdk compile version to 35
* Updates Java compatibility version to 11
* Update dependencies.

## 0.14.0

* Update dependencies.
* Update README.

## 0.13.1

* Update dependencies.

## 0.13.0

* Update dependencies.
* Update README.

## 0.12.1

* Update README.

## 0.12.0

* Update dependencies.
* Update SDK constraint.

## 0.11.0

* Fix: Update build.gradle, support AGP 8.
* Update README.

## 0.10.0

* Update path for Custom models.
* Update README with Custom models tutorial.

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
* __BREAKING:__ For remote firebase-hosted models in iOS, you must now explicitly add the `GoogleMLKit/LinkFirebase` pod to your Podfile. The Swift implementation uses `canImport(MLKitLinkFirebase)` (no preprocessor macro required). This removes an unnecessary dependency on FirebaseCore for those who do not need to use remote models. Please see the updated README for instructions.

## 0.4.0

* Fix trackingId for null values.
* Update `ObjectDetectorOptions` constructor.

## 0.3.0

* Allow multiple instances in native layer.

## 0.2.0

* Fix: return after closing detector in iOS.
* Refactor `ObjectDetectorOptions` and subclasses.
* Add example for loading local custom model.

## 0.1.0

* Update documentation.

## 0.0.2

* Fix: Close detector.
* Update documentation.

## 0.0.1

* Initial release.
