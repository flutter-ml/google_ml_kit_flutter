package com.b.biradar.google_ml_kit.vision;

import android.content.Context;

import androidx.annotation.NonNull;

import com.b.biradar.google_ml_kit.ApiDetectorInterface;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;

import com.google.mlkit.common.model.LocalModel;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.label.ImageLabel;
import com.google.mlkit.vision.label.ImageLabeler;
import com.google.mlkit.vision.label.ImageLabeling;
import com.google.mlkit.vision.label.automl.AutoMLImageLabelerLocalModel;
import com.google.mlkit.vision.label.automl.AutoMLImageLabelerOptions;
import com.google.mlkit.vision.label.defaults.ImageLabelerOptions;
import com.google.mlkit.vision.label.custom.CustomImageLabelerOptions;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

//Detector to identify the entities present in an image.
//It's an abstraction over ImageLabeler provided by ml tool kit.
public class ImageLabelDetector implements ApiDetectorInterface {
    private static final String START = "vision#startImageLabelDetector";
    private static final String CLOSE = "vision#closeImageLabelDetector";

    private final Context context;
    private ImageLabeler imageLabeler;

    public ImageLabelDetector(Context context) {
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
            result.error("ImageLabelDetectorError", "Invalid options", null);
            return;
        }

        String labelerType = (String) options.get("labelerType");
        if (labelerType.equals("default")) {
            imageLabeler = ImageLabeling.getClient(getImageLabelerOptions(options));
        } else if (labelerType.equals("custom")) {
            imageLabeler = ImageLabeling.getClient(getCustomLabelerOptions(options));
        }  else {
            imageLabeler = ImageLabeling.getClient(ImageLabelerOptions.DEFAULT_OPTIONS);
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
        String modelType = (String) labelerOptions.get("customModel");
        String path = (String) labelerOptions.get("path");
        LocalModel localModel;
        if (modelType.equals("asset")) {
            localModel = new LocalModel.Builder().setAssetFilePath(path).build();
        } else {
            localModel = new LocalModel.Builder().setAbsoluteFilePath(path).build();
        }
        CustomImageLabelerOptions customImageLabelerOptions =
                new CustomImageLabelerOptions.Builder(localModel)
                        .setConfidenceThreshold((float) (double) labelerOptions.get("confidenceThreshold"))
                        .build();
        return customImageLabelerOptions;
    }

    //Options for labeler to work with AutoMlVisionModel
    private AutoMLImageLabelerOptions getAutoMLImageLabelerOptions(Map<String, Object> labelerOptions) {
        String modelType = (String) labelerOptions.get("customModel");
        String path = (String) labelerOptions.get("path");
        AutoMLImageLabelerLocalModel autoMLImageLabelerLocalModel;
        if (modelType.equals("assets")) {
            autoMLImageLabelerLocalModel =
                    new AutoMLImageLabelerLocalModel.Builder()
                            .setAssetFilePath(path)
                            .build();
        } else {
            autoMLImageLabelerLocalModel = new AutoMLImageLabelerLocalModel.Builder().setAbsoluteFilePath(path).build();
        }

        AutoMLImageLabelerOptions autoMLImageLabelerOptions =
                new AutoMLImageLabelerOptions.Builder(autoMLImageLabelerLocalModel)
                        .setConfidenceThreshold((float) (double) labelerOptions.get("confidenceThreshold"))
                        .build();

        return autoMLImageLabelerOptions;
    }

    private void closeDetector() {
        imageLabeler.close();
    }
}
