package com.b.biradar.google_ml_kit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.b.biradar.google_ml_kit.nl.EntityExtractor;
import com.b.biradar.google_ml_kit.nl.EntityModelManager;
import com.b.biradar.google_ml_kit.nl.LanguageDetector;
import com.b.biradar.google_ml_kit.nl.OnDeviceTranslator;
import com.b.biradar.google_ml_kit.nl.TranslatorModelManager;
import com.b.biradar.google_ml_kit.vision.BarcodeDetector;
import com.b.biradar.google_ml_kit.vision.FaceDetector;
import com.b.biradar.google_ml_kit.vision.ImageLabelDetector;
import com.b.biradar.google_ml_kit.vision.DigitalInkRecogniser;
import com.b.biradar.google_ml_kit.vision.PoseDetector;
import com.b.biradar.google_ml_kit.vision.TextDetector;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MlKitMethodCallHandler implements MethodChannel.MethodCallHandler {

    private final Map<String, ApiDetectorInterface> handlers;

    public MlKitMethodCallHandler(Context context) {
        List<ApiDetectorInterface> detectors = new ArrayList<ApiDetectorInterface>(
                Arrays.asList(
                        new BarcodeDetector(context),
                        new DigitalInkRecogniser(),
                        new FaceDetector(context),
                        new ImageLabelDetector(context),
                        new PoseDetector(context),
                        new TextDetector(context),
                        new EntityExtractor(),
                        new EntityModelManager(),
                        new LanguageDetector(),
                        new OnDeviceTranslator(),
                        new TranslatorModelManager()
                ));

        handlers = new HashMap<>();
        for (ApiDetectorInterface detector : detectors) {
            for (String method : detector.getMethodsKeys()) {
                handlers.put(method, detector);
            }
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        ApiDetectorInterface handler = handlers.get(call.method);
        if (handler != null) {
            handler.onMethodCall(call, result);
        } else {
            result.notImplemented();
        }
    }
}
