import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A detector that performs segmentation on a given [InputImage].
class SubjectSegmenter {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_subject_segmentation');

  /// A unique identifier for the segmentation session, generated using the current timestamp
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// The options for the subject segmenter
  final SubjectSegmenterOptions options;

  /// Constructor to create an instance of [SubjectSegmenter].
  SubjectSegmenter({required this.options});

  /// Processes the given [InputImage] for segmentation.
  ///
  /// Sends the [InputImage] data to the natvie platform via the method channel
  /// Returns the segmentation mask in the given image.
  Future<SubjectSegmentationResult> processImage(InputImage inputImage) async {
    final results = await _channel
        .invokeMethod('vision#startSubjectSegmenter', <String, dynamic>{
      'id': id,
      'imageData': inputImage.toJson(),
      'options': options.toJson(),
    });
    // Convert the JSON response from the platform into a SubjectSegmentationResult instance.
    final SubjectSegmentationResult masks =
        SubjectSegmentationResult.fromJson(results);
    return masks;
  }

  /// Closes the detector and releases its resources associated with it.
  ///
  /// This should be called when the detector is no longer needed to free up
  /// system resources on the native side.
  Future<void> close() =>
      _channel.invokeMethod('vision#closeSubjectSegmenter', {'id': id});
}

/// A class to represent options for [SubjectSegmenter].
class SubjectSegmenterOptions {
  /// Constructor to create an instance of [SubjectSegmenterOptions].
  ///
  /// NOTE: To improve memory efficiency, it is recommended to only enable the necessary options.
  SubjectSegmenterOptions({
    required this.enableForegroundBitmap,
    required this.enableForegroundConfidenceMask,
    required this.enableMultipleSubjects,
  });

  /// Enables foreground bitmap in [SubjectSegmentationResult].
  final bool enableForegroundBitmap;

  /// Enables foreground confidence mask in [SubjectSegmentationResult].
  final bool enableForegroundConfidenceMask;

  /// Enables multiple subjects in [SubjectSegmentationResult].
  final SubjectResultOptions enableMultipleSubjects;

  /// Returns a json representation of an instance of [SubjectSegmenterOptions].
  Map<String, dynamic> toJson() => {
        'enableForegroundBitmap': enableForegroundBitmap,
        'enableForegroundConfidenceMask': enableForegroundConfidenceMask,
        'enableMultiSubjectBitmap': enableMultipleSubjects.toJson(),
      };
}

/// A class to represent options for results in [Subject].
class SubjectResultOptions {
  /// Enables confidence mask for segmented [Subject]s.
  final bool enableConfidenceMask;

  /// Enables subject bitmap for segmented [Subject]s.
  final bool enableSubjectBitmap;

  /// Constructor to create an instance of [SubjectResultOptions].
  SubjectResultOptions({
    required this.enableConfidenceMask,
    required this.enableSubjectBitmap,
  });

  /// Returns a json representation of an instance of [SubjectResultOptions].
  Map<String, dynamic> toJson() => {
        'enableConfidenceMask': enableConfidenceMask,
        'enableSubjectBitmap': enableSubjectBitmap,
      };
}

/// A data class that represents the segmentation mask returned by the [SubjectSegmentationResult]
class SubjectSegmentationResult {
  /// Returns the masked bitmap for the input image.
  ///
  /// Returns null if it is not enabled by [SubjectSegmenterOptions.enableForegroundConfidenceMask]
  final Uint8List? foregroundBitmap;

  /// Returns the foreground confidence mask for the input image.
  ///
  /// Returns null if it is not enabled by [SubjectSegmenterOptions.enableForegroundConfidenceMask]
  final List<double>? foregroundConfidenceMask;

  /// Returns all segmented Subjects from the input image.
  ///
  /// Returns an empty list if multiple subjects are not enabled by [SubjectSegmenterOptions.enableMultipleSubjects]
  final List<Subject> subjects;

  /// Constructor to create a instance of [SubjectSegmentationResult].
  SubjectSegmentationResult({
    required this.subjects,
    this.foregroundBitmap,
    this.foregroundConfidenceMask,
  });

  /// Returns an instance of [SubjectSegmentationResult] from json
  factory SubjectSegmentationResult.fromJson(Map<dynamic, dynamic> json) {
    List<Subject>? subjects;
    if (json['subjects'] != null) {
      subjects = (json['subjects'] as List)
          .map((json) => Subject.fromJson(json as Map))
          .toList();
    }
    return SubjectSegmentationResult(
      subjects: subjects ?? [],
      foregroundConfidenceMask: json['foregroundConfidenceMask'],
      foregroundBitmap: json['foregroundBitmap'],
    );
  }
}

/// A data class that represents a detected subject within the segmentation mask.
class Subject {
  /// Returns the starting x-coordinate of this subject in the input image.
  final int startX;

  /// Returns the starting y-coordinate of this subject in the input image.
  final int startY;

  /// Returns the width of this subject.
  final int width;

  /// Returns the height of this subject.
  final int height;

  /// Returns the confidence mask for this subject.
  ///
  /// Returns null if it is not enabled by [SubjectResultOptions.enableConfidenceMask]
  final List<double>? confidenceMask;

  /// Returns the masked bitmap for this subject.
  ///
  /// Returns null if it is not enabled by [SubjectResultOptions.enableSubjectBitmap]
  final Uint8List? bitmap;

  /// Constructor to create a instance of [Subject].
  Subject({
    required this.startX,
    required this.startY,
    required this.width,
    required this.height,
    this.confidenceMask,
    this.bitmap,
  });

  /// Creates an instance of [Subject] from a given json.
  factory Subject.fromJson(Map<dynamic, dynamic> json) => Subject(
        startX: json['startX'] as int,
        startY: json['startY'] as int,
        width: json['width'] as int,
        height: json['height'] as int,
        confidenceMask: json['confidenceMask'],
        bitmap: json['bitmap'],
      );
}
