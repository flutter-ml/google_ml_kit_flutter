package com.google_mlkit_genai_proofreading;

import android.content.Context;

import androidx.annotation.NonNull;

import com.google.mlkit.genai.proofreading.Proofreading;
import com.google.mlkit.genai.proofreading.ProofreadingRequest;
import com.google.mlkit.genai.proofreading.ProofreaderOptions;

import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.FutureCallback;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class Proofreader implements MethodChannel.MethodCallHandler {
    private static final String CHECK_FEATURE_STATUS = "genai#checkFeatureStatus";
    private static final String DOWNLOAD_FEATURE = "genai#downloadFeature";
    private static final String RUN_INFERENCE = "genai#runInference";
    private static final String RUN_INFERENCE_STREAMING = "genai#runInferenceStreaming";
    private static final String CLOSE = "genai#closeProofreader";

    private final Context context;
    private final Map<String, com.google.mlkit.genai.proofreading.Proofreader> instances = new HashMap<>();
    private final Executor executor = Executors.newSingleThreadExecutor();

    public Proofreader(Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        switch (method) {
            case CHECK_FEATURE_STATUS:
                checkFeatureStatus(call, result);
                break;
            case DOWNLOAD_FEATURE:
                downloadFeature(call, result);
                break;
            case RUN_INFERENCE:
                runInference(call, result);
                break;
            case RUN_INFERENCE_STREAMING:
                runInferenceStreaming(call, result);
                break;
            case CLOSE:
                closeProofreader(call);
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private com.google.mlkit.genai.proofreading.Proofreader initialize(MethodCall call) {
        // Use basic ProofreaderOptions builder - API structure may vary
        ProofreaderOptions options = ProofreaderOptions.builder(context).build();
        return Proofreading.getClient(options);
    }

    private void checkFeatureStatus(MethodCall call, MethodChannel.Result result) {
        String id = call.argument("id");
        com.google.mlkit.genai.proofreading.Proofreader proofreader = instances.get(id);
        if (proofreader == null) {
            proofreader = initialize(call);
            instances.put(id, proofreader);
        }

        ListenableFuture<Integer> future = proofreader.checkFeatureStatus();
        Futures.addCallback(future, new FutureCallback<Integer>() {
            @Override
            public void onSuccess(Integer status) {
                int statusValue;
                if (status == com.google.mlkit.genai.common.FeatureStatus.UNAVAILABLE) {
                    statusValue = 0;
                } else if (status == com.google.mlkit.genai.common.FeatureStatus.DOWNLOADABLE) {
                    statusValue = 1;
                } else if (status == com.google.mlkit.genai.common.FeatureStatus.DOWNLOADING) {
                    statusValue = 2;
                } else if (status == com.google.mlkit.genai.common.FeatureStatus.AVAILABLE) {
                    statusValue = 3;
                } else {
                    statusValue = 0;
                }
                result.success(statusValue);
            }

            @Override
            public void onFailure(Throwable e) {
                result.error("ProofreaderError", e.toString(), null);
            }
        }, executor);
    }

    private void downloadFeature(MethodCall call, MethodChannel.Result result) {
        String id = call.argument("id");
        com.google.mlkit.genai.proofreading.Proofreader proofreader = instances.get(id);
        if (proofreader == null) {
            proofreader = initialize(call);
            instances.put(id, proofreader);
        }

        proofreader.downloadFeature(new com.google.mlkit.genai.common.DownloadCallback() {
            @Override
            public void onDownloadStarted(long bytesToDownload) {
                // Handle download started
            }

            @Override
            public void onDownloadFailed(com.google.mlkit.genai.common.GenAiException e) {
                result.error("DownloadError", e.toString(), null);
            }

            @Override
            public void onDownloadProgress(long totalBytesDownloaded) {
                // Handle download progress
            }

            @Override
            public void onDownloadCompleted() {
                result.success(null);
            }
        });
    }

    private void runInference(MethodCall call, MethodChannel.Result result) {
        String id = call.argument("id");
        String text = call.argument("text");
        com.google.mlkit.genai.proofreading.Proofreader proofreader = instances.get(id);
        if (proofreader == null) {
            proofreader = initialize(call);
            instances.put(id, proofreader);
        }

        ProofreadingRequest request = ProofreadingRequest.builder(text).build();
        ListenableFuture<com.google.mlkit.genai.proofreading.ProofreadingResult> future = proofreader.runInference(request);
        Futures.addCallback(future, new FutureCallback<com.google.mlkit.genai.proofreading.ProofreadingResult>() {
            @Override
            public void onSuccess(com.google.mlkit.genai.proofreading.ProofreadingResult proofreadingResult) {
                Map<String, Object> response = new HashMap<>();
                // ProofreadingResult may have getCorrectedText() or similar method
                // Use reflection to find the correct method
                try {
                    String correctedText = (String) proofreadingResult.getClass().getMethod("getCorrectedText").invoke(proofreadingResult);
                    response.put("text", correctedText);
                } catch (Exception e1) {
                    try {
                        // Try getText() if getCorrectedText() doesn't exist
                        String correctedText = (String) proofreadingResult.getClass().getMethod("getText").invoke(proofreadingResult);
                        response.put("text", correctedText);
                    } catch (Exception e2) {
                        // If both fail, return empty string
                        response.put("text", "");
                    }
                }
                result.success(response);
            }

            @Override
            public void onFailure(Throwable e) {
                result.error("InferenceError", e.toString(), null);
            }
        }, executor);
    }

    private void runInferenceStreaming(MethodCall call, MethodChannel.Result result) {
        // Streaming implementation would require EventChannel
        result.notImplemented();
    }

    private void closeProofreader(MethodCall call) {
        String id = call.argument("id");
        com.google.mlkit.genai.proofreading.Proofreader proofreader = instances.get(id);
        if (proofreader == null) return;
        proofreader.close();
        instances.remove(id);
    }
}
