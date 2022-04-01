package com.google_mlkit;

import androidx.annotation.NonNull;

import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public interface ApiDetectorInterface {

    List<String> getMethodsKeys();

    void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result);
}
