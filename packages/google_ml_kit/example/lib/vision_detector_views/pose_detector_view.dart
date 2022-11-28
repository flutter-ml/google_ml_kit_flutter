import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../stance_detector/pose_classifier_processor.dart';
import 'camera_view.dart';
import 'painters/pose_painter.dart';

class PoseDetectorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());

  late final PoseClassifierProcessor _poseClassifierProcessor;

  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  String? _lastStance;

  @override
  void initState() {
    _poseClassifierProcessor = PoseClassifierProcessor(isStreamMode: true, onRepInc: (String className, int count) => {_lastStance = '$className ($count)'});
    super.initState();
  }

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
          child: CameraView(
        title: 'Pose Detector',
        customPaint: _customPaint,
        text: _text,
        onImage: (inputImage) {
          processImage(inputImage);
        },
      )),
      Positioned(bottom:150, left:0, right:0, child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [Text(_lastStance ?? 'none', style: TextStyle(color: Colors.white, decoration: TextDecoration.none, fontSize: 12),)],))
    ]);
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final poses = await _poseDetector.processImage(inputImage);

    if (poses.isNotEmpty) {
      try {
        List<String> posResult = _poseClassifierProcessor.getPoseResult(poses.first);
        //print (' R: ${posResult.first} : ${posResult[1]}');
        print(' R: ${posResult[1]}');
        if (_poseClassifierProcessor.isStreamMode)
          {
            _lastStance = posResult[1];
          }
      } catch (e) {
        print('failed');
      }
    }

    if (inputImage.inputImageData?.size != null && inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size, inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
