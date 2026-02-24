package com.google_mlkit_genai_image_description

import android.R.attr.bitmap
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import com.google.common.util.concurrent.FutureCallback
import com.google.common.util.concurrent.Futures
import com.google.mlkit.genai.common.DownloadCallback
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.common.GenAiException
import com.google.mlkit.genai.imagedescription.ImageDescriberOptions
import com.google.mlkit.genai.imagedescription.ImageDescription
import com.google.mlkit.genai.imagedescription.ImageDescriptionRequest
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.IntBuffer
import java.util.concurrent.Executor
import java.util.concurrent.Executors

class ImageDescriber(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, com.google.mlkit.genai.imagedescription.ImageDescriber>()

    companion object {
        private const val CHECK_FEATURE_STATUS = "genai#checkFeatureStatus"
        private const val CLOSE = "genai#closeImageDescriber"
        private const val DOWNLOAD_FEATURE = "genai#downloadFeature"
        private const val RUN_INFERENCE = "genai#runInference"
        private const val RUN_INFERENCE_STREAMING = "genai#runInferenceStreaming"
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
                closeImageDescriber(call)
                result.success(null)
            }
        }
    }

    private fun initialize(): com.google.mlkit.genai.imagedescription.ImageDescriber {
        val options = ImageDescriberOptions.builder(context).build()
        return ImageDescription.getClient(options)
    }

    private fun getOrCreateInstance(call: MethodCall): Pair<String, com.google.mlkit.genai.imagedescription.ImageDescriber> {
        val id = call.argument<String>("id")!!
        val describer = instances.getOrPut(id) { initialize() }
        return id to describer
    }

    private fun checkFeatureStatus(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val (_, imageDescriber) = getOrCreateInstance(call)

        Futures.addCallback(
            imageDescriber.checkFeatureStatus(),
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
                    result.error("ImageDescriberError", e.toString(), null)
                }
            },
            executor,
        )
    }

    private fun downloadFeature(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val (_, imageDescriber) = getOrCreateInstance(call)

        imageDescriber.downloadFeature(
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

    private fun getBitmapFromData(
        imageData: Map<String, Any>,
        result: MethodChannel.Result,
    ): Bitmap? {
        return when (imageData["type"] as? String) {
            "bitmap" -> {
                val bitmapData =
                    imageData["bitmapData"] as? ByteArray
                        ?: return run {
                            result.error("ImageDescriberError", "Bitmap data is null", null)
                            null
                        }

                try {
                    val metadataMap = imageData["metadata"] as? Map<*, *>
                    if (metadataMap != null) {
                        val width = metadataMap["width"].toString().toDouble().toInt()
                        val height = metadataMap["height"].toString().toDouble().toInt()
                        val intBuffer = IntBuffer.allocate(bitmapData.size / 4)

                        for (i in bitmapData.indices step 4) {
                            val r = bitmapData[i].toInt() and 0xFF
                            val g = bitmapData[i + 1].toInt() and 0xFF
                            val b = bitmapData[i + 2].toInt() and 0xFF
                            val a = bitmapData[i + 3].toInt() and 0xFF
                            intBuffer.put((a shl 24) or (r shl 16) or (g shl 8) or b)
                        }
                        intBuffer.rewind()
                        bitmap.copyPixelsFromBuffer(intBuffer)
                        return bitmap
                    }
                } catch (e: Exception) {
                    Log.e("ImageError", "Error creating bitmap from raw data", e)
                }

                BitmapFactory.decodeByteArray(bitmapData, 0, bitmapData.size)
                    ?: return run {
                        result.error("ImageDescriberError", "Failed to decode bitmap from the provided data", null)
                        null
                    }
            }

            "file" -> {
                val path =
                    imageData["path"] as? String
                        ?: return run {
                            result.error("ImageDescriberError", "Image file path is null", null)
                            null
                        }
                val imageFile = File(path)
                if (!imageFile.exists()) {
                    result.error("ImageDescriberError", "Image file does not exist", null)
                    return null
                }
                BitmapFactory.decodeFile(imageFile.absolutePath)
                    ?: return run {
                        result.error("ImageDescriberError", "Failed to decode bitmap from file", null)
                        null
                    }
            }

            "bytes" -> {
                val bytes =
                    imageData["bytes"] as? ByteArray
                        ?: return run {
                            result.error("ImageDescriberError", "Image bytes are null", null)
                            null
                        }
                BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                    ?: return run {
                        result.error("ImageDescriberError", "Failed to decode bitmap from bytes", null)
                        null
                    }
            }

            else -> {
                run {
                    result.error("ImageDescriberError", "Invalid image type", null)
                    null
                }
            }
        }
    }

    private fun runInference(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val (_, imageDescriber) = getOrCreateInstance(call)
        val imageData = call.argument<Map<String, Any>>("imageData") ?: return

        val bitmap = getBitmapFromData(imageData, result) ?: return
        val request = ImageDescriptionRequest.builder(bitmap).build()

        Futures.addCallback(
            imageDescriber.runInference(request),
            object : FutureCallback<com.google.mlkit.genai.imagedescription.ImageDescriptionResult> {
                override fun onSuccess(imageDescriptionResult: com.google.mlkit.genai.imagedescription.ImageDescriptionResult?) {
                    result.success(mapOf("description" to imageDescriptionResult?.description))
                }

                override fun onFailure(e: Throwable) {
                    result.error("InferenceError", e.toString(), null)
                }
            },
            executor,
        )
    }

    private fun closeImageDescriber(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances[id]?.close()
        instances.remove(id)
    }
}
