part of 'vision.dart';

/// Detector to detect text present in the [InputImage] provided.
/// It returns [RecognisedText] which contains the info present in the image.
///
/// Creating an instance of [TextDetector].
/// TextDetector textDetector = GoogleMlKit.instance.textDetector();
/// Call the [processImage()] to process the image.
class TextDetector {
  TextDetector._();

  bool _hasBeenOpened = false;
  bool _isClosed = false;

  /// Function that takes [InputImage] processes it and returns a [RecognisedText] object.
  Future<RecognisedText> processImage(InputImage inputImage) async {
    _hasBeenOpened = true;
    final result = await Vision.channel.invokeMethod('vision#startTextDetector',
        <String, dynamic>{'imageData': inputImage._getImageData()});

    final recognisedText = RecognisedText.fromMap(result);

    return recognisedText;
  }

  Future<void> close() async {
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<void>.value();
    _isClosed = true;
    return Vision.channel.invokeMethod('vision#closeTextDetector');
  }
}

enum TextRecognitionOptions { DEFAULT, CHINESE, DEVANAGIRI, JAPANESE, KOREAN }

class TextDetectorV2 {
  TextDetectorV2._();

  bool _hasBeenOpened = false;
  bool _isClosed = false;

  /// Function that takes [InputImage] processes it and returns a [RecognisedText] object.
  Future<RecognisedText> processImage(InputImage inputImage,
      {TextRecognitionOptions script = TextRecognitionOptions.DEFAULT}) async {
    _hasBeenOpened = true;
    final result = await Vision.channel.invokeMethod(
        'vision#startTextDetectorV2', <String, dynamic>{
      'imageData': inputImage._getImageData(),
      'language': script.index
    });

    final recognisedText = RecognisedText.fromMap(result);

    return recognisedText;
  }

  Future<void> close() async {
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<void>.value();
    _isClosed = true;
    return Vision.channel.invokeMethod('vision#closeTextDetectorV2');
  }
}

/// Class that gives the detected text.
/// Recognised text hierarchy.
/// Recognised Text ---> List<TextBlock> (Blocks of text identified in the image).
/// TextBlock ---> List<TextLine> (Lines of text present in a certain identified block).
/// TextLine ---> List<TextElement> (Fundamental part of a block i.e usually a word or sentence)
class RecognisedText {
  RecognisedText._(this.text, this.blocks);

  factory RecognisedText.fromMap(Map<dynamic, dynamic> map) {
    var resText = map["text"];
    var textBlocks = <TextBlock>[];
    for (var block in map["blocks"]) {
      var textBlock = TextBlock.fromMap(block);
      textBlocks.add(textBlock);
    }
    return RecognisedText._(resText, textBlocks);
  }

  /// String containing all the text identified in a image.
  final String text;

  /// All the blocks of text present in image.
  final List<TextBlock> blocks;
}

/// Class that has a block or group of words present in part of image.
class TextBlock {
  TextBlock._(this.text, this.lines, this.rect, this.recognizedLanguages,
      this.cornerPoints);

  factory TextBlock.fromMap(Map<dynamic, dynamic> map) {
    final text = map['text'];
    final rect = _mapToRect(map['rect']);
    final recognizedLanguages =
        _listToRecognizedLanguages(map['recognizedLanguages']);
    final points = _listToCornerPoints(map['points']);
    final lines = <TextLine>[];
    for (var line in map['lines']) {
      final textLine = TextLine.fromMap(line);
      lines.add(textLine);
    }
    return TextBlock._(text, lines, rect, recognizedLanguages, points);
  }

  /// Text in the block.
  final String text;

  /// List of sentences.
  final List<TextLine> lines;

  /// Rect outlining boundary of block.
  final Rect rect;

  /// List of recognized Latin-based languages in the text block.
  final List<String> recognizedLanguages;

  /// List of corner points of the rect.
  final List<Offset> cornerPoints;
}

/// Class that represents sentence present in a certain block.
class TextLine {
  TextLine._(this.text, this.elements, this.rect, this.recognizedLanguages,
      this.cornerPoints);

  factory TextLine.fromMap(Map<dynamic, dynamic> map) {
    final text = map['text'];
    final rect = _mapToRect(map['rect']);
    final recognizedLanguages =
        _listToRecognizedLanguages(map['recognizedLanguages']);
    final points = _listToCornerPoints(map['points']);
    final elements = <TextElement>[];
    for (var element in map['elements']) {
      final textElement = TextElement.fromMap(element);
      elements.add(textElement);
    }
    return TextLine._(text, elements, rect, recognizedLanguages, points);
  }

  /// Sentence of a block.
  final String text;

  /// List of text element.
  final List<TextElement> elements;

  /// Rect outlining the the text line.
  final Rect rect;

  /// List of recognized Latin-based languages in the text block.
  final List<String> recognizedLanguages;

  /// Corner points of the text line.
  final List<Offset> cornerPoints;
}

/// Fundamental part of text detected.
class TextElement {
  TextElement._(this.text, this.rect, this.cornerPoints);

  factory TextElement.fromMap(Map<dynamic, dynamic> map) {
    final text = map['text'];
    final rect = _mapToRect(map['rect']);
    final points = _listToCornerPoints(map['points']);
    return TextElement._(text, rect, points);
  }

  /// String representation of the text element that was recognized.
  final String text;

  /// Rect outlining the boundary of element.
  final Rect rect;

  /// List of corner points of the element.
  final List<Offset> cornerPoints;
}

/// Convert list of Object? to list of Strings.
List<String> _listToRecognizedLanguages(List<dynamic> languages) {
  var recognizedLanguages = <String>[];
  for (var obj in languages) {
    if (obj != null) {
      recognizedLanguages.add(obj);
    }
  }
  return recognizedLanguages;
}

/// Convert map to Rect.
Rect _mapToRect(Map<dynamic, dynamic> rect) {
  var rec = Rect.fromLTRB((rect["left"]).toDouble(), (rect["top"]).toDouble(),
      (rect["right"]).toDouble(), (rect["bottom"]).toDouble());
  return rec;
}

/// Convert list of map to list of offset.
List<Offset> _listToCornerPoints(List<dynamic> points) {
  var p = <Offset>[];
  for (var point in points) {
    p.add(Offset((point['x']).toDouble(), (point['y']).toDouble()));
  }
  return p;
}
