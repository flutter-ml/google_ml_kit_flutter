package com.google_mlkit_image_labeling;

import android.content.Context;

import androidx.annotation.NonNull;

import com.google.mlkit.common.model.CustomRemoteModel;
import com.google.mlkit.common.model.LocalModel;
import com.google.mlkit.linkfirebase.FirebaseModelSource;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.label.ImageLabel;
import com.google.mlkit.vision.label.ImageLabeler;
import com.google.mlkit.vision.label.ImageLabeling;
import com.google.mlkit.vision.label.custom.CustomImageLabelerOptions;
import com.google.mlkit.vision.label.defaults.ImageLabelerOptions;
import com.google_mlkit_commons.GenericModelManager;
import com.google_mlkit_commons.InputImageConverter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ImageLabelDetector implements MethodChannel.MethodCallHandler {
    private static final String START = "vision#startImageLabelDetector";
    private static final String CLOSE = "vision#closeImageLabelDetector";
    private static final String MANAGE = "vision#manageFirebaseModels";

    private final Context context;
    private final Map<String, ImageLabeler> instances = new HashMap<>();
    private final GenericModelManager genericModelManager = new GenericModelManager();

    public ImageLabelDetector(Context context) {
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
        Map<String, Object> imageData = call.argument("imageData");
        InputImage inputImage = InputImageConverter.getInputImageFromData(imageData, context, result);
        if (inputImage == null) return;

        String id = call.argument("id");
        ImageLabeler imageLabeler = instances.get(id);
        if (imageLabeler == null) {
            Map<String, Object> options = call.argument("options");
            if (options == null) {
                result.error("ImageLabelDetectorError", "Invalid options", null);
                return;
            }

            String type = (String) options.get("type");
            if (type.equals("base")) {
                ImageLabelerOptions labelerOptions = getDefaultOptions(options);
                imageLabeler = ImageLabeling.getClient(labelerOptions);
            } else if (type.equals("local")) {
                CustomImageLabelerOptions labelerOptions = getLocalOptions(options);
                imageLabeler = ImageLabeling.getClient(labelerOptions);
            } else if (type.equals("remote")) {
                CustomImageLabelerOptions labelerOptions = getRemoteOptions(options);
                if (labelerOptions == null) {
                    result.error("Error Model has not been downloaded yet", "Model has not been downloaded yet", "Model has not been downloaded yet");
                    return;
                }
                imageLabeler = ImageLabeling.getClient(labelerOptions);
            } else {
                String error = "Invalid model type: " + type;
                result.error(type, error, error);
                return;
            }
            instances.put(id, imageLabeler);
        }

        imageLabeler.process(inputImage)
                .addOnSuccessListener(imageLabels -> {
                    List<Map<String, Object>> labels = new ArrayList<>(imageLabels.size());
                    for (ImageLabel label : imageLabels) {
                        Map<String, Object> labelData = new HashMap<>();
                        labelData.put("text", label.getText());
                        labelData.put("confidence", label.getConfidence());
                        labelData.put("index", label.getIndex());
                        labels.add(labelData);
                    }

                    result.success(labels);
                })
                .addOnFailureListener(e -> result.error("ImageLabelDetectorError", e.toString(), null));
    }

    //Labeler options that are provided to default image labeler(uses inbuilt model).
    private ImageLabelerOptions getDefaultOptions(Map<String, Object> labelerOptions) {
        float confidenceThreshold = (float) (double) labelerOptions.get("confidenceThreshold");
        return new ImageLabelerOptions.Builder()
                .setConfidenceThreshold(confidenceThreshold)
                .build();
    }

    //Options for labeler to work with custom model.
    private CustomImageLabelerOptions getLocalOptions(Map<String, Object> labelerOptions) {
        float confidenceThreshold = (float) (double) labelerOptions.get("confidenceThreshold");
        int maxCount = (int) labelerOptions.get("maxCount");
        String path = (String) labelerOptions.get("path");
        LocalModel localModel = new LocalModel.Builder()
                .setAbsoluteFilePath(path)
                .build();
        return new CustomImageLabelerOptions.Builder(localModel)
                .setConfidenceThreshold(confidenceThreshold)
                .setMaxResultCount(maxCount)
                .build();
    }

    //Options for labeler to work with custom model.
    private CustomImageLabelerOptions getRemoteOptions(Map<String, Object> labelerOptions) {
        float confidenceThreshold = (float) (double) labelerOptions.get("confidenceThreshold");
        int maxCount = (int) labelerOptions.get("maxCount");
        String name = (String) labelerOptions.get("modelName");

        FirebaseModelSource firebaseModelSource = new FirebaseModelSource.Builder(name).build();
        CustomRemoteModel remoteModel = new CustomRemoteModel.Builder(firebaseModelSource).build();
        if (!genericModelManager.isModelDownloaded(remoteModel)) {
            return null;
        }

        return new CustomImageLabelerOptions.Builder(remoteModel)
                .setConfidenceThreshold(confidenceThreshold)
                .setMaxResultCount(maxCount)
                .build();
    }

    private void closeDetector(MethodCall call) {
        String id = call.argument("id");
        ImageLabeler imageLabeler = instances.get(id);
        if (imageLabeler == null) return;
        imageLabeler.close();
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
