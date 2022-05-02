package com.google_mlkit_face_detection;

import android.content.Context;
import android.graphics.PointF;
import android.graphics.Rect;

import androidx.annotation.NonNull;

import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.face.Face;
import com.google.mlkit.vision.face.FaceContour;
import com.google.mlkit.vision.face.FaceDetection;
import com.google.mlkit.vision.face.FaceDetectorOptions;
import com.google.mlkit.vision.face.FaceLandmark;
import com.google_mlkit_commons.InputImageConverter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

class FaceDetector implements MethodChannel.MethodCallHandler {
    private static final String START = "vision#startFaceDetector";
    private static final String CLOSE = "vision#closeFaceDetector";

    private final Context context;
    private final Map<String, com.google.mlkit.vision.face.FaceDetector> instances = new HashMap<>();

    public FaceDetector(Context context) {
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
        com.google.mlkit.vision.face.FaceDetector detector = instances.get(id);
        if (detector == null) {
            Map<String, Object> options = call.argument("options");
            if (options == null) {
                result.error("FaceDetectorError", "Invalid options", null);
                return;
            }

            FaceDetectorOptions detectorOptions = parseOptions(options);
            detector = FaceDetection.getClient(detectorOptions);
            instances.put(id, detector);
        }

        detector.process(inputImage)
                .addOnSuccessListener(
                        visionFaces -> {
                            List<Map<String, Object>> faces = new ArrayList<>(visionFaces.size());
                            for (Face face : visionFaces) {
                                Map<String, Object> faceData = new HashMap<>();

                                Map<String, Integer> frame = new HashMap<>();
                                Rect rect = face.getBoundingBox();
                                frame.put("left", rect.left);
                                frame.put("top", rect.top);
                                frame.put("right", rect.right);
                                frame.put("bottom", rect.bottom);
                                faceData.put("rect", frame);

                                faceData.put("headEulerAngleX", face.getHeadEulerAngleX());
                                faceData.put("headEulerAngleY", face.getHeadEulerAngleY());
                                faceData.put("headEulerAngleZ", face.getHeadEulerAngleZ());

                                if (face.getSmilingProbability() != null) {
                                    faceData.put("smilingProbability", face.getSmilingProbability());
                                }

                                if (face.getLeftEyeOpenProbability()
                                        != null) {
                                    faceData.put("leftEyeOpenProbability", face.getLeftEyeOpenProbability());
                                }

                                if (face.getRightEyeOpenProbability()
                                        != null) {
                                    faceData.put("rightEyeOpenProbability", face.getRightEyeOpenProbability());
                                }

                                if (face.getTrackingId() != null) {
                                    faceData.put("trackingId", face.getTrackingId());
                                }

                                faceData.put("landmarks", getLandmarkData(face));

                                faceData.put("contours", getContourData(face));

                                faces.add(faceData);
                            }

                            result.success(faces);
                        })
                .addOnFailureListener(
                        e -> result.error("FaceDetectorError", e.toString(), null));
    }

    private FaceDetectorOptions parseOptions(Map<String, Object> options) {
        int classification =
                (boolean) options.get("enableClassification")
                        ? FaceDetectorOptions.CLASSIFICATION_MODE_ALL
                        : FaceDetectorOptions.CLASSIFICATION_MODE_NONE;

        int landmark =
                (boolean) options.get("enableLandmarks")
                        ? FaceDetectorOptions.LANDMARK_MODE_ALL
                        : FaceDetectorOptions.LANDMARK_MODE_NONE;

        int contours =
                (boolean) options.get("enableContours")
                        ? FaceDetectorOptions.CONTOUR_MODE_ALL
                        : FaceDetectorOptions.CONTOUR_MODE_NONE;

        int mode;
        switch ((String) options.get("mode")) {
            case "accurate":
                mode = FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE;
                break;
            case "fast":
                mode = FaceDetectorOptions.PERFORMANCE_MODE_FAST;
                break;
            default:
                throw new IllegalArgumentException("Not a mode:" + options.get("mode"));
        }

        FaceDetectorOptions.Builder builder =
                new FaceDetectorOptions.Builder()
                        .setClassificationMode(classification)
                        .setLandmarkMode(landmark)
                        .setContourMode(contours)
                        .setMinFaceSize((float) ((double) options.get("minFaceSize")))
                        .setPerformanceMode(mode);

        if ((boolean) options.get("enableTracking")) {
            builder.enableTracking();
        }

        return builder.build();
    }

