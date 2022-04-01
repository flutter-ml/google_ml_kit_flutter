import 'dart:ui';

import 'package:flutter/services.dart';

///Detector to process the text that is being written on screen.
class DigitalInkRecognizer {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_digital_ink_recognizer');

  bool _isOpened = false;
  bool _isClosed = false;

  ///Function that invokes the method to read the text written on screen.
  ///It takes modelTag that refers to language that is being processed.
  ///Note that modelTag should follow [BCP 47] guidelines of identifying
  ///language visit this site [https://tools.ietf.org/html/bcp47] to know more.
  ///It takes [List<Offset>] which refers to the points being written on screen.
  Future<List<RecognitionCandidate>> readText(
      List<Offset?> points, String modelTag) async {
    _isOpened = true;
    final List<Map<String, dynamic>> pointsList = <Map<String, dynamic>>[];
    for (final point in points) {
      if (point != null) {
        pointsList.add(<String, dynamic>{'x': point.dx, 'y': point.dy});
      }
    }
    final result = await _channel.invokeMethod(
        'vision#startDigitalInkRecognizer',
        <String, dynamic>{'points': pointsList, 'modelTag': modelTag});

    final List<RecognitionCandidate> candidates = <RecognitionCandidate>[];
    for (final dynamic json in result) {
      final candidate = RecognitionCandidate(json);
      candidates.add(candidate);
    }

    _isClosed = false;
    return candidates;
  }

  ///Close the instance of detector.
  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await _channel.invokeMethod('vision#closeDigitalInkRecognizer');
      _isOpened = false;
      _isClosed = true;
    }
  }
}

///Class that manages the language models that are required to process the image.
///Creating an instance of LanguageModelManager.
///
///  LanguageModelManager _languageModelManager = GoogleMlKit.instance.languageModelManager();
class LanguageModelManager {
  static const MethodChannel _channel = DigitalInkRecognizer._channel;

  ///Check if a particular model is downloaded.Takes the language tag as input.The language should be according to the BCP-47 guidelines.
  Future<bool> isModelDownloaded(String modelTag) async {
    final result = await _channel.invokeMethod('vision#manageInkModels',
        <String, dynamic>{'task': 'check', 'modelTag': modelTag});
    return result as bool;
  }

  ///Downloads the model required to process the specified language. If model has been previously downloaded it returns 'exists'.
  ///Else returns success or failure depending on whether the download completes or not.
  ///To see available models visit [https://developers.google.com/ml-kit/vision/digital-ink-recognition/base-models]
  Future<String> downloadModel(String modelTag) async {
    final result = await _channel.invokeMethod('vision#manageInkModels',
        <String, dynamic>{'task': 'download', 'modelTag': modelTag});
    return result.toString();
  }

  ///Delete the model of the language specified in the argument. If model has not been previously downloaded it returns 'not exists'.
  ///Else returns success or failure depending on whether the deletion completes or not.
  Future<String> deleteModel(String modelTag) async {
    final result = await _channel.invokeMethod('vision#manageInkModels',
        <String, dynamic>{'task': 'delete', 'modelTag': modelTag});
    return result.toString();
  }
}

class RecognitionCandidate {
  final String text;
  final double score;

  RecognitionCandidate(dynamic json)
      : text = json['text'],
        score = json['score'];
}
