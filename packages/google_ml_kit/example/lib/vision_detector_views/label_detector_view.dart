import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import 'camera_view.dart';
import 'painters/label_detector_painter.dart';

class ImageLabelView extends StatefulWidget {
  @override
  _ImageLabelViewState createState() => _ImageLabelViewState();
}

class _ImageLabelViewState extends State<ImageLabelView> {
  ImageLabeler _imageLabeler = ImageLabeler(options: ImageLabelerOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void dispose() {
    _canProcess = false;
    _imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Image Labeler',
      customPaint: _customPaint,
      text: _text,
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
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final labels = await _imageLabeler.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = LabelDetectorPainter(labels);
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Labels found: ${labels.length}\n\n';
      for (final label in labels) {
        text += 'Label: ${label.label}, '
            'Confidence: ${label.confidence.toStringAsFixed(2)}\n\n';
      }
      _text = text;
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
