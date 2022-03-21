import 'nlp/natural_language.dart';
import 'vision/vision.dart';

class GoogleMlKit {
  GoogleMlKit._();

  static final Vision vision = Vision.instance;
  static final NaturalLanguage nlp = NaturalLanguage.instance;
}
