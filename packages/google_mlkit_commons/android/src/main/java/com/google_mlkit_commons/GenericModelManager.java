package com.google_mlkit_commons;

import com.google.mlkit.common.model.DownloadConditions;
import com.google.mlkit.common.model.RemoteModel;
import com.google.mlkit.common.model.RemoteModelManager;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class GenericModelManager {
    private static final String DOWNLOAD = "download";
    private static final String DELETE = "delete";
    private static final String CHECK = "check";

    public interface CheckModelIsDownloadedCallback {
        void onCheckResult(Boolean isDownloaded);

        void onError(Exception e);
    }

    public RemoteModelManager remoteModelManager = RemoteModelManager.getInstance();

    public void manageModel(final RemoteModel model, final MethodCall call, final MethodChannel.Result result) {
        String task = call.argument("task");

        if (task == null) {
            result.notImplemented();
            return;
        }

        switch (task) {
            case DOWNLOAD:
                boolean isWifiReqRequired = call.argument("wifi");
                DownloadConditions downloadConditions;
                if (isWifiReqRequired)
                    downloadConditions = new DownloadConditions.Builder().requireWifi().build();
                else
                    downloadConditions = new DownloadConditions.Builder().build();
                downloadModel(model, downloadConditions, result);
                break;
            case DELETE:
                deleteModel(model, result);
                break;
            case CHECK:
                isModelDownloaded(
                        model,
                        new CheckModelIsDownloadedCallback() {
                            @Override
                            public void onCheckResult(Boolean isDownloaded) {
                                result.success(isDownloaded);
                            }

                            @Override
                            public void onError(Exception e) {
                                result.error("error", e.toString(), null);
                            }
                        }
                );
                break;
            default:
                result.notImplemented();
        }
    }

    public void downloadModel(RemoteModel remoteModel, DownloadConditions downloadConditions, final MethodChannel.Result result) {
        isModelDownloaded(
                remoteModel,
                new CheckModelIsDownloadedCallback() {
                    @Override
                    public void onCheckResult(Boolean isDownloaded) {
                        if (isDownloaded) {
                            result.success("success");
                            return;
                        }

                        remoteModelManager.download(remoteModel, downloadConditions)
                                .addOnSuccessListener(aVoid -> result.success("success"))
                                .addOnFailureListener(e -> result.error("error", e.toString(), null));
                    }

                    @Override
                    public void onError(Exception e) {
                        result.error("error", e.toString(), null);
                    }
                }
        );
    }

    public void deleteModel(RemoteModel remoteModel, final MethodChannel.Result result) {
        isModelDownloaded(remoteModel, new CheckModelIsDownloadedCallback() {
            @Override
            public void onCheckResult(Boolean isDownloaded) {
                if (!isDownloaded) {
                    result.success("success");
                    return;
                }
                remoteModelManager.deleteDownloadedModel(remoteModel)
                        .addOnSuccessListener(aVoid -> result.success("success"))
                        .addOnFailureListener(e -> result.error("error", e.toString(), null));
            }

            @Override
            public void onError(Exception e) {
                result.error("error", e.toString(), null);
            }
        });
    }

    public void isModelDownloaded(RemoteModel model, CheckModelIsDownloadedCallback callback) {
        try {
            remoteModelManager.isModelDownloaded(model)
                    .addOnFailureListener(callback::onError)
                    .addOnSuccessListener(callback::onCheckResult);
        } catch (Exception e) {
            callback.onError(e);
        }
    }
}