package com.google_mlkit_translation;

import androidx.annotation.NonNull;

import com.google.mlkit.nl.translate.TranslateRemoteModel;
import com.google.mlkit.nl.translate.Translation;
import com.google.mlkit.nl.translate.Translator;
import com.google.mlkit.nl.translate.TranslatorOptions;
import com.google_mlkit_commons.GenericModelManager;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class TextTranslator implements MethodChannel.MethodCallHandler {
    private static final String START = "nlp#startLanguageTranslator";
    private static final String CLOSE = "nlp#closeLanguageTranslator";
    private static final String MANAGE = "nlp#manageLanguageModelModels";

    private final GenericModelManager genericModelManager = new GenericModelManager();
    private Translator translator;

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        switch (method) {
            case START:
                translateText(call, result);
                break;
            case CLOSE:
                closeDetector();
                result.success(null);
                break;
            case MANAGE:
                manageModel(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void translateText(MethodCall call, final MethodChannel.Result result) {
        String text = call.argument("text");

        if (translator == null) {
            String sourceLanguage = call.argument("source");
            String targetLanguage = call.argument("target");
            TranslatorOptions options = new TranslatorOptions.Builder()
                    .setSourceLanguage(sourceLanguage)
                    .setTargetLanguage(targetLanguage)
                    .build();
            translator = Translation.getClient(options);
        }

        translator.downloadModelIfNeeded()
                .addOnSuccessListener(
                        (OnSuccessListener) -> {
                            // Model downloaded successfully. Okay to start translating.
                            translator.translate(text)
                                    .addOnSuccessListener(result::success)
                                    .addOnFailureListener(
                                            e -> result.error("error translating", e.toString(), null));
                        })
                .addOnFailureListener(
                        e -> {
                            // Model could not be downloaded or other internal error.
                            result.error("Error building translator", "Either source or target models not downloaded", null);
                        });
    }

    private void closeDetector() {
        if (translator == null) return;
        translator.close();
        translator = null;
    }

    private void manageModel(MethodCall call, final MethodChannel.Result result) {
        TranslateRemoteModel model = new TranslateRemoteModel.Builder(call.argument("model")).build();
        genericModelManager.manageModel(model, call, result);
    }
}
