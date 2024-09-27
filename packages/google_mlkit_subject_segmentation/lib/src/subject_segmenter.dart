// ignore_for_file: unnecessary_lambdas

import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import '../google_mlkit_subject_segmentation.dart';

/// A detector that performs segmentation on a given [InputImage].
class SubjectSegmenter {
  /// A platform channel used to communicate with native code for segmentation
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_subject_segmentation');

  /// A unique identifier for the segmentation session, generated using the current timestamp
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// The options for the subject segmenter
  final SubjectSegmenterOptions options;

  /// Constructor to create an instance of [SubjectSegmention].
  SubjectSegmenter({required this.options});

  /// Processes the given [InputImage] for segmentation.
  ///
  /// Sends the [InputImage] data to the natvie platform via the method channel
  /// Returns the segmentation mask in the given image.
  Future<SubjectSegmenterMask> processImage(InputImage inputImage) async {
    final results = await _channel
        .invokeMethod('vision#startSubjectSegmenter', <String, dynamic>{
      'id': id,
      'imageData': inputImage.toJson(),
      'options': options.toJson(),
    });
    // Convert the JSON response from the platform into a SubjectSegmenterMask instance.
    final SubjectSegmenterMask masks = SubjectSegmenterMask.fromJson(results);
    return masks;
  }

  /// Closes the detector and releases its resources associated with it.
  ///
  /// This should be called when the detector is no longer needed to free up
  /// system resources on the native side.
  Future<void> close() =>
      _channel.invokeMethod('vision#closeSubjectSegmenter', {'id': id});
}

/// Immutable options for configuring features of [SubjectSegmention].
///
/// Used to configure features such as foreground confidence mask, foreground bitmap, multi confidence mask
/// or multi subject bitmap
class SubjectSegmenterOptions {
  /// Constructor for [SubjectSegmenterOptions].
  ///
  /// The parameter to enable options
  /// NOTE: To improve memory efficiency, it is recommended to only enable the necessary options.
  SubjectSegmenterOptions({
    this.enableForegroundConfidenceMask = true,
    this.enableForegroundBitmap = false,
    this.enableMultiConfidenceMask = false,
    this.enableMultiSubjectBitmap = false,
  });

  ///
  /// Enables foreground confidence mask.
  final bool enableForegroundConfidenceMask;

  ///
  /// Enables foreground bitmap
  final bool enableForegroundBitmap;

  ///
  /// Enables confidence mask for segmented Subjects
  final bool enableMultiConfidenceMask;

  ///
  /// Enables subject bitmap for segmented Subjects.
  final bool enableMultiSubjectBitmap;

  /// Returns a json representation of an instance of [SubjectSegmenterOptions].
  Map<String, dynamic> toJson() => {
        'enableForegroundConfidenceMask': enableForegroundConfidenceMask,
        'enableForegroundBitmap': enableForegroundBitmap,
        'enableMultiConfidenceMask': enableMultiConfidenceMask,
        'enableMultiSubjectBitmap': enableMultiSubjectBitmap,
      };
}

/// A data class that represents the segmentation mask returned by the [SubjectSegmenterMask]
class SubjectSegmenterMask {
  /// The width of the segmentation mask
  final int width;

  /// The height of the segmentation mask
  final int height;

  /// The masked bitmap for the input image
  final Uint8List? bitmap;

  /// A list of forground confidence mask for the input image
  final List<double>? confidences;

  /// A list of subjects detected in the image, each respresented by a [Subject] instance
  final List<Subject>? subjects;

  /// Constructor to create a instance of [SubjectSegmenterMask].
  SubjectSegmenterMask({
    required this.width,
    required this.height,
    this.subjects,
    this.bitmap,
    this.confidences,
  });

  /// Returns an instance of [SubjectSegmenterMask] from json
  factory SubjectSegmenterMask.fromJson(Map<dynamic, dynamic> json) {
    List<Subject>? subjects;
    if (json['subjects'] != null) {
      subjects =
          json['subjects'].map((json) => Subject.fromJson(json)).toList();
    }
    return SubjectSegmenterMask(
      width: json['width'] as int,
      height: json['height'] as int,
      subjects: subjects,
      confidences: json['confidences'],
      bitmap: json['bitmap'],
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
  final int subjectWidth;

  /// Returns the height of this subject.
  final int subjectHeight;

  /// A list of confidence values for the detected subject.
  final List<double>? confidences;

  /// The masked bitmap of the subject
  final Uint8List? bitmap;

  Subject({
    required this.startX,
    required this.startY,
    required this.subjectWidth,
    required this.subjectHeight,
    this.confidences,
    this.bitmap,
  });

  /// Creates an instance of [Subject] from a JSON object.
  ///
  /// This factory constructor is used to convert JSON data into a [Subject] object.
  factory Subject.fromJson(Map<dynamic, dynamic> json) {
    return Subject(
      startX: json['startX'] as int,
      startY: json['startY'] as int,
      subjectWidth: json['width'] as int,
      subjectHeight: json['height'] as int,
      confidences: json['confidences'],
      bitmap: json['bitmap'],
    );
  }
}
