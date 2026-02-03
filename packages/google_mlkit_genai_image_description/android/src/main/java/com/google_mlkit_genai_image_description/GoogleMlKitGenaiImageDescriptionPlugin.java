package com.google_mlkit_genai_image_description;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;

public class GoogleMlKitGenaiImageDescriptionPlugin implements FlutterPlugin {
    private MethodChannel channel;
    private static final String channelName = "google_mlkit_genai_image_description";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), channelName);
        channel.setMethodCallHandler(new ImageDescriber(flutterPluginBinding.getApplicationContext()));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