    private Map<String, double[]> getLandmarkData(Face face) {
        Map<String, double[]> landmarks = new HashMap<>();

        landmarks.put("bottomMouth", landmarkPosition(face, FaceLandmark.MOUTH_BOTTOM));
        landmarks.put("rightMouth", landmarkPosition(face, FaceLandmark.MOUTH_RIGHT));
        landmarks.put("leftMouth", landmarkPosition(face, FaceLandmark.MOUTH_LEFT));
        landmarks.put("rightEye", landmarkPosition(face, FaceLandmark.RIGHT_EYE));
        landmarks.put("leftEye", landmarkPosition(face, FaceLandmark.LEFT_EYE));
        landmarks.put("rightEar", landmarkPosition(face, FaceLandmark.RIGHT_EAR));
        landmarks.put("leftEar", landmarkPosition(face, FaceLandmark.LEFT_EAR));
        landmarks.put("rightCheek", landmarkPosition(face, FaceLandmark.RIGHT_CHEEK));
        landmarks.put("leftCheek", landmarkPosition(face, FaceLandmark.LEFT_CHEEK));
        landmarks.put("noseBase", landmarkPosition(face, FaceLandmark.NOSE_BASE));

        return landmarks;
    }

    private Map<String, List<double[]>> getContourData(Face face) {
        Map<String, List<double[]>> contours = new HashMap<>();

        contours.put("face", contourPosition(face, FaceContour.FACE));
        contours.put(
                "leftEyebrowTop", contourPosition(face, FaceContour.LEFT_EYEBROW_TOP));
        contours.put(
                "leftEyebrowBottom", contourPosition(face, FaceContour.LEFT_EYEBROW_BOTTOM));
        contours.put(
                "rightEyebrowTop", contourPosition(face, FaceContour.RIGHT_EYEBROW_TOP));
        contours.put(
                "rightEyebrowBottom",
                contourPosition(face, FaceContour.RIGHT_EYEBROW_BOTTOM));
        contours.put("leftEye", contourPosition(face, FaceContour.LEFT_EYE));
        contours.put("rightEye", contourPosition(face, FaceContour.RIGHT_EYE));
        contours.put("upperLipTop", contourPosition(face, FaceContour.UPPER_LIP_TOP));
        contours.put(
                "upperLipBottom", contourPosition(face, FaceContour.UPPER_LIP_BOTTOM));
        contours.put("lowerLipTop", contourPosition(face, FaceContour.LOWER_LIP_TOP));
        contours.put(
                "lowerLipBottom", contourPosition(face, FaceContour.LOWER_LIP_BOTTOM));
        contours.put("noseBridge", contourPosition(face, FaceContour.NOSE_BRIDGE));
        contours.put("noseBottom", contourPosition(face, FaceContour.NOSE_BOTTOM));
        contours.put("leftCheek", contourPosition(face, FaceContour.LEFT_CHEEK));
        contours.put("rightCheek", contourPosition(face, FaceContour.RIGHT_CHEEK));

        return contours;
    }

    private double[] landmarkPosition(Face face, int landmarkInt) {
        FaceLandmark landmark = face.getLandmark(landmarkInt);
        if (landmark != null) {
            return new double[]{landmark.getPosition().x, landmark.getPosition().y};
        }
        return null;
    }

    private List<double[]> contourPosition(Face face, int contourInt) {
        FaceContour contour = face.getContour(contourInt);
        if (contour != null) {
            List<PointF> contourPoints = contour.getPoints();
            List<double[]> result = new ArrayList<>();
            for (int i = 0; i < contourPoints.size(); i++) {
                result.add(new double[]{contourPoints.get(i).x, contourPoints.get(i).y});
            }
            return result;
        }
        return null;
    }

    private void closeDetector(MethodCall call) {
        String id = call.argument("id");
        com.google.mlkit.vision.face.FaceDetector detector = instances.get(id);
        if (detector == null) return;
        detector.close();
        instances.remove(id);
    }
}
