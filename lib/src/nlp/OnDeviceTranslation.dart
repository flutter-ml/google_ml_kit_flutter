part of 'NaturalLanguage.dart';

/// Creating an instance of [OnDeviceTranslator]
/// ```
/// final _onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
///      sourceLanguage: TranslateLanguage.ENGLISH,
///      targetLanguage: TranslateLanguage.SPANISH);
/// ```
class OnDeviceTranslator {
  final String _sourceLanguage;
  final String _targetLanguage;

  OnDeviceTranslator._(this._sourceLanguage, this._targetLanguage);
  bool _isOpened = false;
  bool _isClosed = false;

  Future<String> translateText(String text) async {
    _isOpened = true;

    final result = await NaturalLanguage.channel.invokeMethod(
        'nlp#startLanguageTranslator', <String, dynamic>{
      "text": text,
      "source": _sourceLanguage,
      "target": _targetLanguage
    });

    return result.toString();
  }

  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await NaturalLanguage.channel.invokeMethod('nlp#closeLanguageTranslator');
      _isClosed = true;
      _isOpened = false;
    }
  }
}

/// Creating instance of [TranslateLanguageModelManager]
/// ```
/// final _languageModelManager = GoogleMlKit.nlp.
///                               translateLanguageModelManager();;
/// ```
class TranslateLanguageModelManager {
  TranslateLanguageModelManager._();

  /// Checks whether a model is downloaded or not.
  Future<bool> isModelDownloaded(String modelTag) async {
    final result = await NaturalLanguage.channel.invokeMethod(
        "nlp#startLanguageModelManager",
        <String, dynamic>{"task": "check", "model": modelTag});
    return result as bool;
  }

  /// Downloads a model.
  /// Returns `success` if model downloads succesfully or model is already downloaded.
  /// On failing to dowload it throws an error.
  Future<String> downloadModel(String modelTag,
      {bool isWifiRequired = true}) async {
    final result = await NaturalLanguage.channel.invokeMethod(
        "nlp#startLanguageModelManager", <String, dynamic>{
      "task": "download",
      "model": modelTag,
      "wifi": isWifiRequired
    });
    return result.toString();
  }

  /// Deletes a model.
  /// Returns `success` if model is delted successfully or model is not present.
  Future<String> deleteModel(String modelTag) async {
    final result = await NaturalLanguage.channel
        .invokeMethod("nlp#startLanguageModelManager", <String, dynamic>{
      "task": "delete",
      "model": modelTag,
    });
    return result.toString();
  }

  /// Returns a list of all downloaded models.
  /// These are `BCP-47` tags.
  Future<List<String>> getAvailableModels() async {
    final result = await NaturalLanguage.channel
        .invokeMethod("nlp#startLanguageModelManager", <String, dynamic>{
      "task": "getModels",
    });

    var _languages = <String>[];

    for (dynamic data in result) {
      _languages.add(data.toString());
    }
    return _languages;
  }
}

/// Class containg all supported languages and their BCP-47 tags.
class TranslateLanguage {
  static const AFRIKAANS = "af";
  static const ALBANIAN = "sq";
  static const ARABIC = "ar";
  static const BELARUSIAN = "be";
  static const BENGALI = "bn";
  static const BULGARIAN = "bg";
  static const CATALAN = "ca";
  static const CHINESE = "zh";
  static const CROATIAN = "hr";
  static const CZECH = "cs";
  static const DANISH = "da";
  static const DUTCH = "nl";
  static const ENGLISH = "en";
  static const ESPERANTO = "eo";
  static const ESTONIAN = "et";
  static const FINNISH = "fi";
  static const FRENCH = "fr";
  static const GALICIAN = "gl";
  static const GEORGIAN = "ka";
  static const GERMAN = "de";
  static const GREEK = "el";
  static const GUJARATI = "gu";
  static const HAITIAN_CREOLE = "ht";
  static const HEBREW = "he";
  static const HINDI = "hi";
  static const HUNGARIAN = "hu";
  static const ICELANDIC = "is";
  static const INDONESIAN = "id";
  static const IRISH = "ga";
  static const ITALIAN = "it";
  static const JAPANESE = "ja";
  static const KANNADA = "kn";
  static const KOREAN = "ko";
  static const LATVIAN = "lv";
  static const LITHUANIAN = "lt";
  static const MACEDONIAN = "mk";
  static const MALAY = "ms";
  static const MALTESE = "mt";
  static const MARATHI = "mr";
  static const NORWEGIAN = "no";
  static const PERSIAN = "fa";
  static const POLISH = "pl";
  static const PORTUGUESE = "pt";
  static const ROMANIAN = "ro";
  static const RUSSIAN = "ru";
  static const SLOVAK = "sk";
  static const SLOVENIAN = "sl";
  static const SPANISH = "es";
  static const SWAHILI = "sw";
  static const SWEDISH = "sv";
  static const TAGALOG = "tl";
  static const TAMIL = "ta";
  static const TELUGU = "te";
  static const THAI = "th";
  static const TURKISH = "tr";
  static const UKRAINIAN = "uk";
  static const URDU = "ur";
  static const VIETNAMESE = "vi";
  static const WELSH = "cy";
}
