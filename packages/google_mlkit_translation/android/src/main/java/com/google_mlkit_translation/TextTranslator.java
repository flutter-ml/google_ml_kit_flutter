package com.google_mlkit_translation;

import androidx.annotation.NonNull;

import com.google.mlkit.nl.translate.TranslateRemoteModel;
import com.google.mlkit.nl.translate.Translation;
import com.google.mlkit.nl.translate.Translator;
import com.google.mlkit.nl.translate.TranslatorOptions;
import com.google_mlkit_commons.GenericModelManager;

import java.util.HashMap;
import java.util.Map;

public class TextTranslator implements Pigeon.OnDeviceTranslatorApi {
    private final Map<String, Translator> instances = new HashMap<>();
    private final GenericModelManager genericModelManager = new GenericModelManager();

    @Override
    public void translateText(
        @NonNull Pigeon.TranslateRequest request, 
        @NonNull Pigeon.Result<String> result
        ) {
        String id = request.getId();
        Translator onDeviceTranslator = instances.get(id);

        if (onDeviceTranslator == null) {
            TranslatorOptions options = new TranslatorOptions.Builder()
                    .setSourceLanguage(request.getSourceLanguage())
                    .setTargetLanguage(request.getTargetLanguage())
                    .build();
            onDeviceTranslator = Translation.getClient(options);
            instances.put(id, onDeviceTranslator);
        }
        final Translator translator = onDeviceTranslator;
        final String text = request.getText();

        translator.downloadModelIfNeeded()
                .addOnSuccessListener(
                        (OnSuccessListener) -> {
                            // Model downloaded successfully. Okay to start translating.
                            translator.translate(text)
                                    .addOnSuccessListener(result::success)
                                    .addOnFailureListener(
                                            e -> result.error(new Exception("Error translating: " + e.getMessage())));
                        })
                .addOnFailureListener(
                        e -> {
                            // Model could not be downloaded, or there was another internal error.
                            result.error(new Exception("Error building translator. Either source or target models are not downloaded: " + e.getMessage()));
                        });
    }

    @Override
    public void closeTranslator(@NonNull Pigeon.CloseTranslatorRequest request) {
        String id = request.getId();
        Translator translator = instances.get(id);
        if (translator == null) return;
        translator.close();
        instances.remove(id);
    }

    @Override
    public void manageModel(@NonNull Pigeon.ModelManagementRequest request, @NonNull Pigeon.Result<Pigeon.ModelManagementResponse> result) {
//        TranslateRemoteModel model = new TranslateRemoteModel.Builder(request.getModel()).build();
//        String task = request.getTask();
//        genericModelManager.manageModel(model, request, result);
    }

}
