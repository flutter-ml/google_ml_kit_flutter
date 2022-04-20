import 'package:flutter/services.dart';

///Generates smart replies based on the conversations list.
///Creating an instance of [SmartReply]
class SmartReply {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_smart_reply');

  final List<Message> _conversation = [];

  List<Message> get conversation => _conversation;

  /// Adds a message to the conversation for local user.
  void addMessageToConversationFromLocalUser(
      String message, int timestamp) async {
    _conversation
        .add(Message(text: message, timestamp: timestamp, userId: 'local'));
  }

  /// Adds a message to the conversation for a remote user.
  void addMessageToConversationFromRemoteUser(
      String message, int timestamp, String userId) async {
    _conversation
        .add(Message(text: message, timestamp: timestamp, userId: userId));
  }

  void clearConversation() {
    _conversation.clear();
  }

  /// Suggests possible replies for the conversation.
  Future<SmartReplySuggestionResult> suggestReplies() async {
    if (_conversation.isEmpty) {
      return SmartReplySuggestionResult(
          SmartReplySuggestionResultStatus.noReply, []);
    }

    final result = await _channel.invokeMethod(
        'nlp#startSmartReply', <String, dynamic>{
      'conversation': _conversation.map((message) => message.toJson()).toList()
    });

    return SmartReplySuggestionResult.fromJson(result);
  }

  Future<void> close() => _channel.invokeMethod('nlp#closeSmartReply');
}

class Message {
  final String text;
  final int timestamp;
  final String userId;

  Message({required this.text, required this.timestamp, required this.userId});

  Map<String, dynamic> toJson() =>
      {'message': text, 'timestamp': timestamp, 'userId': userId};
}

enum SmartReplySuggestionResultStatus {
  success,
  notSupportedLanguage,
  noReply,
}

class SmartReplySuggestionResult {
  SmartReplySuggestionResultStatus status;
  List<String> suggestions;

  SmartReplySuggestionResult(this.status, this.suggestions);

  factory SmartReplySuggestionResult.fromJson(Map<dynamic, dynamic> json) {
    final status =
        SmartReplySuggestionResultStatus.values[json['status'].toInt()];
    final suggestions = <String>[];
    if (status == SmartReplySuggestionResultStatus.success) {
      for (final dynamic line in json['suggestions']) {
        suggestions.add(line);
      }
    }
    return SmartReplySuggestionResult(status, suggestions);
  }

  Map<String, dynamic> toJson() =>
      {'status': status.name, 'suggestions': suggestions};
}
