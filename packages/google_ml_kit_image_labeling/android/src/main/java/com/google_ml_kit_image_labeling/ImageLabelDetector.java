package com.google_ml_kit_image_labeling;

import android.content.Context;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.common.model.CustomRemoteModel;
import com.google.mlkit.common.model.LocalModel;
import com.google.mlkit.linkfirebase.FirebaseModelSource;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.label.ImageLabel;
import com.google.mlkit.vision.label.ImageLabeler;
import com.google.mlkit.vision.label.ImageLabeling;
import com.google.mlkit.vision.label.custom.CustomImageLabelerOptions;
import com.google.mlkit.vision.label.defaults.ImageLabelerOptions;
import com.google_ml_kit_commons.InputImageConverter;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

//Detector to identify the entities present in an image.
//It's an abstraction over ImageLabeler provided by ml tool kit.
public class ImageLabelDetector implements MethodChannel.MethodCallHandler {

    private static final String START = "vision#startImageLabelDetector";
    private static final String CLOSE = "vision#closeImageLabelDetector";

    private String type;
    private final Context context;
    private ImageLabeler imageLabeler;

    public ImageLabelDetector(Context context) {
        this.context = context;
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
            result.error("ImageLabelDetectorError", "Invalid options", null);
            return;
        }

        String labelerType = (String) options.get("labelerType");

        if (imageLabeler == null || type == null ||
                !type.equals(labelerType)) {
            type = labelerType;

            if (labelerType.equals("default")) {
                imageLabeler = ImageLabeling.getClient(getImageLabelerOptions(options));
            } else if (labelerType.equals("customLocal") || labelerType.equals("customRemote")) {
                imageLabeler = ImageLabeling.getClient(getCustomLabelerOptions(options));
            } else {
                imageLabeler = ImageLabeling.getClient(ImageLabelerOptions.DEFAULT_OPTIONS);
            }

        }


        imageLabeler.process(inputImage)
                .addOnSuccessListener(new OnSuccessListener<List<ImageLabel>>() {
                    @Override
                    public void onSuccess(List<ImageLabel> imageLabels) {
                        List<Map<String, Object>> labels = new ArrayList<>(imageLabels.size());
                        for (ImageLabel label : imageLabels) {
                            Map<String, Object> labelData = new HashMap<>();
                            labelData.put("text", label.getText());
                            labelData.put("confidence", label.getConfidence());
                            labelData.put("index", label.getIndex());
                            labels.add(labelData);
                        }

                        result.success(labels);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        result.error("ImageLabelDetectorError", e.toString(), null);
                    }
                });
    }

    //Labeler options that are provided to default image labeler(uses inbuilt model).
    private ImageLabelerOptions getImageLabelerOptions(Map<String, Object> labelerOptions) {
        final ImageLabelerOptions options =
                new ImageLabelerOptions.Builder()
                        .setConfidenceThreshold((float) (double) labelerOptions.get("confidenceThreshold"))
                        .build();
        return options;
    }

    //Options for labeler to work with custom model.
    private CustomImageLabelerOptions getCustomLabelerOptions(Map<String, Object> labelerOptions) {
        boolean isLocal = (boolean) labelerOptions.get("local");
        int maxCount = (int) labelerOptions.get("maxCount");
        if (isLocal) {
            String modelType = (String) labelerOptions.get("type");
            String path = (String) labelerOptions.get("path");
            LocalModel localModel;

            if (modelType.equals("asset")) {
                localModel = new LocalModel.Builder().setAssetFilePath(path).build();
            } else {
                localModel = new LocalModel.Builder().setAbsoluteFilePath(path).build();
            }
            return new CustomImageLabelerOptions.Builder(localModel)
                    .setConfidenceThreshold((float) (double) labelerOptions.get("confidenceThreshold"))
                    .setMaxResultCount(maxCount)
                    .build();
        }

        String name = (String) labelerOptions.get("modelName");

        CustomRemoteModel remoteModel = new CustomRemoteModel.Builder(
                new FirebaseModelSource.Builder(name).build()
        ).build();

        return new CustomImageLabelerOptions.Builder(remoteModel)
                .setConfidenceThreshold((float) (double) labelerOptions.get("confidenceThreshold"))
                .setMaxResultCount(maxCount)
                .build();
    }

    private void closeDetector() {
        imageLabeler.close();
        imageLabeler = null;
    }
}
