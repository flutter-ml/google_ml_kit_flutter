import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextFromWidgetView extends StatefulWidget {
  const TextFromWidgetView({Key? key}) : super(key: key);

  @override
  State<TextFromWidgetView> createState() => _TextFromWidgetViewState();
}

class _TextFromWidgetViewState extends State<TextFromWidgetView> {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _widgetKey = GlobalKey();
  String _extractedText = 'Recognized text will appear here';
  bool _isBusy = false;

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text From Widget Example'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _widgetKey,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'This is sample text\nthat will be captured\nand processed using\nthe ML Kit Text Recognizer.\n\nTry different fonts\nand styles to test\nthe recognition capabilities!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isBusy ? null : _extractTextFromWidget,
              child: const Text('Capture and Recognize Text'),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recognition Result:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: double.infinity,
                    child: Text(_extractedText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _extractTextFromWidget() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
      _extractedText = 'Processing...';
    });

    try {
      // Get the RenderObject from the GlobalKey
      final RenderRepaintBoundary? boundary = _widgetKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        setState(() {
          _extractedText = 'Error: Unable to find widget render object';
          _isBusy = false;
        });
        return;
      }

      // Capture the widget as an image
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Convert to byte data in raw RGBA format
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);

      if (byteData == null) {
        setState(() {
          _extractedText = 'Error: Failed to get image byte data';
          _isBusy = false;
        });
        return;
      }

      final Uint8List bytes = byteData.buffer.asUint8List();

      // Create InputImage from bitmap data with dimensions
      final inputImage = InputImage.fromBitmap(
        bitmap: bytes,
        width: image.width,
        height: image.height,
      );

      // Process the image with the text recognizer
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text.isNotEmpty
            ? recognizedText.text
            : 'No text recognized';
        _isBusy = false;
      });
    } catch (e) {
      setState(() {
        _extractedText = 'Error processing image: $e';
        _isBusy = false;
      });
    }
  }
}
