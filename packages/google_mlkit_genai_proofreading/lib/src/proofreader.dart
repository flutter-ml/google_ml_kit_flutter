import 'dart:async';

import 'package:flutter/services.dart';

/// Input type for proofreading.
enum ProofreadingInputType {
  /// Keyboard input type.
  keyboard,

  /// Voice input type.
  voice,
}

/// Language for proofreading.
enum ProofreadingLanguage {
  /// English language.
  english,

  /// Japanese language.
  japanese,

  /// French language.
  french,

  /// German language.
  german,

  /// Italian language.
  italian,

  /// Spanish language.
  spanish,

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

/// A proofreading result.
class ProofreadingResult {
  /// The corrected text.
  final String text;

  /// Confidence score (0.0 to 1.0).
  final double confidence;

  /// Constructor to create an instance of [ProofreadingResult].
  ProofreadingResult({required this.text, required this.confidence});

  /// Returns an instance of [ProofreadingResult] from a given [json].
  factory ProofreadingResult.fromJson(Map<dynamic, dynamic> json) {
    return ProofreadingResult(
      text: json['text'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

/// A proofreader that checks grammar and spelling.
class Proofreader {
  static const MethodChannel _channel = MethodChannel(
    'google_mlkit_genai_proofreading',
  );

  /// Instance id.
  final String id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Input type for proofreading.
  final ProofreadingInputType inputType;

  /// Language for proofreading.
  final ProofreadingLanguage language;

  /// Constructor to create an instance of [Proofreader].
  Proofreader({required this.inputType, required this.language});

  /// Checks the feature status.
  Future<FeatureStatus> checkFeatureStatus() async {
    final result = await _channel.invokeMethod('genai#checkFeatureStatus', {
      'id': id,
      'inputType': inputType.index,
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
      'inputType': inputType.index,
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
          return null;
        });
    return controller.stream;
  }

  /// Runs inference with non-streaming response.
  Future<List<ProofreadingResult>> runInference(String text) async {
    final result = await _channel.invokeMethod('genai#runInference', {
      'id': id,
      'text': text,
    });
    final List<dynamic> results = result['results'] as List<dynamic>;
    return results.map((json) => ProofreadingResult.fromJson(json)).toList();
  }

  /// Closes the proofreader and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('genai#closeProofreader', {'id': id});
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
