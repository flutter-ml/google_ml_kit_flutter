import 'package:flutter/services.dart';
import 'package:google_ml_kit_language_id/language_identifier.dart';
import 'package:google_ml_kit_translation/on_device_translator.dart';
part 'nlp/entity_extraction.dart';
part 'nlp/smart_reply.dart';

class NaturalLanguage {
  NaturalLanguage._();

  static const MethodChannel channel = MethodChannel('google_ml_kit');

  static final NaturalLanguage instance = NaturalLanguage._();

  /// Returns instance of [LanguageIdentifier].
  LanguageIdentifier languageIdentifier({double confidenceThreshold = 0.5}) {
    return LanguageIdentifier(confidenceThreshold);
  }

  /// Returns instance of [OnDeviceTranslator].
  OnDeviceTranslator onDeviceTranslator(
      {required String sourceLanguage, required String targetLanguage}) {
    return OnDeviceTranslator(sourceLanguage, targetLanguage);
  }

  /// Returns instance of [TranslateLanguageModelManager].
  TranslateLanguageModelManager translateLanguageModelManager() {
    return TranslateLanguageModelManager();
  }

  /// Returns instance of [EntityExtractor].
  EntityExtractor entityExtractor(String language) {
    return EntityExtractor._(language);
  }

  /// Returns instance of [EntityModelManager].
  EntityModelManager entityModelManager() {
    return EntityModelManager._();
  }

  /// Returns instance of [SmartReply].
  SmartReply smartReply() {
    return SmartReply._();
  }
}
