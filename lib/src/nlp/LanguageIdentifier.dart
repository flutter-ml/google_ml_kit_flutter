part of 'NaturalLanguage.dart';

class LanguageIdentifier {
  final double confidenceThreshold;
  LanguageIdentifier._({this.confidenceThreshold = 0.5});

  Future<String> identifyLanguange(String text) async {
    final result = await NaturalLanguage.channel
        .invokeMethod('nlp#start#identifyLanguage');

    return result.toString();
  }
}
