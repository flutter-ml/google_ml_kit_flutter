part of 'google_ml_kit.dart';

class TextDetector {
  TextDetector._();

  bool _isOpened = false;
  bool _isClosed = false;

  Future<void> processImage(InputImage inputImage) async {
    assert(inputImage != null);

    _isOpened = true;
    final result = await GoogleMlKit.channel.invokeMethod(
        'startImageLabelDetector',
        <String, dynamic>{'imageData': inputImage._getImageData()});
  }
}

class RecognisedText{
  RecognisedText(this.textElement, this.textLine, this.textBlock);

  final TextElement textElement;
  final TextLine textLine;
  final TextBlock textBlock;
}

class TextBlock extends TextLine {
  TextBlock(Rect rect, List<Offset> points, String text, String textLanguage,
      List<TextElement> textElements, this.textLines)
      : super(rect, points, text, textLanguage, textElements);
  final List<TextLine> textLines;
}

class TextLine extends TextElement {
  TextLine(Rect rect, List<Offset> points, String text, String textLanguage,
      this.textElements)
      : super(rect, points, text, textLanguage);
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
