part of 'google_ml_kit.dart';

class TextDetector {
  TextDetector._();

  bool _isOpened = false;
  bool _isClosed = false;

  Future<RecognisedText> processImage(InputImage inputImage) async {
    assert(inputImage != null);

    _isOpened = true;
    final result = await GoogleMlKit.channel.invokeMethod('startTextDetector',
        <String, dynamic>{'imageData': inputImage._getImageData()});

    final recognisedText = RecognisedText.fromMap(result);

    return recognisedText;
  }

  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await GoogleMlKit.channel.invokeMethod('closeTextDetector');
      _isClosed = true;
      _isOpened = false;
    }
  }
}

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

  final String text;
  final List<TextBlock> textBlocks;
}

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

  final Rect blockRect;
  final List<Offset> blockPoints;
  final String blockText;
  final List<TextLine> textLines;
}

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

  final Rect lineRect;
  final List<Offset> linePoints;
  final String lineText;
  final List<TextElement> textElements;
}

class TextElement {
  TextElement(this.rect, this.points, this._text, this._textLanguage);

  final Rect rect;
  final String _textLanguage;
  final List<Offset> points;
  final String _text;

  String get getText => _text;

  String get getLanguage => _textLanguage;
}

Rect _mapToRect(Map<dynamic, dynamic> rect) {
  var rec = Rect.fromLTRB(
      (rect["left"] as int).toDouble(),
      (rect["top"] as int).toDouble(),
      (rect["right"] as int).toDouble(),
      (rect["bottom"] as int).toDouble());
  return rec;
}

List<Offset> _mapToOffsetList(List<dynamic> points) {
  var p = <Offset>[];
  for (var point in points) {
    p.add(
        Offset((point['x'] as int).toDouble(), (point['y'] as int).toDouble()));
  }
  return p;
}
