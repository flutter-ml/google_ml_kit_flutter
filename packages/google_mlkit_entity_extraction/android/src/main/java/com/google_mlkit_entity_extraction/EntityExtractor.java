package com.google_mlkit_entity_extraction;

import androidx.annotation.NonNull;

import com.google.mlkit.nl.entityextraction.DateTimeEntity;
import com.google.mlkit.nl.entityextraction.Entity;
import com.google.mlkit.nl.entityextraction.EntityAnnotation;
import com.google.mlkit.nl.entityextraction.EntityExtraction;
import com.google.mlkit.nl.entityextraction.EntityExtractionParams;
import com.google.mlkit.nl.entityextraction.EntityExtractionRemoteModel;
import com.google.mlkit.nl.entityextraction.EntityExtractorOptions;
import com.google.mlkit.nl.entityextraction.FlightNumberEntity;
import com.google.mlkit.nl.entityextraction.IbanEntity;
import com.google.mlkit.nl.entityextraction.IsbnEntity;
import com.google.mlkit.nl.entityextraction.MoneyEntity;
import com.google.mlkit.nl.entityextraction.PaymentCardEntity;
import com.google.mlkit.nl.entityextraction.TrackingNumberEntity;
import com.google_mlkit_commons.GenericModelManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class EntityExtractor implements MethodChannel.MethodCallHandler {
    private static final String START = "nlp#startEntityExtractor";
    private static final String CLOSE = "nlp#closeEntityExtractor";
    private static final String MANAGE = "nlp#manageEntityExtractionModels";

    private final Map<String, com.google.mlkit.nl.entityextraction.EntityExtractor> instances = new HashMap<>();
    private final GenericModelManager genericModelManager = new GenericModelManager();

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        switch (method) {
            case START:
                extractEntities(call, result);
                break;
            case CLOSE:
                closeDetector(call);
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

    private void extractEntities(MethodCall call, final MethodChannel.Result result) {
        String text = call.argument("text");

        String id = call.argument("id");
        com.google.mlkit.nl.entityextraction.EntityExtractor extractor = instances.get(id);
        if (extractor == null) {
            String language = call.argument("language");
            extractor = EntityExtraction.getClient(
                    new EntityExtractorOptions.Builder(language)
                            .build());
            instances.put(id, extractor);
        }
        final com.google.mlkit.nl.entityextraction.EntityExtractor entityExtractor = extractor;

        Map<String, Object> parameters = call.argument("parameters");
        Set<Integer> filters = null;
        if (parameters.get("filters") != null) {
            filters = new HashSet<>((List<Integer>) parameters.get("filters"));
        }

        Locale locale = null;
        if (parameters.get("locale") != null) {
            locale = new Locale.Builder().setLanguage((String) parameters.get("locale")).build();
        }

        TimeZone timeZone = null;
        if (parameters.get("timezone") != null) {
            timeZone = TimeZone.getTimeZone((String) parameters.get("timezone"));
        }

        Long referenceTime = null;
        if (parameters.get("time") != null) {
            referenceTime = (Long) parameters.get("time");
        }

        EntityExtractionParams params = new EntityExtractionParams.Builder(text)
                .setEntityTypesFilter(filters)
                .setPreferredLocale(locale)
                .setReferenceTimeZone(timeZone)
                .setReferenceTime(referenceTime)
                .build();

        entityExtractor
                .downloadModelIfNeeded()
                .addOnSuccessListener(
                        aVoid -> {
                            // Model downloading succeeded, you can call the extraction API here.
                            entityExtractor.annotate(params)
                                    .addOnSuccessListener(entityAnnotations -> {
                                        List<Map<String, Object>> allAnnotations = new ArrayList<>(entityAnnotations.size());

                                        for (EntityAnnotation entityAnnotation : entityAnnotations) {
                                            Map<String, Object> annotation = new HashMap<>();
                                            List<Entity> entities = entityAnnotation.getEntities();
                                            annotation.put("text", entityAnnotation.getAnnotatedText());
                                            annotation.put("start", entityAnnotation.getStart());
                                            annotation.put("end", entityAnnotation.getEnd());

                                            List<Map<String, Object>> allEntities = new ArrayList<>();
                                            for (Entity entity : entities) {
                                                Map<String, Object> entityData = new HashMap<>();
                                                entityData.put("type", entity.getType());
                                                entityData.put("raw", entity.toString());
                                                switch (entity.getType()) {
                                                    case Entity.TYPE_ADDRESS:
                                                    case Entity.TYPE_URL:
                                                    case Entity.TYPE_PHONE:
                                                    case Entity.TYPE_EMAIL:
                                                        break;
                                                    case Entity.TYPE_DATE_TIME:
                                                        DateTimeEntity dateTimeEntity = entity.asDateTimeEntity();
                                                        entityData.put("dateTimeGranularity", dateTimeEntity.getDateTimeGranularity() + 1);
                                                        entityData.put("timestamp", dateTimeEntity.getTimestampMillis());
                                                        break;
                                                    case Entity.TYPE_FLIGHT_NUMBER:
                                                        FlightNumberEntity flightNumberEntity = entity.asFlightNumberEntity();
                                                        entityData.put("code", flightNumberEntity.getAirlineCode());
                                                        entityData.put("number", flightNumberEntity.getFlightNumber());
                                                        break;
                                                    case Entity.TYPE_IBAN:
                                                        IbanEntity ibanEntity = entity.asIbanEntity();
                                                        entityData.put("iban", ibanEntity.getIban());
                                                        entityData.put("code", ibanEntity.getIbanCountryCode());
                                                        break;
                                                    case Entity.TYPE_ISBN:
                                                        IsbnEntity isbnEntity = entity.asIsbnEntity();
                                                        entityData.put("isbn", isbnEntity.getIsbn());
                                                        break;
                                                    case Entity.TYPE_MONEY:
                                                        MoneyEntity moneyEntity = entity.asMoneyEntity();
                                                        entityData.put("fraction", moneyEntity.getFractionalPart());
                                                        entityData.put("integer", moneyEntity.getIntegerPart());
                                                        entityData.put("unnormalized", moneyEntity.getUnnormalizedCurrency());
                                                        break;
                                                    case Entity.TYPE_PAYMENT_CARD:
                                                        PaymentCardEntity paymentCardEntity = entity.asPaymentCardEntity();
                                                        entityData.put("network", paymentCardEntity.getPaymentCardNetwork());
                                                        entityData.put("number", paymentCardEntity.getPaymentCardNumber());
                                                        break;
                                                    case Entity.TYPE_TRACKING_NUMBER:
                                                        TrackingNumberEntity trackingNumberEntity = entity.asTrackingNumberEntity();
                                                        entityData.put("carrier", trackingNumberEntity.getParcelCarrier());
                                                        entityData.put("number", trackingNumberEntity.getParcelTrackingNumber());
                                                        break;
                                                }

                                                allEntities.add(entityData);
                                            }
                                            annotation.put("entities", allEntities);
                                            allAnnotations.add(annotation);
                                        }

                                        result.success(allAnnotations);
                                    })
                                    .addOnFailureListener(e -> result.error("BarcodeDetectorError", e.toString(), null));
                        })
                .addOnFailureListener(
                        e -> {
                            // Model could not be downloaded or other internal error.
                            result.error("Error building extractor", "Model not downloaded", null);
                        });
    }

    private void closeDetector(MethodCall call) {
        String id = call.argument("id");
        com.google.mlkit.nl.entityextraction.EntityExtractor entityExtractor = instances.get(id);
        if (entityExtractor == null) return;
        entityExtractor.close();
        instances.remove(id);
    }

    private void manageModel(MethodCall call, final MethodChannel.Result result) {
        EntityExtractionRemoteModel model =
                new EntityExtractionRemoteModel.Builder(call.argument("model")).build();
        genericModelManager.manageModel(model, call, result);
    }
}
