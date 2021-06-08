package com.google_ml_kit.vision;

import android.content.Context;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseDetection;
import com.google.mlkit.vision.pose.PoseLandmark;
import com.google.mlkit.vision.pose.accurate.AccuratePoseDetectorOptions;
import com.google.mlkit.vision.pose.defaults.PoseDetectorOptions;
import com.google_ml_kit.ApiDetectorInterface;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

//Detector to the pose landmarks present in a image.
//Creates an abstraction over PoseDetector provided by ml kit.
public class PoseDetector implements ApiDetectorInterface {
    private static final String START = "vision#startPoseDetector";
    private static final String CLOSE = "vision#closePoseDetector";

    private final Context context;
    private com.google.mlkit.vision.pose.PoseDetector poseDetector;

    public PoseDetector(Context context) {
        this.context = context;
    }

    @Override
    public List<String> getMethodsKeys() {
        return new ArrayList<>(
                Arrays.asList(START,
                        CLOSE));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        if (method.equals(START)) {
            handleDetection(call, result);
        } else if (method.equals(CLOSE)) {
            closeDetector();
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    private void handleDetection(MethodCall call, final MethodChannel.Result result) {
        Map<String, Object> imageData = (Map<String, Object>) call.argument("imageData");
        InputImage inputImage = InputImageConverter.getInputImageFromData(imageData, context, result);
        if (inputImage == null) return;

        Map<String, Object> options = call.argument("options");
        if (options == null) {
            result.error("PoseDetectorError", "Invalid options", null);
            return;
        }

        String model = (String) options.get("type");
        String mode = (String) options.get("mode");
        int detectorMode = PoseDetectorOptions.STREAM_MODE;
        if (mode.equals("single")) {
            detectorMode = PoseDetectorOptions.SINGLE_IMAGE_MODE;
        }
        if (model.equals("base")) {
            PoseDetectorOptions detectorOptions = new PoseDetectorOptions.Builder()
                    .setDetectorMode(detectorMode)
                    .build();
            poseDetector = PoseDetection.getClient(detectorOptions);
        } else {
            AccuratePoseDetectorOptions detectorOptions = new AccuratePoseDetectorOptions.Builder()
                    .setDetectorMode(detectorMode)
                    .build();
            poseDetector = PoseDetection.getClient(detectorOptions);
        }

        poseDetector.process(inputImage)
                .addOnSuccessListener(
                        new OnSuccessListener<Pose>() {
                            @Override
                            public void onSuccess(Pose pose) {
                                List<List<Map<String, Object>>> array = new ArrayList<>();
                                if (!pose.getAllPoseLandmarks().isEmpty()) {
                                    List<Map<String, Object>> landmarks = new ArrayList<>();
                                    for (PoseLandmark poseLandmark : pose.getAllPoseLandmarks()) {
                                        Map<String, Object> landmarkMap = new HashMap<>();
                                        landmarkMap.put("type", poseLandmark.getLandmarkType());
                                        landmarkMap.put("x", poseLandmark.getPosition().x);
                                        landmarkMap.put("y", poseLandmark.getPosition().y);
                                        landmarks.add(landmarkMap);
                                    }
                                    array.add(landmarks);
                                }
                                result.success(array);
                            }
                        })
                .addOnFailureListener(
                        new OnFailureListener() {
                            @Override
                            public void onFailure(@NonNull Exception e) {
                                result.error("PoseDetectorError", e.toString(), null);
                            }
                        });
    }

    private void closeDetector() {
        poseDetector.close();
    }
}
