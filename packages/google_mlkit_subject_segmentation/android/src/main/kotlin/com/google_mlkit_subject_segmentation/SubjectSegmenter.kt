package com.google_mlkit_subject_segmentation

import android.content.Context
import android.graphics.Bitmap
import com.google.mlkit.vision.segmentation.subject.Subject
import com.google.mlkit.vision.segmentation.subject.SubjectSegmentation
import com.google.mlkit.vision.segmentation.subject.SubjectSegmentationResult
import com.google.mlkit.vision.segmentation.subject.SubjectSegmenterOptions
import com.google_mlkit_commons.InputImageConverter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.nio.FloatBuffer

class SubjectSegmenter(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, com.google.mlkit.vision.segmentation.subject.SubjectSegmenter>()

    companion object {
        private const val START = "vision#startSubjectSegmenter"
        private const val CLOSE = "vision#closeSubjectSegmenter"

        private fun getConfidenceMask(floatBuffer: FloatBuffer): FloatArray {
            val mask = FloatArray(floatBuffer.remaining())
            floatBuffer.get(mask)
            return mask
        }

        private fun getBitmapBytes(bitmap: Bitmap): ByteArray {
            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            return outputStream.toByteArray()
        }

        private fun getSubjectMap(subject: Subject): Map<String, Any> =
            mutableMapOf<String, Any>(
                "startX" to subject.startX,
                "startY" to subject.startY,
                "width" to subject.width,
                "height" to subject.height,
            ).apply {
                subject.confidenceMask?.let { put("confidenceMask", getConfidenceMask(it)) }
                subject.bitmap?.let { put("bitmap", getBitmapBytes(it)) }
            }
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

    private fun handleDetection(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val imageData =
            call.argument<Map<String, Any>>("imageData") ?: run {
                result.error("SubjectSegmenterError", "imageData is nulll", null)
                return
            }
        val inputImage = InputImageConverter.getInputImageFromData(imageData, context, result) ?: return

        val id = call.argument<String>("id") ?: return
        val segmenter = instances.getOrPut(id) { initialize(call) }

        segmenter
            .process(inputImage)
            .addOnSuccessListener { processResult(it, result) }
            .addOnFailureListener { e -> result.error("Subject segmentation failure!", e.message, e) }
    }

    private fun initialize(call: MethodCall): com.google.mlkit.vision.segmentation.subject.SubjectSegmenter {
        val options = call.argument<Map<String, Any>>("options") ?: emptyMap()
        val builder = SubjectSegmenterOptions.Builder()
        configureBuilder(builder, options)
        return SubjectSegmentation.getClient(builder.build())
    }

    private fun configureBuilder(
        builder: SubjectSegmenterOptions.Builder,
        options: Map<String, Any>,
    ) {
        if (options["enableForegroundBitmap"] == true) builder.enableForegroundBitmap()
        if (options["enableForegroundConfidenceMask"] == true) builder.enableForegroundConfidenceMask()

        @Suppress("UNCHECKED_CAST")
        (options["enableMultiSubjectBitmap"] as? Map<String, Any>)?.let {
            configureMultipleSubjects(builder, it)
        }
    }

    private fun configureMultipleSubjects(
        builder: SubjectSegmenterOptions.Builder,
        options: Map<String, Any>,
    ) {
        val enableConfidenceMask = options["enableConfidenceMask"] == true
        val enableSubjectBitmap = options["enableSubjectBitmap"] == true

        if (enableConfidenceMask || enableSubjectBitmap) {
            val subjectOptionsBuilder = SubjectSegmenterOptions.SubjectResultOptions.Builder()
            if (enableConfidenceMask) subjectOptionsBuilder.enableConfidenceMask()
            if (enableSubjectBitmap) subjectOptionsBuilder.enableSubjectBitmap()
            builder.enableMultipleSubjects(subjectOptionsBuilder.build())
        }
    }

    private fun processResult(
        segmentationResult: SubjectSegmentationResult,
        result: MethodChannel.Result,
    ) {
        val resultMap = mutableMapOf<String, Any>()

        segmentationResult.foregroundConfidenceMask?.let {
            resultMap["foregroundConfidenceMask"] = getConfidenceMask(it)
        }
        segmentationResult.foregroundBitmap?.let {
            resultMap["foregroundBitmap"] = getBitmapBytes(it)
        }
        resultMap["subjects"] = segmentationResult.subjects.map { getSubjectMap(it) }

        result.success(resultMap)
    }

    private fun closeDetector(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }
}
