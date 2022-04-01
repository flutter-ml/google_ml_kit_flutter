package com.google_mlkit.nl;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.nl.smartreply.SmartReplyGenerator;
import com.google.mlkit.nl.smartreply.SmartReplySuggestion;
import com.google.mlkit.nl.smartreply.SmartReplySuggestionResult;
import com.google.mlkit.nl.smartreply.TextMessage;
import com.google_mlkit.ApiDetectorInterface;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SmartReply implements ApiDetectorInterface {

    private static final String SUGGEST = "nlp#startSmartReply";
    private static final String ADD = "nlp#addSmartReply";
    private static final String CLOSE = "nlp#closeSmartReply";

    private List<TextMessage> conversation = new ArrayList<>();

    private SmartReplyGenerator smartReplyGenerator;

    @Override
    public List<String> getMethodsKeys() {
        return new ArrayList<>(
                Arrays.asList(SUGGEST,
                        CLOSE, ADD
                ));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String methodCall = call.method;
        if (methodCall.equals(SUGGEST)) suggestReply(result, call);
        else if (methodCall.equals(ADD)) addConversation(call, result);
        else closeDetector();

    }

    private void suggestReply(final MethodChannel.Result result, MethodCall call) {
        if (smartReplyGenerator == null)
            smartReplyGenerator = com.google.mlkit.nl.smartreply.SmartReply.getClient();

        if (conversation.isEmpty())
            result.error("NO CONVERSATIONS", "No conversations have been added", null);
        else {
            smartReplyGenerator.suggestReplies(conversation)
                    .addOnSuccessListener(new OnSuccessListener<SmartReplySuggestionResult>() {
                        @Override
                        public void onSuccess(@NonNull SmartReplySuggestionResult smartReplySuggestionResult) {
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
                        }
                    })
                    .addOnFailureListener(new OnFailureListener() {
                        @Override
                        public void onFailure(@NonNull Exception e) {
                            e.printStackTrace();
                            result.error("failed suggesting", e.toString(), null);
                        }
                    });
        }
    }

    private void addConversation(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        boolean isLocalUser = (boolean) call.argument("localUser");
        String text = (String) call.argument("text");

        if (isLocalUser) conversation.add(TextMessage.createForLocalUser(text,
                System.currentTimeMillis()));
        else conversation.add(TextMessage.createForRemoteUser(text,
                System.currentTimeMillis(), (String) call.argument("uID")));

        result.success("success");
    }

    private void closeDetector() {
        smartReplyGenerator.close();
        smartReplyGenerator = null;
        conversation.clear();
    }
}
