import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class FaceDetector {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_face_detector');

  /// The options for the face detector.
  final FaceDetectorOptions options;

  FaceDetector({required this.options});

  /// Detects faces in the input image.
  Future<List<Face>> processImage(InputImage inputImage) async {
    final result = await _channel.invokeListMethod<dynamic>(
        'vision#startFaceDetector', <String, dynamic>{
      'options': <String, dynamic>{
        'enableClassification': options.enableClassification,
        'enableLandmarks': options.enableLandmarks,
        'enableContours': options.enableContours,
        'enableTracking': options.enableTracking,
        'minFaceSize': options.minFaceSize,
        'mode': options.mode.name,
      },
      'imageData': inputImage.toJson(),
    });

    final List<Face> faces = <Face>[];
    for (final dynamic json in result!) {
      faces.add(Face(json));
    }

    return faces;
  }

  Future<void> close() =>
      _channel.invokeMethod<void>('vision#closeFaceDetector');
}

/// Immutable options for configuring features of [FaceDetector].
///
/// Used to configure features such as classification, face tracking, speed,
/// etc.
class FaceDetectorOptions {
  /// Constructor for [FaceDetectorOptions].
  ///
  /// The parameter minFaceValue must be between 0.0 and 1.0, inclusive.
  const FaceDetectorOptions({
    this.enableClassification = false,
    this.enableLandmarks = false,
    this.enableContours = false,
    this.enableTracking = false,
    this.minFaceSize = 0.1,
    this.mode = FaceDetectorMode.fast,
  })  : assert(minFaceSize >= 0.0),
        assert(minFaceSize <= 1.0);

  /// Whether to run additional classifiers for characterizing attributes.
  ///
  /// E.g. "smiling" and "eyes open".
  final bool enableClassification;

  /// Whether to detect [FaceLandmark]s.
  final bool enableLandmarks;

  /// Whether to detect [FaceContour]s.
  final bool enableContours;

  /// Whether to enable face tracking.
  ///
  /// If enabled, the detector will maintain a consistent ID for each face when
  /// processing consecutive frames.
  final bool enableTracking;

  /// The smallest desired face size.
  ///
  /// Expressed as a proportion of the width of the head to the image width.
  ///
  /// Must be a value between 0.0 and 1.0.
  final double minFaceSize;

  /// Option for controlling additional accuracy / speed trade-offs.
  final FaceDetectorMode mode;
}

/// Represents a face detected by [FaceDetector].
class Face {
  Face(dynamic json)
      : boundingBox = RectJson.fromJson(json['rect']),
        headEulerAngleX = json['headEulerAngleX'],
        headEulerAngleY = json['headEulerAngleY'],
        headEulerAngleZ = json['headEulerAngleZ'],
        leftEyeOpenProbability = json['leftEyeOpenProbability'],
        rightEyeOpenProbability = json['rightEyeOpenProbability'],
        smilingProbability = json['smilingProbability'],
        trackingId = json['trackingId'],
        landmarks = Map<FaceLandmarkType, FaceLandmark?>.fromIterables(
            FaceLandmarkType.values,
            FaceLandmarkType.values.map((FaceLandmarkType type) {
          final List<dynamic>? pos = json['landmarks'][type.name];
          return (pos == null)
              ? null
              : FaceLandmark(
                  type,
                  Offset(pos[0], pos[1]),
                );
        })),
        contours = Map<FaceContourType, FaceContour?>.fromIterables(
            FaceContourType.values,
            FaceContourType.values.map((FaceContourType type) {
          /// added empty map to pass the tests
          final List<dynamic>? arr =
              (json['contours'] ?? <String, dynamic>{})[type.name];
          return (arr == null)
              ? null
              : FaceContour(
                  type,
                  arr
                      .map<Offset>((dynamic pos) => Offset(pos[0], pos[1]))
                      .toList(),
                );
        }));

