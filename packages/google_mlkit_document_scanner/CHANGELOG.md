## 0.7.2

* Add `FlutterFramework` dependency to the Swift package manifest for Flutter Swift Package Manager compatibility (issue #916).
* Bump Android Gradle Plugin (AGP) classpath to 9.1.0 to remove vulnerable transitive `netty` dependency from the build classpath.

## 0.7.1

* Lower the minimum iOS deployment target in the Swift package manifest from 15.5 to 15.0, matching the upstream ML Kit SPM package, so the plugin builds with the default `flutter create` deployment target (15.0).

## 0.7.0

* Migrate iOS plugin stub from CocoaPods to Swift Package Manager.
* Update documentation.

## 0.6.1

* Update `google_mlkit_commons` dependency to `^0.13.0`.

## 0.6.0

* Migrate Android plugin build to AGP built-in Kotlin support (`compilerOptions`)
* Bump minimum Flutter SDK constraint to >=3.44.0 and Dart SDK to ^3.12.0

## 0.5.0

* Migrate Android implementation from Java to Kotlin.
* Migrate iOS plugin stub from Objective-C to Swift.
* Bump Android compileSdk to 36 for AGP 9 compatibility.
* Enable support for Apple Silicon simulator on iOS 26+.
* Note: iOS support is still not available.

## 0.4.1

* Update Android native library `com.google.android.gms:play-services-mlkit-document-scanner` to 16.0.0
* Note: iOS support is not available

## 0.4.0

* Increase android sdk compile version to 35
* Updates Java compatibility version to 11

## 0.3.0

* Update README.

## 0.2.1

* Update dependencies.

## 0.2.0

* Update README.

## 0.1.0

* Update README.

## 0.0.1

* Initial release.
