import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class NaturalLanguage {
  NaturalLanguage._();

  static final NaturalLanguage instance = NaturalLanguage._();

  /// Returns instance of [LanguageIdentifier].
  LanguageIdentifier languageIdentifier({double confidenceThreshold = 0.5}) {
    return LanguageIdentifier(confidenceThreshold: confidenceThreshold);
  }

  /// Returns instance of [OnDeviceTranslator].
  OnDeviceTranslator onDeviceTranslator(
      {required TranslateLanguage sourceLanguage,
      required TranslateLanguage targetLanguage}) {
    return OnDeviceTranslator(
        sourceLanguage: sourceLanguage, targetLanguage: targetLanguage);
  }

  /// Returns instance of [EntityExtractor].
  EntityExtractor entityExtractor(EntityExtractorLanguage language) {
    return EntityExtractor(language: language);
  }

  /// Returns instance of [SmartReply].
  SmartReply smartReply() {
    return SmartReply();
  }
}
