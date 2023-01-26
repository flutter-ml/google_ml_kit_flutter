package com.google_mlkit_selfie_segmentation;

import android.content.Context;

import androidx.annotation.NonNull;

import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.segmentation.Segmentation;
import com.google.mlkit.vision.segmentation.Segmenter;
import com.google.mlkit.vision.segmentation.selfie.SelfieSegmenterOptions;
import com.google_mlkit_commons.InputImageConverter;

import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SelfieSegmenter implements MethodChannel.MethodCallHandler {
    private static final String START = "vision#startSelfieSegmenter";
    private static final String CLOSE = "vision#closeSelfieSegmenter";

    private final Context context;
    private final Map<String, Segmenter> instances = new HashMap<>();

    public SelfieSegmenter(Context context) {
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
            default:
                result.notImplemented();
                break;
        }
    }

    private Segmenter initialize(MethodCall call) {
        Boolean isStream = call.argument("isStream");
        Boolean enableRawSizeMask = call.argument("enableRawSizeMask");

        SelfieSegmenterOptions.Builder builder = new SelfieSegmenterOptions.Builder();

        builder.setDetectorMode(isStream
                ? SelfieSegmenterOptions.STREAM_MODE
                : SelfieSegmenterOptions.SINGLE_IMAGE_MODE);

        if (enableRawSizeMask) {
            builder.enableRawSizeMask();
        }

        SelfieSegmenterOptions options = builder.build();
        return Segmentation.getClient(options);
    }

    private void handleDetection(MethodCall call, final MethodChannel.Result result) {
        Map<String, Object> imageData = (Map<String, Object>) call.argument("imageData");
        InputImage inputImage = InputImageConverter.getInputImageFromData(imageData, context, result);
        if (inputImage == null) return;

        String id = call.argument("id");
        Segmenter segmenter = instances.get(id);
        if (segmenter == null) {
            segmenter = initialize(call);
            instances.put(id, segmenter);
        }

        segmenter.process(inputImage)
                .addOnSuccessListener(
                        segmentationMask -> {
                            Map<String, Object> map = new HashMap<>();
                            ByteBuffer mask = segmentationMask.getBuffer();
                            int maskWidth = segmentationMask.getWidth();
                            int maskHeight = segmentationMask.getHeight();

                            map.put("width", maskWidth);
                            map.put("height", maskHeight);

                            final float[] confidences = new float[maskWidth * maskHeight];
//                            mask.asFloatBuffer().get(confidences, 0, confidences.length);

                            for (int y = 0; y < maskHeight; y++) {
                                for (int x = 0; x < maskWidth; x++) {
                                    // Gets the confidence of the (x,y) pixel in the mask being in the foreground.
                                    // float foregroundConfidence = mask.getFloat();
                                    confidences[y * maskWidth + x] = mask.getFloat();
                                }
                            }

                            map.put("confidences", confidences);

                            result.success(map);
                        })
                .addOnFailureListener(
                        e -> result.error("Selfie segmentation failed!", e.getMessage(), e));
    }

    private void closeDetector(MethodCall call) {
        String id = call.argument("id");
        Segmenter segmenter = instances.get(id);
        if (segmenter == null) return;
        segmenter.close();
        instances.remove(id);
    }
}
