package com.google_mlkit_genai_summarization

import android.content.Context
import com.google.common.util.concurrent.FutureCallback
import com.google.common.util.concurrent.Futures
import com.google.mlkit.genai.common.DownloadCallback
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.common.GenAiException
import com.google.mlkit.genai.summarization.Summarization
import com.google.mlkit.genai.summarization.SummarizationRequest
import com.google.mlkit.genai.summarization.SummarizationResult
import com.google.mlkit.genai.summarization.SummarizerOptions
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class Summarizer(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, com.google.mlkit.genai.summarization.Summarizer>()
    private val executor = Executors.newSingleThreadExecutor()

    companion object {
        private const val CHECK_FEATURE_STATUS = "genai#checkFeatureStatus"
        private const val DOWNLOAD_FEATURE = "genai#downloadFeature"
        private const val RUN_INFERENCE = "genai#runInference"
        private const val RUN_INFERENCE_STREAMING = "genai#runInferenceStreaming"
        private const val CLOSE = "genai#closeSummarizer"
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
                closeSummarizer(call)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initialize(): com.google.mlkit.genai.summarization.Summarizer {
        val options = SummarizerOptions.builder(context).build()
        return Summarization.getClient(options)
    }

    private fun checkFeatureStatus(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val id = call.argument<String>("id") ?: return
        val summarizer = instances.getOrPut(id) { initialize() }

        val future = summarizer.checkFeatureStatus()
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
                    result.error("SummarizerError", e.toString(), null)
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
        val summarizer = instances.getOrPut(id) { initialize() }

        summarizer.downloadFeature(
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
        val summarizer = instances.getOrPut(id) { initialize() }

        val request = SummarizationRequest.builder(text).build()
        val future = summarizer.runInference(request)

        Futures.addCallback(
            future,
            object : FutureCallback<SummarizationResult> {
                override fun onSuccess(summarizationResult: SummarizationResult?) {
                    result.success(mapOf("summary" to summarizationResult?.summary))
                }

                override fun onFailure(e: Throwable) {
                    result.error("InferenceError", e.toString(), null)
                }
            },
            executor,
        )
    }

    private fun closeSummarizer(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }
}
