package com.google_mlkit_digital_ink_recognition;

import androidx.annotation.NonNull;

import com.google.mlkit.common.MlKitException;
import com.google.mlkit.vision.digitalink.DigitalInkRecognition;
import com.google.mlkit.vision.digitalink.DigitalInkRecognitionModel;
import com.google.mlkit.vision.digitalink.DigitalInkRecognitionModelIdentifier;
import com.google.mlkit.vision.digitalink.DigitalInkRecognizerOptions;
import com.google.mlkit.vision.digitalink.Ink;
import com.google.mlkit.vision.digitalink.RecognitionCandidate;
import com.google_mlkit_commons.GenericModelManager;

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
    private String tag = "";

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        switch (method) {
            case START:
                handleDetection(call, result);
                break;
            case CLOSE:
                closeDetector();
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
        String tag = call.argument("model");
        DigitalInkRecognitionModel model = getModel(tag, result);
        if (genericModelManager.isModelDownloaded(model)) {
            if (recognizer == null || this.tag != tag) {
                this.tag = tag;
                closeDetector();
                recognizer = DigitalInkRecognition.getClient(DigitalInkRecognizerOptions.builder(model).build());
            }
        } else {
            result.error("Model Error", "Model has not been downloaded yet ", null);
            return;
        }

        Map<String, Object> inkMap = call.argument("ink");
        List<Map<String, Object>> strokeList = (List<Map<String, Object>>) inkMap.get("strokes");
        Ink.Builder inkBuilder = Ink.builder();
        for (final Map<String, Object> strokeMap : strokeList) {
            Ink.Stroke.Builder strokeBuilder = Ink.Stroke.builder();
            List<Map<String, Object>> pointsList = (List<Map<String, Object>>) strokeMap.get("points");
            for (final Map<String, Object> point : pointsList) {
                float x = (float) (double) point.get("x");
                float y = (float) (double) point.get("y");
                long t = (long) point.get("t");
                Ink.Point strokePoint = Ink.Point.create(x, y, t);
                strokeBuilder.addPoint(strokePoint);
            }
            inkBuilder.addStroke(strokeBuilder.build());
        }
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

    private void closeDetector() {
        if (recognizer == null) return;
        recognizer.close();
        recognizer = null;
    }

    private void manageModel(MethodCall call, final MethodChannel.Result result) {
        String tag = call.argument("model");
        DigitalInkRecognitionModel model = getModel(tag, result);
        genericModelManager.manageModel(model, call, result);
    }

    private DigitalInkRecognitionModel getModel(String tag, final MethodChannel.Result result) {
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
}
