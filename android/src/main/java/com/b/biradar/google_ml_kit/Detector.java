package com.b.biradar.google_ml_kit;

import com.google.mlkit.vision.common.InputImage;

import java.io.IOException;

import io.flutter.plugin.common.MethodChannel;

public interface Detector {
    void handleDetection(InputImage inputImage, MethodChannel.Result result);

    void closeDetector() throws IOException;
}
