import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A text recognizer that recognizes text from a given [InputImage].
class TextRecognizer {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_text_recognizer');

  /// Configurations for the language to be detected.
  final TextRecognitionScript script;

  TextRecognizer({this.script = TextRecognitionScript.latin});

  /// Processes the given [InputImage]  for text recognition and returns a [RecognizedText] object.
  Future<RecognizedText> processImage(InputImage inputImage) async {
    final result = await _channel.invokeMethod(
        'vision#startTextRecognizer', <String, dynamic>{
      'imageData': inputImage.toJson(),
      'script': script.index
    });
    return RecognizedText.fromJson(result);
  }

  /// Closes the detector and releases its resources.
  Future<void> close() => _channel.invokeMethod('vision#closeTextRecognizer');
}

/// Configurations for [TextRecognizer] for different languages.
enum TextRecognitionScript {
  latin,
  chinese,
  devanagiri,
  japanese,
  korean,
}

/// Recognized text in an image.
class RecognizedText {
  /// String containing all the text identified in an image. The string is empty if no text was recognized.
  final String text;

  /// All the blocks of text present in image.
  final List<TextBlock> blocks;

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
}

/// A text block recognized in an image that consists of a list of text lines.
class TextBlock {
  /// String representation of the text block that was recognized.
  final String text;

  /// List of text lines that make up the block.
  final List<TextLine> lines;

  /// Rect outlining boundary of block.
  final Rect rect;

  /// List of recognized languages in the text block. If no languages were recognized, the list is empty.
  final List<String> recognizedLanguages;

  /// List of corner points of the text block in clockwise order starting with the top left point relative to the image in the default coordinate space.
  final List<Offset> cornerPoints;

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
}

/// A text line recognized in an image that consists of a list of elements.
class TextLine {
  /// String representation of the text line that was recognized.
  final String text;

  /// List of text elements that make up the line.
  final List<TextElement> elements;

  /// Rect outlining the the text line.
  final Rect rect;

  /// List of recognized languages in the text line. If no languages were recognized, the list is empty.
  final List<String> recognizedLanguages;

  /// The corner points of the text line in clockwise order starting with the top left point relative to the image in the default coordinate space.
  final List<Offset> cornerPoints;

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
}

/// A text element recognized in an image. A text element is roughly equivalent to a space-separated word in most languages.
class TextElement {
  /// String representation of the text element that was recognized.
  final String text;

  /// Rect that contains the text element.
  final Rect rect;

  /// List of corner points of the text element in clockwise order starting with the top left point relative to the image in the default coordinate space.
  final List<Offset> cornerPoints;

  TextElement(this.text, this.rect, this.cornerPoints);

  factory TextElement.fromJson(Map<dynamic, dynamic> json) {
    final text = json['text'];
    final rect = RectJson.fromJson(json['rect']);
    final points = _listToCornerPoints(json['points']);
    return TextElement(text, rect, points);
  }
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
