package com.google_mlkit;

import androidx.annotation.NonNull;

import com.google_mlkit.nl.EntityExtractor;
import com.google_mlkit.nl.EntityModelManager;
import com.google_mlkit.nl.OnDeviceTranslator;
import com.google_mlkit.nl.SmartReply;
import com.google_mlkit.nl.TranslatorModelManager;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MlKitMethodCallHandler implements MethodChannel.MethodCallHandler {

    private final Map<String, ApiDetectorInterface> handlers;

    public MlKitMethodCallHandler() {
        List<ApiDetectorInterface> detectors = new ArrayList<ApiDetectorInterface>(
                Arrays.asList(
                        new EntityExtractor(),
                        new EntityModelManager(),
                        new OnDeviceTranslator(),
                        new TranslatorModelManager(),
                        new SmartReply()
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
