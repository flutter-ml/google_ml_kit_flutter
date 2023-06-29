import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A text recognizer that recognizes text from a given [InputImage].
class TextRecognizer {
  static const services.MethodChannel _channel =
      services.MethodChannel('google_mlkit_text_recognizer');

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
  TextBlock({
    required this.text,
    required this.lines,
    required this.boundingBox,
    required this.recognizedLanguages,
    required this.cornerPoints,
  });

  /// Returns an instance of [TextBlock] from a given [json].
  factory TextBlock.fromJson(Map<dynamic, dynamic> json) {
    final text = json['text'];
    final boundingBox = RectJson.fromJson(json['rect']);
    final recognizedLanguages =
        _listToRecognizedLanguages(json['recognizedLanguages']);
    final cornerPoints = _listToCornerPoints(json['points']);
    final lines = <TextLine>[];
    for (final line in json['lines']) {
      final textLine = TextLine.fromJson(line);
      lines.add(textLine);
    }
    return TextBlock(
      text: text,
      lines: lines,
      boundingBox: boundingBox,
      recognizedLanguages: recognizedLanguages,
      cornerPoints: cornerPoints,
    );
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

  // The confidence of the recognized line.
  // Only available in Android, for iOS returns null.
  final double? confidence;

  // The angle of the rotation of the recognized line.
  // Only available in Android, for iOS returns null.
  final double? angle;

  /// Constructor to create an instance of [TextLine].
  TextLine({
    required this.text,
    required this.elements,
    required this.boundingBox,
    required this.recognizedLanguages,
    required this.cornerPoints,
    required this.confidence,
    required this.angle,
  });

  /// Returns an instance of [TextLine] from a given [json].
  factory TextLine.fromJson(Map<dynamic, dynamic> json) {
    final text = json['text'];
    final boundingBox = RectJson.fromJson(json['rect']);
    final confidence = json['confidence'];
    final angle = json['angle'];
    final recognizedLanguages =
        _listToRecognizedLanguages(json['recognizedLanguages']);
    final cornerPoints = _listToCornerPoints(json['points']);
    final elements = <TextElement>[];
    for (final element in json['elements']) {
      final textElement = TextElement.fromJson(element);
      elements.add(textElement);
    }
    return TextLine(
      text: text,
      elements: elements,
      boundingBox: boundingBox,
      recognizedLanguages: recognizedLanguages,
      cornerPoints: cornerPoints,
      confidence: confidence,
      angle: angle,
    );
  }
}

/// A text element recognized in an image. A text element is roughly equivalent to a space-separated word in most languages.
class TextElement {
  /// String representation of the text element that was recognized.
  final String text;

  /// List of text elements that make up the line.
  // Only available in Android, for iOS returns an empty list.
  final List<TextSymbol> symbols;

  /// Rect that contains the text element.
  final Rect boundingBox;

  /// List of recognized languages in the text element. If no languages were recognized, the list is empty.
  final List<String> recognizedLanguages;

  /// List of corner points of the text element in clockwise order starting with the top left point relative to the image in the default coordinate space.
  final List<Point<int>> cornerPoints;

  // The confidence of the recognized element.
  // Only available in Android, for iOS returns null.
  final double? confidence;

  // The angle of the rotation of the recognized element.
  // Only available in Android, for iOS returns null.
  final double? angle;

  /// Constructor to create an instance of [TextElement].
  TextElement({
    required this.text,
    required this.symbols,
    required this.boundingBox,
    required this.recognizedLanguages,
    required this.cornerPoints,
    required this.confidence,
    required this.angle,
  });

  /// Returns an instance of [TextElement] from a given [json].
  factory TextElement.fromJson(Map<dynamic, dynamic> json) {
    final text = json['text'];
    final boundingBox = RectJson.fromJson(json['rect']);
    final recognizedLanguages =
        _listToRecognizedLanguages(json['recognizedLanguages']);
    final cornerPoints = _listToCornerPoints(json['points']);
    final confidence = json['confidence'];
    final angle = json['angle'];
    final symbols = <TextSymbol>[];
    for (final symbol in json['symbols']) {
      final textSymbol = TextSymbol.fromJson(symbol);
      symbols.add(textSymbol);
    }
    return TextElement(
      text: text,
      symbols: symbols,
      boundingBox: boundingBox,
      recognizedLanguages: recognizedLanguages,
      cornerPoints: cornerPoints,
      confidence: confidence,
      angle: angle,
    );
  }
}

/// A text symbol recognized in an image. Represents a single symbol in an [TextElement].
class TextSymbol {
  /// String representation of the text symbol that was recognized.
  final String text;

  /// Rect that contains the text symbol.
  final Rect boundingBox;

  /// List of recognized languages in the text symbol. If no languages were recognized, the list is empty.
  final List<String> recognizedLanguages;

  /// List of corner points of the text symbol in clockwise order starting with the top left point relative to the image in the default coordinate space.
  final List<Point<int>> cornerPoints;

  // The confidence of the recognized symbol.
  // Only available in Android, for iOS returns null.
  final double? confidence;

  // The angle of the rotation of the recognized symbol.
  // Only available in Android, for iOS returns null.
  final double? angle;

  /// Constructor to create an instance of [TextSymbol].
  TextSymbol({
    required this.text,
    required this.boundingBox,
    required this.recognizedLanguages,
    required this.cornerPoints,
    required this.confidence,
    required this.angle,
  });

  /// Returns an instance of [TextSymbol] from a given [json].
  factory TextSymbol.fromJson(Map<dynamic, dynamic> json) {
    final text = json['text'];
    final boundingBox = RectJson.fromJson(json['rect']);
    final recognizedLanguages =
        _listToRecognizedLanguages(json['recognizedLanguages']);
    final cornerPoints = _listToCornerPoints(json['points']);
    final confidence = json['confidence'];
    final angle = json['angle'];
    return TextSymbol(
      text: text,
      boundingBox: boundingBox,
      recognizedLanguages: recognizedLanguages,
      cornerPoints: cornerPoints,
      confidence: confidence,
      angle: angle,
    );
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
