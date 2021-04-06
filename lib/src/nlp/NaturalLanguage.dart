import 'package:flutter/services.dart';

part 'LanguageIdentifier.dart';

class NaturalLanguage {
  NaturalLanguage._();
  
  static const MethodChannel channel = MethodChannel('google_ml_kit');

  static final NaturalLanguage instance = NaturalLanguage._();

  LanguageIdentifier languageIdentifier({double confidenceThreshold=0.5}){
    return LanguageIdentifier._(confidenceThreshold);
  }
}
