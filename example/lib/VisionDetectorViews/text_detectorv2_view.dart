import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'camera_view.dart';
import 'painters/text_detector_painter.dart';

class TextDetectorV2View extends StatefulWidget {
  @override
  _TextDetectorViewV2State createState() => _TextDetectorViewV2State();
}

class _TextDetectorViewV2State extends State<TextDetectorV2View> {
  TextDetectorV2 textDetector = GoogleMlKit.vision.textDetectorV2();
  bool isBusy = false;
  CustomPaint? customPaint;

  @override
  void dispose() async {
    super.dispose();
    await textDetector.close();
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
    final recognisedText = await textDetector.processImage(inputImage,
        script: TextRecognitionOptions.DEVANAGIRI);
    print('Found ${recognisedText.blocks.length} textBlocks');
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = TextDetectorPainter(
          recognisedText,
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
