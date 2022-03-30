package com.google_ml_kit_translation;

import androidx.annotation.NonNull;

import com.google.mlkit.common.model.DownloadConditions;
import com.google.mlkit.nl.translate.TranslateRemoteModel;
import com.google.mlkit.nl.translate.Translation;
import com.google.mlkit.nl.translate.Translator;
import com.google.mlkit.nl.translate.TranslatorOptions;
import com.google_ml_kit_commons.GenericModelManager;

import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class TextTranslator implements MethodChannel.MethodCallHandler {

    private static final String START = "nlp#startLanguageTranslator";
    private static final String CLOSE = "nlp#closeLanguageTranslator";
    private static final String START_MODEL_MANAGER = "nlp#startLanguageModelManager";

    private final GenericModelManager genericModelManager = new GenericModelManager();
    private Translator translator;

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        if (method.equals(START)) {
            translateText(call, result);
        } else if (method.equals(CLOSE)) {
            closeDetector();
            result.success(null);
        } else if (method.equals(START_MODEL_MANAGER)) {
            startLanguageModelManager(call, result);
        } else {
            result.notImplemented();
        }
    }

    private void translateText(MethodCall call, final MethodChannel.Result result) {
        String sourceLanguage = call.argument("source");
        String targetLanguage = call.argument("target");

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
            translator = Translation.getClient(translatorOptions);
        } else {
            result.error("Error building translator", "Either source or target models not downloaded", null);
            return;
        }

        String text = call.argument("text");
        translator.translate(text)
                .addOnSuccessListener(result::success)
                .addOnFailureListener(e -> result.error("error translating", e.toString(), null));
    }

    private void closeDetector() {
        translator.close();
    }

    private void startLanguageModelManager(MethodCall call, final MethodChannel.Result result) {
        String task = call.argument("task");
        switch (task) {
            case "download":
                downloadModel(result, call.argument("model"), call.argument("wifi"));
                break;
            case "delete":
                deleteModel(result, call.argument("model"));
                break;
            case "getModels":
                getDownloadedModels(result);
                break;
            case "check":
                TranslateRemoteModel model =
                        new TranslateRemoteModel.Builder(call.argument("model")).build();
                Boolean downloaded = genericModelManager.isModelDownloaded(model);
                if (downloaded != null) result.success(downloaded);
                else result.error("error", null, null);
                break;
            default:
                result.notImplemented();
        }
    }

    private void getDownloadedModels(final MethodChannel.Result result) {
        genericModelManager.remoteModelManager.getDownloadedModels(TranslateRemoteModel.class).addOnSuccessListener(translateRemoteModels -> {
            List<String> downloadedModels = new ArrayList<>();
            for (TranslateRemoteModel translateRemoteModel : translateRemoteModels) {
                downloadedModels.add(translateRemoteModel.getLanguage());
            }
            result.success(downloadedModels);
        }).addOnFailureListener(e -> result.error("Error getting downloaded models", e.toString(), null));
    }

    private void downloadModel(final MethodChannel.Result result, String languageCode, boolean isWifiReqRequired) {
        TranslateRemoteModel model = new TranslateRemoteModel.Builder(languageCode).build();
        DownloadConditions downloadConditions;
        if (isWifiReqRequired)
            downloadConditions = new DownloadConditions.Builder().requireWifi().build();
        else
            downloadConditions = new DownloadConditions.Builder().build();
        genericModelManager.downloadModel(model, downloadConditions, result);
    }

    private void deleteModel(final MethodChannel.Result result, String languageCode) {
        TranslateRemoteModel model = new TranslateRemoteModel.Builder(languageCode).build();
        genericModelManager.deleteModel(model, result);
    }
}
