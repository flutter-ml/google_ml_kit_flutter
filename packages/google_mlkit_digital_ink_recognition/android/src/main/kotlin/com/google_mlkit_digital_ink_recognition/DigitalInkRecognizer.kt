package com.google_mlkit_digital_ink_recognition

import com.google.mlkit.common.MlKitException
import com.google.mlkit.vision.digitalink.common.RecognitionResult
import com.google.mlkit.vision.digitalink.recognition.DigitalInkRecognition
import com.google.mlkit.vision.digitalink.recognition.DigitalInkRecognitionModel
import com.google.mlkit.vision.digitalink.recognition.DigitalInkRecognitionModelIdentifier
import com.google.mlkit.vision.digitalink.recognition.DigitalInkRecognizerOptions
import com.google.mlkit.vision.digitalink.recognition.Ink
import com.google.mlkit.vision.digitalink.recognition.RecognitionContext
import com.google.mlkit.vision.digitalink.recognition.WritingArea
import com.google_mlkit_commons.GenericModelManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class DigitalInkRecognizer : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, com.google.mlkit.vision.digitalink.recognition.DigitalInkRecognizer>()
    private val genericModelManager = GenericModelManager()

    companion object {
        private const val START = "vision#startDigitalInkRecognizer"
        private const val CLOSE = "vision#closeDigitalInkRecognizer"
        private const val MANAGE = "vision#manageInkModels"
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
            }

            MANAGE -> {
                manageModel(call, result)
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
        val tag = call.argument<String>("model")
        val model = getModel(tag!!, result) ?: return

        genericModelManager.isModelDownloaded(
            model,
            object : GenericModelManager.CheckModelIsDownloadedCallback {
                override fun onCheckResult(isDownloaded: Boolean?) {
                    if (isDownloaded == false) {
                        result.error("Model Error", "Model has not been downloaded yet", null)
                        return
                    }
                    handleInkDetectionIfModelDownloaded(call, result, model)
                }

                override fun onError(e: Exception) {
                    result.error("Model download check failed", e.toString(), e)
                }
            },
        )
    }

    private fun handleInkDetectionIfModelDownloaded(
        call: MethodCall,
        result: MethodChannel.Result,
        model: DigitalInkRecognitionModel,
    ) {
        val id = call.argument<String>("id")!!
        val recognizer =
            instances.getOrPut(id) {
                DigitalInkRecognition.getClient(DigitalInkRecognizerOptions.builder(model).build())
            }

        val inkMap = call.argument<Map<String, Any>>("ink")!!
        val strokeList = inkMap["strokes"] as List<Map<String, Any>>
        val inkBuilder = Ink.builder()

        for (strokeMap in strokeList) {
            val strokeBuilder = Ink.Stroke.builder()
            val pointsList = strokeMap["points"] as List<Map<String, Any>>
            for (point in pointsList) {
                val x = (point["x"] as Double).toFloat()
                val y = (point["y"] as Double).toFloat()
                val t =
                    when (val t0 = point["t"]) {
                        is Int -> t0.toLong()
                        else -> t0 as Long
                    }

                strokeBuilder.addPoint(Ink.Point.create(x, y, t))
            }
            inkBuilder.addStroke(strokeBuilder.build())
        }

        val ink = inkBuilder.build()

        val contextMap = call.argument<Map<String, Any>>("context")
        val context =
            contextMap?.let {
                val builder = RecognitionContext.builder()
                builder.setPreContext((it["preContext"] as? String) ?: "")

                (it["writingArea"] as? Map<*, *>)?.let { areaMap ->
                    val width = (areaMap["width"] as Double).toFloat()
                    val height = (areaMap["height"] as Double).toFloat()
                    builder.setWritingArea(WritingArea(width, height))
                }
                builder.build()
            }

        val onSuccess = { recognitionResult: RecognitionResult -> process(recognitionResult, result) }
        val onFailure = { e: Exception -> result.error("recognition Error", e.toString(), null) }

        if (context != null) {
            recognizer
                .recognize(ink, context)
                .addOnSuccessListener(onSuccess)
                .addOnFailureListener(onFailure)
        } else {
            recognizer
                .recognize(ink)
                .addOnSuccessListener(onSuccess)
                .addOnFailureListener(onFailure)
        }
    }

    private fun process(
        recognitionResult: RecognitionResult,
        result: MethodChannel.Result,
    ) {
        val candidateList =
            recognitionResult.candidates.map { candidate ->
                mapOf(
                    "text" to candidate.text,
                    "score" to (candidate.score?.toDouble() ?: 0.0),
                )
            }
        result.success(candidateList)
    }

    private fun getModel(
        tag: String,
        result: MethodChannel.Result,
    ): DigitalInkRecognitionModel? {
        val modelIdentifier =
            try {
                DigitalInkRecognitionModelIdentifier.fromLanguageTag(tag)
            } catch (e: MlKitException) {
                result.error("Failed to create model identifier", e.toString(), null)
                return null
            }

        if (modelIdentifier == null) {
            result.error("Model Identifier error", "No model was found", null)
            return null
        }

        return DigitalInkRecognitionModel.builder(modelIdentifier).build()
    }

    private fun manageModel(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
    }

    private fun closeDetector(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }
}
