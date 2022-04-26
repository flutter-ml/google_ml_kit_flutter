import 'dart:math';

import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A class to perform handwriting recognition on digital ink.
///
/// Digital ink is the vector representation of what a user has written.
/// It is composed of a sequence of strokes, each being a sequence of touch points (coordinates and timestamp).
class DigitalInkRecognizer {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_digital_ink_recognizer');

  /// Performs a recognition of the text written on screen.
  /// It takes a list of [Point] which refers to the points being written on screen.
  /// It takes the [model] that refers to language that is being processed.
  /// Note that [model] should be a BCP 47 language tag.
  /// Visit this site [https://tools.ietf.org/html/bcp47] to learn more.
  Future<List<RecognitionCandidate>> recognize(
      List<Point<int>> points, String model) async {
    final List<Map<String, dynamic>> pointsList = <Map<String, dynamic>>[];
    for (final point in points) {
      pointsList.add(<String, dynamic>{
        'x': point.x,
        'y': point.y,
      });
    }
    final result = await _channel
        .invokeMethod('vision#startDigitalInkRecognizer', <String, dynamic>{
      'points': pointsList,
      'model': model,
    });

    final List<RecognitionCandidate> candidates = <RecognitionCandidate>[];
    for (final dynamic json in result) {
      final candidate = RecognitionCandidate.fromJson(json);
      candidates.add(candidate);
    }

    return candidates;
  }

  /// Closes the recognizer and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('vision#closeDigitalInkRecognizer');
}

/// A subclass of [ModelManager] that manages [DigitalInkRecognitionModel] required to process the image.
class DigitalInkRecognizerModelManager extends ModelManager {
  /// Constructor to create an instance of [DigitalInkRecognizerModelManager].
  DigitalInkRecognizerModelManager()
      : super(
            channel: DigitalInkRecognizer._channel,
            method: 'vision#manageInkModels');
}

/// Individual recognition candidate.
class RecognitionCandidate {
  /// The textual representation of this candidate.
  final String text;

  /// Score of the candidate. Values may be positive or negative.
  ///
  /// More likely candidates get lower values. This value is populated only for models that support it.
  /// Scores are meant to be used to reject candidates whose score is above a threshold.
  /// A particular threshold value for a given application will stay valid after a model update.
  final double score;

  /// Constructor to create an instance of [RecognitionCandidate].
  RecognitionCandidate({required this.text, required this.score});

  /// Returns an instance of [RecognitionCandidate] from a given [json].
  factory RecognitionCandidate.fromJson(Map<dynamic, dynamic> json) =>
      RecognitionCandidate(
        text: json['text'],
        score: json['score'],
      );
}
