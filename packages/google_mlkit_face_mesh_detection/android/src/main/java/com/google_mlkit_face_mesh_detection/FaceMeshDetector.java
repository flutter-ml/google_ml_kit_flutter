package com.google_mlkit_face_mesh_detection;

import android.content.Context;
import android.graphics.Rect;

import androidx.annotation.NonNull;

import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.common.Triangle;
import com.google.mlkit.vision.facemesh.FaceMesh;
import com.google.mlkit.vision.facemesh.FaceMeshDetection;
import com.google.mlkit.vision.facemesh.FaceMeshDetectorOptions;
import com.google.mlkit.vision.facemesh.FaceMeshPoint;
import com.google_mlkit_commons.InputImageConverter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

class FaceMeshDetector implements MethodChannel.MethodCallHandler {
    private static final String START = "vision#startFaceMeshDetector";
    private static final String CLOSE = "vision#closeFaceMeshDetector";

    private final Context context;
    private final Map<String, com.google.mlkit.vision.facemesh.FaceMeshDetector> instances = new HashMap<>();

    public FaceMeshDetector(Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        switch (method) {
            case START:
                handleDetection(call, result);
                break;
            case CLOSE:
                closeDetector(call);
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void handleDetection(MethodCall call, final MethodChannel.Result result) {
        Map<String, Object> imageData = (Map<String, Object>) call.argument("imageData");
        InputImage inputImage = InputImageConverter.getInputImageFromData(imageData, context, result);
        if (inputImage == null) return;

        String id = call.argument("id");
        com.google.mlkit.vision.facemesh.FaceMeshDetector detector = instances.get(id);
        if (detector == null) {
            int option = call.argument("option");
            switch (option) {
                case FaceMeshDetectorOptions.BOUNDING_BOX_ONLY:
                    detector = FaceMeshDetection.getClient(
                            new FaceMeshDetectorOptions.Builder()
                                    .setUseCase(FaceMeshDetectorOptions.BOUNDING_BOX_ONLY)
                                    .build()
                    );
                    break;

                case FaceMeshDetectorOptions.FACE_MESH:
                    detector = FaceMeshDetection.getClient();

                    break;

                default:
                    result.error("FaceMeshDetectorError", "Invalid options", null);
                    return;
            }

            instances.put(id, detector);
        }

        detector.process(inputImage)
                .addOnSuccessListener(
                        visionMeshes -> {
                            List<Map<String, Object>> faceMeshes = new ArrayList<>(visionMeshes.size());
                            for (FaceMesh mesh : visionMeshes) {
                                Map<String, Object> meshData = new HashMap<>();

                                Map<String, Integer> frame = new HashMap<>();
                                Rect rect = mesh.getBoundingBox();
                                frame.put("left", rect.left);
                                frame.put("top", rect.top);
                                frame.put("right", rect.right);
                                frame.put("bottom", rect.bottom);
                                meshData.put("rect", frame);

                                meshData.put("points", pointsToList(mesh.getAllPoints()));

                                List<List<Map<String, Object>>> triangles = new ArrayList<>();
                                for (Triangle<FaceMeshPoint> triangle : mesh.getAllTriangles()) {
                                    triangles.add(pointsToList(triangle.getAllPoints()));
                                }
                                meshData.put("triangles", triangles);

                                int[] types = {
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
                                        FaceMesh.NOSE_BRIDGE
                                };
                                Map<Integer, List<Map<String, Object>>> contours = new HashMap<>();
                                for (int type : types) {
                                    contours.put(type - 1, pointsToList(mesh.getPoints(type)));
                                }
                                meshData.put("contours", contours);

                                faceMeshes.add(meshData);
                            }

                            result.success(faceMeshes);
                        })
                .addOnFailureListener(
                        e -> result.error("FaceMeshDetectorError", e.toString(), null));
    }

    private List<Map<String, Object>> pointsToList(List<FaceMeshPoint> points) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (FaceMeshPoint point : points) {
            list.add(pointToMap(point));
        }
        return list;
    }

    private Map<String, Object> pointToMap(FaceMeshPoint point) {
        Map<String, Object> pointMap = new HashMap<>();
        pointMap.put("index", point.getIndex());
        pointMap.put("x", point.getPosition().getX());
        pointMap.put("y", point.getPosition().getY());
        pointMap.put("z", point.getPosition().getZ());
        return pointMap;
    }

    private void closeDetector(MethodCall call) {
        String id = call.argument("id");
        com.google.mlkit.vision.facemesh.FaceMeshDetector detector = instances.get(id);
        if (detector == null) return;
        detector.close();
        instances.remove(id);
    }
}
