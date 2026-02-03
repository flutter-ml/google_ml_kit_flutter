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

/// A speech recognizer that transcribes speech to text.
class SpeechRecognizer {
  static const MethodChannel _channel = MethodChannel(
    'google_mlkit_genai_speech_recognition',
  );

  /// Instance id.
  final String id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Constructor to create an instance of [SpeechRecognizer].
  SpeechRecognizer();

  /// Checks the feature status.
  Future<FeatureStatus> checkStatus() async {
    final result = await _channel.invokeMethod('genai#checkStatus', {'id': id});
    return FeatureStatus.values[result];
  }

  /// Starts speech recognition.
  Stream<String> startRecognition() {
    final controller = StreamController<String>();
    _channel
        .invokeMethod('genai#startRecognition', {'id': id})
        .then((_) {
          // In a real implementation, this would use an event channel
          // to stream the recognition results incrementally.
        })
        .catchError((error) {
          controller.addError(error);
        });
    return controller.stream;
  }

  /// Stops speech recognition.
  Future<void> stopRecognition() async {
    await _channel.invokeMethod('genai#stopRecognition', {'id': id});
  }

  /// Closes the speech recognizer and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('genai#closeSpeechRecognizer', {'id': id});
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
