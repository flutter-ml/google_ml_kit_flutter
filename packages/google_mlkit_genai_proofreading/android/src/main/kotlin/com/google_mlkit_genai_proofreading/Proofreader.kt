package com.google_mlkit_genai_proofreading

import android.content.Context
import com.google.common.util.concurrent.FutureCallback
import com.google.common.util.concurrent.Futures
import com.google.mlkit.genai.common.DownloadCallback
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.common.GenAiException
import com.google.mlkit.genai.proofreading.ProofreaderOptions
import com.google.mlkit.genai.proofreading.Proofreading
import com.google.mlkit.genai.proofreading.ProofreadingRequest
import com.google.mlkit.genai.proofreading.ProofreadingResult
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class Proofreader(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    companion object {
        private const val CHECK_FEATURE_STATUS = "genai#checkFeatureStatus"
        private const val DOWNLOAD_FEATURE = "genai#downloadFeature"
        private const val RUN_INFERENCE = "genai#runInference"
        private const val RUN_INFERENCE_STREAMING = "genai#runInferenceStreaming"
        private const val CLOSE = "genai#closeProofreader"
    }

    private val instances = mutableMapOf<String, com.google.mlkit.genai.proofreading.Proofreader>()
    private val executor = Executors.newSingleThreadExecutor()

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
                closeProofreader(call)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initialize(call: MethodCall): com.google.mlkit.genai.proofreading.Proofreader {
        val options = ProofreaderOptions.builder(context).build()
        return Proofreading.getClient(options)
    }

    private fun checkFeatureStatus(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val id = call.argument<String>("id") ?: return result.error("ProofreaderError", "Missing id", null)
        val proofreader = instances.getOrPut(id) { initialize(call) }

        val future = proofreader.checkFeatureStatus()
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
                    result.error("ProofreaderError", e.toString(), null)
                }
            },
            executor,
        )
    }

    private fun downloadFeature(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val id = call.argument<String>("id") ?: return result.error("ProofreaderError", "Missing id", null)
        val proofreader = instances.getOrPut(id) { initialize(call) }

        proofreader.downloadFeature(
            object : DownloadCallback {
                override fun onDownloadStarted(bytesToDownload: Long) {}

                override fun onDownloadFailed(e: GenAiException) {
                    result.error("DownloadError", e.toString(), null)
                }

                override fun onDownloadProgress(totalBytesDownloaded: Long) {}

                override fun onDownloadCompleted() {
                    result.success(null)
                }
            },
        )
    }

    private fun runInference(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val id = call.argument<String>("id") ?: return result.error("ProofreaderError", "Missing id", null)
        val text = call.argument<String>("text") ?: return result.error("ProofreaderError", "Missing text", null)
        val proofreader = instances.getOrPut(id) { initialize(call) }

        val request = ProofreadingRequest.builder(text).build()
        val future = proofreader.runInference(request)
        Futures.addCallback(
            future,
            object : FutureCallback<ProofreadingResult> {
                override fun onSuccess(proofreadingResult: ProofreadingResult?) {
                    val correctedText =
                        proofreadingResult?.let {
                            runCatching {
                                it.javaClass.getMethod("getCorrectedText").invoke(it) as? String
                            }.getOrNull() ?: runCatching {
                                it.javaClass.getMethod("getText").invoke(it) as? String
                            }.getOrNull() ?: ""
                        } ?: ""
                    result.success(mapOf("text" to correctedText))
                }

                override fun onFailure(e: Throwable) {
                    result.error("InferenceError", e.toString(), null)
                }
            },
            executor,
        )
    }

    private fun closeProofreader(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }
}
