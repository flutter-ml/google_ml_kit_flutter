import 'dart:async';

import 'package:flutter/services.dart';

/// A class to manage remote models.
class ModelManager {
  /// The method name to be called.
  final String method;

  /// The channel used to manage the remote model.
  final MethodChannel channel;

  /// Constructor to create an instance of [ModelManager].
  ModelManager({required this.channel, required this.method});

  /// Checks whether a model is downloaded or not.
  Future<bool> isModelDownloaded(String model) async {
    final result = await channel.invokeMethod(method, <String, dynamic>{
      'task': 'check',
      'model': model,
    });
    return result as bool;
  }

  /// Downloads a model.
  /// Returns true if model downloads successfully or model is already downloaded.
  /// On failing to download it throws an error.
  Future<bool> downloadModel(String model, {bool isWifiRequired = true}) async {
    final result = await channel.invokeMethod(method, <String, dynamic>{
      'task': 'download',
      'model': model,
      'wifi': isWifiRequired
    });
    return result.toString() == 'success';
  }

  /// Deletes a model.
  /// Returns true if model is deleted successfully or model is not present.
  Future<bool> deleteModel(String model) async {
    final result = await channel.invokeMethod(method, <String, dynamic>{
      'task': 'delete',
      'model': model,
    });
    return result.toString() == 'success';
  }
}
