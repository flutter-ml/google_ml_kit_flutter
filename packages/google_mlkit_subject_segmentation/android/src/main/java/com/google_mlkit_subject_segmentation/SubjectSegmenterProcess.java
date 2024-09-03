package com.google_mlkit_subject_segmentation;

import android.content.Context;

import androidx.annotation.NonNull;

import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.segmentation.subject.Subject;
import com.google.mlkit.vision.segmentation.subject.SubjectSegmentation;
import com.google.mlkit.vision.segmentation.subject.SubjectSegmenter;

import java.util.ArrayList;
import java.util.List;
import java.nio.FloatBuffer;
import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import com.google.mlkit.vision.segmentation.subject.SubjectSegmenterOptions;
import com.google_mlkit_commons.InputImageConverter;

public class SubjectSegmenterProcess implements MethodChannel.MethodCallHandler {
    private static final String START = "vision#startSubjectSegmenter";
    private static final String CLOSE = "vision#closeSubjectSegmenter";

    private final Context context;

    private static final String TAG = "Logger";
     
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

    private SubjectSegmenter initialize(MethodCall call) {
        SubjectSegmenterOptions.Builder builder = new SubjectSegmenterOptions.Builder()
                .enableMultipleSubjects(new SubjectSegmenterOptions.SubjectResultOptions.Builder()
                .enableConfidenceMask().build());
        SubjectSegmenterOptions options = builder.build();
        return SubjectSegmentation.getClient(options);
    }

    private void handleDetection(MethodCall call, MethodChannel.Result result){
        Map<String, Object> imageData = (Map<String, Object>) call.argument("imageData");
        InputImage inputImage = InputImageConverter.getInputImageFromData(imageData, context, result);
        if (inputImage == null) return;
        imageHeight = inputImage.getHeight();
        imageWidth = inputImage.getWidth();
        String id = call.argument("id");
        SubjectSegmenter subjectSegmenter = instances.get(id);
        if (subjectSegmenter == null) {
            subjectSegmenter = initialize(call);
            instances.put(id, subjectSegmenter);
        }

       subjectSegmenter.process(inputImage)
               .addOnSuccessListener( subjectSegmentationResult -> {
                List<Map<String, Object>> subjectsData = new ArrayList<>();
                for(Subject subject : subjectSegmentationResult.getSubjects()){
                    Map<String, Object> subjectData = getStringObjectMap(subject);
                    subjectsData.add(subjectData);
                }
                Map<String, Object> map = new HashMap<>();
                map.put("subjects", subjectsData);
                map.put("width", imageWidth);
                map.put("height", imageHeight);
                result.success(map);
               }).addOnFailureListener( e -> result.error("Subject segmentation failed!", e.getMessage(), e) );
    }

    @NonNull
    private static Map<String, Object> getStringObjectMap(Subject subject) {
        Map<String, Object> subjectData = new HashMap<>();
        subjectData.put("startX", subject.getStartX());
        subjectData.put("startY", subject.getStartY());
        subjectData.put("width", subject.getWidth());
        subjectData.put("height", subject.getHeight());

        FloatBuffer confidenceMask = subject.getConfidenceMask();
        assert confidenceMask != null;
        float[] confidences = new float[confidenceMask.remaining()];
        confidenceMask.get(confidences);
        subjectData.put("confidences", confidences);
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
