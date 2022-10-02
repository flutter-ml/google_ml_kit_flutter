import 'dart:math';

import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A text recognizer that recognizes text from a given [InputImage].
class TextRecognizer {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_text_recognizer');

  /// Configurations for the language to be detected.
  final TextRecognitionScript script;

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Constructor to create an instance of [TextRecognizer].
  TextRecognizer({this.script = TextRecognitionScript.latin});

  /// Processes the given [InputImage]  for text recognition and returns a [RecognizedText] object.
  Future<RecognizedText> processImage(InputImage inputImage) async {
    final result = await _channel.invokeMethod(
        'vision#startTextRecognizer', <String, dynamic>{
      'id': id,
      'imageData': inputImage.toJson(),
      'script': script.index
    });
    return RecognizedText.fromJson(result);
  }

  /// Closes the recognizer and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('vision#closeTextRecognizer', {'id': id});
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

  /// Constructor to create an instance of [RecognizedText].
  RecognizedText({required this.text, required this.blocks});

  /// Returns an instance of [RecognizedText] from a given [json].
  factory RecognizedText.fromJson(Map<dynamic, dynamic> json) {
    final resText = json['text'];
    final textBlocks = <TextBlock>[];
    for (final block in json['blocks']) {
      final textBlock = TextBlock.fromJson(block);
      textBlocks.add(textBlock);
    }
    return RecognizedText(text: resText, blocks: textBlocks);
  }
}

/// A text block recognized in an image that consists of a list of text lines.
class TextBlock {
  /// String representation of the text block that was recognized.
  final String text;

  /// List of text lines that make up the block.
  final List<TextLine> lines;

  /// Rect that contains the text block.
  final Rect boundingBox;

  /// List of recognized languages in the text block. If no languages were recognized, the list is empty.
  final List<String> recognizedLanguages;

  /// List of corner points of the text block in clockwise order starting with the top left point relative to the image in the default coordinate space.
  final List<Point<int>> cornerPoints;

  /// Constructor to create an instance of [TextBlock].
  TextBlock(
      {required this.text,
      required this.lines,
      required this.boundingBox,
      required this.recognizedLanguages,
      required this.cornerPoints});

  /// Returns an instance of [TextBlock] from a given [json].
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
    return TextBlock(
        text: text,
        lines: lines,
        boundingBox: rect,
        recognizedLanguages: recognizedLanguages,
        cornerPoints: points);
  }
}

/// A text line recognized in an image that consists of a list of elements.
class TextLine {
  /// String representation of the text line that was recognized.
  final String text;

  /// List of text elements that make up the line.
  final List<TextElement> elements;

  /// Rect that contains the text line.
  final Rect boundingBox;

  /// List of recognized languages in the text line. If no languages were recognized, the list is empty.
  final List<String> recognizedLanguages;

  /// The corner points of the text line in clockwise order starting with the top left point relative to the image in the default coordinate space.
  final List<Point<int>> cornerPoints;

  /// Constructor to create an instance of [TextLine].
  TextLine(
      {required this.text,
      required this.elements,
      required this.boundingBox,
      required this.recognizedLanguages,
      required this.cornerPoints});

  /// Returns an instance of [TextLine] from a given [json].
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
    return TextLine(
        text: text,
        elements: elements,
        boundingBox: rect,
        recognizedLanguages: recognizedLanguages,
        cornerPoints: points);
  }
}

/// A text element recognized in an image. A text element is roughly equivalent to a space-separated word in most languages.
class TextElement {
  /// String representation of the text element that was recognized.
  final String text;

  /// Rect that contains the text element.
  final Rect boundingBox;

  /// List of corner points of the text element in clockwise order starting with the top left point relative to the image in the default coordinate space.
  final List<Point<int>> cornerPoints;

  /// Constructor to create an instance of [TextElement].
  TextElement(
      {required this.text,
      required this.boundingBox,
      required this.cornerPoints});

  /// Returns an instance of [TextElement] from a given [json].
  factory TextElement.fromJson(Map<dynamic, dynamic> json) {
    final text = json['text'];
    final rect = RectJson.fromJson(json['rect']);
    final points = _listToCornerPoints(json['points']);
    return TextElement(text: text, boundingBox: rect, cornerPoints: points);
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

/// Convert list of map to list of [Point].
List<Point<int>> _listToCornerPoints(List<dynamic> points) {
  final p = <Point<int>>[];
  for (final point in points) {
    p.add(Point<int>(point['x'].toInt(), point['y'].toInt()));
  }
  return p;
}
