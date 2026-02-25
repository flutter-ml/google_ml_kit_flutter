package com.google_mlkit_image_labeling

import android.content.Context
import com.google.mlkit.common.model.CustomRemoteModel
import com.google.mlkit.common.model.LocalModel
import com.google.mlkit.linkfirebase.FirebaseModelSource
import com.google.mlkit.vision.label.ImageLabeler
import com.google.mlkit.vision.label.ImageLabeling
import com.google.mlkit.vision.label.custom.CustomImageLabelerOptions
import com.google.mlkit.vision.label.defaults.ImageLabelerOptions
import com.google_mlkit_commons.GenericModelManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ImageLabelDetector(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, ImageLabeler>()
    private val genericModelManager = GenericModelManager()

    companion object {
        private const val START = "vision#startImageLabelDetector"
        private const val CLOSE = "vision#closeImageLabelDetector"
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
        var imageLabeler = instances[id]

        if (imageLabeler == null) {
            val options =
                call.argument<Map<String, Any>>("options") ?: run {
                    result.error("ImageLabelDetectorError", "Invalid options", null)
                    return
                }

            when (val type = options["type"] as? String) {
                "base" -> {
                    imageLabeler = ImageLabeling.getClient(getDefaultOptions(options))
                }

                "local" -> {
                    imageLabeler = ImageLabeling.getClient(getLocalOptions(options))
                }

                "remote" -> {
                    val confidenceThreshold = (options["confidenceThreshold"] as Double).toFloat()
                    val maxCount = options["maxCount"] as Int
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
                                startImageLabelDetector(
                                    ImageLabeling.getClient(
                                        CustomImageLabelerOptions
                                            .Builder(remoteModel)
                                            .setConfidenceThreshold(confidenceThreshold)
                                            .setMaxResultCount(maxCount)
                                            .build(),
                                    ),
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
            instances[id] = imageLabeler!!
        }

        startImageLabelDetector(imageLabeler, inputImage, result)
    }

    private fun startImageLabelDetector(
        imageLabeler: ImageLabeler,
        inputImage: com.google.mlkit.vision.common.InputImage,
        result: MethodChannel.Result,
    ) {
        imageLabeler
            .process(inputImage)
            .addOnSuccessListener { imageLabels ->
                val labels =
                    imageLabels.map { label ->
                        mapOf(
                            "text" to label.text,
                            "confidence" to label.confidence,
                            "index" to label.index,
                        )
                    }
                result.success(labels)
            }.addOnFailureListener { e ->
                result.error("ImageLabelDetectorError", e.toString(), null)
            }
    }

    private fun getDefaultOptions(labelerOptions: Map<String, Any>): ImageLabelerOptions {
        val confidenceThreshold = (labelerOptions["confidenceThreshold"] as Double).toFloat()
        return ImageLabelerOptions
            .Builder()
            .setConfidenceThreshold(confidenceThreshold)
            .build()
    }

    private fun getLocalOptions(labelerOptions: Map<String, Any>): CustomImageLabelerOptions {
        val confidenceThreshold = (labelerOptions["confidenceThreshold"] as Double).toFloat()
        val maxCount = labelerOptions["maxCount"] as Int
        val path = labelerOptions["path"] as String
        val localModel = LocalModel.Builder().setAbsoluteFilePath(path).build()
        return CustomImageLabelerOptions
            .Builder(localModel)
            .setConfidenceThreshold(confidenceThreshold)
            .setMaxResultCount(maxCount)
            .build()
    }

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
