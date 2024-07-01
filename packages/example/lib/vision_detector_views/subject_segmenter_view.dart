import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';

import 'detector_view.dart';
import 'painters/subject_segmentation_painter.dart';

class SubjectSegmenterView extends StatefulWidget {
  @override
  State<SubjectSegmenterView> createState() => _SubjectSegmenterViewState();
}

class _SubjectSegmenterViewState extends State<SubjectSegmenterView> {
  final SubjectSegmenter _segmenter = SubjectSegmenter();
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() async {
    _canProcess = false;
    _segmenter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Subject Segmenter',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final mask = await _segmenter.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null &&
        mask != null) {
      final painter = SubjectSegmentationPainter(
        mask,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      // TODO: set _customPaint to draw on top of image
      _text =
          'There is a mask with ${(mask?.confidences ?? []).where((element) => element > 0.8).length} elements';
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
