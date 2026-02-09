package com.google_mlkit_translation;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

public class GoogleMlKitTranslationPlugin implements FlutterPlugin {
    private TextTranslator translateApi;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        translateApi = new TextTranslator();
        Pigeon.OnDeviceTranslatorApi.setUp(
        flutterPluginBinding.getBinaryMessenger(), translateApi);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Pigeon.OnDeviceTranslatorApi.setUp(binding.getBinaryMessenger(), null);
    }
}
