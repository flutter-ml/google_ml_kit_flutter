package com.google_mlkit_language_id

import com.google.mlkit.nl.languageid.LanguageIdentification
import com.google.mlkit.nl.languageid.LanguageIdentificationOptions
import com.google.mlkit.nl.languageid.LanguageIdentifier
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class LanguageDetector : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, LanguageIdentifier>()

    companion object {
        private const val START = "nlp#startLanguageIdentifier"
        private const val CLOSE = "nlp#closeLanguageIdentifier"
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            START -> {
                identifyLanguages(call, result)
            }

            CLOSE -> {
                closeDetector(call)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun identifyLanguages(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val id = call.argument<String>("id") ?: return
        val languageIdentifier =
            instances.getOrPut(id) {
                val confidence = call.argument<Double>("confidence") ?: 0.0
                LanguageIdentification.getClient(
                    LanguageIdentificationOptions
                        .Builder()
                        .setConfidenceThreshold(confidence.toFloat())
                        .build(),
                )
            }

        val possibleLanguages = call.argument<Boolean>("possibleLanguages") ?: false
        val text = call.argument<String>("text") ?: return

        if (!possibleLanguages) {
            identifyLanguage(text, languageIdentifier, result)
        } else {
            identifyPossibleLanguages(text, languageIdentifier, result)
        }
    }

    private fun identifyLanguage(
        text: String,
        languageIdentifier: LanguageIdentifier,
        result: MethodChannel.Result,
    ) {
        languageIdentifier
            .identifyLanguage(text)
            .addOnSuccessListener { result.success(it) }
            .addOnFailureListener { e -> result.error("Language Identification Error", e.toString(), null) }
    }

    private fun identifyPossibleLanguages(
        text: String,
        languageIdentifier: LanguageIdentifier,
        result: MethodChannel.Result,
    ) {
        languageIdentifier
            .identifyPossibleLanguages(text)
            .addOnSuccessListener { identifiedLanguages ->
                val languageList =
                    identifiedLanguages.map { language ->
                        mapOf(
                            "confidence" to language.confidence,
                            "language" to language.languageTag,
                        )
                    }
                result.success(languageList)
            }.addOnFailureListener { e -> result.error("Error identifying possible languages", e.toString(), null) }
    }

    private fun closeDetector(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }
}
