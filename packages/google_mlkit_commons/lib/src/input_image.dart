import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

/// Image format that ML Kit takes to process the image.
class InputImage {
  /// The file path to the image.
  final String? filePath;

  /// The bytes of the image.
  final Uint8List? bytes;

  /// The type of image.
  final InputImageType type;

  /// The image data when creating an image of type = [InputImageType.bytes].
  final InputImageData? inputImageData;

  InputImage._(
      {this.filePath, this.bytes, required this.type, this.inputImageData});

  /// Creates an instance of [InputImage] from path of image stored in device.
  factory InputImage.fromFilePath(String path) {
    return InputImage._(filePath: path, type: InputImageType.file);
  }

  /// Creates an instance of [InputImage] by passing a file.
  factory InputImage.fromFile(File file) {
    return InputImage._(filePath: file.path, type: InputImageType.file);
  }

  /// Creates an instance of [InputImage] using bytes.
  factory InputImage.fromBytes(
      {required Uint8List bytes, required InputImageData inputImageData}) {
    return InputImage._(
        bytes: bytes,
        type: InputImageType.bytes,
        inputImageData: inputImageData);
  }

  /// Returns a json representation of an instance of [InputImage].
  Map<String, dynamic> toJson() => {
        'bytes': bytes,
        'type': type.name,
        'path': filePath,
        'metadata': inputImageData == null ? 'none' : inputImageData!.toJson()
      };
}

/// The type of [InputImage].
enum InputImageType {
  file,
  bytes,
}

/// Data of image required when creating image from bytes.
class InputImageData {
  /// Size of image.
  final Size size;

  /// Image rotation degree.
  final InputImageRotation imageRotation;

  /// Format of the input image.
  final InputImageFormat inputImageFormat;

  /// The plane attributes to create the image buffer on iOS.
  ///
  /// Not used on Android.
  final List<InputImagePlaneMetadata>? planeData;

  /// Constructor to create an instance of [InputImageData].
  InputImageData(
      {required this.size,
      required this.imageRotation,
      required this.inputImageFormat,
      required this.planeData});

  /// Returns a json representation of an instance of [InputImageData].
  Map<String, dynamic> toJson() => {
        'width': size.width,
        'height': size.height,
        'rotation': imageRotation.rawValue,
        'imageFormat': inputImageFormat.rawValue,
        'planeData': planeData
            ?.map((InputImagePlaneMetadata plane) => plane.toJson())
            .toList(),
      };
}

/// Plane attributes to create the image buffer on iOS.
///
/// When using iOS, [height], and [width] throw [AssertionError]
/// if `null`.
class InputImagePlaneMetadata {
  /// The row stride for this color plane, in bytes.
  final int bytesPerRow;

  /// Height of the pixel buffer on iOS.
  final int? height;

  /// Width of the pixel buffer on iOS.
  final int? width;

  /// Constructor to create an instance of [InputImagePlaneMetadata].
  InputImagePlaneMetadata({
    required this.bytesPerRow,
    this.height,
    this.width,
  });

  /// Returns a json representation of an instance of [InputImagePlaneMetadata].
  Map<String, dynamic> toJson() => {
        'bytesPerRow': bytesPerRow,
        'height': height,
        'width': width,
      };
}

/// The camera rotation angle to be specified
enum InputImageRotation {
  rotation0deg,
  rotation90deg,
  rotation180deg,
  rotation270deg
}

extension InputImageRotationValue on InputImageRotation {
  int get rawValue {
    switch (this) {
      case InputImageRotation.rotation0deg:
        return 0;
      case InputImageRotation.rotation90deg:
        return 90;
      case InputImageRotation.rotation180deg:
        return 180;
      case InputImageRotation.rotation270deg:
        return 270;
    }
  }

  static InputImageRotation? fromRawValue(int rawValue) {
    try {
      return InputImageRotation.values
          .firstWhere((element) => element.rawValue == rawValue);
    } catch (_) {
      return null;
    }
  }
}

/// To indicate the format of image while creating input image from bytes
enum InputImageFormat {
  nv21,
  yv12,
  yuv_420_888,
  yuv420,
  bgra8888,
}

extension InputImageFormatValue on InputImageFormat {
  // source: https://developers.google.com/android/reference/com/google/mlkit/vision/common/InputImage#constants
  int get rawValue {
    switch (this) {
      case InputImageFormat.nv21:
        return 17;
      case InputImageFormat.yv12:
        return 842094169;
      case InputImageFormat.yuv_420_888:
        return 35;
      case InputImageFormat.yuv420:
        return 875704438;
      case InputImageFormat.bgra8888:
        return 1111970369;
    }
  }

  static InputImageFormat? fromRawValue(int rawValue) {
    try {
      return InputImageFormat.values
          .firstWhere((element) => element.rawValue == rawValue);
    } catch (_) {
      return null;
    }
  }
}
