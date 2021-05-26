part of 'NaturalLanguage.dart';

class SmartReply{
  bool _hasBeenOpened = false;
  bool _isClosed = false;
  int _conversationCount = 0;

  SmartReply._();

  Future<void> addConversationForLocalUser(String text) async{
    
    final result = NaturalLanguage.channel.invokeMethod(
        'nlp#addSmartReply', <String, dynamic>{
      'text': text,
      'localUser' : true
    });
    _conversationCount++;
    print(result.toString());
  }

  Future<void> addConversationForRemoteUser(String text, String uID) async{
  
    final result = NaturalLanguage.channel.invokeMethod(
        'nlp#addSmartReply', <String, dynamic>{
      'text': text,
      'localUser' : false,
      'uID' : uID
    });
    _conversationCount++;
    print(result.toString());
  }

  Future<List<SmartReplySuggestion>> suggestReplies() async{
    _hasBeenOpened = true;
    _isClosed = false;

    if(_conversationCount==0){
      print("No conversations added yet");
      return <SmartReplySuggestion>[];
    }

    final result = await NaturalLanguage.channel.invokeMethod('nlp#startSmartReply');
    var suggestions = <SmartReplySuggestion>[];
    
    for(dynamic suggestion in result){
        suggestions.add(SmartReplySuggestion(suggestion['result'], suggestion['toString']));
    }

    return suggestions;

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

class SmartReplySuggestion{
  final String _text;
  final String _toString;

  SmartReplySuggestion(this._text, this._toString);

  String getText() => _text;

  @override
  String toString() => _toString;
}

