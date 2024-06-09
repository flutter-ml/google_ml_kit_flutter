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
  Future<List<SubjectSegmenterMask>> processImage(InputImage inputImage) async {
    List<dynamic> results = await _channel
        .invokeMethod('vision#startSubjectSegmentation', <String, dynamic>{
      'id': id,
      'imageData': inputImage.toJson(),
    });

    List<SubjectSegmenterMask> masks =
        results.map((e) => SubjectSegmenterMask.fromJson(e)).toList();
    return masks;
  }

  /// Closes the detector and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('vision#closeSubjectSegmentation', {'id': id});
}

class SubjectSegmenterMask {
  /// The width of the mask.
  final int width;

  /// The height of the mask.
  final int height;

  /// The confidence of the pixel in the mask being in the foreground.
  final List<double> confidences;

  /// Constructir to create a instance of [SubjectSegmenterMask].
  SubjectSegmenterMask({
    required this.width,
    required this.height,
    required this.confidences,
  });

  /// Returns an instance of [SubjectSegmenterMask] from json
  factory SubjectSegmenterMask.fromJson(Map<String, dynamic> json) {
    final values = json['confidences'];
    final List<double> confidences = [];
    for (final item in values) {
      confidences.add(double.parse(item.toString()));
    }
    return SubjectSegmenterMask(
      width: json['width'] as int,
      height: json['height'] as int,
      confidences: confidences,
    );
  }
}
