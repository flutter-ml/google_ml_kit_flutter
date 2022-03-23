import 'natural_language.dart';
import 'vision.dart';

class GoogleMlKit {
  GoogleMlKit._();

  static final Vision vision = Vision.instance;
  static final NaturalLanguage nlp = NaturalLanguage.instance;
}
