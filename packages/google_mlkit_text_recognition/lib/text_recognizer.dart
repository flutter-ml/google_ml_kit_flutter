import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/commons.dart';

/// Detector to detect text present in the [InputImage] provided.
/// It returns [RecognizedText] which contains the info present in the image.
///
/// Creating an instance of [TextRecognizer].
/// TextRecognizer textRecognizer = GoogleMlKit.instance.textRecognizer();
/// Call the [processImage()] to process the image.
class TextRecognizer {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_text_recognizer');

  final TextRecognitionScript script;

  TextRecognizer({this.script = TextRecognitionScript.latin});

  /// Function that takes [InputImage] processes it and returns a [RecognizedText] object.
  Future<RecognizedText> processImage(InputImage inputImage) async {
    final result = await _channel.invokeMethod(
        'vision#startTextRecognizer', <String, dynamic>{
      'imageData': inputImage.toJson(),
      'script': script.index
    });
    return RecognizedText.fromJson(result);
  }

  Future<void> close() => _channel.invokeMethod('vision#closeTextRecognizer');
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
  RecognizedText(this.text, this.blocks);

  factory RecognizedText.fromJson(Map<dynamic, dynamic> json) {
    final resText = json['text'];
    final textBlocks = <TextBlock>[];
    for (final block in json['blocks']) {
      final textBlock = TextBlock.fromJson(block);
      textBlocks.add(textBlock);
    }
    return RecognizedText(resText, textBlocks);
  }

  /// String containing all the text identified in a image.
  final String text;

  /// All the blocks of text present in image.
  final List<TextBlock> blocks;
}

/// Class that has a block or group of words present in part of image.
class TextBlock {
  TextBlock(this.text, this.lines, this.rect, this.recognizedLanguages,
      this.cornerPoints);

  factory TextBlock.fromJson(Map<dynamic, dynamic> json) {
    final text = json['text'];
    final rect = RectJson.fromJson(json['rect']);
    final recognizedLanguages =
        _listToRecognizedLanguages(json['recognizedLanguages']);
    final points = _listToCornerPoints(json['points']);
    final lines = <TextLine>[];
    for (final line in json['lines']) {
      final textLine = TextLine.fromJson(line);
      lines.add(textLine);
    }
    return TextBlock(text, lines, rect, recognizedLanguages, points);
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
  TextLine(this.text, this.elements, this.rect, this.recognizedLanguages,
      this.cornerPoints);

  factory TextLine.fromJson(Map<dynamic, dynamic> json) {
    final text = json['text'];
    final rect = RectJson.fromJson(json['rect']);
    final recognizedLanguages =
        _listToRecognizedLanguages(json['recognizedLanguages']);
    final points = _listToCornerPoints(json['points']);
    final elements = <TextElement>[];
    for (final element in json['elements']) {
      final textElement = TextElement.fromJson(element);
      elements.add(textElement);
    }
    return TextLine(text, elements, rect, recognizedLanguages, points);
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
  TextElement(this.text, this.rect, this.cornerPoints);

  factory TextElement.fromJson(Map<dynamic, dynamic> json) {
    final text = json['text'];
    final rect = RectJson.fromJson(json['rect']);
    final points = _listToCornerPoints(json['points']);
    return TextElement(text, rect, points);
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

/// Convert list of map to list of offset.
List<Offset> _listToCornerPoints(List<dynamic> points) {
  final p = <Offset>[];
  for (final point in points) {
    p.add(Offset((point['x']).toDouble(), (point['y']).toDouble()));
  }
  return p;
}
