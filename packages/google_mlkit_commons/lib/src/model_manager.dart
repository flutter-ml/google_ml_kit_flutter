import 'dart:async';

import 'pigeon.dart';

/// A class to manage remote models.
class ModelManager {
  final ModelManagerApi _api;

  /// Constructor to create an instance of [ModelManager]
  /// If [api] is not provided, uses the default generate API.
  ModelManager({ModelManagerApi? api}) : _api = api ?? ModelManagerApi();

  /// Checks whether a model is downloaded or not.
  Future<bool> isModelDownloaded(String model) async {
    return await _api.isModelDownloaded(model);
  }

  /// Downloads a model
  /// Returns true if model downloads successfully or model is already downloaded.
  /// On failing to download it thros an error.
  Future<bool> downloadModel(String model, {bool isWifiRequired = true}) async {
    final request = ModelManagementReqest(
      task: 'download',
      model: model,
      isWifiRequired: isWifiRequired,
    );
    final response = await _api.downloadModel(request);
    return response.success;
  }

  // Deletes a model
  /// Returns true if model is deleted successfully or model is not present
  Future<bool> deleteModel(String model) async {
    final response = await _api.deleteModel(model);
    return response.success;
  }
}
