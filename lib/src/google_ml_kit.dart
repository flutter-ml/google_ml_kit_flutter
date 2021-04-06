import 'vision/ml_vision.dart';
import 'nlp/NLP.dart';

class GoogleMlKit {
  GoogleMlKit._();

  static final Vision vision = Vision.instance;
  static final NaturalLanguage nlp = NaturalLanguage.instance;
}
