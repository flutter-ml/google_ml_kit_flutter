package com.google_mlkit_object_detection;

import android.content.Context;
import android.graphics.Rect;

import androidx.annotation.NonNull;

import com.google.mlkit.common.model.CustomRemoteModel;
import com.google.mlkit.common.model.LocalModel;
import com.google.mlkit.linkfirebase.FirebaseModelSource;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.objects.DetectedObject;
import com.google.mlkit.vision.objects.ObjectDetection;
import com.google.mlkit.vision.objects.custom.CustomObjectDetectorOptions;
import com.google.mlkit.vision.objects.defaults.ObjectDetectorOptions;
import com.google_mlkit_commons.GenericModelManager;
import com.google_mlkit_commons.InputImageConverter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ObjectDetector implements MethodChannel.MethodCallHandler {
    private static final String START = "vision#startObjectDetector";
    private static final String CLOSE = "vision#closeObjectDetector";
    private static final String MANAGE = "vision#manageFirebaseModels";

    private final Context context;
    private final Map<String, com.google.mlkit.vision.objects.ObjectDetector> instances = new HashMap<>();
    private final GenericModelManager genericModelManager = new GenericModelManager();

    public ObjectDetector(Context context) {
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
            case MANAGE:
                manageModel(call, result);
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
        com.google.mlkit.vision.objects.ObjectDetector objectDetector = instances.get(id);
        if (objectDetector == null) {
            Map<String, Object> options = call.argument("options");
            if (options == null) {
                result.error("ImageLabelDetectorError", "Invalid options", null);
                return;
            }

            String type = (String) options.get("type");
            if (type.equals("base")) {
                ObjectDetectorOptions detectorOptions = getDefaultOptions(options);
                objectDetector = ObjectDetection.getClient(detectorOptions);
            } else if (type.equals("local")) {
                CustomObjectDetectorOptions detectorOptions = getLocalOptions(options);
                objectDetector = ObjectDetection.getClient(detectorOptions);
            } else if (type.equals("remote")) {
                CustomObjectDetectorOptions detectorOptions = getRemoteOptions(options);
                if (detectorOptions == null) {
                    result.error("Error Model has not been downloaded yet", "Model has not been downloaded yet", "Model has not been downloaded yet");
                    return;
                }
                objectDetector = ObjectDetection.getClient(detectorOptions);
            } else {
                String error = "Invalid model type: " + type;
                result.error(type, error, error);
                return;
            }
            instances.put(id, objectDetector);
        }

        objectDetector.process(inputImage).addOnSuccessListener(detectedObjects -> {
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
        }).addOnFailureListener(e -> {
            e.printStackTrace();
            result.error("ObjectDetectionError", e.toString(), null);
        });
    }

    private ObjectDetectorOptions getDefaultOptions(Map<String, Object> options) {
        int mode = (int) options.get("mode");
        mode = mode == 0 ?
                ObjectDetectorOptions.STREAM_MODE :
                ObjectDetectorOptions.SINGLE_IMAGE_MODE;
        boolean classify = (boolean) options.get("classify");
        boolean multiple = (boolean) options.get("multiple");

        ObjectDetectorOptions.Builder builder = new ObjectDetectorOptions.Builder()
                .setDetectorMode(mode);
        if (classify) builder.enableClassification();
        if (multiple) builder.enableMultipleObjects();
        return builder.build();
    }

    private CustomObjectDetectorOptions getLocalOptions(Map<String, Object> options) {
        int mode = (int) options.get("mode");
        mode = mode == 0 ?
                CustomObjectDetectorOptions.STREAM_MODE :
                CustomObjectDetectorOptions.SINGLE_IMAGE_MODE;
        boolean classify = (boolean) options.get("classify");
        boolean multiple = (boolean) options.get("multiple");
        double threshold = (double) options.get("threshold");
        int maxLabels = (int) options.get("maxLabels");
        String path = (String) options.get("path");

        LocalModel localModel = new LocalModel.Builder()
                .setAbsoluteFilePath(path)
                .build();

        CustomObjectDetectorOptions.Builder builder = new CustomObjectDetectorOptions.Builder(localModel);
        builder.setDetectorMode(mode);
        if (classify) builder.enableClassification();
        if (multiple) builder.enableMultipleObjects();
        builder.setMaxPerObjectLabelCount(maxLabels);
        builder.setClassificationConfidenceThreshold((float) threshold);
        return builder.build();
    }

    private CustomObjectDetectorOptions getRemoteOptions(Map<String, Object> options) {
        int mode = (int) options.get("mode");
        mode = mode == 0 ?
                CustomObjectDetectorOptions.STREAM_MODE :
                CustomObjectDetectorOptions.SINGLE_IMAGE_MODE;
        boolean classify = (boolean) options.get("classify");
        boolean multiple = (boolean) options.get("multiple");
        double threshold = (double) options.get("threshold");
        int maxLabels = (int) options.get("maxLabels");
        String name = (String) options.get("modelName");

        FirebaseModelSource firebaseModelSource = new FirebaseModelSource.Builder(name)
                .build();
        CustomRemoteModel remoteModel = new CustomRemoteModel.Builder(firebaseModelSource)
                .build();
        if (!genericModelManager.isModelDownloaded(remoteModel)) {
            return null;
        }

        CustomObjectDetectorOptions.Builder builder = new CustomObjectDetectorOptions.Builder(remoteModel);
        builder.setDetectorMode(mode);
        if (classify) builder.enableClassification();
        if (multiple) builder.enableMultipleObjects();
        builder.setMaxPerObjectLabelCount(maxLabels);
        builder.setClassificationConfidenceThreshold((float) threshold);
        return builder.build();
    }

    private void addData(Map<String, Object> addTo,
                         Integer trackingId,
                         Rect rect,
                         List<DetectedObject.Label> labelList) {
        List<Map<String, Object>> labels = new ArrayList<>();
        addLabels(labels, labelList);
        addTo.put("rect", getBoundingPoints(rect));
        addTo.put("labels", labels);
        addTo.put("trackingId", trackingId);
    }

    private Map<String, Integer> getBoundingPoints(Rect rect) {
        Map<String, Integer> frame = new HashMap<>();
        frame.put("left", rect.left);
        frame.put("top", rect.top);
        frame.put("right", rect.right);
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

    private void closeDetector(MethodCall call) {
        String id = call.argument("id");
        com.google.mlkit.vision.objects.ObjectDetector objectDetector = instances.get(id);
        if (objectDetector == null) return;
        objectDetector.close();
        instances.remove(id);
    }

    private void manageModel(MethodCall call, final MethodChannel.Result result) {
        FirebaseModelSource firebaseModelSource = new FirebaseModelSource.Builder(call.argument("model"))
                .build();
        CustomRemoteModel model = new CustomRemoteModel.Builder(firebaseModelSource)
                .build();
        genericModelManager.manageModel(model, call, result);
    }
}
