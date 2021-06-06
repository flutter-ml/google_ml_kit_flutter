package com.google_ml_kit.vision;

import android.content.Context;
import android.graphics.Point;
import android.graphics.Rect;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.objects.DetectedObject;
import com.google.mlkit.vision.objects.ObjectDetection;
import com.google.mlkit.vision.objects.defaults.ObjectDetectorOptions;
import com.google_ml_kit.ApiDetectorInterface;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ObjectDetector implements ApiDetectorInterface {
    private static final String START = "vision#startObjectDetector";
    private static final String CLOSE = "vision#closeObjectDetector";

    private final Context context;
    private com.google.mlkit.vision.objects.ObjectDetector objectDetector;

    public ObjectDetector(Context context) {
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
        String methodCall = call.method;
        if (methodCall.equals(START)) handleDetection(call, result);
        else close();
    }

    private void handleDetection(MethodCall call, final MethodChannel.Result result) {

        Map<String, Object> imageData = (Map<String, Object>) call.argument("imageData");
        InputImage inputImage = InputImageConverter.getInputImageFromData(imageData, context, result);

        if (inputImage == null) return;
        if (objectDetector == null)
            initiateDetector((Map<String, Object>) call.argument("options"));

        objectDetector.process(inputImage).addOnSuccessListener(new OnSuccessListener<List<DetectedObject>>() {
            @Override
            public void onSuccess(@NonNull List<DetectedObject> detectedObjects) {
                Log.e("Object Detection","success");
                if(detectedObjects.size()>0) Log.e("Detected Objects",detectedObjects.get(0).getLabels().toString());
                List<Map<String, Object>> objects = new ArrayList<>();
                for (DetectedObject detectedObject : detectedObjects) {
                    Map<String, Object> objectMap = new HashMap<>();

                    addData(objectMap,
                            detectedObject.getTrackingId(),
                            detectedObject.getBoundingBox(),
                            detectedObject.getLabels());

                    objects.add(objectMap);
                }
                result.success(objects);
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                e.printStackTrace();
                result.error("ObjectDetectionError", e.toString(), null);
            }
        });
    }

    private void initiateDetector(Map<String, Object> options) {
        ObjectDetectorOptions objectDetectorOptions;
        ObjectDetectorOptions.Builder builder = new ObjectDetectorOptions.Builder()
                .setDetectorMode(ObjectDetectorOptions.SINGLE_IMAGE_MODE);

        boolean classify = (boolean) options.get("classify");
        boolean multipleObjects = (boolean) options.get("multiple");

        if (classify) builder.enableClassification();
        if (multipleObjects) builder.enableMultipleObjects();

        objectDetectorOptions = builder.build();

        objectDetector = ObjectDetection.getClient(objectDetectorOptions);
    }

    private void addData(Map<String, Object> addTo,
                         Integer trackingId,
                         Rect rect,
                         List<DetectedObject.Label> labelList) {

        List<Map<String, Object>> labels = new ArrayList<>();
        addLabels(labels, labelList);

        addTo.put("rect", getBoundingPoints(rect));
        addTo.put("labels", labels);
        addTo.put("trackingID", trackingId);
    }

    private Map<String, Integer> getBoundingPoints(Rect rect) {
        Map<String, Integer> frame = new HashMap<>();
        frame.put("left", rect.left);
        frame.put("right", rect.right);
        frame.put("top", rect.top);
        frame.put("bottom", rect.bottom);
        return frame;
    }

    private void addLabels(List<Map<String, Object>> labels, List<DetectedObject.Label> labelList) {
        for (DetectedObject.Label label : labelList) {
            Map<String, Object> labelData = new HashMap<>();
            labelData.put("index", label.getIndex());
            labelData.put("text", label.getText());
            labelData.put("confidence", (double) label.getConfidence());
            labels.add(labelData);
        }
    }

    private void close() {
        objectDetector.close();
        objectDetector = null;
    }


}
