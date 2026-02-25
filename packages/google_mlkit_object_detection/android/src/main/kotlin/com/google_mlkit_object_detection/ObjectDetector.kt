package com.google_mlkit_object_detection

import android.content.Context
import android.graphics.Rect
import com.google.mlkit.common.model.CustomRemoteModel
import com.google.mlkit.common.model.LocalModel
import com.google.mlkit.linkfirebase.FirebaseModelSource
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.objects.DetectedObject
import com.google.mlkit.vision.objects.ObjectDetection
import com.google.mlkit.vision.objects.custom.CustomObjectDetectorOptions
import com.google.mlkit.vision.objects.defaults.ObjectDetectorOptions
import com.google_mlkit_commons.GenericModelManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ObjectDetector(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, com.google.mlkit.vision.objects.ObjectDetector>()
    private val genericModelManager = GenericModelManager()

    companion object {
        private const val START = "vision#startObjectDetector"
        private const val CLOSE = "vision#closeObjectDetector"
        private const val MANAGE = "vision#manageFirebaseModels"
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
        val imageData = call.argument<Map<String, Any>>("imageData")
        val inputImage = InputImageConverter.getInputImageFromData(imageData, context, result) ?: return

        val id = call.argument<String>("id") ?: return
        var objectDetector = instances[id]

        if (objectDetector == null) {
            val options =
                call.argument<Map<String, Any>>("options") ?: run {
                    result.error("ImageLabelDetectorError", "Invalid options", null)
                    return
                }

            when (val type = options["type"] as? String) {
                "base" -> {
                    objectDetector = ObjectDetection.getClient(getDefaultOptions(options))
                }

                "local" -> {
                    objectDetector = ObjectDetection.getClient(getLocalOptions(options))
                }

                "remote" -> {
                    val mode = options["mode"] as Int
                    val finalMode =
                        if (mode == 0) {
                            CustomObjectDetectorOptions.STREAM_MODE
                        } else {
                            CustomObjectDetectorOptions.SINGLE_IMAGE_MODE
                        }
                    val classify = options["classify"] as Boolean
                    val multiple = options["multiple"] as Boolean
                    val threshold = options["threshold"] as Double
                    val maxLabels = options["maxLabels"] as Int
                    val name = options["modelName"] as String

                    val firebaseModelSource = FirebaseModelSource.Builder(name).build()
                    val remoteModel = CustomRemoteModel.Builder(firebaseModelSource).build()

                    genericModelManager.isModelDownloaded(
                        remoteModel,
                        object : GenericModelManager.CheckModelIsDownloadedCallback {
                            override fun onCheckResult(isDownloaded: Boolean) {
                                if (!isDownloaded) {
                                    result.error(
                                        "Error Model has not been downloaded yet",
                                        "Model has not been downloaded yet",
                                        "Model has not been downloaded yet",
                                    )
                                    return
                                }

                                val builder =
                                    CustomObjectDetectorOptions
                                        .Builder(remoteModel)
                                        .setDetectorMode(finalMode)
                                        .setMaxPerObjectLabelCount(maxLabels)
                                        .setClassificationConfidenceThreshold(threshold.toFloat())
                                if (classify) builder.enableClassification()
                                if (multiple) builder.enableMultipleObjects()

                                startObjectDetection(
                                    ObjectDetection.getClient(builder.build()),
                                    inputImage,
                                    result,
                                )
                            }

                            override fun onError(e: Exception) {
                                result.error("Model download check failed", e.message, e)
                            }
                        },
                    )
                    return
                }

                else -> {
                    val error = "Invalid model type: $type"
                    result.error(type ?: "unknown", error, error)
                    return
                }
            }
            instances[id] = objectDetector!!
        }

        startObjectDetection(objectDetector, inputImage, result)
    }

    private fun startObjectDetection(
        objectDetector: com.google.mlkit.vision.objects.ObjectDetector,
        inputImage: InputImage,
        result: MethodChannel.Result,
    ) {
        objectDetector
            .process(inputImage)
            .addOnSuccessListener { detectedObjects ->
                val objects =
                    detectedObjects.map { detectedObject ->
                        mutableMapOf<String, Any?>().apply {
                            addData(this, detectedObject.trackingId, detectedObject.boundingBox, detectedObject.labels)
                        }
                    }
                result.success(objects)
            }.addOnFailureListener { e ->
                e.printStackTrace()
                result.error("ObjectDetectionError", e.toString(), null)
            }
    }

    private fun getDefaultOptions(options: Map<String, Any>): ObjectDetectorOptions {
        val mode =
            if (options["mode"] as Int == 0) {
                ObjectDetectorOptions.STREAM_MODE
            } else {
                ObjectDetectorOptions.SINGLE_IMAGE_MODE
            }
        val classify = options["classify"] as Boolean
        val multiple = options["multiple"] as Boolean

        return ObjectDetectorOptions
            .Builder()
            .setDetectorMode(mode)
            .apply {
                if (classify) enableClassification()
                if (multiple) enableMultipleObjects()
            }.build()
    }

    private fun getLocalOptions(options: Map<String, Any>): CustomObjectDetectorOptions {
        val mode =
            if (options["mode"] as Int == 0) {
                CustomObjectDetectorOptions.STREAM_MODE
            } else {
                CustomObjectDetectorOptions.SINGLE_IMAGE_MODE
            }
        val classify = options["classify"] as Boolean
        val multiple = options["multiple"] as Boolean
        val threshold = options["threshold"] as Double
        val maxLabels = options["maxLabels"] as Int
        val path = options["path"] as String

        val localModel = LocalModel.Builder().setAbsoluteFilePath(path).build()

        return CustomObjectDetectorOptions
            .Builder(localModel)
            .setDetectorMode(mode)
            .apply {
                if (classify) enableClassification()
                if (multiple) enableMultipleObjects()
            }.setMaxPerObjectLabelCount(maxLabels)
            .setClassificationConfidenceThreshold(threshold.toFloat())
            .build()
    }

    private fun addData(
        addTo: MutableMap<String, Any?>,
        trackingId: Int?,
        rect: Rect,
        labelList: List<DetectedObject.Label>,
    ) {
        addTo["rect"] = getBoundingPoints(rect)
        addTo["labels"] =
            labelList.map { label ->
                mapOf(
                    "index" to label.index,
                    "text" to label.text,
                    "confidence" to label.confidence.toDouble(),
                )
            }
        addTo["trackingId"] = trackingId
    }

    private fun getBoundingPoints(rect: Rect) =
        mapOf(
            "left" to rect.left,
            "top" to rect.top,
            "right" to rect.right,
            "bottom" to rect.bottom,
        )

    private fun closeDetector(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }

    private fun manageModel(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val firebaseModelSource = FirebaseModelSource.Builder(call.argument("model")).build()
        val model = CustomRemoteModel.Builder(firebaseModelSource).build()
        genericModelManager.manageModel(model, call, result)
    }
}
