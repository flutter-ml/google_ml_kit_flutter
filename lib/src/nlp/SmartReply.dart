part of 'NaturalLanguage.dart';

///Generates smart replies based on the conversations list.
///Creating an instance of [SmartReply]
///```
///final smartReply = GoogleMlKit.nlp.smartReply();
///```
class SmartReply {
  bool _hasBeenOpened = false;
  bool _isClosed = false;
  int _conversationCount = 0;

  SmartReply._();

  /// Adds conversation for local user.
  Future<void> addConversationForLocalUser(String text) async {
    final result = NaturalLanguage.channel.invokeMethod('nlp#addSmartReply',
        <String, dynamic>{'text': text, 'localUser': true});
    _conversationCount++;
    print(result.toString());
  }

  /// Adds conversation for remote user.
  Future<void> addConversationForRemoteUser(String text, String uID) async {
    final result = NaturalLanguage.channel.invokeMethod('nlp#addSmartReply',
        <String, dynamic>{'text': text, 'localUser': false, 'uID': uID});
    _conversationCount++;
    print(result.toString());
  }

  ///Suggests possible replies for the conversation.
  ///Returns a map having the status of suggestions and all the suggestions.
  Future<Map<String, dynamic>> suggestReplies() async {
    _hasBeenOpened = true;
    _isClosed = false;

    var suggestions = <SmartReplySuggestion>[];
    if (_conversationCount == 0) {
      print("No conversations added yet");
      return <String, dynamic>{'status': 2, 'suggestions': suggestions};
    }

    final result =
        await NaturalLanguage.channel.invokeMethod('nlp#startSmartReply');

    if (result['suggestions'] != null) {
      for (dynamic suggestion in result['suggestions']) {
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
      await NaturalLanguage.channel.invokeMethod('nlp#closeSmartReply');
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
