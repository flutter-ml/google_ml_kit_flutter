import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A detector that performs segmentation on a given [InputImage].
class SelfieSegmenter {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_selfie_segmenter');

  /// The mode for the [Segmenter].
  /// The default value is [SegmenterMode.stream].
  final SegmenterMode mode;

  /// Asks the segmenter to return the raw size mask which matches the model output size.
  // The raw mask size (e.g. 256x256) is usually smaller than the input image size.
  // Without specifying this option, the segmenter will rescale the raw mask to match the input image size.
  // Consider using this option if you want to apply customized rescaling logic or rescaling is not needed for your use case.
  final bool enableRawSizeMask;

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Constructor to create an instance of [SelfieSegmenter].
  SelfieSegmenter({
    this.mode = SegmenterMode.stream,
    this.enableRawSizeMask = false,
  });

  /// Processes the given [InputImage] for segmentation.
  /// Returns the segmentation mask in the given image or nil if there was an error.
  Future<SegmentationMask?> processImage(InputImage inputImage) async {
    final result = await _channel
        .invokeMethod('vision#startSelfieSegmenter', <String, dynamic>{
      'id': id,
      'imageData': inputImage.toJson(),
      'isStream': mode == SegmenterMode.stream,
      'enableRawSizeMask': enableRawSizeMask,
    });

    return result == null ? null : SegmentationMask.fromJson(result);
  }

  /// Closes the detector and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('vision#closeSelfieSegmenter', {'id': id});
}

/// The mode for the [Segmenter].
enum SegmenterMode {
  /// To process a static image.
  /// This mode is designed for single images that are not related.
  /// In this mode, the segmenter will process each image independently, with no smoothing over frames.
  single,

  /// To process a stream of images.
  /// This mode is designed for streaming frames from video or camera.
  /// In this mode, the segmenter will leverage results from previous frames to return smoother segmentation results.
  stream,
}

/// The result from a [Segmenter] operation.
class SegmentationMask {
  /// The width of the mask.
  final int width;

  /// The height of the mask.
  final int height;

  /// The confidence of the pixel in the mask being in the foreground.
  final List<double> confidences;

  /// Constructor to create an instance of [SegmentationMask].
  SegmentationMask({
    required this.width,
    required this.height,
    required this.confidences,
  });

  /// Returns an instance of [SegmentationMask] from a given [json].
  factory SegmentationMask.fromJson(Map<dynamic, dynamic> json) {
    final values = json['confidences'];
    final List<double> confidences = [];
    for (final item in values) {
      confidences.add(double.parse(item.toString()));
    }
    return SegmentationMask(
      width: json['width'] as int,
      height: json['height'] as int,
      confidences: confidences,
    );
  }
}
