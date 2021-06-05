package com.google_ml_kit.nl;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.nl.translate.TranslateRemoteModel;
import com.google.mlkit.nl.translate.Translation;
import com.google.mlkit.nl.translate.Translator;
import com.google.mlkit.nl.translate.TranslatorOptions;
import com.google_ml_kit.ApiDetectorInterface;
import com.google_ml_kit.GenericModelManager;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class OnDeviceTranslator implements ApiDetectorInterface {
    private static final String START = "nlp#startLanguageTranslator";
    private static final String CLOSE = "nlp#closeLanguageTranslator";

    private final GenericModelManager genericModelManager = new GenericModelManager();
    private Translator translator;

    @Override
    public List<String> getMethodsKeys() {
        return new ArrayList<>(
                Arrays.asList(START,
                        CLOSE));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        if (method.equals(START)) {
            translateText(call, result);
        } else if (method.equals(CLOSE)) {
            closeDetector();
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    private void translateText(MethodCall call, final MethodChannel.Result result) {
        String sourceLanguage = (String) call.argument("source");
        String targetLanguage = (String) call.argument("target");

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

        String text = (String) call.argument("text");
        translator.translate(text)
                .addOnSuccessListener(new OnSuccessListener<String>() {
                    @Override
                    public void onSuccess(@NonNull String s) {
                        result.success(s);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        result.error("error translating", e.toString(), null);
                    }
                });
    }

    private void closeDetector() {
        translator.close();
    }
}

