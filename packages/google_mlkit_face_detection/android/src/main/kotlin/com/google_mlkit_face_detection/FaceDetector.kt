package com.google_mlkit_face_detection

import android.content.Context
import com.google.mlkit.vision.face.Face
import com.google.mlkit.vision.face.FaceContour
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions
import com.google.mlkit.vision.face.FaceLandmark
import com.google_mlkit_commons.InputImageConverter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FaceDetector(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, com.google.mlkit.vision.face.FaceDetector>()

    companion object {
        private const val START = "vision#startFaceDetector"
        private const val CLOSE = "vision#closeFaceDetector"
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
                result.error("FaceDetectorError", "imageData is null", null)
                return
            }
        val inputImage = InputImageConverter.getInputImageFromData(imageData, context, result) ?: return

        val id = call.argument<String>("id")!!
        val detector =
            instances.getOrPut(id) {
                val options =
                    call.argument<Map<String, Any>>("options")
                        ?: return result.error("FaceDetectorError", "Invalid options", null)
                FaceDetection.getClient(parseOptions(options))
            }

        detector
            .process(inputImage)
            .addOnSuccessListener { visionFaces ->
                val faces =
                    visionFaces.map { face ->
                        buildMap<String, Any?> {
                            val rect = face.boundingBox
                            put(
                                "rect",
                                mapOf(
                                    "left" to rect.left,
                                    "top" to rect.top,
                                    "right" to rect.right,
                                    "bottom" to rect.bottom,
                                ),
                            )
                            put("headEulerAngleX", face.headEulerAngleX)
                            put("headEulerAngleY", face.headEulerAngleY)
                            put("headEulerAngleZ", face.headEulerAngleZ)
                            face.smilingProbability?.let { put("smilingProbability", it) }
                            face.leftEyeOpenProbability?.let { put("leftEyeOpenProbability", it) }
                            face.rightEyeOpenProbability?.let { put("rightEyeOpenProbability", it) }
                            face.trackingId?.let { put("trackingId", it) }
                            put("landmarks", getLandmarkData(face))
                            put("contours", getContourData(face))
                        }
                    }
                result.success(faces)
            }.addOnFailureListener { e ->
                result.error("FaceDetectorError", e.toString(), null)
            }
    }

    private fun parseOptions(options: Map<String, Any>): FaceDetectorOptions {
        val classification =
            if (options["enableClassification"] as Boolean) {
                FaceDetectorOptions.CLASSIFICATION_MODE_ALL
            } else {
                FaceDetectorOptions.CLASSIFICATION_MODE_NONE
            }

        val landmark =
            if (options["enableLandmarks"] as Boolean) {
                FaceDetectorOptions.LANDMARK_MODE_ALL
            } else {
                FaceDetectorOptions.LANDMARK_MODE_NONE
            }

        val contours =
            if (options["enableContours"] as Boolean) {
                FaceDetectorOptions.CONTOUR_MODE_ALL
            } else {
                FaceDetectorOptions.CONTOUR_MODE_NONE
            }

        val mode =
            when (options["mode"] as String) {
                "accurate" -> FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE
                "fast" -> FaceDetectorOptions.PERFORMANCE_MODE_FAST
                else -> throw IllegalArgumentException("Not a mode: ${options["mode"]}")
            }

        return FaceDetectorOptions
            .Builder()
            .setClassificationMode(classification)
            .setLandmarkMode(landmark)
            .setContourMode(contours)
            .setMinFaceSize((options["minFaceSize"] as Double).toFloat())
            .setPerformanceMode(mode)
            .apply {
                if (options["enableTracking"] as Boolean) enableTracking()
            }.build()
    }

    private fun getLandmarkData(face: Face): Map<String, DoubleArray?> =
        mapOf(
            "bottomMouth" to landmarkPosition(face, FaceLandmark.MOUTH_BOTTOM),
            "rightMouth" to landmarkPosition(face, FaceLandmark.MOUTH_RIGHT),
            "leftMouth" to landmarkPosition(face, FaceLandmark.MOUTH_LEFT),
            "rightEye" to landmarkPosition(face, FaceLandmark.RIGHT_EYE),
            "leftEye" to landmarkPosition(face, FaceLandmark.LEFT_EYE),
            "rightEar" to landmarkPosition(face, FaceLandmark.RIGHT_EAR),
            "leftEar" to landmarkPosition(face, FaceLandmark.LEFT_EAR),
            "rightCheek" to landmarkPosition(face, FaceLandmark.RIGHT_CHEEK),
            "leftCheek" to landmarkPosition(face, FaceLandmark.LEFT_CHEEK),
            "noseBase" to landmarkPosition(face, FaceLandmark.NOSE_BASE),
        )

    private fun getContourData(face: Face): Map<String, List<DoubleArray>?> =
        mapOf(
            "face" to contourPosition(face, FaceContour.FACE),
            "leftEyebrowTop" to contourPosition(face, FaceContour.LEFT_EYEBROW_TOP),
            "leftEyebrowBottom" to contourPosition(face, FaceContour.LEFT_EYEBROW_BOTTOM),
            "rightEyebrowTop" to contourPosition(face, FaceContour.RIGHT_EYEBROW_TOP),
            "rightEyebrowBottom" to contourPosition(face, FaceContour.RIGHT_EYEBROW_BOTTOM),
            "leftEye" to contourPosition(face, FaceContour.LEFT_EYE),
            "rightEye" to contourPosition(face, FaceContour.RIGHT_EYE),
            "upperLipTop" to contourPosition(face, FaceContour.UPPER_LIP_TOP),
            "upperLipBottom" to contourPosition(face, FaceContour.UPPER_LIP_BOTTOM),
            "lowerLipTop" to contourPosition(face, FaceContour.LOWER_LIP_TOP),
            "lowerLipBottom" to contourPosition(face, FaceContour.LOWER_LIP_BOTTOM),
            "noseBridge" to contourPosition(face, FaceContour.NOSE_BRIDGE),
            "noseBottom" to contourPosition(face, FaceContour.NOSE_BOTTOM),
            "leftCheek" to contourPosition(face, FaceContour.LEFT_CHEEK),
            "rightCheek" to contourPosition(face, FaceContour.RIGHT_CHEEK),
        )

    private fun landmarkPosition(
        face: Face,
        landmarkInt: Int,
    ): DoubleArray? =
        face.getLandmark(landmarkInt)?.position?.let {
            doubleArrayOf(it.x.toDouble(), it.y.toDouble())
        }

    private fun contourPosition(
        face: Face,
        contourInt: Int,
    ): List<DoubleArray>? =
        face.getContour(contourInt)?.points?.map {
            doubleArrayOf(it.x.toDouble(), it.y.toDouble())
        }

    private fun closeDetector(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }
}
