package com.google_mlkit_image_labeling

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

class GoogleMlKitImageLabelingPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel

    companion object {
        private const val CHANNEL_NAME = "google_mlkit_image_labeler"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(ImageLabelDetector(flutterPluginBinding.applicationContext))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
