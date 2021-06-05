package com.google_ml_kit.nl;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.common.model.DownloadConditions;
import com.google.mlkit.nl.entityextraction.EntityExtractionRemoteModel;
import com.google_ml_kit.ApiDetectorInterface;
import com.google_ml_kit.GenericModelManager;

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
                Boolean downloaded = genericModelManager.isModelDownloaded(model);
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
                List<String> downloadedModels = new ArrayList<>();
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
        EntityExtractionRemoteModel downloadModel = new EntityExtractionRemoteModel.Builder(language).build();
        DownloadConditions downloadConditions;
        if (isWifiReqRequired)
            downloadConditions = new DownloadConditions.Builder().requireWifi().build();
        else
            downloadConditions = new DownloadConditions.Builder().build();
        genericModelManager.downloadModel(downloadModel, downloadConditions, result);
    }

    private void deleteModel(final MethodChannel.Result result, String languageCode) {
        EntityExtractionRemoteModel model = new EntityExtractionRemoteModel.Builder(languageCode).build();
        genericModelManager.deleteModel(model, result);
    }
}
