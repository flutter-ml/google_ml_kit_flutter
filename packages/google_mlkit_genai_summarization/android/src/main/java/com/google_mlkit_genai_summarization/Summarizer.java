package com.google_mlkit_genai_summarization;

import android.content.Context;

import androidx.annotation.NonNull;

import com.google.mlkit.genai.summarization.Summarization;
import com.google.mlkit.genai.summarization.SummarizationRequest;
import com.google.mlkit.genai.summarization.SummarizerOptions;

import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.FutureCallback;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class Summarizer implements MethodChannel.MethodCallHandler {
    private static final String CHECK_FEATURE_STATUS = "genai#checkFeatureStatus";
    private static final String DOWNLOAD_FEATURE = "genai#downloadFeature";
    private static final String RUN_INFERENCE = "genai#runInference";
    private static final String RUN_INFERENCE_STREAMING = "genai#runInferenceStreaming";
    private static final String CLOSE = "genai#closeSummarizer";

    private final Context context;
    private final Map<String, com.google.mlkit.genai.summarization.Summarizer> instances = new HashMap<>();
    private final Executor executor = Executors.newSingleThreadExecutor();

    public Summarizer(Context context) {
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
                closeSummarizer(call);
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private com.google.mlkit.genai.summarization.Summarizer initialize(MethodCall call) {
        // Use basic SummarizerOptions builder - API structure may vary
        SummarizerOptions options = SummarizerOptions.builder(context).build();
        return Summarization.getClient(options);
    }

    private void checkFeatureStatus(MethodCall call, MethodChannel.Result result) {
        String id = call.argument("id");
        com.google.mlkit.genai.summarization.Summarizer summarizer = instances.get(id);
        if (summarizer == null) {
            summarizer = initialize(call);
            instances.put(id, summarizer);
        }

        ListenableFuture<Integer> future = summarizer.checkFeatureStatus();
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
                result.error("SummarizerError", e.toString(), null);
            }
        }, executor);
    }

    private void downloadFeature(MethodCall call, MethodChannel.Result result) {
        String id = call.argument("id");
        com.google.mlkit.genai.summarization.Summarizer summarizer = instances.get(id);
        if (summarizer == null) {
            summarizer = initialize(call);
            instances.put(id, summarizer);
        }

        summarizer.downloadFeature(new com.google.mlkit.genai.common.DownloadCallback() {
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
        com.google.mlkit.genai.summarization.Summarizer summarizer = instances.get(id);
        if (summarizer == null) {
            summarizer = initialize(call);
            instances.put(id, summarizer);
        }

        SummarizationRequest request = SummarizationRequest.builder(text).build();
        ListenableFuture<com.google.mlkit.genai.summarization.SummarizationResult> future = summarizer.runInference(request);
        Futures.addCallback(future, new FutureCallback<com.google.mlkit.genai.summarization.SummarizationResult>() {
            @Override
            public void onSuccess(com.google.mlkit.genai.summarization.SummarizationResult summarizationResult) {
                Map<String, Object> resultMap = new HashMap<>();
                resultMap.put("summary", summarizationResult.getSummary());
                result.success(resultMap);
            }

            @Override
            public void onFailure(Throwable e) {
                result.error("InferenceError", e.toString(), null);
            }
        }, executor);
    }

    private void runInferenceStreaming(MethodCall call, MethodChannel.Result result) {
        // Streaming implementation would require EventChannel
        // For now, this is a placeholder
        result.notImplemented();
    }

    private void closeSummarizer(MethodCall call) {
        String id = call.argument("id");
        com.google.mlkit.genai.summarization.Summarizer summarizer = instances.get(id);
        if (summarizer == null) return;
        summarizer.close();
        instances.remove(id);
    }
}
