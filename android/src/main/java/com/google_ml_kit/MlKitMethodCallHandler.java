package com.google_ml_kit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.google_ml_kit.nl.LanguageDetector;
import com.google_ml_kit.vision.TextDetector;

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
                        new TextDetector(context),
                        new LanguageDetector()
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
