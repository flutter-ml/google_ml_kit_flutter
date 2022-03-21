import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit_barcode_scanner/barcode_scanner.dart';
import 'package:google_ml_kit_commons/commons.dart';
import 'package:google_ml_kit_face_detection/face_detector.dart';
import 'package:google_ml_kit_pose_detection/pose_detector.dart';

part 'digital_ink_recognizer.dart';
part 'label_detector.dart';
part 'object_detector.dart';
part 'text_detector.dart';

/// Get instance of the individual api's using instance of [Vision]
/// For example
/// To get an instance of [ImageLabeler]
/// ImageLabeler imageLabeler = GoogleMlKit.instance.imageLabeler();

class Vision {
  Vision._();

  static const MethodChannel channel = MethodChannel('google_ml_kit');

  // Creates an instance of [GoogleMlKit] by calling the private constructor
  static final Vision instance = Vision._();

  /// Get an instance of [ImageLabeler] by calling this function
  /// [imageLabelerOptions]  if not provided it creates [ImageLabeler] with [ImageLabelerOptions]
  /// You can provide either [CustomImageLabelerOptions] to use a custom tflite model
  /// Or [AutoMLImageLabelerOptions] to use auto ml vision model trained by you
  ImageLabeler imageLabeler([dynamic imageLabelerOptions]) {
    return ImageLabeler._(imageLabelerOptions ?? ImageLabelerOptions());
  }

  /// Returns instance of [BarcodeScanner]. By default it searches the input image for all [BarcodeFormat]s.
  /// To limit the search model to specific [BarcodeFormat] pass list of [BarcodeFormat] as argument.
  BarcodeScanner barcodeScanner([List<BarcodeFormat>? formatList]) {
    return BarcodeScanner(formats: formatList);
  }

  /// Returns instance of [PoseDetector].By default it returns all [PoseLandmark] available in image
  /// To limit the result to specific [PoseLandmark] pass list of [PoseLandmark]'s a
  /// All the 33 positions have been declared as static constants in [PoseLandmark] class
  PoseDetector poseDetector({PoseDetectorOptions? poseDetectorOptions}) {
    return PoseDetector(poseDetectorOptions ?? PoseDetectorOptions());
  }

  /// Creates on instance of [LanguageModelManager].
  LanguageModelManager languageModelManager() {
    return LanguageModelManager._();
  }

  /// Returns an instance of [DigitalInkRecogniser]
  DigitalInkRecogniser digitalInkRecogniser() {
    return DigitalInkRecogniser._();
  }

  /// Return an instance of [TextDetector].
  TextDetector textDetector() {
    return TextDetector._();
  }

  /// Return an instance of [FaceDetector].
  FaceDetector faceDetector([FaceDetectorOptions? options]) {
    return FaceDetector(options ?? const FaceDetectorOptions());
  }

  /// Returns an instance of [ObjectDetector].
  ObjectDetector objectDetector(ObjectDetectorOptionsBase options) {
    return ObjectDetector._(options);
  }

  /// returns an instance of [RemoteModelManager].
  RemoteModelManager remoteModelManager() {
    return RemoteModelManager();
  }

  /// Returns an instance of Text Detector v2.
  TextDetectorV2 textDetectorV2() {
    return TextDetectorV2._();
  }
}

/// Class to manage firebase remote models.
class RemoteModelManager {
  Future<bool> isModelDownloaded(String modelName) async {
    final result = await Vision.channel.invokeMethod('vision#manageRemoteModel',
        <String, dynamic>{'task': 'check', 'model': modelName});
    return result as bool;
  }

  /// Downloads a model.
  /// Returns `success` if model downloads successfully or model is already downloaded.
  /// On failing to download it throws an error.
  Future<String> downloadModel(String modelTag,
      {bool isWifiRequired = true}) async {
    final result = await Vision.channel.invokeMethod(
        'vision#manageRemoteModel', <String, dynamic>{
      'task': 'download',
      'model': modelTag,
      'wifi': isWifiRequired
    });
    return result.toString();
  }

  /// Deletes a model.
  /// Returns `success` if model is deleted successfully or model is not present.
  Future<String> deleteModel(String modelTag) async {
    final result = await Vision.channel
        .invokeMethod('vision#manageRemoteModel', <String, dynamic>{
      'task': 'delete',
      'model': modelTag,
    });
    return result.toString();
  }
}
