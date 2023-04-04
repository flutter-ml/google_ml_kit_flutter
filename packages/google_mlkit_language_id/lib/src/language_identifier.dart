import 'package:flutter/services.dart';

/// A class that identifies the main language or possible languages for the given text.
class LanguageIdentifier {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_language_identifier');

  /// This code is returned when no language could be determined.
  final String undeterminedLanguageCode = 'und';

  /// The confidence threshold for language identification.
  /// The identified languages will have a confidence higher or equal to the confidence threshold.
  /// The value should be between 0 and 1.
  final double confidenceThreshold;

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Constructor to create an instance of [IdentifiedLanguage].
  LanguageIdentifier({required this.confidenceThreshold});

  /// Identifies the language of the given [text].
  /// If no language could be determined then [undeterminedLanguageCode] is returned.
  /// More information: https://developers.google.com/ml-kit/language/identification
  Future<String> identifyLanguage(String text) async {
    final result = await _channel.invokeMethod(
        'nlp#startLanguageIdentifier', <String, dynamic>{
      'id': id,
      'text': text,
      'possibleLanguages': false,
      'confidence': confidenceThreshold
    });

    return result.toString();
  }

  /// Identifies the possible languages of the given [text].
  /// If no language could be determined then [undeterminedLanguageCode] is returned.
  /// More information: https://developers.google.com/ml-kit/language/identification
  Future<List<IdentifiedLanguage>> identifyPossibleLanguages(
      String text) async {
    final result = await _channel
        .invokeMethod('nlp#startLanguageIdentifier', <String, dynamic>{
      'id': id,
      'text': text,
      'possibleLanguages': true,
      'confidence': confidenceThreshold
    });

    final languages = <IdentifiedLanguage>[];
    for (final dynamic json in result) {
      languages.add(IdentifiedLanguage.fromJson(json));
    }

    return languages;
  }

  /// Closes the identifier and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('nlp#closeLanguageIdentifier', {'id': id});
}

/// An identified language for the given input text.
class IdentifiedLanguage {
  /// The BCP 47 language tag for the language.
  /// More information: https://tools.ietf.org/rfc/bcp/bcp47.txt
  final String languageTag;

  /// The confidence score of the language.
  final double confidence;

  /// Constructor to create an instance of [IdentifiedLanguage].
  IdentifiedLanguage({required this.languageTag, required this.confidence});

  /// Returns an instance of [IdentifiedLanguage] from a given [json].
  factory IdentifiedLanguage.fromJson(Map<dynamic, dynamic> json) =>
      IdentifiedLanguage(
        languageTag: json['language'],
        confidence: json['confidence'],
      );
}
