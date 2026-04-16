package com.google_mlkit_document_scanner

import android.app.Activity
import android.content.Intent
import android.content.IntentSender
import com.google.mlkit.vision.documentscanner.GmsDocumentScanner
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class DocumentScanner(
    private val binding: ActivityPluginBinding,
) : MethodChannel.MethodCallHandler,
    PluginRegistry.ActivityResultListener {
    private val instances = HashMap<String, GmsDocumentScanner>()
    private var pendingResult: MethodChannel.Result? = null

    companion object {
        private const val START = "vision#startDocumentScanner"
        private const val CLOSE = "vision#closeDocumentScanner"
        private const val TAG = "DocumentScanner"
        private const val START_DOCUMENT_ACTIVITY = 0x362738
    }

    init {
        binding.addActivityResultListener(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            START -> {
                handleScanner(call, result)
            }

            CLOSE -> {
                closeScanner(call)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun handleScanner(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val id = call.argument<String>("id")
        var scanner = instances[id]
        pendingResult = result

        if (scanner == null) {
            val options =
                call.argument<Map<String, Any>>("options") ?: run {
                    consumePendingResult()?.error(TAG, "Invalid options", null)
                    return
                }
            val scannerOptions = parseOptions(options)
            scanner = GmsDocumentScanning.getClient(scannerOptions)
            instances[id!!] = scanner
        }

        val activity = binding.activity
        scanner
            .getStartScanIntent(activity)
            .addOnSuccessListener { intentSender ->
                try {
                    activity.startIntentSenderForResult(intentSender, START_DOCUMENT_ACTIVITY, null, 0, 0, 0)
                } catch (e: IntentSender.SendIntentException) {
                    consumePendingResult()?.error(TAG, "Failed to start document scanner", null)
                }
            }.addOnFailureListener {
                consumePendingResult()?.error(TAG, "Failed to start document scanner", null)
            }
    }

    private fun parseOptions(options: Map<String, Any>): GmsDocumentScannerOptions {
        val isGalleryImportAllowed = options["isGalleryImport"] as Boolean
        val pageLimit = options["pageLimit"] as Int
        val formatStrings = options["formats"] as List<*>

        val formatConstants =
            formatStrings.map { format ->
                when (format) {
                    "pdf" -> GmsDocumentScannerOptions.RESULT_FORMAT_PDF
                    "jpeg" -> GmsDocumentScannerOptions.RESULT_FORMAT_JPEG
                    else -> throw IllegalArgumentException("Not a format: $format")
                }
            }

        val mode =
            when (options["mode"] as String) {
                "base" -> GmsDocumentScannerOptions.SCANNER_MODE_BASE
                "filter" -> GmsDocumentScannerOptions.SCANNER_MODE_BASE_WITH_FILTER
                "full" -> GmsDocumentScannerOptions.SCANNER_MODE_FULL
                else -> throw IllegalArgumentException("Not a mode: ${options["mode"]}")
            }

        val builder =
            GmsDocumentScannerOptions
                .Builder()
                .setGalleryImportAllowed(isGalleryImportAllowed)
                .setPageLimit(pageLimit)
                .setScannerMode(mode)

        if (formatConstants.isNotEmpty()) {
            if (formatConstants.size > 1) {
                builder.setResultFormats(formatConstants[0], formatConstants[1])
            } else {
                builder.setResultFormats(formatConstants[0])
            }
        }

        return builder.build()
    }

    private fun closeScanner(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        intent: Intent?,
    ): Boolean {
        if (requestCode == START_DOCUMENT_ACTIVITY) {
            when (resultCode) {
                Activity.RESULT_OK -> {
                    val result = GmsDocumentScanningResult.fromActivityResultIntent(intent)
                    result?.let { handleScanningResult(it) }
                }

                Activity.RESULT_CANCELED -> {
                    consumePendingResult()?.error(TAG, "Operation cancelled", null)
                }

                else -> {
                    consumePendingResult()?.error(TAG, "Unknown Error", null)
                }
            }
            return true
        }
        return false
    }

    private fun handleScanningResult(result: GmsDocumentScanningResult) {
        val reply = consumePendingResult() ?: return

        val resultMap = HashMap<String, Any?>()

        val pdf = result.pdf
        if (pdf != null) {
            resultMap["pdf"] =
                hashMapOf(
                    "pageCount" to pdf.pageCount,
                    "uri" to pdf.uri.path,
                )
        } else {
            resultMap["pdf"] = null
        }

        val pages = result.pages
        if (!pages.isNullOrEmpty()) {
            resultMap["images"] = pages.map { it.imageUri.path }
        } else {
            resultMap["images"] = null
        }

        reply.success(resultMap)
    }

    /**
     * Atomically returns the current [pendingResult] and clears the field, so a subsequent
     * duplicate callback (e.g. a redelivered activity result on some OEM builds) cannot submit
     * a second reply on the same [MethodChannel.Result] and trigger
     * `IllegalStateException: Reply already submitted`.
     */
    private fun consumePendingResult(): MethodChannel.Result? {
        val reply = pendingResult
        pendingResult = null
        return reply
    }
}
