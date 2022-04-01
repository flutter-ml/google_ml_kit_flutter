package com.google_mlkit_commons;

import androidx.annotation.NonNull;

import com.google.mlkit.common.model.CustomRemoteModel;
import com.google.mlkit.common.model.DownloadConditions;
import com.google.mlkit.linkfirebase.FirebaseModelSource;
import com.google_mlkit_commons.GenericModelManager;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class CustomRemoteModelManager implements MethodChannel.MethodCallHandler {

    private static final String MANAGE = "vision#manageRemoteModel";

    private final GenericModelManager genericModelManager = new GenericModelManager();

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        if (method.equals(MANAGE)) {
            handleCall(call, result);
        } else {
            result.notImplemented();
        }
    }

    private void handleCall(MethodCall call, final MethodChannel.Result result) {
        String task = (String) call.argument("task");
        String modelName = (String) call.argument("model");
        CustomRemoteModel model = new CustomRemoteModel.Builder(
                new FirebaseModelSource.Builder(modelName).build()
        ).build();
        switch (task) {
            case "download":
                downloadModel(result, model, (boolean) call.argument("wifi"));
                break;
            case "delete":
                genericModelManager.deleteModel(model, result);
                break;
            case "check":
                Boolean downloaded = genericModelManager.isModelDownloaded(model);
                if (downloaded != null) result.success(downloaded);
                else result.error("Verify Failed", "Error in running the is DownLoad method", null);
                break;
            default:
                result.notImplemented();
        }
    }

    private void downloadModel(final MethodChannel.Result result, CustomRemoteModel model, boolean isWifiReqRequired) {
        DownloadConditions downloadConditions;
        if (isWifiReqRequired)
            downloadConditions = new DownloadConditions.Builder().requireWifi().build();
        else
            downloadConditions = new DownloadConditions.Builder().build();
        genericModelManager.downloadModel(model, downloadConditions, result);
    }
}
