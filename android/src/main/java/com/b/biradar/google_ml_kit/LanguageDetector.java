package com.b.biradar.google_ml_kit;

import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.nl.languageid.IdentifiedLanguage;
import com.google.mlkit.nl.languageid.LanguageIdentification;
import com.google.mlkit.nl.languageid.LanguageIdentificationOptions;
import com.google.mlkit.nl.languageid.LanguageIdentifier;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class LanguageDetector {
    private final LanguageIdentifier languageIdentifier;

    LanguageDetector(double confidenceThreshold) {
        languageIdentifier = LanguageIdentification.getClient(
                new LanguageIdentificationOptions.Builder()
                        .setConfidenceThreshold((float) confidenceThreshold)
                        .build());
    }

    public void identifyLanguage(String text, final MethodChannel.Result result){
        languageIdentifier.identifyLanguage(text).addOnSuccessListener(new OnSuccessListener<String>() {
            @Override
            public void onSuccess(@NonNull String languageCode) {
                result.success(languageCode);
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                Log.e("LanguageIdnfction Error", e.toString());
                result.error("Language Identification Error", e.toString(),null);
            }
        });
    }

    public void identifyPossibleLanguages(String text, final MethodChannel.Result result){
        languageIdentifier.identifyPossibleLanguages(text).addOnSuccessListener(new OnSuccessListener<List<IdentifiedLanguage>>() {
            @Override
            public void onSuccess(@NonNull List<IdentifiedLanguage> identifiedLanguages) {
                List<Map<String,Object>> languageList = new ArrayList<>(identifiedLanguages.size());
                for(IdentifiedLanguage language: identifiedLanguages){
                    Map<String, Object> languageData = new HashMap<>();
                    languageData.put("confidence",language.getConfidence());
                    languageData.put("language",language.getLanguageTag());
                    languageList.add(languageData);
                }

                result.success(languageList);
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                Log.e("LanguageIdnfction Error", e.toString());
                result.error("Error identifying possible languages",e.toString(),null);
            }
        });
    }

    public void close(){
        languageIdentifier.close();
    }
}
