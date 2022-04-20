package com.google_mlkit_smart_reply;

import androidx.annotation.NonNull;

import com.google.mlkit.nl.smartreply.SmartReplyGenerator;
import com.google.mlkit.nl.smartreply.SmartReplySuggestion;
import com.google.mlkit.nl.smartreply.SmartReplySuggestionResult;
import com.google.mlkit.nl.smartreply.TextMessage;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SmartReply implements MethodChannel.MethodCallHandler {
    private static final String START = "nlp#startSmartReply";
    private static final String CLOSE = "nlp#closeSmartReply";

    private SmartReplyGenerator smartReplyGenerator;

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String methodCall = call.method;
        switch (methodCall) {
            case START:
                suggestReply(call, result);
                break;
            case CLOSE:
                closeDetector();
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }

    }

    private void suggestReply(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        List<TextMessage> conversation = new ArrayList<>();
        List<Map<String, Object>> json = call.argument("conversation");

        for (final Map<String, Object> object : json) {
            String message = (String) object.get("message");
            long timestamp = (long) object.get("timestamp");
            String userId = (String) object.get("userId");
            if (userId == "local") {
                conversation.add(TextMessage.createForLocalUser(message,
                        timestamp));
            } else {
                conversation.add(TextMessage.createForRemoteUser(message,
                        timestamp, userId));
            }
        }

        if (smartReplyGenerator == null)
            smartReplyGenerator = com.google.mlkit.nl.smartreply.SmartReply.getClient();

        smartReplyGenerator.suggestReplies(conversation)
                .addOnSuccessListener(smartReplySuggestionResult -> {
                    int status = smartReplySuggestionResult.getStatus();
                    Map<String, Object> suggestionResult = new HashMap<>();
                    suggestionResult.put("status", status);
                    if (status == SmartReplySuggestionResult.STATUS_SUCCESS) {
                        List<String> suggestions = new ArrayList<>();
                        for (SmartReplySuggestion suggestion : smartReplySuggestionResult.getSuggestions()) {
                            suggestions.add(suggestion.getText());
                        }
                        suggestionResult.put("suggestions", suggestions);
                    }
                    result.success(suggestionResult);
                })
                .addOnFailureListener(e -> result.error("failed suggesting", e.toString(), null));
    }

    private void closeDetector() {
        if (smartReplyGenerator == null) return;
        smartReplyGenerator.close();
    }
}
