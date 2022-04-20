package com.google_mlkit_translation;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;

public class GoogleMlKitTranslationPlugin implements FlutterPlugin {
    private MethodChannel channel;
    private static final String channelName = "google_mlkit_on_device_translator";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), channelName);
        channel.setMethodCallHandler(new TextTranslator());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
