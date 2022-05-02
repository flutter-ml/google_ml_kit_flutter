import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A detector for performing body-pose estimation.
class PoseDetector {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_pose_detector');

  /// The options for the pose detector.
  final PoseDetectorOptions options;

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Constructor to create an instance of [PoseDetector].
  PoseDetector({required this.options});

  /// Processes the given [InputImage] for pose detection.
  /// It returns a list of [Pose].
  Future<List<Pose>> processImage(InputImage inputImage) async {
    final result = await _channel.invokeMethod(
        'vision#startPoseDetector', <String, dynamic>{
      'options': options.toJson(),
      'id': id,
      'imageData': inputImage.toJson()
    });

    final List<Pose> poses = [];
    for (final pose in result) {
      final Map<PoseLandmarkType, PoseLandmark> landmarks = {};
      for (final point in pose) {
        final landmark = PoseLandmark.fromJson(point);
        landmarks[landmark.type] = landmark;
      }
      poses.add(Pose(landmarks: landmarks));
    }

    return poses;
  }

  /// Closes the detector and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('vision#closePoseDetector', {'id': id});
}

/// Determines the parameters on which [PoseDetector] works.
class PoseDetectorOptions {
  /// Specifies whether to use base or accurate pose model.
  final PoseDetectionModel model;

  /// The mode for the pose detector.
  final PoseDetectionMode mode;

  /// Constructor to create an instance of [PoseDetectorOptions].
  PoseDetectorOptions(
      {this.model = PoseDetectionModel.base,
      this.mode = PoseDetectionMode.stream});

  /// Returns a json representation of an instance of [PoseDetectorOptions].
  Map<String, dynamic> toJson() => {
        'model': model.name,
        'mode': mode.name,
      };
}

// Specifies whether to use base or accurate pose model.
enum PoseDetectionModel {
  /// Base pose detector with streaming.
  base,

  /// Accurate pose detector on static images.
  accurate,
}

/// The mode for the pose detector.
enum PoseDetectionMode {
  /// To process a static image. This mode is designed for single images where the detection of each image is independent.
  single,

  /// To process a stream of images. This mode is designed for streaming frames from video or camera.
  stream,
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

/// Describes a pose detection result.
class Pose {
  /// A map of all the landmarks in the detected pose.
  final Map<PoseLandmarkType, PoseLandmark> landmarks;

  /// Constructor to create an instance of [Pose].
  Pose({required this.landmarks});
}

/// A landmark in a pose detection result.
class PoseLandmark {
  /// The landmark type.
  final PoseLandmarkType type;

  /// Gives x coordinate of landmark in image frame.
  final double x;

  /// Gives y coordinate of landmark in image frame.
  final double y;

  /// Gives z coordinate of landmark in image space.
  final double z;

  /// Gives the likelihood of this landmark being in the image frame.
  final double likelihood;

  /// Constructor to create an instance of [PoseLandmark].
  PoseLandmark({
    required this.type,
    required this.x,
    required this.y,
    required this.z,
    required this.likelihood,
  });

  /// Returns an instance of [PoseLandmark] from a given [json].
  factory PoseLandmark.fromJson(Map<dynamic, dynamic> json) {
    return PoseLandmark(
      type: PoseLandmarkType.values[json['type'].toInt()],
      x: json['x'],
      y: json['y'],
      z: json['z'],
      likelihood: json['likelihood'] ?? 0.0,
    );
  }
}
