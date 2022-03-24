package com.google_ml_kit.nl;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.nl.entityextraction.DateTimeEntity;
import com.google.mlkit.nl.entityextraction.Entity;
import com.google.mlkit.nl.entityextraction.EntityAnnotation;
import com.google.mlkit.nl.entityextraction.EntityExtraction;
import com.google.mlkit.nl.entityextraction.EntityExtractionParams;
import com.google.mlkit.nl.entityextraction.EntityExtractorOptions;
import com.google.mlkit.nl.entityextraction.FlightNumberEntity;
import com.google.mlkit.nl.entityextraction.IbanEntity;
import com.google.mlkit.nl.entityextraction.IsbnEntity;
import com.google.mlkit.nl.entityextraction.MoneyEntity;
import com.google.mlkit.nl.entityextraction.PaymentCardEntity;
import com.google.mlkit.nl.entityextraction.TrackingNumberEntity;
import com.google_ml_kit.ApiDetectorInterface;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class EntityExtractor implements ApiDetectorInterface {

    private static final String START = "nlp#startEntityExtractor";
    private static final String CLOSE = "nlp#closeEntityExtractor";

    private com.google.mlkit.nl.entityextraction.EntityExtractor entityExtractor;

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
            extractEntities(call, result);
        } else if (method.equals(CLOSE)) {
            closeDetector();
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    private void extractEntities(MethodCall call, final MethodChannel.Result result) {
        String language = (String) call.argument("language");
        Map<String, Object> parameters = (Map<String, Object>) call.argument("parameters");
        String text = (String) call.argument("text");

        entityExtractor = EntityExtraction.getClient(
                new EntityExtractorOptions.Builder(language)
                        .build());

        Set<Integer> filters = null;
        Locale locale = null;
        TimeZone timeZone = null;
        if (parameters.get("filters") != null) {
            filters = new HashSet<>(((List<Integer>) parameters.get("filters")));
        }

        if (parameters.get("locale") != null) {
            Map<String, Object> localeParams = (Map<String, Object>) parameters.get("locale");
            locale = new Locale.Builder().setLanguage((String) localeParams.get("language")).build();
        }
        if (parameters.get("timezone") != null) {
            timeZone = TimeZone.getTimeZone((String) parameters.get("timezone"));
        }

        EntityExtractionParams params = new EntityExtractionParams.Builder(text)
                .setEntityTypesFilter(filters)
                .setPreferredLocale(locale)
                .setReferenceTimeZone(timeZone)
                .build();

        entityExtractor.annotate(params)
                .addOnSuccessListener(new OnSuccessListener<List<EntityAnnotation>>() {
                    @Override
                    public void onSuccess(@NonNull List<EntityAnnotation> entityAnnotations) {
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
                                        entityData.put("dateTimeGranularity", dateTimeEntity.getDateTimeGranularity());
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
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        result.error("BarcodeDetectorError", e.toString(), null);
                    }
                });
    }

    public void closeDetector() {
        entityExtractor.close();
    }
}
