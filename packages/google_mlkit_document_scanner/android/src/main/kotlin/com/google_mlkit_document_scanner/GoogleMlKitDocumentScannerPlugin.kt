package com.google_mlkit_document_scanner

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class GoogleMlKitDocumentScannerPlugin :
    FlutterPlugin,
    ActivityAware {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        channel.setMethodCallHandler(DocumentScanner(binding))
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        channel.setMethodCallHandler(DocumentScanner(binding))
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onDetachedFromActivity() {}

    companion object {
        private const val CHANNEL_NAME = "google_mlkit_document_scanner"
    }
}
