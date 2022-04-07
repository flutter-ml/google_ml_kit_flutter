import 'package:flutter/services.dart';

class LanguageIdentifier {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_language_identifier');

  /// This error code is used to signal that no language could be determined.
  final String errorCodeNoLanguageIdentified = 'und';

  final double confidenceThreshold;

  LanguageIdentifier({required this.confidenceThreshold});

  /// Identifies the language of the given [text].
  /// In no language could be determined, the [errorCodeNoLanguageIdentified] error code is returned.
  /// More information: https://developers.google.com/ml-kit/language/identification
  Future<String> identifyLanguage(String text) async {
    final result = await _channel.invokeMethod(
        'nlp#startLanguageIdentifier', <String, dynamic>{
      'text': text,
      'possibleLanguages': false,
      'confidence': confidenceThreshold
    });

    return result.toString();
  }

  /// Identifies the possible languages of the given [text].
  /// In no language could be determined, the [errorCodeNoLanguageIdentified] as error code is returned.
  /// More information: https://developers.google.com/ml-kit/language/identification
  Future<List<IdentifiedLanguage>> identifyPossibleLanguages(
      String text) async {
    final result = await _channel.invokeMethod(
        'nlp#startLanguageIdentifier', <String, dynamic>{
      'text': text,
      'possibleLanguages': true,
      'confidence': confidenceThreshold
    });

    final languages = <IdentifiedLanguage>[];
    for (final dynamic json in result) {
      languages.add(IdentifiedLanguage(json));
    }

    return languages;
  }

  Future<void> close() => _channel.invokeMethod('nlp#closeLanguageIdentifier');
}

class IdentifiedLanguage {
  final String languageCode;
  final double confidence;

  IdentifiedLanguage(dynamic json)
      : languageCode = json['language'],
        confidence = json['confidence'];
}
