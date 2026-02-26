package com.google_mlkit_genai_rewriting

import android.content.Context
import com.google.common.util.concurrent.FutureCallback
import com.google.common.util.concurrent.Futures
import com.google.mlkit.genai.common.DownloadCallback
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.common.GenAiException
import com.google.mlkit.genai.rewriting.RewriterOptions
import com.google.mlkit.genai.rewriting.Rewriting
import com.google.mlkit.genai.rewriting.RewritingRequest
import com.google.mlkit.genai.rewriting.RewritingResult
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class Rewriter(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, com.google.mlkit.genai.rewriting.Rewriter>()
    private val executor = Executors.newSingleThreadExecutor()

    companion object {
        private const val CHECK_FEATURE_STATUS = "genai#checkFeatureStatus"
        private const val DOWNLOAD_FEATURE = "genai#downloadFeature"
        private const val RUN_INFERENCE = "genai#runInference"
        private const val RUN_INFERENCE_STREAMING = "genai#runInferenceStreaming"
        private const val CLOSE = "genai#closeRewriter"
    }

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
                closeRewriter(call)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initialize(call: MethodCall): com.google.mlkit.genai.rewriting.Rewriter {
        val options = RewriterOptions.builder(context).build()
        return Rewriting.getClient(options)
    }

    private fun checkFeatureStatus(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val id = call.argument<String>("id") ?: return
        val rewriter = instances.getOrPut(id) { initialize(call) }

        val future = rewriter.checkFeatureStatus()
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
                    result.error("RewriterError", e.toString(), null)
                }
            },
            executor,
        )
    }

    private fun downloadFeature(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val id = call.argument<String>("id") ?: return
        val rewriter = instances.getOrPut(id) { initialize(call) }

        rewriter.downloadFeature(
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
        val id = call.argument<String>("id") ?: return
        val text = call.argument<String>("text") ?: return
        val rewriter = instances.getOrPut(id) { initialize(call) }

        val request = RewritingRequest.builder(text).build()
        val future = rewriter.runInference(request)

        Futures.addCallback(
            future,
            object : FutureCallback<RewritingResult> {
                override fun onSuccess(rewritingResult: RewritingResult?) {
                    val rewrittenText =
                        rewritingResult?.let {
                            runCatching { it.javaClass.getMethod("getText").invoke(it) as? String }
                                .getOrNull()
                                ?: runCatching { it.javaClass.getMethod("getRewrittenText").invoke(it) as? String }
                                    .getOrNull()
                                ?: ""
                        } ?: ""
                    result.success(mapOf("text" to rewrittenText))
                }

                override fun onFailure(e: Throwable) {
                    result.error("InferenceError", e.toString(), null)
                }
            },
            executor,
        )
    }

    private fun closeRewriter(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }
}
