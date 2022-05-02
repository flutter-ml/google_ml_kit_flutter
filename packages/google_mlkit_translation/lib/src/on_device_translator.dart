import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A class that translates on device the given input text.
class OnDeviceTranslator {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_on_device_translator');

  /// The source language of the input.
  final TranslateLanguage sourceLanguage;

  /// The target language to translate the input into.
  final TranslateLanguage targetLanguage;

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Constructor to create an instance of [OnDeviceTranslator].
  OnDeviceTranslator(
      {required this.sourceLanguage, required this.targetLanguage});

  /// Translates the given [text] from the source language into the target language.
  Future<String> translateText(String text) async {
    final result = await _channel
        .invokeMethod('nlp#startLanguageTranslator', <String, dynamic>{
      'id': id,
      'text': text,
      'source': sourceLanguage.bcpCode,
      'target': targetLanguage.bcpCode
    });

    return result.toString();
  }

  /// Closes the translator and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('nlp#closeLanguageTranslator', {'id': id});
}

/// A subclass of [ModelManager] that manages [TranslateRemoteModel] required to process the image.
class OnDeviceTranslatorModelManager extends ModelManager {
  /// Constructor to create an instance of [OnDeviceTranslatorModelManager].
  OnDeviceTranslatorModelManager()
      : super(
            channel: OnDeviceTranslator._channel,
            method: 'nlp#manageLanguageModelModels');
}

/// All supported languages by on-device translation.
/// More information: https://developers.google.com/ml-kit/language/translation/translation-language-support
enum TranslateLanguage {
  /// Afrikaans
  afrikaans,

  /// Albanian
  albanian,

  /// Arabic
  arabic,

  /// Belarusian
  belarusian,

  /// Bengali
  bengali,

  /// Bulgarian
  bulgarian,

  /// Catalan
  catalan,

  /// Chinese
  chinese,

  /// Croatian
  croatian,

  /// Czech
  czech,

  /// Danish
  danish,

  /// Dutch
  dutch,

  /// English
  english,

  /// Esperanto
  esperanto,

  /// Estonian
  estonian,

  /// Finnish
  finnish,

  /// French
  french,

  /// Galician
  galician,

  /// Georgian
  georgian,

  /// German
  german,

  /// Greek
  greek,

  /// Gujarati
  gujarati,

  /// Haitian
  haitian,

  /// Hebrew
  hebrew,

  /// Hindi
  hindi,

  /// Hungarian
  hungarian,

  /// Icelandic
  icelandic,

  /// Indonesian
  indonesian,

  /// Irish
  irish,

  /// Italian
  italian,

  /// Japanese
  japanese,

  /// Kannada
  kannada,

  /// Korean
  korean,

  /// Latvian
  latvian,

  /// Lithuanian
  lithuanian,

  /// Macedonian
  macedonian,

  /// Malay
  malay,

  /// Maltese
  maltese,

  /// Marathi
  marathi,

  /// Norwegian
  norwegian,

  /// Persian
  persian,

  /// Polish
  polish,

  /// Portuguese
  portuguese,

  /// Romanian
  romanian,

  /// Russian
  russian,

  /// Slovak
  slovak,

  /// Slovenian
  slovenian,

  /// Spanish
  spanish,

  /// Swahili
  swahili,

  /// Swedish
  swedish,

  /// Tagalog
  tagalog,

  /// Tamil
  tamil,

  /// Telugu
  telugu,

  /// Thai
  thai,

  /// Turkish
  turkish,

  /// Ukrainian
  ukrainian,

  /// Urdu
  urdu,

  /// Vietnamese
  vietnamese,

  /// Welsh
  welsh,
}

extension BCP47Code on TranslateLanguage {
  /// Returns BCP-47 tag of the language.
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
      case TranslateLanguage.haitian:
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

  static TranslateLanguage? fromRawValue(String bcpCode) {
    try {
      return TranslateLanguage.values
          .firstWhere((element) => element.bcpCode == bcpCode);
    } catch (_) {
      return null;
    }
  }
}
