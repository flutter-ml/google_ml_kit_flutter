import 'package:flutter/services.dart';
import 'package:google_mlkit_entity_extraction/entity_extractor.dart';
import 'package:google_mlkit_language_id/language_identifier.dart';
import 'package:google_mlkit_smart_reply/smart_reply.dart';
import 'package:google_mlkit_translation/on_device_translator.dart';

class NaturalLanguage {
  NaturalLanguage._();

  static const MethodChannel channel = MethodChannel('google_mlkit');

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
    return EntityExtractor(language);
  }

  /// Returns instance of [EntityModelManager].
  EntityModelManager entityModelManager() {
    return EntityModelManager();
  }

  /// Returns instance of [SmartReply].
  SmartReply smartReply() {
    return SmartReply();
  }
}
