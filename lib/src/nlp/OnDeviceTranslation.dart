part of 'NaturalLanguage.dart';

class OnDeviceTranslator {
  final String sourceLanguage;
  final String targetLanguage;

  OnDeviceTranslator._(this.sourceLanguage, this.targetLanguage);
  bool _isOpened = false;
  bool _isClosed = false;

  Future<String> translateText(String text) async {
    _isOpened = true;

    final result = await NaturalLanguage.channel.invokeMethod(
        'nlp#startLanguageTranslator', <String, dynamic>{
      "text": text,
      "source": sourceLanguage,
      "target": targetLanguage
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

class TranslateLanguageModelManager {
  TranslateLanguageModelManager._();

  Future<String> isModelDownloaded(String modelTag) async {
    final result = await NaturalLanguage.channel.invokeMethod(
        "nlp#startLanguageModelManager",
        <String, dynamic>{"task": "isDownloaded", "model": modelTag});
    return result.toString();
  }

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

  Future<String> deleteModel(String modelTag) async {
    final result = await NaturalLanguage.channel
        .invokeMethod("nlp#startLanguageModelManager", <String, dynamic>{
      "task": "delete",
      "model": modelTag,
    });
    return result.toString();
  }

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
