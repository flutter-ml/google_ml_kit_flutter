import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:google_ml_kit_commons/commons.dart';

/// Detector to detect text present in the [InputImage] provided.
/// It returns [RecognizedText] which contains the info present in the image.
///
/// Creating an instance of [TextRecognizer].
/// TextRecognizer textRecognizer = GoogleMlKit.instance.textRecognizer();
/// Call the [processImage()] to process the image.
class TextRecognizer {
  static const MethodChannel _channel =
      MethodChannel('google_ml_kit_text_recognizer');

  bool _hasBeenOpened = false;
  bool _isClosed = false;

  /// Function that takes [InputImage] processes it and returns a [RecognizedText] object.
  Future<RecognizedText> processImage(InputImage inputImage,
      {TextRecognitionScript script = TextRecognitionScript.latin}) async {
    _hasBeenOpened = true;
    final result = await _channel.invokeMethod(
        'vision#startTextRecognizer', <String, dynamic>{
      'imageData': inputImage.getImageData(),
      'script': script.index
    });

    final recognizedText = RecognizedText.fromMap(result);

    return recognizedText;
  }

  Future<void> close() async {
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<void>.value();
    _isClosed = true;
    return _channel.invokeMethod('vision#closeTextRecognizer');
  }
}

enum TextRecognitionScript {
  latin,
  chinese,
  devanagiri,
  japanese,
  korean,
}

/// Class that gives the detected text.
/// Recognized text hierarchy.
/// Recognized Text ---> List<TextBlock> (Blocks of text identified in the image).
/// TextBlock ---> List<TextLine> (Lines of text present in a certain identified block).
/// TextLine ---> List<TextElement> (Fundamental part of a block i.e usually a word or sentence)
class RecognizedText {
  RecognizedText._(this.text, this.blocks);

  factory RecognizedText.fromMap(Map<dynamic, dynamic> map) {
    final resText = map['text'];
    final textBlocks = <TextBlock>[];
    for (final block in map['blocks']) {
      final textBlock = TextBlock.fromMap(block);
      textBlocks.add(textBlock);
    }
    return RecognizedText._(resText, textBlocks);
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
    for (final line in map['lines']) {
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
    for (final element in map['elements']) {
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
  final recognizedLanguages = <String>[];
  for (final obj in languages) {
    if (obj != null) {
      recognizedLanguages.add(obj);
    }
  }
  return recognizedLanguages;
}

/// Convert map to Rect.
Rect _mapToRect(Map<dynamic, dynamic> rect) {
  final rec = Rect.fromLTRB((rect['left']).toDouble(), (rect['top']).toDouble(),
      (rect['right']).toDouble(), (rect['bottom']).toDouble());
  return rec;
}

/// Convert list of map to list of offset.
List<Offset> _listToCornerPoints(List<dynamic> points) {
  final p = <Offset>[];
  for (final point in points) {
    p.add(Offset((point['x']).toDouble(), (point['y']).toDouble()));
  }
  return p;
}
