import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartOptions: DartOptions(),
    kotlinOut: 'android/src/main/kotlin/com/google_mlkit_commons/messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.google_mlkit_commons'),
    swiftOut: 'ios/Runner/Messages.g.swift',
    swiftOptions: SwiftOptions(),
    dartPackageName: 'google_mlkit_commons',
  ),
)
class ModelManagementRequest {
  String task;
  String model;
  bool? isWifiRequired;

  ModelManagementRequest({
    required this.task,
    required this.model,
    this.isWifiRequired,
  });
}

class ModelManagementResponse {
  bool success;
  String? message;

  ModelManagementResponse({required this.success, this.message});
}

@HostApi()
abstract class ModelManagerApi {
  @async
  bool isModelDownloaded(String model);

  @async
  ModelManagementResponse downloadModel(ModelManagementRequest request);

  @async
  ModelManagementResponse deleteModel(String model);
}
