package com.b.biradar.google_ml_kit;

import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.common.model.DownloadConditions;
import com.google.mlkit.common.model.RemoteModelManager;
import com.google.mlkit.nl.entityextraction.DateTimeEntity;
import com.google.mlkit.nl.entityextraction.Entity;
import com.google.mlkit.nl.entityextraction.EntityAnnotation;
import com.google.mlkit.nl.entityextraction.EntityExtraction;
import com.google.mlkit.nl.entityextraction.EntityExtractionParams;
import com.google.mlkit.nl.entityextraction.EntityExtractionRemoteModel;
import com.google.mlkit.nl.entityextraction.EntityExtractor;
import com.google.mlkit.nl.entityextraction.EntityExtractorOptions;
import com.google.mlkit.nl.entityextraction.FlightNumberEntity;
import com.google.mlkit.nl.entityextraction.IbanEntity;
import com.google.mlkit.nl.entityextraction.IsbnEntity;
import com.google.mlkit.nl.entityextraction.MoneyEntity;
import com.google.mlkit.nl.entityextraction.PaymentCardEntity;
import com.google.mlkit.nl.entityextraction.TrackingNumberEntity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;

import io.flutter.plugin.common.MethodChannel;

public class EntityExtractorApi {
    private final EntityExtractor entityExtractor;

    public EntityExtractorApi(EntityExtractor entityExtractor) {
        this.entityExtractor = entityExtractor;
    }

    static EntityExtractorApi getInstance(String language){
        EntityExtractor entityExtractor =  EntityExtraction.getClient(
                        new EntityExtractorOptions.Builder(language)
                                .build());

        return new EntityExtractorApi(entityExtractor);
    }

