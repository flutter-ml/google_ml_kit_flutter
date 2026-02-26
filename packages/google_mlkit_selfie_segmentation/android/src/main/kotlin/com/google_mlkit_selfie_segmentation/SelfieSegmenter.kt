package com.google_mlkit_selfie_segmentation

import android.content.Context
import com.google.mlkit.vision.segmentation.Segmentation
import com.google.mlkit.vision.segmentation.Segmenter
import com.google.mlkit.vision.segmentation.selfie.SelfieSegmenterOptions
import com.google_mlkit_commons.InputImageConverter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SelfieSegmenter(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, Segmenter>()

    companion object {
        private const val START = "vision#startSelfieSegmenter"
        private const val CLOSE = "vision#closeSelfieSegmenter"
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            START -> {
                handleDetection(call, result)
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

    private fun initialize(call: MethodCall): Segmenter {
        val isStream = call.argument<Boolean>("isStream") ?: false
        val enableRawSizeMask = call.argument<Boolean>("enableRawSizeMask") ?: false

        val options =
            SelfieSegmenterOptions
                .Builder()
                .setDetectorMode(
                    if (isStream) {
                        SelfieSegmenterOptions.STREAM_MODE
                    } else {
                        SelfieSegmenterOptions.SINGLE_IMAGE_MODE
                    },
                ).apply { if (enableRawSizeMask) enableRawSizeMask() }
                .build()

        return Segmentation.getClient(options)
    }

    private fun handleDetection(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val imageData =
            call.argument<Map<String, Any>>("imageData") ?: run {
                result.error("SelfieSegmenterError", "imageData is null", null)
                return
            }
        val inputImage = InputImageConverter.getInputImageFromData(imageData, context, result) ?: return

        val id = call.argument<String>("id") ?: return
        val segmenter = instances.getOrPut(id) { initialize(call) }

        segmenter
            .process(inputImage)
            .addOnSuccessListener { segmentationMask ->
                val mask = segmentationMask.buffer
                val maskWidth = segmentationMask.width
                val maskHeight = segmentationMask.height

                val confidences =
                    FloatArray(maskWidth * maskHeight) { i ->
                        val y = i / maskWidth
                        val x = i % maskWidth
                        mask.getFloat()
                    }

                result.success(
                    mapOf(
                        "width" to maskWidth,
                        "height" to maskHeight,
                        "confidences" to confidences,
                    ),
                )
            }.addOnFailureListener { e ->
                result.error("Selfie segmentation failed!", e.message, e)
            }
    }

    private fun closeDetector(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }
}
