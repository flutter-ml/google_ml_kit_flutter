import 'package:flutter/material.dart';

import 'package:flutter/services.dart' as services;
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A face mesh detector that detects a face mesh in a given [InputImage].
class FaceMeshDetector {
  static const services.MethodChannel _channel =
      services.MethodChannel('google_mlkit_face_mesh_detector');

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Options for [FaceMeshDetector].
  final FaceMeshDetectorOptions option;

  /// Constructor to create an instance of [FaceMeshDetector].
  FaceMeshDetector({required this.option});

  /// Processes the given image for face mesh detection.
  Future<List<FaceMesh>> processImage(InputImage inputImage) async {
    final result = await _channel.invokeListMethod<dynamic>(
        'vision#startFaceMeshDetector', <String, dynamic>{
      'id': id,
      'option': option.index,
      'imageData': inputImage.toJson(),
    });

    final List<FaceMesh> meshes = <FaceMesh>[];
    for (final dynamic json in result!) {
      meshes.add(FaceMesh.fromJson(json));
    }

    return meshes;
  }

  /// Closes the detector and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod<void>('vision#closeFaceMeshDetector', {'id': id});
}

/// Represent face mesh detected by [FaceMeshDetector].
class FaceMesh {
  /// Returns the NonNull axis-aligned bounding rectangle of the detected face mesh.
  final Rect boundingBox;

  /// Returns a list of [FaceMeshPoint] representing the whole detected face.
  final List<FaceMeshPoint> points;

  /// Returns a list of [FaceMeshTriangle] representing logical triangle surfaces of detected face.
  final List<FaceMeshTriangle> triangles;

  /// Returns a map with lists of FaceMeshPoint representing a specific contour.
  final Map<FaceMeshContourType, List<FaceMeshPoint>?> contours;

  /// Creates a face mesh.
  FaceMesh(
      {required this.boundingBox,
      required this.points,
      required this.triangles,
      required this.contours});

  /// Returns an instance of [FaceMesh] from a given [json].
  factory FaceMesh.fromJson(Map<dynamic, dynamic> json) => FaceMesh(
        boundingBox: RectJson.fromJson(json['rect']),
        points: json['points']
            .map((element) {
              return FaceMeshPoint.fromJson(element);
            })
            .cast<FaceMeshPoint>()
            .toList(),
        triangles: json['triangles']
            .map((element) {
              return FaceMeshTriangle.fromJson(element);
            })
            .cast<FaceMeshTriangle>()
            .toList(),
        contours: Map<FaceMeshContourType, List<FaceMeshPoint>>.fromIterables(
            FaceMeshContourType.values,
            FaceMeshContourType.values.map((FaceMeshContourType type) {
          final List<dynamic>? arr = (json['contours'] ?? {})[type.index];
          return (arr == null)
              ? []
              : arr
                  .map((element) {
                    return FaceMeshPoint.fromJson(element);
                  })
                  .cast<FaceMeshPoint>()
                  .toList();
        })),
      );
}

/// Represents a 3D point in face mesh, by index and PointF3D.
class FaceMeshPoint {
  /// Gets the index of the face mesh point, ranging from 0 to 467.
  final int index;

  /// Returns the X value of the point.
  final double x;

  /// Returns the Y value of the point.
  final double y;

  /// Returns the Z value of the point.
  final double z;

  /// Creates a face mesh point.
  FaceMeshPoint({
    required this.index,
    required this.x,
    required this.y,
    required this.z,
  });

  /// Returns an instance of [FaceMeshPoint] from a given [json].
  factory FaceMeshPoint.fromJson(Map<dynamic, dynamic> json) => FaceMeshPoint(
        index: json['index'],
        x: json['x'],
        y: json['y'],
        z: json['z'],
      );
}

/// Represents a triangle with 3 generic points.
class FaceMeshTriangle {
  /// Gets all points inside the [FaceMeshTriangle].
  final List<FaceMeshPoint> points;

  /// Creates a triangle with 3 generic points.
  FaceMeshTriangle({required this.points});

  /// Returns an instance of [FaceMeshTriangle] from a given [json].
  factory FaceMeshTriangle.fromJson(List<dynamic> json) => FaceMeshTriangle(
      points: json
          .map((element) {
            return FaceMeshPoint.fromJson(element);
          })
          .cast<FaceMeshPoint>()
          .toList());
}

/// Options for [FaceMeshDetector].
enum FaceMeshDetectorOptions {
  /// Only provides a bounding box for a detected face mesh.
  /// This is the fastest face detector, but has with range limitation(faces must be within ~2 meters or ~7 feet of the camera).
  boundingBoxOnly,

  /// Provides a bounding box and additional face mesh info (468 3D points and triangle info).
  /// When compared to the [boundingBoxOnly] use case, latency increases by ~15%.
  faceMesh,
}

/// Type of face mesh contour.
enum FaceMeshContourType {
  faceOval,
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
}
