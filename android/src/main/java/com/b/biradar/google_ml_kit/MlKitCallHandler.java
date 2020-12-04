package com.b.biradar.google_ml_kit;

import android.content.Context;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.mlkit.vision.common.InputImage;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MlKitCallHandler implements MethodChannel.MethodCallHandler {
    private final Context applicationContext;
    Map<String, Detector> detectorMap = new HashMap<String, Detector>();

    public MlKitCallHandler(Context applicationContext) {
        this.applicationContext = applicationContext;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "startBarcodeScanner":
            case "startPoseDetector":
            case "startImageLabelDetector":
            case "startTextDetector":
                handleDetection(call, result);
                break;
            case "closeBarcodeScanner":
            case "closePoseDetector":
            case "closeImageLabelDetector":
            case "closeTextDetector":
                closeDetector(call, result);
                break;
            default:
                result.notImplemented();
        }
    }


    private void handleDetection(MethodCall call, MethodChannel.Result result) {
        Map<String, Object> options = call.argument("options");
        InputImage inputImage;
        try {
            inputImage = getInputImage((Map<String, Object>) call.argument("imageData"), result);
        } catch (Exception e) {
            Log.e("ImageError", "Getting Image failed");
            e.printStackTrace();
            result.error("imageInputError", e.toString(), null);
            return;
        }

        Detector detector = detectorMap.get(call.method.substring(5));

        if (detector == null) {
            switch (call.method) {
                case "startBarcodeScanner":
                    detector = new BarcodeDetector((List<Integer>) call.argument("formats"));
                    break;
                case "startPoseDetector":
                    detector = new MlPoseDetector((Map<String, Object>) call.argument("options"));
                    break;
                case "startImageLabelDetector":
                    detector = new ImageLabelDetector(options);
                    break;
                case "startTextDetector":
            }

            detectorMap.put(call.method.substring(5), detector);
        }


        assert detector != null;
        detector.handleDetection(inputImage, result);

    }

    private void closeDetector(MethodCall call, MethodChannel.Result result) {
        final Detector detector = detectorMap.get(call.method.substring(5));
        Log.e("Detector Map", detectorMap.toString());
        if (detector == null) {
            String error = String.format(call.method.substring(5), "Has been closed or not been created yet");
            throw new IllegalArgumentException(error);
        }

        try {
            detector.closeDetector();
            result.success(null);
        } catch (IOException e) {
            result.error("Could not close", e.getMessage(), null);
        } finally {
            detectorMap.remove(call.method.substring(5));
        }
    }

    private InputImage getInputImage(Map<String, Object> imageData, MethodChannel.Result result) {
        String model = (String) imageData.get("type");
        InputImage inputImage;
        if (model.equals("file")) {
            try {
                inputImage = InputImage.fromFilePath(applicationContext, Uri.fromFile(new File(((String) imageData.get("path")))));
                return inputImage;
            } catch (IOException e) {
                Log.e("ImageError", "Getting Image failed");
                e.printStackTrace();
                result.error("imageInputError", e.toString(), null);
                return null;
            }
        } else if (model.equals("bytes")) {
            Map<String, Object> metaData = (Map<String, Object>) imageData.get("metadata");
            inputImage = InputImage.fromByteArray((byte[]) imageData.get("bytes"),
                    (int) (double) metaData.get("width"),
                    (int) (double) metaData.get("height"),
                    (int) metaData.get("rotation"),
                    InputImage.IMAGE_FORMAT_NV21);
            return inputImage;

        } else {
            new IOException("Error occurred");
            return null;
        }
    }
}
