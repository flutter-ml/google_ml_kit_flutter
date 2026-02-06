package com.google_mlkit_genai_image_description;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.mlkit.genai.imagedescription.ImageDescription;
import com.google.mlkit.genai.imagedescription.ImageDescriptionRequest;
import com.google.mlkit.genai.imagedescription.ImageDescriberOptions;

import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.FutureCallback;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ImageDescriber implements MethodChannel.MethodCallHandler {
    private static final String CHECK_FEATURE_STATUS = "genai#checkFeatureStatus";
    private static final String DOWNLOAD_FEATURE = "genai#downloadFeature";
    private static final String RUN_INFERENCE = "genai#runInference";
    private static final String RUN_INFERENCE_STREAMING = "genai#runInferenceStreaming";
    private static final String CLOSE = "genai#closeImageDescriber";

    private final Context context;
    private final Map<String, com.google.mlkit.genai.imagedescription.ImageDescriber> instances = new HashMap<>();
    private final Executor executor = Executors.newSingleThreadExecutor();

    public ImageDescriber(Context context) {
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
                closeImageDescriber(call);
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private com.google.mlkit.genai.imagedescription.ImageDescriber initialize(MethodCall call) {
        ImageDescriberOptions options = ImageDescriberOptions.builder(context).build();
        return ImageDescription.getClient(options);
    }

    private void checkFeatureStatus(MethodCall call, MethodChannel.Result result) {
        String id = call.argument("id");
        com.google.mlkit.genai.imagedescription.ImageDescriber imageDescriber = instances.get(id);
        if (imageDescriber == null) {
            imageDescriber = initialize(call);
            instances.put(id, imageDescriber);
        }

        ListenableFuture<Integer> future = imageDescriber.checkFeatureStatus();
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
                result.error("ImageDescriberError", e.toString(), null);
            }
        }, executor);
    }

    private void downloadFeature(MethodCall call, MethodChannel.Result result) {
        String id = call.argument("id");
        com.google.mlkit.genai.imagedescription.ImageDescriber imageDescriber = instances.get(id);
        if (imageDescriber == null) {
            imageDescriber = initialize(call);
            instances.put(id, imageDescriber);
        }

        imageDescriber.downloadFeature(new com.google.mlkit.genai.common.DownloadCallback() {
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

    private Bitmap getBitmapFromData(Map<String, Object> imageData, MethodChannel.Result result) {
        String model = (String) imageData.get("type");
        if (model != null && model.equals("bitmap")) {
            try {
                byte[] bitmapData = (byte[]) imageData.get("bitmapData");
                if (bitmapData == null) {
                    result.error("ImageDescriberError", "Bitmap data is null", null);
                    return null;
                }
                
                try {
                    Map<String, Object> metadataMap = (Map<String, Object>) imageData.get("metadata");
                    if (metadataMap != null) {
                        int width = Double.valueOf(Objects.requireNonNull(metadataMap.get("width")).toString()).intValue();
                        int height = Double.valueOf(Objects.requireNonNull(metadataMap.get("height")).toString()).intValue();
                        
                        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
                        java.nio.IntBuffer intBuffer = java.nio.IntBuffer.allocate(bitmapData.length / 4);
                        
                        for (int i = 0; i < bitmapData.length; i += 4) {
                            int r = bitmapData[i] & 0xFF;
                            int g = bitmapData[i + 1] & 0xFF;
                            int b = bitmapData[i + 2] & 0xFF;
                            int a = bitmapData[i + 3] & 0xFF;
                            intBuffer.put((a << 24) | (r << 16) | (g << 8) | b);
                        }
                        intBuffer.rewind();
                        bitmap.copyPixelsFromBuffer(intBuffer);
                        return bitmap;
                    }
                } catch (Exception e) {
                    Log.e("ImageError", "Error creating bitmap from raw data", e);
                }
                
                Bitmap bitmap = BitmapFactory.decodeByteArray(bitmapData, 0, bitmapData.length);
                if (bitmap == null) {
                    result.error("ImageDescriberError", "Failed to decode bitmap from the provided data", null);
                    return null;
                }
                return bitmap;
            } catch (Exception e) {
                Log.e("ImageError", "Getting Bitmap failed", e);
                result.error("ImageDescriberError", e.toString(), null);
                return null;
            }
        } else if (model != null && model.equals("file")) {
            try {
                String path = (String) imageData.get("path");
                if (path == null) {
                    result.error("ImageDescriberError", "Image file path is null", null);
                    return null;
                }
                File imageFile = new File(path);
                if (!imageFile.exists()) {
                    result.error("ImageDescriberError", "Image file does not exist", null);
                    return null;
                }
                Bitmap bitmap = BitmapFactory.decodeFile(imageFile.getAbsolutePath());
                if (bitmap == null) {
                    result.error("ImageDescriberError", "Failed to decode bitmap from file", null);
                    return null;
                }
                return bitmap;
            } catch (Exception e) {
                Log.e("ImageError", "Getting Bitmap from file failed", e);
                result.error("ImageDescriberError", e.toString(), null);
                return null;
            }
        } else if (model != null && model.equals("bytes")) {
            try {
                byte[] bytes = (byte[]) imageData.get("bytes");
                if (bytes == null) {
                    result.error("ImageDescriberError", "Image bytes are null", null);
                    return null;
                }
                Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
                if (bitmap == null) {
                    result.error("ImageDescriberError", "Failed to decode bitmap from bytes", null);
                    return null;
                }
                return bitmap;
            } catch (Exception e) {
                Log.e("ImageError", "Getting Bitmap from bytes failed", e);
                result.error("ImageDescriberError", e.toString(), null);
                return null;
            }
        }
        result.error("ImageDescriberError", "Invalid image type", null);
        return null;
    }

    private void runInference(MethodCall call, MethodChannel.Result result) {
        String id = call.argument("id");
        Map<String, Object> imageData = call.argument("imageData");
        com.google.mlkit.genai.imagedescription.ImageDescriber imageDescriber = instances.get(id);
        if (imageDescriber == null) {
            imageDescriber = initialize(call);
            instances.put(id, imageDescriber);
        }

        Bitmap bitmap = getBitmapFromData(imageData, result);
        if (bitmap == null) return;

        ImageDescriptionRequest request = ImageDescriptionRequest.builder(bitmap).build();
        ListenableFuture<com.google.mlkit.genai.imagedescription.ImageDescriptionResult> future = imageDescriber.runInference(request);
        Futures.addCallback(future, new FutureCallback<com.google.mlkit.genai.imagedescription.ImageDescriptionResult>() {
            @Override
            public void onSuccess(com.google.mlkit.genai.imagedescription.ImageDescriptionResult imageDescriptionResult) {
                Map<String, Object> response = new HashMap<>();
                response.put("description", imageDescriptionResult.getDescription());
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

    private void closeImageDescriber(MethodCall call) {
        String id = call.argument("id");
        com.google.mlkit.genai.imagedescription.ImageDescriber imageDescriber = instances.get(id);
        if (imageDescriber == null) return;
        imageDescriber.close();
        instances.remove(id);
    }
}
