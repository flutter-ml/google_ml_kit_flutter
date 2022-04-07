package com.google_mlkit_smart_reply;

import androidx.annotation.NonNull;

import com.google.mlkit.nl.smartreply.SmartReplyGenerator;
import com.google.mlkit.nl.smartreply.SmartReplySuggestion;
import com.google.mlkit.nl.smartreply.TextMessage;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SmartReply implements MethodChannel.MethodCallHandler {
    private static final String SUGGEST = "nlp#startSmartReply";
    private static final String ADD = "nlp#addSmartReply";
    private static final String CLOSE = "nlp#closeSmartReply";

    private final List<TextMessage> conversation = new ArrayList<>();
    private SmartReplyGenerator smartReplyGenerator;

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String methodCall = call.method;
        switch (methodCall) {
            case SUGGEST:
                suggestReply(result);
                break;
            case ADD:
                addConversation(call, result);
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

    private void suggestReply(final MethodChannel.Result result) {
        if (smartReplyGenerator == null)
            smartReplyGenerator = com.google.mlkit.nl.smartreply.SmartReply.getClient();

        if (conversation.isEmpty())
            result.error("NO CONVERSATIONS", "No conversations have been added", null);
        else {
            smartReplyGenerator.suggestReplies(conversation)
                    .addOnSuccessListener(smartReplySuggestionResult -> {
                        Map<String, Object> suggestionResult = new HashMap<>();
                        suggestionResult.put("status", smartReplySuggestionResult.getStatus());
                        if (smartReplySuggestionResult.getStatus() == 0) {
                            List<Map<String, String>> suggestions =
                                    new ArrayList<>(smartReplySuggestionResult.getSuggestions().size());
                            for (SmartReplySuggestion suggestion : smartReplySuggestionResult.getSuggestions()) {
                                Map<String, String> tempSuggestion = new HashMap<>();
                                tempSuggestion.put("result", suggestion.getText());
                                tempSuggestion.put("toString", suggestion.toString());
                                suggestions.add(tempSuggestion);
                            }
                            suggestionResult.put("suggestions", suggestions);
                        }
                        result.success(suggestionResult);
                    })
                    .addOnFailureListener(e -> {
                        e.printStackTrace();
                        result.error("failed suggesting", e.toString(), null);
                    });
        }
    }

    private void addConversation(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        boolean isLocalUser = call.argument("localUser");
        String text = call.argument("text");

        if (isLocalUser) conversation.add(TextMessage.createForLocalUser(text,
                System.currentTimeMillis()));
        else conversation.add(TextMessage.createForRemoteUser(text,
                System.currentTimeMillis(), call.argument("uID")));

        result.success("success");
    }

    private void closeDetector() {
        if (smartReplyGenerator == null) return;
        smartReplyGenerator.close();
        conversation.clear();
    }
}
