package com.google_mlkit_translation

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

class GoogleMlKitTranslationPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel

    companion object {
        private const val CHANNEL_NAME = "google_mlkit_on_device_translator"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(TextTranslator())
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
