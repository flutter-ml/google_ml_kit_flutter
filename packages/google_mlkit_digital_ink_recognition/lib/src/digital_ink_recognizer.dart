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

  /// Refers to language that is being processed.
  //  Note that model should be a BCP 47 language tag from https://developers.google.com/ml-kit/vision/digital-ink-recognition/base-models?hl=en#text
  //  Visit this site [https://tools.ietf.org/html/bcp47] to learn more.
  final String languageCode;

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Constructor to create an instance of [DigitalInkRecognizer].
  DigitalInkRecognizer({required this.languageCode});

  /// Performs a recognition of the text written on screen.
  /// It takes an instance of [Ink] which refers to the user input as a list of [Stroke].
  Future<List<RecognitionCandidate>> recognize(Ink ink,
      {DigitalInkRecognitionContext? context}) async {
    final result = await _channel
        .invokeMethod('vision#startDigitalInkRecognizer', <String, dynamic>{
      'id': id,
      'ink': ink.toJson(),
      'context': context?._isValid == true ? context?.toJson() : null,
      'model': languageCode,
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
      _channel.invokeMethod('vision#closeDigitalInkRecognizer', {'id': id});
}

/// Information about the context in which an ink has been drawn.
/// Pass this object to a [DigitalInkRecognizer] alongside an [Ink] to improve the recognition quality.
class DigitalInkRecognitionContext {
  /// Characters immediately before the position where the recognized text should be inserted.
  final String? preContext;

  /// Size of the writing area.
  final WritingArea? writingArea;

  /// Constructor to create an instance of [DigitalInkRecognitionContext].
  DigitalInkRecognitionContext({this.preContext, this.writingArea});

  bool get _isValid => preContext != null || writingArea != null;

  /// Returns a json representation of an instance of [WritingArea].
  Map<String, dynamic> toJson() => {
        'preContext': preContext,
        'writingArea': writingArea?.toJson(),
      };
}

/// The writing area is the area on the screen where the user can draw an ink.
class WritingArea {
  /// Writing area width, in the same units as used in [StrokePoint].
  final double width;

  /// Writing area height, in the same units as used in [StrokePoint].
  final double height;

  /// Constructor to create an instance of [WritingArea].
  WritingArea({required this.width, required this.height});

  /// Returns a json representation of an instance of [WritingArea].
  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
      };
}

/// Represents the user input as a collection of [Stroke] and serves as input for the handwriting recognition task.
class Ink {
  /// List of strokes composing the ink.
  List<Stroke> strokes = [];

  /// Returns a json representation of an instance of [Ink].
  Map<String, dynamic> toJson() => {
        'strokes': strokes.map((stroke) => stroke.toJson()).toList(),
      };
}

/// Represents a sequence of touch points between a pen (resp. touch) down and pen (resp. touch) up event.
class Stroke {
  /// List of touch points as [Point].
  List<StrokePoint> points = [];

  /// Returns a json representation of an instance of [Stroke].
  Map<String, dynamic> toJson() => {
        'points': points.map((point) => point.toJson()).toList(),
      };
}

/// A single touch point from the user.
class StrokePoint {
  /// Horizontal coordinate. Increases to the right.
  final double x;

  /// Vertical coordinate. Increases downward.
  final double y;

  /// Time when the point was recorded, in milliseconds.
  final int t;

  /// Constructor to create an instance of [StrokePoint].
  StrokePoint({required this.x, required this.y, required this.t});

  /// Returns a json representation of an instance of [StrokePoint].
  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        't': t,
      };
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
