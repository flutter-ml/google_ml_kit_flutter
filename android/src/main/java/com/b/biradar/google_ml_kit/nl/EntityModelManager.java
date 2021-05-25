package com.b.biradar.google_ml_kit.nl;

import android.util.Log;

import androidx.annotation.NonNull;

import com.b.biradar.google_ml_kit.ApiDetectorInterface;
import com.b.biradar.google_ml_kit.GenericModelManager;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;

import com.google.mlkit.common.model.DownloadConditions;
import com.google.mlkit.nl.entityextraction.EntityExtractionRemoteModel;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class EntityModelManager implements ApiDetectorInterface {
    private static final String START = "nlp#startEntityModelManager";
    
    private final GenericModelManager genericModelManager = new GenericModelManager();

    @Override
    public List<String> getMethodsKeys() {
        return new ArrayList<>(
                Arrays.asList(START));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        if (method.equals(START)) {
            startEntityModelManager(call, result);
        } else {
            result.notImplemented();
        }
    }

    private void startEntityModelManager(MethodCall call, final MethodChannel.Result result) {
        String task = (String) call.argument("task");
        switch (task) {
            case "download":
                downloadModel(result, (String) call.argument("model"), (boolean) call.argument("wifi"));
                break;
            case "delete":
                deleteModel(result, (String) call.argument("model"));
                break;
            case "getModels":
                getDownloadedModels(result);
                break;
            case "check":
                EntityExtractionRemoteModel model =
                        new EntityExtractionRemoteModel.Builder((String) call.argument("model")).build();
                Boolean downloaded = new GenericModelManager().isModelDownloaded(model);
                if (downloaded != null) result.success(downloaded);
                else result.error("error", null, null);
                break;
            default:
                result.notImplemented();
        }
    }

    private void getDownloadedModels(final MethodChannel.Result result) {
        genericModelManager.remoteModelManager.getDownloadedModels(EntityExtractionRemoteModel.class).addOnSuccessListener(new OnSuccessListener<Set<EntityExtractionRemoteModel>>() {
            @Override
            public void onSuccess(@NonNull Set<EntityExtractionRemoteModel> entityExtractionRemoteModels) {
                List<String> downloadedModels = new ArrayList<>(entityExtractionRemoteModels.size());
                for (EntityExtractionRemoteModel entityRemoteModel : entityExtractionRemoteModels) {
                    downloadedModels.add(entityRemoteModel.getModelIdentifier());
                }
                result.success(downloadedModels);
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                result.error("Error getting downloaded models", e.toString(), null);
            }
        });
    }

    private void downloadModel(final MethodChannel.Result result, String language, boolean isWifiReqRequired) {
        final EntityExtractionRemoteModel downloadModel = new EntityExtractionRemoteModel.Builder(language).build();
        final DownloadConditions downloadConditions;

        if (genericModelManager.isModelDownloaded(downloadModel)) {
            Log.e("Already downloaded", "Model is already present");
            result.success("success");
            return;
        }

        Log.e("Wifi", String.valueOf(isWifiReqRequired));
        if (isWifiReqRequired)
            downloadConditions = new DownloadConditions.Builder().requireWifi().build();
        else downloadConditions = new DownloadConditions.Builder().build();

        genericModelManager.downloadModel(downloadModel, downloadConditions, result);
    }

    private void deleteModel(final MethodChannel.Result result, String languageCode) {
        EntityExtractionRemoteModel deleteModel = new EntityExtractionRemoteModel.Builder(languageCode).build();

        if (!genericModelManager.isModelDownloaded(deleteModel)) {
            Log.e("error", "Model not present");
            result.success("success");
            return;
        }
        genericModelManager.deleteModel(deleteModel, result);
    }
}
