part of 'NaturalLanguage.dart';

class LanguageIdentifier {
  final double _confidenceThreshold;
  LanguageIdentifier._(this._confidenceThreshold );

  Future<String> identifyLanguange(String text) async {
    print('In identify language text = $text');
    final result = await NaturalLanguage.channel
        .invokeMethod('nlp#startLanguageIdentifier',<String,dynamic>{
          "text" : text,
          "possibleLanguages" : "no",
          "confidence" : _confidenceThreshold
        });

    return result.toString();
  }

  Future<List<IdentifiedLanguage>> identifyPossibleLanguages(String text)async{
    final result = await NaturalLanguage.channel.invokeMethod('nlp#startLanguageIdentifier',<String,dynamic>{
          "text" : text,
          "possibleLanguages" : "yes",
          "confidence" : _confidenceThreshold
        });

    var languages = <IdentifiedLanguage>[];
    
    for(dynamic languageData in result){
      languages.add(IdentifiedLanguage(languageData['language'],languageData['confidence']));
    }

    return languages;
  } 
  
}

class IdentifiedLanguage{
  final String _languageTag;
  final double _confidence;

  IdentifiedLanguage(this._languageTag, this._confidence);

  String get language  => _languageTag;
  double get confidence => _confidence; 
}

