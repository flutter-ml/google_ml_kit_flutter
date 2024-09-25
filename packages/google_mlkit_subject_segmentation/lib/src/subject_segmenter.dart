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

  /// Constructor to create an instance of [FaceDetector].
  SubjectSegmenter({required this.options});

  /// Processes the given [InputImage] for segmentation.
  ///
  /// Sends the [InputImage] data to the natvie platform via the method channel
  /// Returns the segmentation mask in the given image or nil if there was an error.
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

/// Immutable options for configuring features of [FaceDetector].
///
/// Used to configure features such as classification, face tracking, speed,
/// etc.
class SubjectSegmenterOptions {
  /// Constructor for [FaceDetectorOptions].
  ///
  /// The parameter [minFaceSize] must be between 0.0 and 1.0, inclusive.
  SubjectSegmenterOptions({
    this.enableForegroundConfidenceMask = false,
    this.enableForegroundBitmap = false,
    this.enableMultiConfidenceMask = false,
    this.enableMultiSubjectBitmap = false,
  }) : assert(
            (enableForegroundConfidenceMask ? 1 : 0) +
                    (enableForegroundBitmap ? 1 : 0) +
                    (enableMultiConfidenceMask ? 1 : 0) +
                    (enableMultiSubjectBitmap ? 1 : 0) ==
                1,
            'Exactly one option must be true');

  ///
  /// TODO: Comment here
  ///
  final bool enableForegroundConfidenceMask;

  ///
  /// TODO: comment here
  ///
  final bool enableForegroundBitmap;

  ///
  /// TODO: Comment here
  ///
  final bool enableMultiConfidenceMask;

  ///
  ///
  ///
  final bool enableMultiSubjectBitmap;

  /// Returns a json representation of an instance of [SubjectSegmenterOptions].
  Map<String, dynamic> toJson() => {
        'enableForegroundConfidenceMask': enableForegroundConfidenceMask,
        'enableForegroundBitmap': enableForegroundBitmap,
        'enableMultiConfidenceMask': enableMultiConfidenceMask,
        'enableMultiSubjectBitmap': enableMultiSubjectBitmap,
      };

  // Factory constructor to ensure one option is selected if none are provided
  factory SubjectSegmenterOptions.withDefaultOption() {
    return SubjectSegmenterOptions(enableForegroundConfidenceMask: true);
  }

  // Method to validate options
  static bool areOptionsValid({
    bool enableForegroundConfidenceMask = false,
    bool enableForegroundBitmap = false,
    bool enableMultiConfidenceMask = false,
    bool enableMultiSubjectBitmap = false,
  }) {
    return (enableForegroundConfidenceMask ? 1 : 0) +
            (enableForegroundBitmap ? 1 : 0) +
            (enableMultiConfidenceMask ? 1 : 0) +
            (enableMultiSubjectBitmap ? 1 : 0) ==
        1;
  }
}

/// A data class that represents the segmentation mask returned by the [SubjectSegmenterMask]
class SubjectSegmenterMask {
  /// The width of the segmentation mask
  final int width;

  /// The height of the segmentation mask
  final int height;

  /// A list of subjects detected in the image, each respresented by a [Subject] instance
  final List<Subject> subjects;

  /// Constructor to create a instance of [SubjectSegmenterMask].
  ///
  /// The [width] and [height] represent the dimensions of the mark,
  /// and [subjects] is a list of detected subjects
  SubjectSegmenterMask({
    required this.width,
    required this.height,
    required this.subjects,
  });

  /// Returns an instance of [SubjectSegmenterMask] from json
  factory SubjectSegmenterMask.fromJson(Map<dynamic, dynamic> json) {
    final List<dynamic> list = json['subjects'];
    final List<Subject> subjects =
        list.map((json) => Subject.fromJson(json)).toList();
    return SubjectSegmenterMask(
      width: json['width'] as int,
      height: json['height'] as int,
      subjects: subjects,
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
  final List<double> confidences;

  Subject(
      {required this.startX,
      required this.startY,
      required this.subjectWidth,
      required this.subjectHeight,
      required this.confidences});

  /// Creates an instance of [Subject] from a JSON object.
  ///
  /// This factory constructor is used to convert JSON data into a [Subject] object.

  factory Subject.fromJson(Map<dynamic, dynamic> json) {
    return Subject(
        startX: json['startX'] as int,
        startY: json['startY'] as int,
        subjectWidth: json['width'] as int,
        subjectHeight: json['height'] as int,
        confidences: json['confidences']);
  }
}
