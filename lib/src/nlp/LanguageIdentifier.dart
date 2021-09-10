part of 'NaturalLanguage.dart';

class LanguageIdentifier {
  LanguageIdentifier._(this._confidenceThreshold);

  /// This error code is used inside a [PlatformException] to signal that no language could be determined.
  final String errorCodeNoLanguageIdentified = "no language identified";

  final double _confidenceThreshold;
  bool _isOpened = false;
  bool _isClosed = false;

  /// Identifies the language of the given [text].
  /// In no language could be determined, a [PlatformException] with the [errorCodeNoLanguageIdentified] as error code is thrown.
  /// More information: https://developers.google.com/ml-kit/language/identification
  Future<String> identifyLanguage(String text) async {
    _isOpened = true;

    final result = await NaturalLanguage.channel.invokeMethod(
        'nlp#startLanguageIdentifier', <String, dynamic>{
      "text": text,
      "possibleLanguages": "no",
      "confidence": _confidenceThreshold
    });

    return result.toString();
  }

  /// Identifies the possible languages of the given [text].
  /// In no language could be determined, a [PlatformException] with the [errorCodeNoLanguageIdentified] as error code is thrown.
  /// More information: https://developers.google.com/ml-kit/language/identification
  Future<List<IdentifiedLanguage>> identifyPossibleLanguages(
      String text) async {
    _isOpened = true;

    final result = await NaturalLanguage.channel.invokeMethod(
        'nlp#startLanguageIdentifier', <String, dynamic>{
      "text": text,
      "possibleLanguages": "yes",
      "confidence": _confidenceThreshold
    });

    var languages = <IdentifiedLanguage>[];

    for (dynamic languageData in result) {
      languages.add(IdentifiedLanguage(
          languageData['language'], languageData['confidence']));
    }

    return languages;
  }

  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await NaturalLanguage.channel.invokeMethod('nlp#closeLanguageIdentifier');
      _isClosed = true;
      _isOpened = false;
    }
  }
}

class IdentifiedLanguage {
  final String _languageTag;
  final double _confidence;

  IdentifiedLanguage(this._languageTag, this._confidence);

  String get language => _languageTag;
  double get confidence => _confidence;
}

