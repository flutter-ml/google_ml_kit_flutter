package com.google_mlkit_barcode_scanning

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class GoogleMlKitBarcodeScanningPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel

    companion object {
        private const val CHANNEL_NAME = "google_mlkit_barcode_scanning"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(BarcodeScanner(flutterPluginBinding.applicationContext))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        result.notImplemented()
    }
}
