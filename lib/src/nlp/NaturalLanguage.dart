import 'dart:ffi';

import 'package:flutter/services.dart';

part 'LanguageIdentifier.dart';
part 'OnDeviceTranslation.dart';
part 'EntityExtraction.dart';
class NaturalLanguage {
  NaturalLanguage._();

  static const MethodChannel channel = MethodChannel('google_ml_kit');

  static final NaturalLanguage instance = NaturalLanguage._();

  LanguageIdentifier languageIdentifier({double confidenceThreshold = 0.5}) {
    return LanguageIdentifier._(confidenceThreshold);
  }

  OnDeviceTranslator onDeviceTranslator(
      {required String sourceLanguage, required String targetLanguage}) {
    return OnDeviceTranslator._(sourceLanguage, targetLanguage);
  }

  TranslateLanguageModelManager translateLanguageModelManager() {
    return TranslateLanguageModelManager._();
  }

  EntityExtractor entityExtractor(String language){
    return EntityExtractor._(language);
  }

  EntityModelManager entityModelManager(){
    return EntityModelManager._();
  }
}
