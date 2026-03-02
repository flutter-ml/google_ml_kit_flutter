package com.google_mlkit_pose_detection

import android.content.Context
import com.google.mlkit.vision.pose.PoseDetection
import com.google.mlkit.vision.pose.PoseLandmark
import com.google.mlkit.vision.pose.accurate.AccuratePoseDetectorOptions
import com.google.mlkit.vision.pose.defaults.PoseDetectorOptions
import com.google_mlkit_commons.InputImageConverter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PoseDetector(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, com.google.mlkit.vision.pose.PoseDetector>()

    companion object {
        private const val START = "vision#startPoseDetector"
        private const val CLOSE = "vision#closePoseDetector"
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
                result.error("PoseDetectorError", "imageData is null", null)
                return
            }
            
        val inputImage = InputImageConverter.getInputImageFromData(imageData, context, result) ?: return

        val id = call.argument<String>("id") ?: return
        var poseDetector = instances[id]

        if (poseDetector == null) {
            val options =
                call.argument<Map<String, Any>>("options") ?: run {
                    result.error("PoseDetectorError", "Invalid options", null)
                    return
                }

            val detectorMode =
                if (options["mode"] as? String == "single") {
                    PoseDetectorOptions.SINGLE_IMAGE_MODE
                } else {
                    PoseDetectorOptions.STREAM_MODE
                }

            poseDetector =
                if (options["model"] as? String == "base") {
                    PoseDetection.getClient(
                        PoseDetectorOptions
                            .Builder()
                            .setDetectorMode(detectorMode)
                            .build(),
                    )
                } else {
                    PoseDetection.getClient(
                        AccuratePoseDetectorOptions
                            .Builder()
                            .setDetectorMode(detectorMode)
                            .build(),
                    )
                }
            instances[id] = poseDetector
        }

        poseDetector
            .process(inputImage)
            .addOnSuccessListener { pose ->
                val array = mutableListOf<List<Map<String, Any>>>()
                if (pose.allPoseLandmarks.isNotEmpty()) {
                    val landmarks =
                        pose.allPoseLandmarks.map { poseLandmark ->
                            mapOf(
                                "type" to poseLandmark.landmarkType,
                                "x" to poseLandmark.position3D.x,
                                "y" to poseLandmark.position3D.y,
                                "z" to poseLandmark.position3D.z,
                                "likelihood" to poseLandmark.inFrameLikelihood,
                            )
                        }
                    array.add(landmarks)
                }
                result.success(array)
            }.addOnFailureListener { e ->
                result.error("PoseDetectorError", e.toString(), null)
            }
    }

    private fun closeDetector(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }
}
