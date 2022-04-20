import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A detector that processes the input image and return list of [PoseLandmark].
///
/// To gt an instance of the class
/// create [PoseDetectorOptions]
/// ```dart
///  final options = PoseDetectorOptions(
///    poseDetectionModel: PoseDetectionModel.AccuratePoseDetector,
///     poseDetectionMode: PoseDetectionMode.StaticImage);
///   //  Note : [PoseDetectorOptions] is optional parameter,if not given it gives [PoseDetector] with default options
///   PoseDetector poseDetector = GoogleMlKit.instance.poseDetector();
/// ```
class PoseDetector {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_pose_detector');

  final PoseDetectorOptions options;

  PoseDetector({required this.options});

  /// Process the image and returns a map where key denotes [PoseLandmark] i.e location. Value contains the info of the PoseLandmark i.e
  Future<List<Pose>> processImage(InputImage inputImage) async {
    final result = await _channel.invokeMethod(
        'vision#startPoseDetector', <String, dynamic>{
      'options': options.toJson(),
      'imageData': inputImage.toJson()
    });

    final List<Pose> poses = [];
    for (final pose in result) {
      final Map<PoseLandmarkType, PoseLandmark> landmarks = {};
      for (final point in pose) {
        final landmark = PoseLandmark.fromJson(point);
        landmarks[landmark.type] = landmark;
      }
      poses.add(Pose(landmarks));
    }

    return poses;
  }

  Future<void> close() => _channel.invokeMethod('vision#closePoseDetector');
}

/// [PoseDetectorOptions] determines the parameters on which [PoseDetector] works
class PoseDetectorOptions {
  /// enum PoseDetectionModel default is set to Base Pose Detector Model.
  final PoseDetectionModel model;

  /// enum PoseDetectionMode, currently only static supported.
  final PoseDetectionMode mode;

  PoseDetectorOptions(
      {this.model = PoseDetectionModel.base,
      this.mode = PoseDetectionMode.stream});

  Map<String, dynamic> toJson() => {
        'type': PoseDetectionModel.base.name,
        'mode': PoseDetectionMode.single.name,
      };
}

// enum to specify whether to use base pose model or accurate posed model
// To know differences between these two visit this [https://developers.google.com/ml-kit/vision/pose-detection/android] site
enum PoseDetectionModel {
  base,
  accurate,
}

// To decide whether you want to process a static image and wait for a future
// or stream image please note feature to stream image is not yet available and will be implemented in the future
enum PoseDetectionMode {
  single,
  stream,
}

enum LandmarkSelectionType {
  all,
  specific,
}

/// Available pose landmarks detected by [PoseDetector].
enum PoseLandmarkType {
  nose,
  leftEyeInner,
  leftEye,
  leftEyeOuter,
  rightEyeInner,
  rightEye,
  rightEyeOuter,
  leftEar,
  rightEar,
  leftMouth,
  rightMouth,
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftPinky,
  rightPinky,
  leftIndex,
  rightIndex,
  leftThumb,
  rightThumb,
  leftHip,
  rightHip,
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
  leftHeel,
  rightHeel,
  leftFootIndex,
  rightFootIndex
}

class Pose {
  Pose(this.landmarks);

  final Map<PoseLandmarkType, PoseLandmark> landmarks;
}

/// This gives the [Offset] information as to where pose landmarks are locates in image.
class PoseLandmark {
  PoseLandmark(
    this.type,
    this.x,
    this.y,
    this.z,
    this.likelihood,
  );

  final PoseLandmarkType type;

  /// Gives x coordinate of landmark in image frame.
  final double x;

  /// Gives y coordinate of landmark in image frame.
  final double y;

  /// Gives z coordinate of landmark in image space.
  final double z;

  /// Gives the likelihood of this landmark being in the image frame.
  final double likelihood;

  factory PoseLandmark.fromJson(Map<dynamic, dynamic> json) {
    return PoseLandmark(
      PoseLandmarkType.values[json['type']],
      json['x'],
      json['y'],
      json['z'],
      json['likelihood'] ?? 0.0,
    );
  }
}
