package com.google_mlkit_translation

import com.google.mlkit.nl.translate.TranslateRemoteModel
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.Translator
import com.google.mlkit.nl.translate.TranslatorOptions
import com.google_mlkit_commons.GenericModelManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class TextTranslator : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, Translator>()
    private val genericModelManager = GenericModelManager()

    companion object {
        private const val START = "nlp#startLanguageTranslator"
        private const val CLOSE = "nlp#closeLanguageTranslator"
        private const val MANAGE = "nlp#manageLanguageModelModels"
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            START -> {
                translateText(call, result)
            }

            CLOSE -> {
                closeDetector(call)
                result.success(null)
            }

            MANAGE -> {
                manageModel(call, result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun translateText(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val text = call.argument<String>("text") ?: return
        val id = call.argument<String>("id") ?: return

        val translator =
            instances.getOrPut(id) {
                val sourceLanguage = call.argument<String>("source") ?: return
                val targetLanguage = call.argument<String>("target") ?: return
                Translation.getClient(
                    TranslatorOptions
                        .Builder()
                        .setSourceLanguage(sourceLanguage)
                        .setTargetLanguage(targetLanguage)
                        .build(),
                )
            }

        translator
            .downloadModelIfNeeded()
            .addOnSuccessListener {
                translator
                    .translate(text)
                    .addOnSuccessListener { result.success(it) }
                    .addOnFailureListener { e -> result.error("error translating", e.toString(), null) }
            }.addOnFailureListener {
                result.error("Error building translator", "Either source or target models not downloaded", null)
            }
    }

    private fun closeDetector(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }

    private fun manageModel(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val model = TranslateRemoteModel.Builder(call.argument<String>("model").toString()).build()
        genericModelManager.manageModel(model, call, result)
    }
}