class LanguageInfo {
  static const Map<String, List> BcpMap = {
    'af': ['Afrikaans', 'Latin'],
    'am': ['Amharic', "Ge'ez"],
    'ar': ['Arabic', 'Arabic'],
    'ar-Latn': ['Arabic', 'Latin'],
    'az': ['Azerbaijani', 'Latin'],
    'be': ['Belarusian', 'Cyrillic'],
    'bg': ['Bulgarian', 'Cyrillic'],
    'bg-Latn': ['Bulgarian', 'Latin'],
    'bn': ['Bengali', 'Bengali'],
    'bs': ['Bosnian', 'Latin'],
    'ca': ['Catalan', 'Latin'],
    'ceb': ['Cebuano', 'Latin'],
    'co': ['Corsican', 'Latin'],
    'cs': ['Czech', 'Latin'],
    'cy': ['Welsh', 'Latin'],
    'da': ['Danish', 'Latin'],
    'de': ['German', 'Latin'],
    'el': ['Greek', 'Greek'],
    'el-Latn': ['Greek', 'Latin'],
    'en': ['English', 'Latin'],
    'eo': ['Esperanto', 'Latin'],
    'es': ['Spanish', 'Latin'],
    'et': ['Estonian', 'Latin'],
    'eu': ['Basque', 'Latin'],
    'fa': ['Persian', 'Arabic'],
    'fi': ['Finnish', 'Latin'],
    'fil': ['Filipino', 'Latin'],
    'fr': ['French', 'Latin'],
    'ga': ['Irish', 'Latin'],
    'gl': ['Galician', 'Latin'],
    'gu': ['Gujarati', 'Gujarati'],
    'ha': ['Hausa', 'Latin'],
    'haw': ['Hawaiian', 'Latin'],
    'he': ['Hebrew', 'Hebrew'],
    'hi': ['Hindi', 'Devanagari'],
    'hi-Latn': ['Hindi', 'Latin'],
    'hmn': ['Hmong', 'Latin'],
    'hr': ['Croatian', 'Latin'],
    'ht': ['Haitian', 'Latin'],
    'hu': ['Hungarian', 'Latin'],
    'hy': ['Armenian', 'Armenian'],
    'id': ['Indonesian', 'Latin'],
    'ig': ['Igbo', 'Latin'],
    'is': ['Icelandic', 'Latin'],
    'it': ['Italian', 'Latin'],
    'ja': ['Japanese', 'Japanese'],
    'ja-Latn': ['Japanese', 'Latin'],
    'jv': ['Javanese', 'Latin'],
    'ka': ['Georgian', 'Georgian'],
    'kk': ['Kazakh', 'Cyrillic'],
    'km': ['Khmer', 'Khmer'],
    'kn': ['Kannada', 'Kannada'],
    'ko': ['Korean', 'Korean'],
    'ku': ['Kurdish', 'Latin'],
    'ky': ['Kyrgyz', 'Cyrillic'],
    'la': ['Latin', 'Latin'],
    'lb': ['Luxembourgish', 'Latin'],
    'lo': ['Lao', 'Lao'],
    'lt': ['Lithuanian', 'Latin'],
    'lv': ['Latvian', 'Latin'],
    'mg': ['Malagasy', 'Latin'],
    'mi': ['Maori', 'Latin'],
    'mk': ['Macedonian', 'Cyrillic'],
    'ml': ['Malayalam', 'Malayalam'],
    'mn': ['Mongolian', 'Cyrillic'],
    'mr': ['Marathi', 'Devanagari'],
    'ms': ['Malay', 'Latin'],
    'mt': ['Maltese', 'Latin'],
    'my': ['Burmese', 'Myanmar'],
    'ne': ['Nepali', 'Devanagari'],
    'nl': ['Dutch', 'Latin'],
    'no': ['Norwegian', 'Latin'],
    'ny': ['Nyanja', 'Latin'],
    'pa': ['Punjabi', 'Gurmukhi'],
    'pl': ['Polish', 'Latin'],
    'ps': ['Pashto', 'Arabic'],
    'pt': ['Portuguese', 'Latin'],
    'ro': ['Romanian', 'Latin'],
    'ru': ['Russian', 'Cyrillic'],
    'ru-Latn': ['Russian', 'English'],
    'sd': ['Sindhi', 'Arabic'],
    'si': ['Sinhala', 'Sinhala'],
    'sk': ['Slovak', 'Latin'],
    'sl': ['Slovenian', 'Latin'],
    'sm': ['Samoan', 'Latin'],
    'sn': ['Shona', 'Latin'],
    'so': ['Somali', 'Latin'],
    'sq': ['Albanian', 'Latin'],
    'sr': ['Serbian', 'Cyrillic'],
    'st': ['Sesotho', 'Latin'],
    'su': ['Sundanese', 'Latin'],
    'sv': ['Swedish', 'Latin'],
    'sw': ['Swahili', 'Latin'],
    'ta': ['Tamil', 'Tamil'],
    'te': ['Telugu', 'Telugu'],
    'tg': ['Tajik', 'Cyrillic'],
    'th': ['Thai', 'Thai'],
    'tr': ['Turkish', 'Latin'],
    'uk': ['Ukrainian', 'Cyrillic'],
    'ur': ['Urdu', 'Arabic'],
    'uz': ['Uzbek', 'Latin'],
    'vi': ['Vietnamese', 'Latin'],
    'xh': ['Xhosa', 'Latin'],
    'yi': ['Yiddish', 'Hebrew'],
    'yo': ['Yoruba', 'Latin'],
    'zh': ['Chinese', 'Chinese'],
    'zh-Latn': ['Chinese', 'Latin'],
    'zu': ['Zulu', 'Latin'],
    'fy': ['Western-Frisian', 'Latin'],
    'gd': ['Scots-Gaelic', 'Latin'],
    'und': ['unknow', 'unknown']
  };
}
