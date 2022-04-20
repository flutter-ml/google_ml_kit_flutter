import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'camera_view.dart';
import 'painters/object_detector_painter.dart';

class ObjectDetectorView extends StatefulWidget {
  @override
  _ObjectDetectorView createState() => _ObjectDetectorView();
}

class _ObjectDetectorView extends State<ObjectDetectorView> {
  final LocalModel _model = LocalModel('object_labeler.tflite');
  late ObjectDetector _objectDetector;
  final bool _useLocalModel = false;
  bool _isBusy = false;
  CustomPaint? _customPaint;

  @override
  void initState() {
    _objectDetector = ObjectDetector(
        options: _useLocalModel
            ? CustomObjectDetectorOptions(_model,
                multipleObjects: true, classifyObjects: true)
            : ObjectDetectorOptions(
                classifyObjects: true, multipleObjects: true));
    super.initState();
  }

  @override
  void dispose() {
    _objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Object Detector',
      customPaint: _customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      initialDirection: CameraLensDirection.back,
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (_isBusy) return;
    _isBusy = true;
    final result = await _objectDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null &&
        result.isNotEmpty) {
      final painter = ObjectDetectorPainter(
          result,
          inputImage.inputImageData!.imageRotation,
          inputImage.inputImageData!.size);
      _customPaint = CustomPaint(painter: painter);
    } else {
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
