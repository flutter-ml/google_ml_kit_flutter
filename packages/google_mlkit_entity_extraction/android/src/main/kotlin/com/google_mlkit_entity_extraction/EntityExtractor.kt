package com.google_mlkit_entity_extraction

import com.google.mlkit.nl.entityextraction.Entity
import com.google.mlkit.nl.entityextraction.EntityExtraction
import com.google.mlkit.nl.entityextraction.EntityExtractionParams
import com.google.mlkit.nl.entityextraction.EntityExtractionRemoteModel
import com.google.mlkit.nl.entityextraction.EntityExtractorOptions
import com.google_mlkit_commons.GenericModelManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import java.util.TimeZone

class EntityExtractor : MethodChannel.MethodCallHandler {
    companion object {
        private const val START = "nlp#startEntityExtractor"
        private const val CLOSE = "nlp#closeEntityExtractor"
        private const val MANAGE = "nlp#manageEntityExtractionModels"
    }

    private val instances = HashMap<String, com.google.mlkit.nl.entityextraction.EntityExtractor>()
    private val genericModelManager = GenericModelManager()

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            START -> {
                extractEntities(call, result)
            }

            CLOSE -> {
                closeDetector(call)
                result.success(null)
            }

            MANAGE -> {
                manageModel(call, result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun extractEntities(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val text = call.argument<String>("text")
        val id = call.argument<String>("id")

        var extractor = instances[id]
        if (extractor == null) {
            val language = call.argument<String>("language")!!
            extractor =
                EntityExtraction.getClient(
                    EntityExtractorOptions.Builder(language).build(),
                )
            instances[id!!] = extractor
        }

        val entityExtractor = extractor

        val parameters = call.argument<Map<String, Any>>("parameters")!!
        val filters = (parameters["filters"] as? List<Int>)?.toHashSet()

        val locale =
            (parameters["locale"] as? String)?.let {
                Locale.Builder().setLanguage(it).build()
            }

        val timeZone =
            (parameters["timezone"] as? String)?.let {
                TimeZone.getTimeZone(it)
            }

        val referenceTime = parameters["time"] as? Long

        val params =
            EntityExtractionParams
                .Builder(text!!)
                .setEntityTypesFilter(filters)
                .setPreferredLocale(locale)
                .setReferenceTimeZone(timeZone)
                .setReferenceTime(referenceTime)
                .build()

        entityExtractor
            .downloadModelIfNeeded()
            .addOnSuccessListener {
                entityExtractor
                    .annotate(params)
                    .addOnSuccessListener { entityAnnotations ->
                        val allAnnotation =
                            entityAnnotations.map { entityAnnotation ->
                                val allEntities =
                                    entityAnnotation.entities.map { entity ->
                                        val entityData = HashMap<String, Any>()
                                        entityData["type"] = entity.type
                                        entityData["raw"] = entity.toString()

                                        when (entity.type) {
                                            Entity.TYPE_ADDRESS,
                                            Entity.TYPE_URL,
                                            Entity.TYPE_PHONE,
                                            Entity.TYPE_EMAIL,
                                            -> {
                                                Unit
                                            }

                                            Entity.TYPE_DATE_TIME -> {
                                                val dateTimeEntity = entity.asDateTimeEntity()
                                                entityData["dateTimeGranularity"] = dateTimeEntity!!.dateTimeGranularity + 1
                                                entityData["timestamp"] = dateTimeEntity.timestampMillis
                                            }

                                            Entity.TYPE_FLIGHT_NUMBER -> {
                                                val flightNumberEntity = entity.asFlightNumberEntity()
                                                entityData["code"] = flightNumberEntity!!.airlineCode
                                                entityData["number"] = flightNumberEntity.flightNumber
                                            }

                                            Entity.TYPE_IBAN -> {
                                                val ibanEntity = entity.asIbanEntity()
                                                entityData["iban"] = ibanEntity!!.iban
                                                entityData["code"] = ibanEntity.ibanCountryCode
                                            }

                                            Entity.TYPE_ISBN -> {
                                                entityData["isbn"] = entity.asIsbnEntity()!!.isbn
                                            }

                                            Entity.TYPE_MONEY -> {
                                                val moneyEntity = entity.asMoneyEntity()
                                                entityData["fraction"] = moneyEntity!!.fractionalPart
                                                entityData["integer"] = moneyEntity.integerPart
                                                entityData["unnormalized"] = moneyEntity.unnormalizedCurrency
                                            }

                                            Entity.TYPE_PAYMENT_CARD -> {
                                                val paymentCardEntity = entity.asPaymentCardEntity()
                                                entityData["network"] = paymentCardEntity!!.paymentCardNetwork
                                                entityData["number"] = paymentCardEntity.paymentCardNumber
                                            }

                                            Entity.TYPE_TRACKING_NUMBER -> {
                                                val trackingNumberEntity = entity.asTrackingNumberEntity()
                                                entityData["carrier"] = trackingNumberEntity!!.parcelCarrier
                                                entityData["number"] = trackingNumberEntity.parcelTrackingNumber
                                            }
                                        }
                                        entityData
                                    }

                                hashMapOf(
                                    "text" to entityAnnotation.annotatedText,
                                    "start" to entityAnnotation.start,
                                    "end" to entityAnnotation.end,
                                    "entities" to allEntities,
                                )
                            }
                        result.success(allAnnotation)
                    }.addOnFailureListener { e ->
                        result.error("BarcodeDetectorError", e.toString(), null)
                    }
            }.addOnFailureListener {
                result.error("Error building extractor", "Model not downloaded", null)
            }
    }

    private fun closeDetector(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        val entityExtractor = instances[id] ?: return
        entityExtractor.close()
        instances.remove(id)
    }

    private fun manageModel(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val model = EntityExtractionRemoteModel.Builder(call.argument<String>("model")!!).build()
        genericModelManager.manageModel(model, call, result)
    }
}
