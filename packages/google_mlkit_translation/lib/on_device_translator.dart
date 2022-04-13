import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/commons.dart';

/// Creating an instance of [OnDeviceTranslator]
/// ```
/// final _onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
///      sourceLanguage: TranslateLanguage.ENGLISH,
///      targetLanguage: TranslateLanguage.SPANISH);
/// ```
class OnDeviceTranslator {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_on_device_translator');

  final TranslateLanguage sourceLanguage;
  final TranslateLanguage targetLanguage;

  OnDeviceTranslator(
      {required this.sourceLanguage, required this.targetLanguage});

  Future<String> translateText(String text) async {
    final result = await _channel.invokeMethod(
        'nlp#startLanguageTranslator', <String, dynamic>{
      'text': text,
      'source': sourceLanguage.bcpCode,
      'target': targetLanguage.bcpCode
    });

    return result.toString();
  }

  Future<void> close() => _channel.invokeMethod('nlp#closeLanguageTranslator');
}

/// Creating instance of [OnDeviceTranslatorModelManager]
/// ```
/// final _languageModelManager = GoogleMlKit.nlp.
///                               translateLanguageModelManager();;
/// ```
class OnDeviceTranslatorModelManager extends ModelManager {
  OnDeviceTranslatorModelManager()
      : super(
            channel: OnDeviceTranslator._channel,
            method: 'nlp#manageLanguageModelModels');
}

/// Class containg all supported languages and their BCP-47 tags.
enum TranslateLanguage {
  afrikaans,
  albanian,
  arabic,
  belarusian,
  bengali,
  bulgarian,
  catalan,
  chinese,
  croatian,
  czech,
  danish,
  dutch,
  english,
  esperanto,
  estonian,
  finnish,
  french,
  galician,
  georgian,
  german,
  greek,
  gujarati,
  haitianCreole,
  hebrew,
  hindi,
  hungarian,
  icelandic,
  indonesian,
  irish,
  italian,
  japanese,
  kannada,
  korean,
  latvian,
  lithuanian,
  macedonian,
  malay,
  maltese,
  marathi,
  norwegian,
  persian,
  polish,
  portuguese,
  romanian,
  russian,
  slovak,
  slovenian,
  spanish,
  swahili,
  swedish,
  tagalog,
  tamil,
  telugu,
  thai,
  turkish,
  ukrainian,
  urdu,
  vietnamese,
  welsh,
}

extension BCP47Code on TranslateLanguage {
  String get bcpCode {
    switch (this) {
      case TranslateLanguage.afrikaans:
        return 'af';
      case TranslateLanguage.albanian:
        return 'sq';
      case TranslateLanguage.arabic:
        return 'ar';
      case TranslateLanguage.belarusian:
        return 'be';
      case TranslateLanguage.bengali:
        return 'bn';
      case TranslateLanguage.bulgarian:
        return 'bg';
      case TranslateLanguage.catalan:
        return 'ca';
      case TranslateLanguage.chinese:
        return 'zh';
      case TranslateLanguage.croatian:
        return 'hr';
      case TranslateLanguage.czech:
        return 'cs';
      case TranslateLanguage.danish:
        return 'da';
      case TranslateLanguage.dutch:
        return 'nl';
      case TranslateLanguage.english:
        return 'en';
      case TranslateLanguage.esperanto:
        return 'eo';
      case TranslateLanguage.estonian:
        return 'et';
      case TranslateLanguage.finnish:
        return 'fi';
      case TranslateLanguage.french:
        return 'fr';
      case TranslateLanguage.galician:
        return 'gl';
      case TranslateLanguage.georgian:
        return 'ka';
      case TranslateLanguage.german:
        return 'de';
      case TranslateLanguage.greek:
        return 'el';
      case TranslateLanguage.gujarati:
        return 'gu';
      case TranslateLanguage.haitianCreole:
        return 'ht';
      case TranslateLanguage.hebrew:
        return 'he';
      case TranslateLanguage.hindi:
        return 'hi';
      case TranslateLanguage.hungarian:
        return 'hu';
      case TranslateLanguage.icelandic:
        return 'is';
      case TranslateLanguage.indonesian:
        return 'id';
      case TranslateLanguage.irish:
        return 'ga';
      case TranslateLanguage.italian:
        return 'it';
      case TranslateLanguage.japanese:
        return 'ja';
      case TranslateLanguage.kannada:
        return 'kn';
      case TranslateLanguage.korean:
        return 'ko';
      case TranslateLanguage.latvian:
        return 'lv';
      case TranslateLanguage.lithuanian:
        return 'lt';
      case TranslateLanguage.macedonian:
        return 'mk';
      case TranslateLanguage.malay:
        return 'ms';
      case TranslateLanguage.maltese:
        return 'mt';
      case TranslateLanguage.marathi:
        return 'mr';
      case TranslateLanguage.norwegian:
        return 'no';
      case TranslateLanguage.persian:
        return 'fa';
      case TranslateLanguage.polish:
        return 'pl';
      case TranslateLanguage.portuguese:
        return 'pt';
      case TranslateLanguage.romanian:
        return 'ro';
      case TranslateLanguage.russian:
        return 'ru';
      case TranslateLanguage.slovak:
        return 'sk';
      case TranslateLanguage.slovenian:
        return 'sl';
      case TranslateLanguage.spanish:
        return 'es';
      case TranslateLanguage.swahili:
        return 'sw';
      case TranslateLanguage.swedish:
        return 'sv';
      case TranslateLanguage.tagalog:
        return 'tl';
      case TranslateLanguage.tamil:
        return 'ta';
      case TranslateLanguage.telugu:
        return 'te';
      case TranslateLanguage.thai:
        return 'th';
      case TranslateLanguage.turkish:
        return 'tr';
      case TranslateLanguage.ukrainian:
        return 'uk';
      case TranslateLanguage.urdu:
        return 'ur';
      case TranslateLanguage.vietnamese:
        return 'vi';
      case TranslateLanguage.welsh:
        return 'cy';
    }
  }

  static TranslateLanguage fromRawValue(String bcpCode) {
    return TranslateLanguage.values.firstWhere(
        (element) => element.bcpCode == bcpCode,
        orElse: () => TranslateLanguage.english);
  }
}
