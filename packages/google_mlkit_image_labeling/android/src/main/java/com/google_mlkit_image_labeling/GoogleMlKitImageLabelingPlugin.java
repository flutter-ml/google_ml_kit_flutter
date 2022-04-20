package com.google_mlkit_image_labeling;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;

public class GoogleMlKitImageLabelingPlugin implements FlutterPlugin {
    private MethodChannel channel;
    private static final String channelName = "google_mlkit_image_labeler";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), channelName);
        channel.setMethodCallHandler(new ImageLabelDetector(flutterPluginBinding.getApplicationContext()));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
