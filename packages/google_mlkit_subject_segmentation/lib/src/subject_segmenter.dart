import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A detector that performs segmentation on a given [InputImage].
class SubjectSegmenter {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_subject_segmentation');

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Processes the given [InputImage] for segmentation.
  /// Returns the segmentation mask in the given image or nil if there was an error.
  Future<SubjectSegmenterMask> processImage(InputImage inputImage) async {
    final results = await _channel
        .invokeMethod('vision#startSubjectSegmenter', <String, dynamic>{
      'id': id,
      'imageData': inputImage.toJson(),
    });
    SubjectSegmenterMask masks = SubjectSegmenterMask.fromJson(results);
    return masks;
  }

  /// Closes the detector and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('vision#closeSubjectSegmenter', {'id': id});
}

class SubjectSegmenterMask {
  final int width;

  final int height;

  final List<Subject> subjects;

  /// Constructir to create a instance of [SubjectSegmenterMask].
  SubjectSegmenterMask({
    required this.width,
    required this.height,
    required this.subjects,
  });

  /// Returns an instance of [SubjectSegmenterMask] from json
  factory SubjectSegmenterMask.fromJson(Map<dynamic, dynamic> json) {
    List<dynamic> list = json['subjects'];
    List<Subject> subjects = list.map((e) => Subject.fromJson(e)).toList();
    return SubjectSegmenterMask(
      width: json['width'] as int,
      height: json['height'] as int,
      subjects: subjects,
    );
  }
}

class Subject {
  final int startX;
  final int startY;
  final int subjectWidth;
  final int subjectHeight;
  final List<double> confidences;

  Subject(
      {required this.startX,
      required this.startY,
      required this.subjectWidth,
      required this.subjectHeight,
      required this.confidences});

  factory Subject.fromJson(Map<dynamic, dynamic> json) {
    return Subject(
        startX: json['startX'] as int,
        startY: json['startY'] as int,
        subjectWidth: json['width'] as int,
        subjectHeight: json['height'] as int,
        confidences: json['confidences']);
  }

  Map<dynamic, dynamic> toJson() {
    return {
      "startX": startX,
      "startY": startY,
      "subjectWidth": subjectWidth,
      "subjectHeight": subjectHeight,
      "confidences": confidences,
    };
  }
}
