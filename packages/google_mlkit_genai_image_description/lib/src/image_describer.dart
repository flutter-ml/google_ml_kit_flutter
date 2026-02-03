import 'dart:async';

import 'package:flutter/services.dart';

/// Feature status for GenAI APIs.
enum FeatureStatus {
  /// Feature is unavailable.
  unavailable,

  /// Feature is downloadable.
  downloadable,

  /// Feature is currently downloading.
  downloading,

  /// Feature is available.
  available,
}

/// An image describer that generates descriptions for images.
class ImageDescriber {
  static const MethodChannel _channel = MethodChannel(
    'google_mlkit_genai_image_description',
  );

  /// Instance id.
  final String id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Constructor to create an instance of [ImageDescriber].
  ImageDescriber();

  /// Checks the feature status.
  Future<FeatureStatus> checkFeatureStatus() async {
    final result = await _channel.invokeMethod('genai#checkFeatureStatus', {
      'id': id,
    });
    return FeatureStatus.values[result];
  }

  /// Downloads the feature if needed.
  Future<void> downloadFeature({
    void Function(int bytesToDownload)? onDownloadStarted,
    void Function(GenAiException exception)? onDownloadFailed,
    void Function(int totalBytesDownloaded)? onDownloadProgress,
    void Function()? onDownloadCompleted,
  }) async {
    await _channel.invokeMethod('genai#downloadFeature', {'id': id});
  }

  /// Runs inference with streaming response.
  Stream<String> runInferenceStreaming(dynamic imageData) {
    final controller = StreamController<String>();
    _channel
        .invokeMethod('genai#runInferenceStreaming', {
          'id': id,
          'imageData': imageData,
        })
        .then((_) {
          // In a real implementation, this would use an event channel
          // to stream the results incrementally.
        })
        .catchError((error) {
          controller.addError(error);
        });
    return controller.stream;
  }

  /// Runs inference with non-streaming response.
  Future<String> runInference(dynamic imageData) async {
    final result = await _channel.invokeMethod('genai#runInference', {
      'id': id,
      'imageData': imageData,
    });
    return result['description'] as String;
  }

  /// Closes the image describer and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('genai#closeImageDescriber', {'id': id});
}

/// Exception thrown by GenAI APIs.
class GenAiException implements Exception {
  /// Error code.
  final int code;

  /// Error message.
  final String message;

  /// Constructor to create an instance of [GenAiException].
  GenAiException(this.code, this.message);

  @override
  String toString() => 'GenAiException(code: $code, message: $message)';
}
