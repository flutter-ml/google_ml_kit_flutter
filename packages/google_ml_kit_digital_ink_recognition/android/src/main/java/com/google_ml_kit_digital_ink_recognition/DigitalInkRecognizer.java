package com.google_ml_kit_digital_ink_recognition;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.mlkit.common.MlKitException;
import com.google.mlkit.common.model.DownloadConditions;
import com.google.mlkit.vision.digitalink.DigitalInkRecognition;
import com.google.mlkit.vision.digitalink.DigitalInkRecognitionModel;
import com.google.mlkit.vision.digitalink.DigitalInkRecognitionModelIdentifier;
import com.google.mlkit.vision.digitalink.DigitalInkRecognizerOptions;
import com.google.mlkit.vision.digitalink.Ink;
import com.google.mlkit.vision.digitalink.RecognitionCandidate;
import com.google_ml_kit_commons.GenericModelManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class DigitalInkRecognizer implements MethodChannel.MethodCallHandler {

    private static final String START = "vision#startDigitalInkRecognizer";
    private static final String CLOSE = "vision#closeDigitalInkRecognizer";
    private static final String MANAGE = "vision#manageInkModels";

    private com.google.mlkit.vision.digitalink.DigitalInkRecognizer recognizer;
    private final GenericModelManager genericModelManager = new GenericModelManager();

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        if (START.equals(method)) {
            handleDetection(call, result);
        } else if (MANAGE.equals(method)) {
            manageInkModels(call, result);
        } else if (CLOSE.equals(method)) {
            closeDetector();
        } else {
            result.notImplemented();
        }
    }

    private void handleDetection(MethodCall call, final MethodChannel.Result result) {
        DigitalInkRecognitionModel model = getModel(call, result);
        if (genericModelManager.isModelDownloaded(model)) {
            recognizer = DigitalInkRecognition.getClient(DigitalInkRecognizerOptions.builder(model).build());
        } else {
            result.error("Model Error", "Model has not been downloaded yet ", null);
            return;
        }
        List<Map<String, Object>> points = (List<Map<String, Object>>) call.argument("points");
        Ink.Builder inkBuilder = Ink.builder();
        Ink.Stroke.Builder strokeBuilder;
        strokeBuilder = Ink.Stroke.builder();

        for (final Map<String, Object> point : points) {
            Ink.Point inkPoint = new Ink.Point() {
                @Override
                public float getX() {
                    return (float) (double) point.get("x");
                }

                @Override
                public float getY() {
                    return (float) (double) point.get("y");
                }

                @Nullable
                @Override
                public Long getTimestamp() {
                    return null;
                }
            };
            strokeBuilder.addPoint(inkPoint);
        }
        inkBuilder.addStroke(strokeBuilder.build());
        Ink ink = inkBuilder.build();

        recognizer.recognize(ink)
                .addOnSuccessListener(recognitionResult -> {
                    List<Map<String, Object>> candidatesList = new ArrayList<>(recognitionResult.getCandidates().size());
                    for (RecognitionCandidate candidate : recognitionResult.getCandidates()) {
                        Map<String, Object> candidateData = new HashMap<>();
                        double score = 0;
                        if (candidate.getScore() != null)
                            score = candidate.getScore().doubleValue();
                        candidateData.put("text", candidate.getText());
                        candidateData.put("score", score);
                        candidatesList.add(candidateData);
                    }
                    result.success(candidatesList);
                })
                .addOnFailureListener(e -> result.error("recognition Error", e.toString(), null));
    }

    private void manageInkModels(MethodCall call, final MethodChannel.Result result) {
        DigitalInkRecognitionModel model = getModel(call, result);
        String task = (String) call.argument("task");
        switch (task) {
            case "download":
                DownloadConditions downloadConditions = new DownloadConditions.Builder().build();
                genericModelManager.downloadModel(model, downloadConditions, result);
                break;
            case "delete":
                genericModelManager.deleteModel(model, result);
                break;
            case "check":
                Boolean downloaded = genericModelManager.isModelDownloaded(model);
                if (downloaded != null) result.success(downloaded);
                else result.error("Verify Failed", "Error in running the is DownLoad method", null);
                break;
            default:
                result.notImplemented();
        }
    }

    private DigitalInkRecognitionModel getModel(MethodCall call, final MethodChannel.Result result) {
        String tag = (String) call.argument("modelTag");
        DigitalInkRecognitionModelIdentifier modelIdentifier;
        try {
            modelIdentifier = DigitalInkRecognitionModelIdentifier.fromLanguageTag(tag);
        } catch (MlKitException e) {
            result.error("Failed to create model identifier", e.toString(), null);
            return null;
        }
        if (modelIdentifier == null) {
            result.error("Model Identifier error", "No model was found", null);
            return null;
        }
        return DigitalInkRecognitionModel.builder(modelIdentifier).build();
    }

    private void closeDetector() {
        recognizer.close();
    }
}
