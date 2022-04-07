import 'package:google_mlkit_entity_extraction/entity_extractor.dart';
import 'package:google_mlkit_language_id/language_identifier.dart';
import 'package:google_mlkit_smart_reply/smart_reply.dart';
import 'package:google_mlkit_translation/on_device_translator.dart';

class NaturalLanguage {
  NaturalLanguage._();

  static final NaturalLanguage instance = NaturalLanguage._();

  /// Returns instance of [LanguageIdentifier].
  LanguageIdentifier languageIdentifier({double confidenceThreshold = 0.5}) {
    return LanguageIdentifier(confidenceThreshold: confidenceThreshold);
  }

  /// Returns instance of [OnDeviceTranslator].
  OnDeviceTranslator onDeviceTranslator(
      {required String sourceLanguage, required String targetLanguage}) {
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
