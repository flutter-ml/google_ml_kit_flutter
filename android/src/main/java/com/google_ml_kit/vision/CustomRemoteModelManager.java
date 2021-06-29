package com.google_ml_kit.vision;

import androidx.annotation.NonNull;

import com.google.mlkit.common.model.CustomRemoteModel;
import com.google.mlkit.common.model.DownloadConditions;
import com.google.mlkit.linkfirebase.FirebaseModelSource;
import com.google_ml_kit.ApiDetectorInterface;
import com.google_ml_kit.GenericModelManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class CustomRemoteModelManager implements ApiDetectorInterface {
    private static final String START = "vision#startRemoteModelManager";
    private final GenericModelManager genericModelManager = new GenericModelManager();

    @Override
    public List<String> getMethodsKeys() {
        return new ArrayList<>(
                Collections.singletonList(START));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        if (method.equals(START)) {
            handleCall(call, result);
        } else {
            result.notImplemented();
        }
    }

    private void handleCall(MethodCall call, final MethodChannel.Result result) {
        String task = call.argument("task");

        switch (Objects.requireNonNull(task)) {
            case "download":
                downloadModel(result, call.argument("model"), call.argument("wifi"));
                break;
            case "delete":
                deleteModel(result, call.argument("model"));
                break;
            case "check":
                CustomRemoteModel model =
                        new CustomRemoteModel.Builder(
                            new FirebaseModelSource.Builder(call.argument("model")).build()
                        ).build();
                Boolean downloaded = genericModelManager.isModelDownloaded(model);
                if (downloaded != null) result.success(downloaded);
                else result.error("error", null, null);
                break;
            default:
                result.notImplemented();
        }
    }

    private void downloadModel(final MethodChannel.Result result, String modelName, boolean isWifiReqRequired) {
        CustomRemoteModel downloadModel = new CustomRemoteModel.Builder(
                new FirebaseModelSource.Builder(modelName).build()
        ).build();

        DownloadConditions downloadConditions;
        if (isWifiReqRequired)
            downloadConditions = new DownloadConditions.Builder().requireWifi().build();
        else
            downloadConditions = new DownloadConditions.Builder().build();
        genericModelManager.downloadModel(downloadModel, downloadConditions, result);
    }

    private void deleteModel(final MethodChannel.Result result, String modelName) {
        CustomRemoteModel deleteModel = new CustomRemoteModel.Builder(
                new FirebaseModelSource.Builder(modelName).build()
        ).build();

        genericModelManager.deleteModel(deleteModel, result);
    }
}
