import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'camera_view.dart';
import 'painters/label_detector_painter.dart';

class ImageLabelView extends StatefulWidget {
  @override
  _ImageLabelViewState createState() => _ImageLabelViewState();
}

class _ImageLabelViewState extends State<ImageLabelView> {
  ImageLabeler _imageLabeler = ImageLabeler(options: ImageLabelerOptions());
  bool _isBusy = false;
  CustomPaint? _customPaint;

  @override
  void dispose() {
    _imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Image Labeler',
      customPaint: _customPaint,
      onImage: (inputImage) {
        // comment this line if you want to use custom model
        processImageWithDefaultModel(inputImage);
        // uncomment this line if you want to use custom model
        // processImageWithRemoteModel(inputImage);
      },
    );
  }

  Future<void> processImageWithDefaultModel(InputImage inputImage) async {
    _imageLabeler = ImageLabeler(options: ImageLabelerOptions());
    processImage(inputImage);
  }

  // Add the tflite model in android/src/main/assets
  Future<void> processImageWithRemoteModel(InputImage inputImage) async {
    final options = FirebaseLabelerOption(
        confidenceThreshold: 0.5, modelName: 'bird-classifier');
    _imageLabeler = ImageLabeler(options: options);
    processImage(inputImage);
  }

  Future<void> processImage(InputImage inputImage) async {
    if (_isBusy) return;
    _isBusy = true;
    await Future.delayed(Duration(milliseconds: 50));
    final labels = await _imageLabeler.processImage(inputImage);
    final painter = LabelDetectorPainter(labels);
    _customPaint = CustomPaint(painter: painter);
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
