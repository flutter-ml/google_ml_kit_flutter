import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.absoluteImageSize, this.rotation);

  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.green;

    poses.forEach((pose) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
            Offset(
              translateX(landmark.x, rotation, size, absoluteImageSize),
              translateY(landmark.y, rotation, size, absoluteImageSize),
            ),
            1,
            paint);
      });

      final leftPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Colors.yellow;

      final rightPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Colors.blueAccent;

      PoseLandmark leftShoulder =
          pose.landmarks[PoseLandmarkType.leftShoulder]!;
      PoseLandmark rightShoulder =
          pose.landmarks[PoseLandmarkType.rightShoulder]!;
      PoseLandmark leftElbow = pose.landmarks[PoseLandmarkType.leftElbow]!;
      PoseLandmark rightElbow = pose.landmarks[PoseLandmarkType.rightElbow]!;
      PoseLandmark leftWrist = pose.landmarks[PoseLandmarkType.leftWrist]!;
      PoseLandmark rightWrist = pose.landmarks[PoseLandmarkType.rightWrist]!;
      PoseLandmark leftHip = pose.landmarks[PoseLandmarkType.leftHip]!;
      PoseLandmark rightHip = pose.landmarks[PoseLandmarkType.rightHip]!;

      //Draw body
      canvas.drawLine(
          Offset(translateX(leftHip.x, rotation, size, absoluteImageSize),
              translateY(leftHip.y, rotation, size, absoluteImageSize)),
          Offset(translateX(leftShoulder.x, rotation, size, absoluteImageSize),
              translateY(leftShoulder.y, rotation, size, absoluteImageSize)),
          leftPaint);

      canvas.drawLine(
          Offset(translateX(rightHip.x, rotation, size, absoluteImageSize),
              translateY(rightHip.y, rotation, size, absoluteImageSize)),
          Offset(translateX(rightShoulder.x, rotation, size, absoluteImageSize),
              translateY(rightShoulder.y, rotation, size, absoluteImageSize)),
          rightPaint);

      //Draw arms
      canvas.drawLine(
          Offset(translateX(leftElbow.x, rotation, size, absoluteImageSize),
              translateY(leftElbow.y, rotation, size, absoluteImageSize)),
          Offset(translateX(leftWrist.x, rotation, size, absoluteImageSize),
              translateY(leftWrist.y, rotation, size, absoluteImageSize)),
          leftPaint);

      canvas.drawLine(
          Offset(translateX(leftElbow.x, rotation, size, absoluteImageSize),
              translateY(leftElbow.y, rotation, size, absoluteImageSize)),
          Offset(translateX(leftShoulder.x, rotation, size, absoluteImageSize),
              translateY(leftShoulder.y, rotation, size, absoluteImageSize)),
          leftPaint);

      canvas.drawLine(
          Offset(translateX(rightElbow.x, rotation, size, absoluteImageSize),
              translateY(rightElbow.y, rotation, size, absoluteImageSize)),
          Offset(translateX(rightWrist.x, rotation, size, absoluteImageSize),
              translateY(rightWrist.y, rotation, size, absoluteImageSize)),
          rightPaint);
      canvas.drawLine(
          Offset(translateX(rightElbow.x, rotation, size, absoluteImageSize),
              translateY(rightElbow.y, rotation, size, absoluteImageSize)),
          Offset(translateX(rightShoulder.x, rotation, size, absoluteImageSize),
              translateY(rightShoulder.y, rotation, size, absoluteImageSize)),
          rightPaint);
    });
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
