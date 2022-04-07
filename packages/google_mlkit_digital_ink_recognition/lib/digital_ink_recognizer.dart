import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/commons.dart';

///Detector to process the text that is being written on screen.
class DigitalInkRecognizer {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_digital_ink_recognizer');

  ///Function that invokes the method to read the text written on screen.
  ///It takes modelTag that refers to language that is being processed.
  ///Note that modelTag should follow [BCP 47] guidelines of identifying
  ///language visit this site [https://tools.ietf.org/html/bcp47] to know more.
  ///It takes [List<Offset>] which refers to the points being written on screen.
  Future<List<RecognitionCandidate>> readText(
      List<Offset?> points, String modelTag) async {
    final List<Map<String, dynamic>> pointsList = <Map<String, dynamic>>[];
    for (final point in points) {
      if (point != null) {
        pointsList.add(<String, dynamic>{'x': point.dx, 'y': point.dy});
      }
    }
    final result = await _channel.invokeMethod(
        'vision#startDigitalInkRecognizer',
        <String, dynamic>{'points': pointsList, 'model': modelTag});

    final List<RecognitionCandidate> candidates = <RecognitionCandidate>[];
    for (final dynamic json in result) {
      final candidate = RecognitionCandidate(json);
      candidates.add(candidate);
    }

    return candidates;
  }

  ///Close the instance of detector.
  Future<void> close() =>
      _channel.invokeMethod('vision#closeDigitalInkRecognizer');
}

///Class that manages the language models that are required to process the image.
///Creating an instance of DigitalInkRecognizerModelManager.
class DigitalInkRecognizerModelManager extends ModelManager {
  DigitalInkRecognizerModelManager()
      : super(
            channel: DigitalInkRecognizer._channel,
            method: 'vision#manageInkModels');
}

class RecognitionCandidate {
  final String text;
  final double score;

  RecognitionCandidate(dynamic json)
      : text = json['text'],
        score = json['score'];
}
