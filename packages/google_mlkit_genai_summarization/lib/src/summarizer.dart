import 'dart:async';

import 'package:flutter/services.dart';

/// Input type for summarization.
enum SummarizationInputType {
  /// Article input type.
  article,

  /// Conversation input type.
  conversation,
}

/// Output type for summarization.
enum SummarizationOutputType {
  /// One bullet point output.
  oneBullet,

  /// Two bullet points output.
  twoBullets,

  /// Three bullet points output.
  threeBullets,
}

/// Language for summarization.
enum SummarizationLanguage {
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

/// A summarizer that generates summaries of articles or conversations.
class Summarizer {
  static const MethodChannel _channel = MethodChannel(
    'google_mlkit_genai_summarization',
  );

  /// Instance id.
  final String id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Input type for summarization.
  final SummarizationInputType inputType;

  /// Output type for summarization.
  final SummarizationOutputType outputType;

  /// Language for summarization.
  final SummarizationLanguage language;

  /// Whether to enable auto truncation for long inputs.
  final bool longInputAutoTruncationEnabled;

  /// Constructor to create an instance of [Summarizer].
  Summarizer({
    required this.inputType,
    required this.outputType,
    required this.language,
    this.longInputAutoTruncationEnabled = false,
  });

  /// Checks the feature status.
  Future<FeatureStatus> checkFeatureStatus() async {
    final result = await _channel.invokeMethod('genai#checkFeatureStatus', {
      'id': id,
      'inputType': inputType.index,
      'outputType': outputType.index,
      'language': language.index,
      'longInputAutoTruncationEnabled': longInputAutoTruncationEnabled,
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
      'inputType': inputType.index,
      'outputType': outputType.index,
      'language': language.index,
      'longInputAutoTruncationEnabled': longInputAutoTruncationEnabled,
    });

    // Note: In a real implementation, these callbacks would be handled
    // through event channels or method channel callbacks.
    // This is a simplified version.
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
          return null;
        });
    return controller.stream;
  }

  /// Runs inference with non-streaming response.
  Future<String> runInference(String text) async {
    final result = await _channel.invokeMethod('genai#runInference', {
      'id': id,
      'text': text,
    });
    return result['summary'] as String;
  }

  /// Closes the summarizer and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('genai#closeSummarizer', {'id': id});
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
