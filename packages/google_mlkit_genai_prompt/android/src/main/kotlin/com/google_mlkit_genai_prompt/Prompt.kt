package com.google_mlkit_genai_prompt

import android.content.Context
import com.google.common.util.concurrent.FutureCallback
import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.ListenableFuture
import com.google.mlkit.genai.common.DownloadCallback
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.common.GenAiException
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executor
import java.util.concurrent.Executors

class Prompt(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, Any>()

    companion object {
        private const val CHECK_FEATURE_STATUS = "genai#checkFeatureStatus"
        private const val DOWNLOAD_FEATURE = "genai#downloadFeature"
        private const val RUN_INFERENCE = "genai#runInference"
        private const val RUN_INFERENCE_STREAMING = "genai#runInferenceStreaming"
        private const val CLOSE = "genai#closePrompt"
    }

    private val executor: Executor = Executors.newSingleThreadExecutor()

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            CHECK_FEATURE_STATUS -> {
                checkFeatureStatus(call, result)
            }

            DOWNLOAD_FEATURE -> {
                downloadFeature(call, result)
            }

            RUN_INFERENCE -> {
                runInference(call, result)
            }

            RUN_INFERENCE_STREAMING -> {
                result.notImplemented()
            }

            CLOSE -> {
                closePrompt(call)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initialize(call: MethodCall): Any =
        try {
            val generationInstance =
                Class
                    .forName("com.google.mlkit.genai.prompt.Generation")
                    .getField("INSTANCE")
                    .get(null)
            val generativeModel =
                generationInstance
                    ?.javaClass
                    ?.getMethod("getClient")
                    ?.invoke(generationInstance)
            Class
                .forName("com.google.mlkit.genai.prompt.GenerativeModelFutures")
                .getMethod("from", Class.forName("com.google.mlkit.genai.prompt.GenerativeModel"))
                .invoke(null, generativeModel) ?: Any()
        } catch (e: Exception) {
            Any()
        }

    private fun checkFeatureStatus(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val id = call.argument<String>("id") ?: return result.error("PromptError", "Missing id", null)
        val generativeModel = instances.getOrPut(id) { initialize(call) }

        try {
            @Suppress("UNCHECKED_CAST")
            val future =
                generativeModel.javaClass
                    .getMethod("checkStatus")
                    .invoke(generativeModel) as ListenableFuture<Int>

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
                        result.error("PromptError", e.toString(), null)
                    }
                },
                executor,
            )
        } catch (e: Exception) {
            result.error("PromptError", "Failed to check status: $e", null)
        }
    }

    private fun downloadFeature(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val id = call.argument<String>("id") ?: return result.error("PromptError", "Missing id", null)
        val generativeModel = instances.getOrPut(id) { initialize(call) }

        try {
            generativeModel.javaClass
                .getMethod("download", DownloadCallback::class.java)
                .invoke(
                    generativeModel,
                    object : DownloadCallback {
                        override fun onDownloadStarted(p0: Long) {}

                        override fun onDownloadFailed(e: GenAiException) {
                            result.error("DownloadError", e.toString(), null)
                        }

                        override fun onDownloadProgress(totalBytesDownloaded: Long) {}

                        override fun onDownloadCompleted() {
                            result.success(null)
                        }
                    },
                )
        } catch (e: Exception) {
            result.error("PromptError", "Failed to download $e", null)
        }
    }

    private fun runInference(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        result.error("PromptError", "Prompt API inference not yet fully implemented", null)
    }

    private fun closePrompt(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)
    }
}
