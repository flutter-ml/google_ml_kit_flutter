## 0.5.0

* Update dependencies.

## 0.4.0

* Update dependencies.
* __BREAKING:__ For remote firebase-hosted models in iOS, you must now explicitly add the `GoogleMLKit/LinkFirebase` pod and preprocessor flag to your Podfile. This removes an unnecessary dependency on FirebaseCore for those who do not need to use remote models. Please see the updated README for instructions.

## 0.3.0

* Allow multiple instances in native layer.

## 0.2.0

* Fix: return after closing detector in iOS.
* Refactor `ImageLabelerOptions` and subclasses.
* Add example for loading local custom model.

## 0.1.0

* Update documentation.

## 0.0.2

* Fix: Close detector.
* Update documentation.

## 0.0.1

* Initial release.
