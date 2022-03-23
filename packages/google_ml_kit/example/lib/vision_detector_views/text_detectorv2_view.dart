import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'camera_view.dart';
import 'painters/text_detector_painter.dart';

class TextRecognizerV2View extends StatefulWidget {
  @override
  _TextRecognizerViewV2State createState() => _TextRecognizerViewV2State();
}

class _TextRecognizerViewV2State extends State<TextRecognizerV2View> {
  TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();
  bool isBusy = false;
  CustomPaint? customPaint;

  @override
  void dispose() async {
    super.dispose();
    await textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Text Detector V2',
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final recognizedText = await textRecognizer.processImage(inputImage,
        script: TextRecognitionScript.devanagiri);
    print('Found ${recognizedText.blocks.length} textBlocks');
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = TextRecognizerPainter(
          recognizedText,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
