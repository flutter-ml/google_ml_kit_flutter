package com.b.biradar.google_ml_kit;

import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.common.model.DownloadConditions;
import com.google.mlkit.common.model.RemoteModel;
import com.google.mlkit.common.model.RemoteModelManager;
import com.google.mlkit.nl.translate.TranslateRemoteModel;
import com.google.mlkit.nl.translate.Translation;
import com.google.mlkit.nl.translate.Translator;
import com.google.mlkit.nl.translate.TranslatorOptions;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import io.flutter.plugin.common.MethodChannel;

public class OnDeviceTranslator {
    private static final GenericModelManager genericModelManager = new GenericModelManager();
    private final Translator translator;

    public OnDeviceTranslator(Translator translator) {
        this.translator = translator;
    }

    public static OnDeviceTranslator Instance(String sourceLanguage, String targetLanguage, MethodChannel.Result result) {
        TranslateRemoteModel sourceModel =
                new TranslateRemoteModel.Builder(sourceLanguage).build();

        TranslateRemoteModel targetModel =
                new TranslateRemoteModel.Builder(targetLanguage).build();

        if (genericModelManager.isModelDownloaded(sourceModel) &&
                genericModelManager.isModelDownloaded(targetModel)) {
            TranslatorOptions translatorOptions = new TranslatorOptions.Builder()
                    .setSourceLanguage(sourceLanguage)
                    .setTargetLanguage(targetLanguage)
                    .build();
            final Translator translator = Translation.getClient(translatorOptions);

            return new OnDeviceTranslator(translator);
        } else {
            result.error("Error building translator", "Either source or target models not downloaded", null);
            return null;
        }
    }

    public void translateText(String text, final MethodChannel.Result result) {
        translator.translate(text).addOnSuccessListener(new OnSuccessListener<String>() {
            @Override
            public void onSuccess(@NonNull String s) {
                result.success(s);
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                Log.e("error translating", e.toString());
                result.error("error translating", e.toString(), null);
            }
        });
    }

    public void close() {
        translator.close();
        Log.e("Detector closed", "");
    }
}

class TranslatorModelManager {
    RemoteModelManager remoteModelManager = RemoteModelManager.getInstance();
    GenericModelManager genericModelManager = new GenericModelManager();
//    ExecutorService executorService = Executors.newCachedThreadPool();

    public void getDownloadedModels(final MethodChannel.Result result) {
        remoteModelManager.getDownloadedModels(TranslateRemoteModel.class).addOnSuccessListener(new OnSuccessListener<Set<TranslateRemoteModel>>() {
            @Override
            public void onSuccess(@NonNull Set<TranslateRemoteModel> translateRemoteModels) {
                List<String> downloadedModels = new ArrayList<>(translateRemoteModels.size());
                for (TranslateRemoteModel translateRemoteModel : translateRemoteModels) {
                    downloadedModels.add(translateRemoteModel.getLanguage());
                }
                result.success(downloadedModels);
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                Log.e("Error getting models", e.toString());
                result.error("Error getting downloaded models", e.toString(), null);
            }
        });
    }

    public void downloadModel(final MethodChannel.Result result, String languageCode, boolean isWifiReqRequired) {

        final TranslateRemoteModel downloadModel = new TranslateRemoteModel.Builder(languageCode).build();
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

    public void deleteModel(final MethodChannel.Result result, String languageCode) {
        TranslateRemoteModel deleteModel = new TranslateRemoteModel.Builder(languageCode).build();

        if (!genericModelManager.isModelDownloaded(deleteModel)) {
            Log.e("error", "Model not present");
            result.success("success");
            return;
        }
        genericModelManager.deleteModel(deleteModel, result);
    }


}