  /// The axis-aligned bounding rectangle of the detected face.
  ///
  /// The point (0, 0) is defined as the upper-left corner of the image.
  final Rect boundingBox;

  /// The rotation of the face about the horizontal axis of the image.
  ///
  /// Represented in degrees.
  ///
  /// A face with a positive Euler X angle is turned to the camera's up and down.
  ///
  final double? headEulerAngleX;

  /// The rotation of the face about the vertical axis of the image.
  ///
  /// Represented in degrees.
  ///
  /// A face with a positive Euler Y angle is turned to the camera's right and
  /// to its left.
  ///
  /// The Euler Y angle is guaranteed only when using the "accurate" mode
  /// setting of the face detector (as opposed to the "fast" mode setting, which
  /// takes some shortcuts to make detection faster).
  final double? headEulerAngleY;

  /// The rotation of the face about the axis pointing out of the image.
  ///
  /// Represented in degrees.
  ///
  /// A face with a positive Euler Z angle is rotated counter-clockwise relative
  /// to the camera.
  ///
  /// ML Kit always reports the Euler Z angle of a detected face.
  final double? headEulerAngleZ;

  /// Probability that the face's left eye is open.
  ///
  /// A value between 0.0 and 1.0 inclusive, or null if probability was not
  /// computed.
  final double? leftEyeOpenProbability;

  /// Probability that the face's right eye is open.
  ///
  /// A value between 0.0 and 1.0 inclusive, or null if probability was not
  /// computed.
  final double? rightEyeOpenProbability;

  /// Probability that the face is smiling.
  ///
  /// A value between 0.0 and 1.0 inclusive, or null if probability was not
  /// computed.
  final double? smilingProbability;

  /// The tracking ID if the tracking is enabled.
  ///
  /// Null if tracking was not enabled.
  final int? trackingId;

  /// Gets the landmark based on the provided [FaceLandmarkType].
  ///
  /// Null if landmark was not detected.
  final Map<FaceLandmarkType, FaceLandmark?> landmarks;

  /// Gets the contour based on the provided [FaceContourType].
  ///
  /// Null if contour was not detected.
  final Map<FaceContourType, FaceContour?> contours;
}

/// Represent a face landmark.
///
/// A landmark is a point on a detected face, such as an eye, nose, or mouth.
class FaceLandmark {
  FaceLandmark(this.type, this.position);

  /// The [FaceLandmarkType] of this landmark.
  final FaceLandmarkType type;

  /// Gets a 2D point for landmark position.
  ///
  /// The point (0, 0) is defined as the upper-left corner of the image.
  final Offset position;
}

/// Represent a face contour.
///
/// Contours of facial features.
class FaceContour {
  FaceContour(this.type, this.positionsList);

  /// The [FaceContourType] of this contour.
  final FaceContourType type;

  /// Gets a 2D point [List] for contour positions.
  ///
  /// The point (0, 0) is defined as the upper-left corner of the image.
  final List<Offset> positionsList;
}

/// Option for controlling additional trade-offs in performing face detection.
///
/// Accurate tends to detect more faces and may be more precise in determining
/// values such as position, at the cost of speed.
enum FaceDetectorMode {
  accurate,
  fast,
}

/// Available face landmarks detected by [FaceDetector].
enum FaceLandmarkType {
  bottomMouth,
  rightMouth,
  leftMouth,
  rightEye,
  leftEye,
  rightEar,
  leftEar,
  rightCheek,
  leftCheek,
  noseBase,
}

/// Available face contour types detected by [FaceDetector].
enum FaceContourType {
  face,
  leftEyebrowTop,
  leftEyebrowBottom,
  rightEyebrowTop,
  rightEyebrowBottom,
  leftEye,
  rightEye,
  upperLipTop,
  upperLipBottom,
  lowerLipTop,
  lowerLipBottom,
  noseBridge,
  noseBottom,
  leftCheek,
  rightCheek
}
