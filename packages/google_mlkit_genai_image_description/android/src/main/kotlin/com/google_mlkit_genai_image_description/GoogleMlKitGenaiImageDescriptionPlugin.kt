package com.google_mlkit_genai_image_description

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

class GoogleMlKitGenaiImageDescriptionPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel

    companion object {
        private const val CHANNEL_NAME = "google_mlkit_genai_image_description"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(ImageDescriber(flutterPluginBinding.applicationContext))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
