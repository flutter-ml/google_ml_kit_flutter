package com.google_mlkit_genai_speech_recognition

import android.content.Context
import com.google.common.util.concurrent.FutureCallback
import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.ListenableFuture
import com.google.mlkit.genai.common.FeatureStatus
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class SpeechRecognizer(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, Any>()
    private val executor = Executors.newSingleThreadExecutor()

    companion object {
        private const val CHECK_STATUS = "genai#checkStatus"
        private const val START_RECOGNITION = "genai#startRecognition"
        private const val STOP_RECOGNITION = "genai#stopRecognition"
        private const val CLOSE = "genai#closeSpeechRecognizer"
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            CHECK_STATUS -> {
                checkStatus(call, result)
            }

            START_RECOGNITION -> {
                result.notImplemented()
            }

            STOP_RECOGNITION -> {
                result.notImplemented()
            }

            CLOSE -> {
                closeSpeechRecognizer(call)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initialize(call: MethodCall): Any =
        runCatching {
            val optionsBuilder =
                Class
                    .forName("com.google.mlkit.genai.speechrecognition.SpeechRecognizerOptions")
                    .getMethod("builder", Context::class.java)
                    .invoke(null, context)!!
            val options = optionsBuilder.javaClass.getMethod("build").invoke(optionsBuilder)!!
            Class
                .forName("com.google.mlkit.genai.speechrecognition.SpeechRecognition")
                .getMethod("getClient", options.javaClass)
                .invoke(null, options)!!
        }.getOrDefault(Any())

    private fun checkStatus(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val id = call.argument<String>("id") ?: return
        val speechRecognizer = instances.getOrPut(id) { initialize(call) }

        runCatching {
            @Suppress("UNCHECKED_CAST")
            val future =
                speechRecognizer.javaClass
                    .getMethod("checkStatus")
                    .invoke(speechRecognizer) as ListenableFuture<Int>

            Futures.addCallback(
                future,
                object : FutureCallback<Int> {
                    override fun onSuccess(status: Int?) {
                        val statusValue =
                            when (status) {
                                FeatureStatus.UNAVAILABLE -> 0
                                FeatureStatus.DOWNLOADABLE -> 1
                                FeatureStatus.DOWNLOADING -> 2
                                FeatureStatus.AVAILABLE -> 3
                                else -> 0
                            }
                        result.success(statusValue)
                    }

                    override fun onFailure(e: Throwable) {
                        result.error("SpeechRecognizerError", e.toString(), null)
                    }
                },
                executor,
            )
        }.onFailure { e ->
            result.error("SpeechRecognizerError", "Failed to check status: $e", null)
        }
    }

    private fun closeSpeechRecognizer(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        val speechRecognizer = instances.remove(id) ?: return
        runCatching { speechRecognizer.javaClass.getMethod("close").invoke(speechRecognizer) }
    }
}
