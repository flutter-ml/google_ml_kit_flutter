package com.google_mlkit_commons

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

class GoogleMlKitCommonsPlugin: FlutterPlugin {

    private var genericModelManager: GenericModelManager? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        genericModelManager = GenericModelManager()
        ModelManagerApi.setUp(flutterPluginBinding.binaryMessenger, genericModelManager)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        ModelManagerApi.setUp(binding.binaryMessenger,null)
        genericModelManager = null
    }
}