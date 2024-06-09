package com.google_mlkit_subject_segmentation;

import android.content.Context;

import androidx.annotation.NonNull;

import com.google.mlkit.vision.segmentation.subject.SubjectSegmenter;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SubjectSegmenterProcess implements MethodChannel.MethodCallHandler {
    private static final String START = "vision#startSubjectSegmenter";
    private static final String CLOSE = "vision#closeSubjectSegmenter";

    private final Context context;
    private final Map<String, SubjectSegmenter> instances = new HashMap<>();

    public SubjectSegmenterProcess(Context context) {
        this.context = context;
    }
    @Override
    public void onMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {

    }

    private void closeDetector(MethodCall call) {
        String id = call.argument("id");
        SubjectSegmenter subjectSegmenter = instances.get(id);
        if (subjectSegmenter == null) return;
        subjectSegmenter.close();
        instances.remove(id);
    }
}
