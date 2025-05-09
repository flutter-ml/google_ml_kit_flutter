package com.google_mlkit_subject_segmentation;

import android.content.Context;
import android.graphics.Bitmap;

import androidx.annotation.NonNull;

import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.segmentation.subject.Subject;
import com.google.mlkit.vision.segmentation.subject.SubjectSegmentation;
import com.google.mlkit.vision.segmentation.subject.SubjectSegmentationResult;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.List;
import java.nio.FloatBuffer;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import com.google.mlkit.vision.segmentation.subject.SubjectSegmenterOptions;
import com.google_mlkit_commons.InputImageConverter;

public class SubjectSegmenter implements MethodChannel.MethodCallHandler {
    private static final String START = "vision#startSubjectSegmenter";
    private static final String CLOSE = "vision#closeSubjectSegmenter";

    private final Context context;

    private final Map<String, com.google.mlkit.vision.segmentation.subject.SubjectSegmenter> instances = new HashMap<>();

    public SubjectSegmenter(Context context) {
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

    private void handleDetection(MethodCall call, MethodChannel.Result result) {
        Map<String, Object> imageData = (Map<String, Object>) call.argument("imageData");
        InputImageConverter converter = new InputImageConverter();
        InputImage inputImage = converter.getInputImageFromData(imageData, context, result);
        if (inputImage == null) return;

        String id = call.argument("id");
        com.google.mlkit.vision.segmentation.subject.SubjectSegmenter subjectSegmenter = getOrCreateSegmenter(id, call);
        subjectSegmenter.process(inputImage)
            .addOnSuccessListener(subjectSegmentationResult -> processResult(subjectSegmentationResult, result))
            .addOnFailureListener(e -> result.error("Subject segmentation failure!", e.getMessage(), e))
            // Closing is necessary for both success and failure.
            .addOnCompleteListener(r -> converter.close());
    }

    private com.google.mlkit.vision.segmentation.subject.SubjectSegmenter getOrCreateSegmenter(String id, MethodCall call) {
        return instances.computeIfAbsent(id, k -> initialize(call));
    }

    private com.google.mlkit.vision.segmentation.subject.SubjectSegmenter initialize(MethodCall call) {
        Map<String, Object> options = call.argument("options");
        SubjectSegmenterOptions.Builder builder = new SubjectSegmenterOptions.Builder();
        assert options != null;
        configureBuilder(builder, options);
        return SubjectSegmentation.getClient(builder.build());
    }

    private void configureBuilder(SubjectSegmenterOptions.Builder builder, Map<String, Object> options) {
        if (Boolean.TRUE.equals(options.get("enableForegroundBitmap"))) {
            builder.enableForegroundBitmap();
        }
        if (Boolean.TRUE.equals(options.get("enableForegroundConfidenceMask"))) {
            builder.enableForegroundConfidenceMask();
        }
        configureMultipleSubjects(builder, (Map<String, Object>) options.get("enableMultiSubjectBitmap"));
    }

    private void configureMultipleSubjects(SubjectSegmenterOptions.Builder builder, Map<String, Object> options) {
        boolean enableConfidenceMask = Boolean.TRUE.equals(options.get("enableConfidenceMask"));
        boolean enableSubjectBitmap = Boolean.TRUE.equals(options.get("enableSubjectBitmap"));
        SubjectSegmenterOptions.SubjectResultOptions.Builder subjectResultOptionsBuilder = new SubjectSegmenterOptions.SubjectResultOptions.Builder();
        if (enableConfidenceMask) subjectResultOptionsBuilder.enableConfidenceMask();
        if (enableSubjectBitmap) subjectResultOptionsBuilder.enableSubjectBitmap();
        if (enableConfidenceMask || enableSubjectBitmap) {
            builder.enableMultipleSubjects(subjectResultOptionsBuilder.build());
        }
    }

    private void processResult(SubjectSegmentationResult subjectSegmentationResult, MethodChannel.Result result) {
        Map<String, Object> resultMap = new HashMap<>();
        FloatBuffer foregroundConfidenceMask = subjectSegmentationResult.getForegroundConfidenceMask();
        if (foregroundConfidenceMask != null) {
            resultMap.put("foregroundConfidenceMask", getConfidenceMask(foregroundConfidenceMask));
        }
        Bitmap foregroundBitmap = subjectSegmentationResult.getForegroundBitmap();
        if (foregroundBitmap != null) {
            resultMap.put("foregroundBitmap", getBitmapBytes(foregroundBitmap));
        }
        List<Map<String, Object>> subjectsData = new ArrayList<>();
        for (Subject subject : subjectSegmentationResult.getSubjects()) {
            Map<String, Object> subjectData = getStringObjectMap(subject);
            subjectsData.add(subjectData);
        }
        resultMap.put("subjects", subjectsData);
        result.success(resultMap);
    }

    private static float[] getConfidenceMask(FloatBuffer floatBuffer) {
        float[] mask = new float[floatBuffer.remaining()];
        floatBuffer.get(mask);
        return mask;
    }

    private static byte[] getBitmapBytes(Bitmap bitmap) {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream);
        return outputStream.toByteArray();
    }

    @NonNull
    private static Map<String, Object> getStringObjectMap(Subject subject) {
        Map<String, Object> subjectData = new HashMap<>();
        subjectData.put("startX", subject.getStartX());
        subjectData.put("startY", subject.getStartY());
        subjectData.put("width", subject.getWidth());
        subjectData.put("height", subject.getHeight());
        FloatBuffer confidenceMask = subject.getConfidenceMask();
        if (confidenceMask != null) {
            subjectData.put("confidenceMask", getConfidenceMask(confidenceMask));
        }
        Bitmap bitmap = subject.getBitmap();
        if (bitmap != null) {
            subjectData.put("bitmap", getBitmapBytes(bitmap));
        }
        return subjectData;
    }

    private void closeDetector(MethodCall call) {
        String id = call.argument("id");
        com.google.mlkit.vision.segmentation.subject.SubjectSegmenter subjectSegmenter = instances.get(id);
        if (subjectSegmenter == null) return;
        subjectSegmenter.close();
        instances.remove(id);
    }
}
