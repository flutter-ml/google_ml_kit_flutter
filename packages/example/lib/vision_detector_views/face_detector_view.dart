import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'detector_view.dart';
import 'painters/face_detector_painter.dart';

class FaceDetectorView extends StatefulWidget {
  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;

    setState(() {
      _text = '';  // 갱신할 텍스트 초기화
    });

    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      _isBusy = false;
      return;
    }

    // 사각형 그리기
    final squareRect = _getSquareRect(faces, inputImage.metadata!.size);
    // 로그로 squareRect 확인
    if (squareRect != null) {
      print("Updated squareRect: $squareRect");
    } else {
      print("No square rect detected.");
    }
    
    // 화면을 갱신할 필요가 있을 때만 CustomPaint 업데이트
    setState(() {
      _customPaint = CustomPaint(
        painter: FaceDetectorPainter(
          faces,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
          squareRect: squareRect,
        ),
      );
    });

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  Rect? _getSquareRect(List<Face> faces,Size imageSize) {
    // 얼굴에서 필요한 랜드마크를 추출하여 정사각형 영역 계산
    for (final face in faces) {
      final landmarks = face.landmarks;
      final bottomLip = landmarks[FaceLandmarkType.bottomMouth]?.position;
      final nose = landmarks[FaceLandmarkType.noseBase]?.position;
      final leftMouth = landmarks[FaceLandmarkType.leftMouth]?.position;
      final rightMouth = landmarks[FaceLandmarkType.rightMouth]?.position;

      if (bottomLip != null && nose != null && leftMouth != null && rightMouth != null) {
        // 각 랜드마크의 중심 계산
        final centerX = (leftMouth.x + rightMouth.x + bottomLip.x + nose.x) / 4;
        final centerY = (leftMouth.y + rightMouth.y + bottomLip.y + nose.y) / 4;
        print('X: $centerY');
        print('Y: $centerX');
        // 정사각형 영역의 크기 및 좌표 계산
        final squareSize = (leftMouth.x-rightMouth.x)*2.0;
        final squareLeft = (centerX - squareSize/2 );
        final squareTop = (centerY - squareSize/2 );

        return Rect.fromLTWH(squareLeft, squareTop, squareSize, squareSize);
      }
    }
    return null;  // 얼굴 랜드마크가 모두 존재하지 않으면 null 반환
  }
}