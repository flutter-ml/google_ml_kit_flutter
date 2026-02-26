package com.google_mlkit_smart_reply

import com.google.mlkit.nl.smartreply.SmartReply
import com.google.mlkit.nl.smartreply.SmartReplyGenerator
import com.google.mlkit.nl.smartreply.SmartReplySuggestionResult
import com.google.mlkit.nl.smartreply.TextMessage
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SmartReplyHandler : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, SmartReplyGenerator>()

    companion object {
        private const val START = "nlp#startSmartReply"
        private const val CLOSE = "nlp#closeSmartReply"
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            START -> {
                suggestReply(call, result)
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

    private fun suggestReply(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val json = call.argument<List<Map<String, Any>>>("conversation") ?: return

        val conversation =
            json.map { obj ->
                val message = obj["message"] as String
                val timestamp = obj["timestamp"] as Long
                val userId = obj["userId"] as String
                if (userId == "local") {
                    TextMessage.createForLocalUser(message, timestamp)
                } else {
                    TextMessage.createForRemoteUser(message, timestamp, userId)
                }
            }

        val id = call.argument<String>("id") ?: return
        val smartReplyGenerator = instances.getOrPut(id) { SmartReply.getClient() }

        smartReplyGenerator
            .suggestReplies(conversation)
            .addOnSuccessListener { smartReplySuggestionResult ->
                val status = smartReplySuggestionResult.status
                val suggestionResult = mutableMapOf<String, Any>("status" to status)
                if (status == SmartReplySuggestionResult.STATUS_SUCCESS) {
                    suggestionResult["suggestions"] = smartReplySuggestionResult.suggestions.map { it.text }
                }
                result.success(suggestionResult)
            }.addOnFailureListener { e ->
                result.error("failed suggesting", e.toString(), null)
            }
    }

    private fun closeDetector(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }
}
