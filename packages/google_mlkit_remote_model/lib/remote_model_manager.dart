import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/commons.dart';

/// Class to manage firebase remote models.
class RemoteModelManager extends ModelManager {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_remote_model_manager');

  RemoteModelManager()
      : super(channel: _channel, method: 'vision#manageRemoteModel');
}