    public void identifyParams(Map<String,Object> parameters, final MethodChannel.Result result, String text){
        Set<Integer> filters = null;
        Locale locale = null;
        TimeZone timeZone = null;
        if(parameters.get("filters")!=null){
            filters = new HashSet<Integer>(((List<Integer>) parameters.get("filters")));
        }

        if (parameters.get("locale")!=null){
            Map<String,Object> localeParams = (Map<String, Object>) parameters.get("locale");
            locale = new Locale.Builder().setLanguage((String) localeParams.get("language")).build();
        }
        if (parameters.get("timezone")!=null){
            timeZone = TimeZone.getTimeZone((String) parameters.get("timezone"));
        }

        EntityExtractionParams params =  new EntityExtractionParams.Builder(text)
                                                .setEntityTypesFilter(filters)
                                                .setPreferredLocale(locale)
                                                .setReferenceTimeZone(timeZone)
                                                .build();

        entityExtractor
                .annotate(params)
                    .addOnSuccessListener(new OnSuccessListener<List<EntityAnnotation>>() {
                            @Override
                            public void onSuccess(@NonNull List<EntityAnnotation> entityAnnotations) {
                                List<Map<String,Object>> allAnnotations = new ArrayList<>(entityAnnotations.size());

                                for (EntityAnnotation entityAnnotation : entityAnnotations){
                                    Map<String, Object> annotation = new HashMap<>();
                                    List<Entity> entities = entityAnnotation.getEntities();
                                    annotation.put("text",entityAnnotation.getAnnotatedText());
                                    annotation.put("start",entityAnnotation.getStart());
                                    annotation.put("end",entityAnnotation.getEnd());

                                    List<Map<String,Object>> allEntities = new ArrayList<>();
                                    for (Entity entity : entities){
                                        Map<String, Object>  entityData = new HashMap<>();
                                        entityData.put("type",entity.getType());
                                        switch (entity.getType()){
                                            case Entity.TYPE_ADDRESS:
                                            case Entity.TYPE_URL:
                                            case Entity.TYPE_PHONE:
                                            case Entity.TYPE_EMAIL:
                                                entityData.put("raw",entity.toString());
                                                break;
                                            case Entity.TYPE_DATE_TIME:
                                                DateTimeEntity dateTimeEntity = entity.asDateTimeEntity();
                                                entityData.put("dateTimeGranularity",dateTimeEntity.getDateTimeGranularity());
                                                entityData.put("timestamp",dateTimeEntity.getTimestampMillis());
                                                break;
                                            case Entity.TYPE_FLIGHT_NUMBER:
                                                FlightNumberEntity flightNumberEntity = entity.asFlightNumberEntity();
                                                entityData.put("code",flightNumberEntity.getAirlineCode());
                                                entityData.put("number",flightNumberEntity.getFlightNumber());
                                                break;
                                            case Entity.TYPE_IBAN:
                                                IbanEntity ibanEntity = entity.asIbanEntity();
                                                entityData.put("iban",ibanEntity.getIban());
                                                entityData.put("code",ibanEntity.getIbanCountryCode());
                                                break;
                                            case Entity.TYPE_ISBN:
                                                IsbnEntity isbnEntity = entity.asIsbnEntity();
                                                entityData.put("isbn",isbnEntity.getIsbn());
                                                break;
                                            case Entity.TYPE_MONEY:
                                                MoneyEntity moneyEntity = entity.asMoneyEntity();
                                                entityData.put("fraction",moneyEntity.getFractionalPart());
                                                entityData.put("integer",moneyEntity.getIntegerPart());
                                                entityData.put("unnormalized",moneyEntity.getUnnormalizedCurrency());
                                                break;
                                            case Entity.TYPE_PAYMENT_CARD:
                                                PaymentCardEntity paymentCardEntity = entity.asPaymentCardEntity();
                                                entityData.put("network",paymentCardEntity.getPaymentCardNetwork());
                                                entityData.put("number",paymentCardEntity.getPaymentCardNumber());
                                                break;
                                            case Entity.TYPE_TRACKING_NUMBER:
                                                TrackingNumberEntity trackingNumberEntity = entity.asTrackingNumberEntity();
                                                entityData.put("carries", trackingNumberEntity.getParcelCarrier());
                                                entityData.put("number", trackingNumberEntity.getParcelTrackingNumber());
                                                break;
                                        }

                                        allEntities.add(entityData);
                                    }

                                    allAnnotations.add(annotation);
                                }

                                result.success(allAnnotations);
                            }
                        }).addOnFailureListener(new OnFailureListener() {
                            @Override
                            public void onFailure(@NonNull Exception e) {

                        }
        });
    }

    public void close(){
        entityExtractor.close();
    }
}

class EntityModelManager{
    private final RemoteModelManager remoteModelManager = RemoteModelManager.getInstance();
    private final GenericModelManager genericModelManager = new GenericModelManager();

    public void getDownloadedModels(final MethodChannel.Result result) {
        remoteModelManager.getDownloadedModels(EntityExtractionRemoteModel.class).addOnSuccessListener(new OnSuccessListener<Set<EntityExtractionRemoteModel>>() {
            @Override
            public void onSuccess(@NonNull Set<EntityExtractionRemoteModel> entityExtractionRemoteModels) {
                List<String> downloadedModels = new ArrayList<>(entityExtractionRemoteModels.size());
                for (EntityExtractionRemoteModel entityRemoteModel : entityExtractionRemoteModels) {
                    downloadedModels.add(entityRemoteModel.getModelName());
                }
                result.success(downloadedModels);
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {

            }
        });
    }

    public void downloadModel(final MethodChannel.Result result, String language, boolean isWifiReqRequired) {

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

    public void deleteModel(final MethodChannel.Result result, String languageCode) {
        EntityExtractionRemoteModel deleteModel = new EntityExtractionRemoteModel.Builder(languageCode).build();

        if (!genericModelManager.isModelDownloaded(deleteModel)) {
            Log.e("error", "Model not present");
            result.success("success");
            return;
        }
        genericModelManager.deleteModel(deleteModel, result);
    }
}
