package com.google_ml_kit.nl;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.nl.languageid.IdentifiedLanguage;
import com.google.mlkit.nl.languageid.LanguageIdentification;
import com.google.mlkit.nl.languageid.LanguageIdentificationOptions;
import com.google.mlkit.nl.languageid.LanguageIdentifier;
import com.google_ml_kit.ApiDetectorInterface;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class LanguageDetector implements ApiDetectorInterface {
    private static final String START = "nlp#startLanguageIdentifier";
    private static final String CLOSE = "nlp#closeLanguageIdentifier";

    // NOTE: changing this value means a breaking change for plugin API (on dart side)
    private static final String errorCodeNoLanguageIdentified = "no language identified";

    private static final String bcpLanguageTagUndetermined = "und";

    private LanguageIdentifier languageIdentifier;

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
            identifyLanguages(call, result);
        } else if (method.equals(CLOSE)) {
            closeDetector();
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    private void identifyLanguages(MethodCall call, final MethodChannel.Result result) {
        double confidence = (double) call.argument("confidence");
        languageIdentifier = LanguageIdentification.getClient(
                new LanguageIdentificationOptions.Builder()
                        .setConfidenceThreshold((float) confidence)
                        .build());

        if (call.argument("possibleLanguages").equals("no")) {
            identifyLanguage((String) call.argument("text"), result);
        } else {
            identifyPossibleLanguages((String) call.argument("text"), result);
        }
    }

    private void identifyLanguage(String text, final MethodChannel.Result result) {
        languageIdentifier.identifyLanguage(text)
                .addOnSuccessListener(new OnSuccessListener<String>() {
                    @Override
                    public void onSuccess(@NonNull String languageCode) {
                      if(languageCode.equals(bcpLanguageTagUndetermined)) {
                        result.error(errorCodeNoLanguageIdentified, "no language detected", null);
                        return;
                      }
                      result.success(languageCode);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        result.error("Language Identification Error", e.toString(), null);
                    }
                });
    }

    private void identifyPossibleLanguages(String text, final MethodChannel.Result result) {
        languageIdentifier.identifyPossibleLanguages(text)
                .addOnSuccessListener(new OnSuccessListener<List<IdentifiedLanguage>>() {
                    @Override
                    public void onSuccess(@NonNull List<IdentifiedLanguage> identifiedLanguages) {
                        List<Map<String, Object>> languageList = new ArrayList<>();
                        if(identifiedLanguages.size() == 1 && identifiedLanguages.get(0).getLanguageTag().equals(bcpLanguageTagUndetermined)) {
                            result.error(errorCodeNoLanguageIdentified, "no languages detected", null);
                            return;
                        }
                        for (IdentifiedLanguage language : identifiedLanguages) {
                            Map<String, Object> languageData = new HashMap<>();
                            languageData.put("confidence", language.getConfidence());
                            languageData.put("language", language.getLanguageTag());
                            languageList.add(languageData);
                        }

                        result.success(languageList);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        result.error("Error identifying possible languages", e.toString(), null);
                    }
                });
    }

    private void closeDetector() {
        languageIdentifier.close();
    }
}
