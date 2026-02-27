package com.google_mlkit_face_mesh_detection

import android.content.Context
import com.google.mlkit.vision.facemesh.FaceMesh
import com.google.mlkit.vision.facemesh.FaceMeshDetection
import com.google.mlkit.vision.facemesh.FaceMeshDetectorOptions
import com.google.mlkit.vision.facemesh.FaceMeshPoint
import com.google_mlkit_commons.InputImageConverter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FaceMeshDetector(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, com.google.mlkit.vision.facemesh.FaceMeshDetector>()

    companion object {
        private const val START = "vision#startFaceMeshDetector"
        private const val CLOSE = "vision#closeFaceMeshDetector"
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
                result.error("FaceMeshDetectorError", "imageData is null", null)
                return
            }
        val converter = InputImageConverter()
        val inputImage = converter.getInputImageFromData(imageData, context, result) ?: return

        val id = call.argument<String>("id")!!
        var detector = instances[id]

        if (detector == null) {
            detector =
                when (val option = call.argument<Int>("option")) {
                    FaceMeshDetectorOptions.BOUNDING_BOX_ONLY -> {
                        FaceMeshDetection.getClient(
                            FaceMeshDetectorOptions
                                .Builder()
                                .setUseCase(FaceMeshDetectorOptions.BOUNDING_BOX_ONLY)
                                .build(),
                        )
                    }

                    FaceMeshDetectorOptions.FACE_MESH -> {
                        FaceMeshDetection.getClient()
                    }

                    else -> {
                        result.error("FaceMeshDetectorError", "Invalid options", null)
                        return
                    }
                }
            instances[id] = detector
        }

        detector
            .process(inputImage)
            .addOnSuccessListener { visionMeshes ->
                val faceMeshes =
                    visionMeshes.map { mesh ->
                        val rect = mesh.boundingBox
                        val frame =
                            mapOf(
                                "left" to rect.left,
                                "top" to rect.top,
                                "right" to rect.right,
                                "bottom" to rect.bottom,
                            )

                        val triangles =
                            mesh.allTriangles.map { triangle ->
                                pointsToList(triangle.allPoints)
                            }

                        val types =
                            intArrayOf(
                                FaceMesh.FACE_OVAL,
                                FaceMesh.LEFT_EYEBROW_TOP,
                                FaceMesh.LEFT_EYEBROW_BOTTOM,
                                FaceMesh.RIGHT_EYEBROW_TOP,
                                FaceMesh.RIGHT_EYEBROW_BOTTOM,
                                FaceMesh.LEFT_EYE,
                                FaceMesh.RIGHT_EYE,
                                FaceMesh.UPPER_LIP_TOP,
                                FaceMesh.UPPER_LIP_BOTTOM,
                                FaceMesh.LOWER_LIP_TOP,
                                FaceMesh.LOWER_LIP_BOTTOM,
                                FaceMesh.NOSE_BRIDGE,
                            )

                        val contours =
                            types.associate { type ->
                                (type - 1) to pointsToList(mesh.getPoints(type))
                            }

                        mapOf(
                            "rect" to frame,
                            "points" to pointsToList(mesh.allPoints),
                            "triangles" to triangles,
                            "contours" to contours,
                        )
                    }
                result.success(faceMeshes)
            }.addOnFailureListener { e ->
                result.error("FaceMeshDetectorError", e.toString(), null)
            }.addOnCompleteListener { converter.close() }
    }

    private fun pointsToList(points: List<FaceMeshPoint>): List<Map<String, Any>> = points.map { pointToMap(it) }

    private fun pointToMap(point: FaceMeshPoint): Map<String, Any> =
        mapOf(
            "index" to point.index,
            "x" to point.position.x,
            "y" to point.position.y,
            "z" to point.position.z,
        )

    private fun closeDetector(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances[id]?.close()
        instances.remove(id)
    }
}
