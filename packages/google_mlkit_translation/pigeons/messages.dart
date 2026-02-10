import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon.dart',
    dartOptions: DartOptions(),
    javaOut: 'android/src/main/java/com/google_mlkit_translation/Pigeon.java',
    javaOptions: JavaOptions(package: 'com.google_mlkit_translation'),
    objcHeaderOut: 'ios/Classes/Pigeon.h',
    objcSourceOut: 'ios/Classes/Pigeon.m',
    objcOptions: ObjcOptions(),
  ),
)
class TranslateRequest {
  final String id;
  final String text;
  final String sourceLanguage;
  final String targetLanguage;

  TranslateRequest({
    required this.id,
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
  });
}

class CloseTranslatorRequest {
  final String id;

  CloseTranslatorRequest(this.id);
}

class ModelManagementRequest {
  final String model;
  final String task;

  ModelManagementRequest({required this.model, required this.task});
}

class ModelManagementResponse {
  final bool success;
  final String? message;

  ModelManagementResponse({required this.success, this.message});
}

@HostApi()
abstract class OnDeviceTranslatorApi {
  @async
  String translateText(TranslateRequest request);

  void closeTranslator(CloseTranslatorRequest request);
}
