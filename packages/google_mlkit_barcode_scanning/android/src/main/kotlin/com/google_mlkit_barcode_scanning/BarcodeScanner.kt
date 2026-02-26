package com.google_mlkit_barcode_scanning

import android.content.Context
import android.graphics.Point
import android.graphics.Rect
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google_mlkit_commons.InputImageConverter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BarcodeScanner(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, com.google.mlkit.vision.barcode.BarcodeScanner>()

    companion object {
        private const val START = "vision#startBarcodeScanner"
        private const val CLOSE = "vision#closeBarcodeScanner"
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            START -> {
                handleDetection(call, result)
            }

            CLOSE -> {
                closeDetector(call)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initialize(call: MethodCall): com.google.mlkit.vision.barcode.BarcodeScanner {
        val formatList = call.argument<List<Int>>("formats")!!
        val options =
            if (formatList.size > 1) {
                val rest = formatList.drop(1).toIntArray()
                BarcodeScannerOptions
                    .Builder()
                    .setBarcodeFormats(formatList[0], *rest)
                    .build()
            } else {
                BarcodeScannerOptions
                    .Builder()
                    .setBarcodeFormats(formatList[0])
                    .build()
            }

        return BarcodeScanning.getClient(options)
    }

    private fun handleDetection(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val imageData = call.argument<Map<String, Any>>("imageData") ?: run {
            result.error("BarcodeDetectorError", "imageData is null", null) 
            return
        }
        
        val inputImage = InputImageConverter.getInputImageFromData(imageData, context, result) ?: return

        val id = call.argument<String>("id")!!
        val scanner = instances.getOrPut(id) { initialize(call) }

        scanner
            .process(inputImage)
            .addOnSuccessListener { barcodes ->
                val barcodeList =
                    barcodes.map { barcode ->
                        buildMap<String, Any?> {
                            val valueType = barcode.valueType
                            put("type", valueType)
                            put("format", barcode.format)
                            put("rawValue", barcode.rawValue)
                            put("rawBytes", barcode.rawBytes)
                            put("displayValue", barcode.displayValue)
                            put("rect", getBoundingPoints(barcode.boundingBox))
                            put("points", barcode.cornerPoints?.let { getPoints(it) } ?: emptyList<Any>())

                            when (valueType) {
                                Barcode.TYPE_UNKNOWN,
                                Barcode.TYPE_ISBN,
                                Barcode.TYPE_PRODUCT,
                                Barcode.TYPE_TEXT,
                                -> {
                                    Unit
                                }

                                Barcode.TYPE_WIFI -> {
                                    barcode.wifi?.let {
                                        put("ssid", it.ssid)
                                        put("password", it.password)
                                        put("encryption", it.encryptionType)
                                    }
                                }

                                Barcode.TYPE_URL -> {
                                    barcode.url?.let {
                                        put("title", it.title)
                                        put("url", it.url)
                                    }
                                }

                                Barcode.TYPE_EMAIL -> {
                                    barcode.email?.let {
                                        put("address", it.address)
                                        put("body", it.body)
                                        put("subject", it.subject)
                                        put("emailType", it.type)
                                    }
                                }

                                Barcode.TYPE_PHONE -> {
                                    barcode.phone?.let {
                                        put("number", it.number)
                                        put("phoneType", it.type)
                                    }
                                }

                                Barcode.TYPE_SMS -> {
                                    barcode.sms?.let {
                                        put("message", it.message)
                                        put("number", it.phoneNumber)
                                    }
                                }

                                Barcode.TYPE_GEO -> {
                                    barcode.geoPoint?.let {
                                        put("latitude", it.lat)
                                        put("longitude", it.lng)
                                    }
                                }

                                Barcode.TYPE_DRIVER_LICENSE -> {
                                    barcode.driverLicense?.let {
                                        put("addressCity", it.addressCity)
                                        put("addressState", it.addressState)
                                        put("addressZip", it.addressZip)
                                        put("addressStreet", it.addressStreet)
                                        put("issueDate", it.issueDate)
                                        put("birthDate", it.birthDate)
                                        put("expiryDate", it.expiryDate)
                                        put("gender", it.gender)
                                        put("licenseNumber", it.licenseNumber)
                                        put("firstName", it.firstName)
                                        put("lastName", it.lastName)
                                        put("country", it.issuingCountry)
                                    }
                                }

                                Barcode.TYPE_CONTACT_INFO -> {
                                    barcode.contactInfo?.let { contact ->
                                        put("firstName", contact.name?.first)
                                        put("lastName", contact.name?.last)
                                        put("formattedName", contact.name?.formattedName)
                                        put("organization", contact.organization)
                                        put(
                                            "addresses",
                                            contact.addresses.map { address ->
                                                mapOf(
                                                    "addressType" to address.type,
                                                    "addressLines" to address.addressLines.toList(),
                                                )
                                            },
                                        )
                                        put(
                                            "phones",
                                            contact.phones.map { phone ->
                                                mapOf("number" to phone.number, "phoneType" to phone.type)
                                            },
                                        )
                                        put(
                                            "emails",
                                            contact.emails.map { email ->
                                                mapOf(
                                                    "address" to email.address,
                                                    "body" to email.body,
                                                    "subject" to email.subject,
                                                    "emailType" to email.type,
                                                )
                                            },
                                        )
                                        put("urls", contact.urls.toList())
                                    }
                                }

                                Barcode.TYPE_CALENDAR_EVENT -> {
                                    barcode.calendarEvent?.let {
                                        put("description", it.description)
                                        put("location", it.location)
                                        put("status", it.status)
                                        put("summary", it.summary)
                                        put("organizer", it.organizer)
                                        put("start", it.start?.rawValue)
                                        put("end", it.end?.rawValue)
                                    }
                                }
                            }
                        }
                    }
                result.success(barcodeList)
            }.addOnFailureListener { e ->
                result.error("BarcodeDetectorError", e.toString(), null)
            }
    }

    private fun getPoints(cornerPoints: Array<Point>) =
        cornerPoints.map {
            mapOf("x" to it.x, "y" to it.y)
        }

    private fun getBoundingPoints(rect: Rect?) =
        rect?.let {
            mapOf("left" to it.left, "right" to it.right, "top" to it.top, "bottom" to it.bottom)
        } ?: emptyMap<String, Int>()

    private fun closeDetector(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }
}
