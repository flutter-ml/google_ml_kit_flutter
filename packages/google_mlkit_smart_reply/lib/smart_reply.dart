import 'package:flutter/services.dart';

///Generates smart replies based on the conversations list.
///Creating an instance of [SmartReply]
///```
///final smartReply = GoogleMlKit.nlp.smartReply();
///```
class SmartReply {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_smart_reply');

  int _conversationCount = 0;

  /// Adds conversation for local user.
  Future addConversationForLocalUser(String text) async {
    final result = _channel.invokeMethod('nlp#addSmartReply', <String, dynamic>{
      'text': text,
      'localUser': true,
    });
    _conversationCount++;
    return result;
  }

  /// Adds conversation for remote user.
  Future addConversationForRemoteUser(String text, String uID) async {
    final result = _channel.invokeMethod('nlp#addSmartReply', <String, dynamic>{
      'text': text,
      'localUser': false,
      'uID': uID,
    });
    _conversationCount++;
    return result;
  }

  // /Suggests possible replies for the conversation.
  /// Returns a map having the status of suggestions and all the suggestions.
  Future<Map<String, dynamic>> suggestReplies() async {
    final suggestions = <SmartReplySuggestion>[];
    if (_conversationCount == 0) {
      return <String, dynamic>{
        'status': 2,
        'suggestions': suggestions,
      };
    }

    final result = await _channel.invokeMethod('nlp#startSmartReply');

    if (result['suggestions'] != null) {
      for (final dynamic suggestion in result['suggestions']) {
        suggestions.add(
            SmartReplySuggestion(suggestion['result'], suggestion['toString']));
      }
    }

    return <String, dynamic>{
      'status': result['status'],
      'suggestions': suggestions
    };
  }

  Future<void> close() => _channel.invokeMethod('nlp#closeSmartReply');
}

class SmartReplySuggestion {
  final String text;
  final String _toString;

  SmartReplySuggestion(this.text, this._toString);

  @override
  String toString() => _toString;
}
