import 'dart:async';

import 'package:flutter/services.dart';

/// Output type for rewriting.
enum RewritingOutputType {
  /// Formal output type.
  formal,

  /// Concise output type.
  concise,

  /// Emoji output type.
  emoji,
}

/// Language for rewriting.
enum RewritingLanguage {
  /// English language.
  english,

  /// Japanese language.
  japanese,

  /// Korean language.
  korean,
}

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

/// A rewriter that rewrites text in different styles.
class Rewriter {
  static const MethodChannel _channel = MethodChannel(
    'google_mlkit_genai_rewriting',
  );

  /// Instance id.
  final String id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Output type for rewriting.
  final RewritingOutputType outputType;

  /// Language for rewriting.
  final RewritingLanguage language;

  /// Constructor to create an instance of [Rewriter].
  Rewriter({required this.outputType, required this.language});

  /// Checks the feature status.
  Future<FeatureStatus> checkFeatureStatus() async {
    final result = await _channel.invokeMethod('genai#checkFeatureStatus', {
      'id': id,
      'outputType': outputType.index,
      'language': language.index,
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
    await _channel.invokeMethod('genai#downloadFeature', {
      'id': id,
      'outputType': outputType.index,
      'language': language.index,
    });
  }

  /// Runs inference with streaming response.
  Stream<String> runInferenceStreaming(String text) {
    final controller = StreamController<String>();
    _channel
        .invokeMethod('genai#runInferenceStreaming', {'id': id, 'text': text})
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
  Future<String> runInference(String text) async {
    final result = await _channel.invokeMethod('genai#runInference', {
      'id': id,
      'text': text,
    });
    return result['text'] as String;
  }

  /// Closes the rewriter and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('genai#closeRewriter', {'id': id});
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
