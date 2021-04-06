part of 'vision.dart';

///Detector to detect text present in the [InputImage] provided.
///It returns [RecognisedText] which contains the info present in the image.
///
/// Creating an instance of [TextDetector].
/// TextDetector textDetector = GoogleMlKit.instance.textDetector();
/// Call the [processImage()] to process the image.
class TextDetector {
  TextDetector._();

  bool _isOpened = false;
  bool _isClosed = false;

  /// Function that takes [InputImage] processes it and returns a [RecognisedText] object.
  Future<RecognisedText> processImage(InputImage inputImage) async {
    _isOpened = true;
    final result = await Vision.channel.invokeMethod('vision#startTextDetector',
        <String, dynamic>{'imageData': inputImage._getImageData()});

    final recognisedText = RecognisedText.fromMap(result);

    return recognisedText;
  }

  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await Vision.channel.invokeMethod('vision#closeTextDetector');
      _isClosed = true;
      _isOpened = false;
    }
  }
}

///Class that gives the detected text.
///Recognised text hierarchy.
///Recognised Text ---> List<TextBlock> (Blocks of text identified in the image).
///TextBlock ---> List<TextLine> (Lines of text present in a certain identified block).
///TextLine ---> List<TextElement> (Fundamental part of a block i.e usually a word or sentence)
class RecognisedText {
  RecognisedText._(this.text, this.textBlocks);

  factory RecognisedText.fromMap(Map<dynamic, dynamic> map) {
    var resText = map["result"];
    var textBlocks = <TextBlock>[];
    for (var block in map["blocks"]) {
      var textBlock = TextBlock.fromMap(block);
      textBlocks.add(textBlock);
    }
    return RecognisedText._(resText, textBlocks);
  }

  ///String containing all the text identified in a image.
  final String text;

  ///All the blocks of text present in image.
  final List<TextBlock> textBlocks;
}

///Class that has a block or group of words present in part of image.
class TextBlock {
  TextBlock._(this.textLines, this.blockText, this.blockPoints, this.blockRect);

  factory TextBlock.fromMap(Map<dynamic, dynamic> map) {
    var blockText = map['blockText'];
    var textLines = <TextLine>[];
    var rect = _mapToRect(map['blockRect']);
    var offsetList = _mapToOffsetList(map['blockPoints']);
    for (var line in map['textLines']) {
      var textLine = TextLine.fromMap(line);
      textLines.add(textLine);
    }
    return TextBlock._(textLines, blockText, offsetList, rect);
  }

  ///Rect outlining boundary of block.
  final Rect blockRect;

  ///List of corner points of the rect.
  final List<Offset> blockPoints;

  ///Text in the block.
  final String blockText;

  ///List of sentences.
  final List<TextLine> textLines;
}

///Class that represents sentence present in a certain block.
class TextLine {
  TextLine._(this.lineRect, this.linePoints, this.lineText, this.textElements);

  factory TextLine.fromMap(Map<dynamic, dynamic> map) {
    var lineText = map['lineText'];
    var textElements = <TextElement>[];
    var rect = _mapToRect(map['lineRect']);
    var offsetList = _mapToOffsetList(map['linePoints']);
    var elements = map['textElements'];

    for (var ele in elements) {
      var textEle = TextElement(
          _mapToRect(ele['elementRect']),
          _mapToOffsetList(ele['elementPoints']),
          ele['elementText'],
          ele['elementLang']);
      textElements.add(textEle);
    }
    return TextLine._(rect, offsetList, lineText, textElements);
  }

  ///Rect outlining the the text line.
  final Rect lineRect;

  ///Corner points of the text line.
  final List<Offset> linePoints;

  ///Sentence of a block.
  final String lineText;

  ///List of text element.
  final List<TextElement> textElements;
}

///Fundamental part of text detected.
class TextElement {
  TextElement(this.rect, this.points, this._text, this._textLanguage);

  ///Rect outlining the boundary of element.
  final Rect rect;

  ///Language of the text detected.
  final String _textLanguage;

  ///List of corner points of the element.
  final List<Offset> points;

  ///Word in a line.
  final String _text;

  ///Getter for the word.
  String get getText => _text;

  ///Getter for identified language.
  String get getLanguage => _textLanguage;
}

///Convert map to Rect.
Rect _mapToRect(Map<dynamic, dynamic> rect) {
  var rec = Rect.fromLTRB(
      (rect["left"] as int).toDouble(),
      (rect["top"] as int).toDouble(),
      (rect["right"] as int).toDouble(),
      (rect["bottom"] as int).toDouble());
  return rec;
}

///Convert List of map to list of offset.
List<Offset> _mapToOffsetList(List<dynamic> points) {
  var p = <Offset>[];
  for (var point in points) {
    p.add(
        Offset((point['x'] as int).toDouble(), (point['y'] as int).toDouble()));
  }
  return p;
}
