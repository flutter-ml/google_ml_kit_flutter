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

  final String sourceLanguage;
  final String targetLanguage;

  OnDeviceTranslator(
      {required this.sourceLanguage, required this.targetLanguage});

  Future<String> translateText(String text) async {
    final result = await _channel.invokeMethod(
        'nlp#startLanguageTranslator', <String, dynamic>{
      'text': text,
      'source': sourceLanguage,
      'target': targetLanguage
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
class TranslateLanguage {
  static const afrikaans = 'af';
  static const albanian = 'sq';
  static const arabic = 'ar';
  static const belarusian = 'be';
  static const bengali = 'bn';
  static const bulgarian = 'bg';
  static const catalan = 'ca';
  static const chinese = 'zh';
  static const croatian = 'hr';
  static const czech = 'cs';
  static const danish = 'da';
  static const dutch = 'nl';
  static const english = 'en';
  static const esperanto = 'eo';
  static const estonian = 'et';
  static const finnish = 'fi';
  static const french = 'fr';
  static const galician = 'gl';
  static const georgian = 'ka';
  static const german = 'de';
  static const greek = 'el';
  static const gujarati = 'gu';
  static const haitianCreole = 'ht';
  static const hebrew = 'he';
  static const hindi = 'hi';
  static const hungarian = 'hu';
  static const icelandic = 'is';
  static const indonesian = 'id';
  static const irish = 'ga';
  static const italian = 'it';
  static const japanese = 'ja';
  static const kannada = 'kn';
  static const korean = 'ko';
  static const latvian = 'lv';
  static const lithuanian = 'lt';
  static const macedonian = 'mk';
  static const malay = 'ms';
  static const maltese = 'mt';
  static const marathi = 'mr';
  static const norwegian = 'no';
  static const persian = 'fa';
  static const polish = 'pl';
  static const portuguese = 'pt';
  static const romanian = 'ro';
  static const russian = 'ru';
  static const slovak = 'sk';
  static const slovenian = 'sl';
  static const spanish = 'es';
  static const swahili = 'sw';
  static const swedish = 'sv';
  static const tagalog = 'tl';
  static const tamil = 'ta';
  static const telugu = 'te';
  static const thai = 'th';
  static const turkish = 'tr';
  static const ukrainian = 'uk';
  static const urdu = 'ur';
  static const vietnamese = 'vi';
  static const welsh = 'cy';
}
