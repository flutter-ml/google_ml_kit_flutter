package com.google_mlkit_subject_segmentation;

import android.content.Context;
import android.graphics.Bitmap;

import androidx.annotation.NonNull;

import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.segmentation.subject.Subject;
import com.google.mlkit.vision.segmentation.subject.SubjectSegmentation;
import com.google.mlkit.vision.segmentation.subject.SubjectSegmentationResult;
import com.google.mlkit.vision.segmentation.subject.SubjectSegmenter;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.nio.FloatBuffer;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import com.google.mlkit.vision.segmentation.subject.SubjectSegmenterOptions;
import com.google_mlkit_commons.InputImageConverter;

public class SubjectSegmenterProcess implements MethodChannel.MethodCallHandler {
    private static final String START = "vision#startSubjectSegmenter";
    private static final String CLOSE = "vision#closeSubjectSegmenter";

    private final Context context;
     
    private int imageWidth;
    private int imageHeight;

    private final Map<String, SubjectSegmenter> instances = new HashMap<>();

    public SubjectSegmenterProcess(Context context) {
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
        InputImage inputImage = InputImageConverter.getInputImageFromData(call.argument("imageData"), context, result);
        if(inputImage == null) return;
        imageHeight = inputImage.getHeight();
        imageWidth = inputImage.getWidth();

        String id = call.argument("id");
        SubjectSegmenter subjectSegmenter = getOrCreateSegmenter(id, call);

        subjectSegmenter.process(inputImage)
                .addOnSuccessListener(subjectSegmentationResult -> processResult(subjectSegmentationResult, call, result))
                .addOnFailureListener(e -> result.error("Subject segmentation failure!", e.getMessage(), e));

    }

    private SubjectSegmenter getOrCreateSegmenter(String id, MethodCall call) {
        return instances.computeIfAbsent(id, k -> initialize(call));
    }
    private SubjectSegmenter initialize(MethodCall call) {
        Map<String, Object> options = call.argument("options");
        SubjectSegmenterOptions.Builder builder = new SubjectSegmenterOptions.Builder();
        assert options != null;
        configureBuilder(builder, options);
        return SubjectSegmentation.getClient(builder.build());
    }

    private void configureBuilder(SubjectSegmenterOptions.Builder builder, Map<String, Object> options) {
        if(Boolean.TRUE.equals(options.get("enableForegroundBitmap"))){
            builder.enableForegroundBitmap();
        }
        if(Boolean.TRUE.equals(options.get("enableForegroundConfidenceMask"))){
            builder.enableForegroundConfidenceMask();
        }
        configureMultipleSubjects(builder, options);
    }

    private void configureMultipleSubjects(SubjectSegmenterOptions.Builder builder, Map<String, Object> options) {
           boolean enableMultiConfidenceMask = Boolean.TRUE.equals(options.get("enableMultiConfidenceMask")) ;
           boolean enableMultiSubjectBitmap = Boolean.TRUE.equals(options.get("enableMultiSubjectBitmap"));

           if(enableMultiConfidenceMask || enableMultiSubjectBitmap) {
               SubjectSegmenterOptions.SubjectResultOptions.Builder subjectBuilder = new SubjectSegmenterOptions.SubjectResultOptions.Builder();
               if(enableMultiConfidenceMask) subjectBuilder.enableConfidenceMask();
               if(enableMultiSubjectBitmap) subjectBuilder.enableSubjectBitmap();
               builder.enableMultipleSubjects(subjectBuilder.build());
           }
    }

    private void processResult(SubjectSegmentationResult subjectSegmentationResult, MethodCall call, MethodChannel.Result result) {
           Map<String, Object> resultMap = new HashMap<>();
           Map<String, Object> options = call.argument("options");

            assert options != null;
            if(Boolean.TRUE.equals(options.get("enableForegroundBitmap")))  {
                addForegroundBitmap(resultMap, subjectSegmentationResult.getForegroundBitmap());
            }

            if(Boolean.TRUE.equals(options.get("enableForegroundConfidenceMask"))){
                addConfidenceMask(resultMap, subjectSegmentationResult.getForegroundConfidenceMask());
            }
            if(Boolean.TRUE.equals(options.get("enableMultiConfidenceMask")) || Boolean.TRUE.equals(options.get("enableMultiSubjectBitmap"))) {

                List<Map<String, Object>> subjectsData = new ArrayList<>();
                for(Subject subject: subjectSegmentationResult.getSubjects()){
                    Map<String, Object> subjectData = getStringObjectMap(subject, options);
                    subjectsData.add(subjectData);
                }
               resultMap.put("subjects", subjectsData);
            }
            resultMap.put("width", imageWidth);
            resultMap.put("height", imageHeight);

            result.success(resultMap);
    }

    private void addForegroundBitmap(Map<String, Object> map, Bitmap bitmap) {
        if(bitmap != null) {
            map.put("bitmap", getBitmapBytes(bitmap));
        }
    }

    private void addConfidenceMask(Map<String, Object> map, FloatBuffer mask) {
        if(mask != null) {
            map.put("confidences", getConfidences(mask));
        }
    }

    private static float[] getConfidences(FloatBuffer floatBuffer) {
        float[] confidences = new float[floatBuffer.remaining()];
        floatBuffer.get(confidences);
        return confidences;
    }

    private static byte[] getBitmapBytes(Bitmap bitmap) {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream);
        return outputStream.toByteArray();
    }


    @NonNull
    private static Map<String, Object> getStringObjectMap(Subject subject, Map<String, Object> options) {
        Map<String, Object> subjectData = new HashMap<>();
        subjectData.put("startX", subject.getStartX());
        subjectData.put("startY", subject.getStartY());
        subjectData.put("width", subject.getWidth());
        subjectData.put("height", subject.getHeight());
        if(Boolean.TRUE.equals(options.get("enableMultiConfidenceMask"))){
            subjectData.put("confidences", getConfidences(Objects.requireNonNull(subject.getConfidenceMask())));
        }
        if(Boolean.TRUE.equals(options.get("enableMultiSubjectBitmap"))) {
           subjectData.put("bitmap", getBitmapBytes(Objects.requireNonNull(subject.getBitmap())));
        }
        return subjectData;
    }

    private void closeDetector(MethodCall call) {
        String id = call.argument("id");
        SubjectSegmenter subjectSegmenter = instances.get(id);
        if (subjectSegmenter == null) return;
        subjectSegmenter.close();
        instances.remove(id);
    }
}
