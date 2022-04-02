import 'package:flutter/services.dart';

///Generates smart replies based on the conversations list.
///Creating an instance of [SmartReply]
///```
///final smartReply = GoogleMlKit.nlp.smartReply();
///```
class SmartReply {
  bool _hasBeenOpened = false;
  bool _isClosed = false;
  int _conversationCount = 0;

  static const MethodChannel _channel =
      MethodChannel('google_mlkit_smart_reply');
  SmartReply();

  /// Adds conversation for local user.
  Future addConversationForLocalUser(String text) async {
    final result = _channel.invokeMethod('nlp#addSmartReply',
        <String, dynamic>{'text': text, 'localUser': true});
    _conversationCount++;
    return result;
  }

  /// Adds conversation for remote user.
  Future addConversationForRemoteUser(String text, String uID) async {
    final result = _channel.invokeMethod('nlp#addSmartReply',
        <String, dynamic>{'text': text, 'localUser': false, 'uID': uID});
    _conversationCount++;
    return result;
  }

  // /Suggests possible replies for the conversation.
  /// Returns a map having the status of suggestions and all the suggestions.
  Future<Map<String, dynamic>> suggestReplies() async {
    _hasBeenOpened = true;
    _isClosed = false;

    final suggestions = <SmartReplySuggestion>[];
    if (_conversationCount == 0) {
      return <String, dynamic>{'status': 2, 'suggestions': suggestions};
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

  Future<void> close() async {
    if (!_isClosed && _hasBeenOpened) {
      await _channel.invokeMethod('nlp#closeSmartReply');
      _hasBeenOpened = false;
      _isClosed = true;
      _conversationCount = 0;
    }
  }
}

class SmartReplySuggestion {
  final String _text;
  final String _toString;

  SmartReplySuggestion(this._text, this._toString);

  String getText() => _text;

  @override
  String toString() => _toString;
}
