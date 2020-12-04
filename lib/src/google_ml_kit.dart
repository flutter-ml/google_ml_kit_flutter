import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'label_detector.dart';

part 'barcode_scanner.dart';

part 'pose_detector.dart';

enum InputImageFormat { NV21, YV21, YUV_420_888 }
enum CustomTrainedModel { asset, file }
enum InputImageRotation {
  Rotation_0deg,
  Rotation_90deg,
  Rotation_180deg,
  Rotation_270deg
}

class GoogleMlKit {
  GoogleMlKit._();

  static const MethodChannel channel = const MethodChannel('google_ml_kit');

  static final GoogleMlKit instance = GoogleMlKit._();

  ImageLabeler imageLabeler([dynamic imageLabelerOptions]) {
    return ImageLabeler._(imageLabelerOptions ?? ImageLabelerOptions());
  }

  BarcodeScanner barcodeScanner([List<int> formatList]) {
    return BarcodeScanner(formats: formatList);
  }

  PoseDetector poseDetector({PoseDetectorOptions poseDetectorOptions}) {
    return PoseDetector(poseDetectorOptions == null
        ? PoseDetectorOptions()
        : poseDetectorOptions);
  }
}

class InputImage {
  InputImage._(
      {String filePath,
      Uint8List bytes,
      @required String imageType,
      InputImageData inputImageData})
      : this.filePath = filePath,
        this.bytes = bytes,
        this.imageType = imageType,
        this.inputImageData = inputImageData;

  factory InputImage.fromFilePath(String path) {
    assert(path != null);
    return InputImage._(filePath: path, imageType: "file");
  }

  factory InputImage.fromFile(File file) {
    assert(file != null);
    return InputImage._(filePath: file.path, imageType: "file");
  }

  factory InputImage.fromBytes(
      {Uint8List bytes, InputImageData inputImageData, String path}) {
    assert(bytes != null);
    assert(inputImageData != null);
    return InputImage._(
        bytes: bytes,
        imageType: "bytes",
        inputImageData: inputImageData,
        filePath: path);
  }

  final String filePath;
  final Uint8List bytes;
  final String imageType;
  final InputImageData inputImageData;

  Map<String, dynamic> _getImageData() {
    var map = <String, dynamic>{
      "bytes": bytes,
      "type": imageType,
      "path": filePath ?? null,
      "metadata": inputImageData == null ? "none" : inputImageData.getMetaData()
    };
    return map;
  }
}

class InputImageData {
  final Size size;
  final InputImageRotation imageRotation;
  final InputImageFormat inputImageFormat;

  InputImageData(
      {this.size,
      this.imageRotation,
      this.inputImageFormat = InputImageFormat.NV21});

  Map<String, dynamic> getMetaData() {
    var map = <String, dynamic>{
      'width': size.width,
      'height': size.height,
      'rotation': _imageRotationToInt(imageRotation),
      'imageFormat': _imageFormatToInt(inputImageFormat)
    };
    return map;
  }
}

int _imageFormatToInt(InputImageFormat inputImageFormat) {
  switch (inputImageFormat) {
    case InputImageFormat.NV21:
      return 17;
    case InputImageFormat.YV21:
      return 35;
    case InputImageFormat.YUV_420_888:
      return 842094169;
    default:
      return 17;
  }
}

int _imageRotationToInt(InputImageRotation inputImageRotation) {
  switch (inputImageRotation) {
    case InputImageRotation.Rotation_0deg:
      return 0;
      break;
    case InputImageRotation.Rotation_90deg:
      return 90;
      break;
    case InputImageRotation.Rotation_180deg:
      return 180;
      break;
    case InputImageRotation.Rotation_270deg:
      return 270;
      break;
    default:
      return 0;
  }
}
