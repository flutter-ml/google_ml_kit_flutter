import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

part 'barcode_scanner.dart';

part 'digital_ink_recognizer.dart';

part 'face_detector.dart';

part 'label_detector.dart';

part 'pose_detector.dart';

part 'text_detector.dart';

// To indicate the format of image while creating input image from bytes
enum InputImageFormat { NV21, YV12, YUV_420_888 }

//To specify whether tflite models are stored in asset directory or file stored in device
enum CustomTrainedModel { asset, file }

//The camera rotation angle to be specified
enum InputImageRotation {
  Rotation_0deg,
  Rotation_90deg,
  Rotation_180deg,
  Rotation_270deg
}

///Get instance of the individual api's using instance of [Vision]
///For example
///To get an instance of [ImageLabeler]
///ImageLabeler imageLabeler = GoogleMlKit.instance.imageLabeler();

class Vision {
  Vision._();

  static const MethodChannel channel = MethodChannel('google_ml_kit');

  //Creates an instance of [GoogleMlKit] by calling the private constructor
  static final Vision instance = Vision._();

  ///Get an instance of [ImageLabeler] by calling this function
  /// [imageLabelerOptions]  if not provided it creates [ImageLabeler] with [ImageLabelerOptions]
  /// You can provide either [CustomImageLabelerOptions] to use a custom tflite model
  /// Or [AutoMLImageLabelerOptions] to use auto ml vision model trained by you
  ImageLabeler imageLabeler([dynamic imageLabelerOptions]) {
    return ImageLabeler._(imageLabelerOptions ?? ImageLabelerOptions());
  }

  ///Returns instance of [BarcodeScanner].By default it searches the input image for all [BarcodeFormat]
  ///To limit the search model to specific [BarcodeFormat] pass list of [BarcodeFormat] as arguement
  ///All the supported formats have been declared as static constants in [Barcode] class
  BarcodeScanner barcodeScanner([List<int>? formatList]) {
    return BarcodeScanner(formats: formatList);
  }

  ///Returns instance of [PoseDetector].By default it returns all [PoseLandmark] available in image
  ///To limit the result to specific [PoseLandmark] pass list of [PoseLandmark]'s a
  ///All the 33 positions have been declared as static constants in [PoseLandmark] class
  PoseDetector poseDetector({PoseDetectorOptions? poseDetectorOptions}) {
    return PoseDetector(poseDetectorOptions ?? PoseDetectorOptions());
  }

  ///Creates on instance of [LanguageModelManager].
  LanguageModelManager languageModelManager() {
    return LanguageModelManager._();
  }

  ///Returns an instance of [DigitalInkRecogniser]
  DigitalInkRecogniser digitalInkRecogniser() {
    return DigitalInkRecogniser._();
  }

  ///Return an instance of [TextDetector].
  TextDetector textDetector() {
    return TextDetector._();
  }

  ///Return an instance of [FaceDetector].
  FaceDetector faceDetector([FaceDetectorOptions? options]) {
    return FaceDetector._(options ?? const FaceDetectorOptions());
  }

}

///[InputImage] is the format Google' Ml kit takes to process the image
class InputImage {
  InputImage._(
      {String? filePath,
      Uint8List? bytes,
      required String imageType,
      InputImageData? inputImageData})
      : filePath = filePath,
        bytes = bytes,
        imageType = imageType,
        inputImageData = inputImageData;

  ///Create InputImage from path of image stored in device.
  factory InputImage.fromFilePath(String path) {
    return InputImage._(filePath: path, imageType: 'file');
  }

  ///Create InputImage by passing a file.
  factory InputImage.fromFile(File file) {
    return InputImage._(filePath: file.path, imageType: 'file');
  }

  ///Create InputImage using bytes.
  factory InputImage.fromBytes(
      {required Uint8List bytes,
      required InputImageData inputImageData}) {
    return InputImage._(
        bytes: bytes,
        imageType: 'bytes',
        inputImageData: inputImageData);
  }

  final String? filePath;
  final Uint8List? bytes;
  final String imageType;
  final InputImageData? inputImageData;

  Map<String, dynamic> _getImageData() {
    var map = <String, dynamic>{
      'bytes': bytes,
      'type': imageType,
      'path': filePath,
      'metadata':
          inputImageData == null ? 'none' : inputImageData!.getMetaData()
    };
    return map;
  }
}

///Data of image required when creating image from bytes.
class InputImageData {
  ///Size of image.
  final Size? size;

  ///Image rotation degree.
  final InputImageRotation? imageRotation;

  ///Format of the input image.
  final InputImageFormat inputImageFormat;

  InputImageData(
      {this.size,
      this.imageRotation,
      this.inputImageFormat = InputImageFormat.NV21});

  ///Function to get the metadata of image processing purposes
  Map<String, dynamic> getMetaData() {
    var map = <String, dynamic>{
      'width': size?.width,
      'height': size?.height,
      'rotation': _imageRotationToInt(imageRotation),
      'imageFormat': _imageFormatToInt(inputImageFormat)
    };
    return map;
  }
}

// source: https://developers.google.com/android/reference/com/google/mlkit/vision/common/InputImage#constants
int _imageFormatToInt(InputImageFormat inputImageFormat) {
  switch (inputImageFormat) {
    case InputImageFormat.NV21:
      return 17;
    case InputImageFormat.YV12:
      return 842094169;
    case InputImageFormat.YUV_420_888:
      return 35;
    default:
      return 17;
  }
}

///Function to convert enum [InputImageRotation] to integer value.
int _imageRotationToInt(InputImageRotation? inputImageRotation) {
  switch (inputImageRotation) {
    case InputImageRotation.Rotation_0deg:
      return 0;
    case InputImageRotation.Rotation_90deg:
      return 90;
    case InputImageRotation.Rotation_180deg:
      return 180;
    case InputImageRotation.Rotation_270deg:
      return 270;
    default:
      return 0;
  }
}
