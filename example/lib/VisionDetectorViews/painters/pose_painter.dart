import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(this.landmarks, this.absoluteImageSize, this.rotation);

  final Map<int, PoseLandmark> landmarks;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.green;

    if (landmarks.length > 0) {
      landmarks.forEach((key, value) {
        canvas.drawCircle(
            Offset(
              translateX(value.x, rotation, size, absoluteImageSize),
              translateY(value.y, rotation, size, absoluteImageSize),
            ),
            1,
            paint);
      });

      // final leftPaint = Paint()
      //   ..style = PaintingStyle.stroke
      //   ..strokeWidth = 6
      //   ..color = Colors.yellow;
      //
      // final rightPaint = Paint()
      //   ..style = PaintingStyle.stroke
      //   ..strokeWidth = 6
      //   ..color = Colors.blueAccent;
      //
      // PoseLandmark leftShoulder = landmarks[PoseLandmark.LEFT_SHOULDER]!;
      // PoseLandmark rightShoulder = landmarks[PoseLandmark.RIGHT_SHOULDER]!;
      // PoseLandmark leftElbow = landmarks[PoseLandmark.LEFT_ELBOW]!;
      // PoseLandmark rightElbow = landmarks[PoseLandmark.RIGHT_ELBOW]!;
      // PoseLandmark leftWrist = landmarks[PoseLandmark.LEFT_WRIST]!;
      // PoseLandmark rightWrist = landmarks[PoseLandmark.RIGHT_WRIST]!;
      // PoseLandmark leftHip = landmarks[PoseLandmark.LEFT_HIP]!;
      // PoseLandmark rightHip = landmarks[PoseLandmark.RIGHT_HIP]!;
      // PoseLandmark leftKnee = landmarks[PoseLandmark.LEFT_KNEE]!;
      // PoseLandmark rightKnee = landmarks[PoseLandmark.RIGHT_KNEE]!;
      // PoseLandmark leftAnkle = landmarks[PoseLandmark.LEFT_ANKLE]!;
      // PoseLandmark rightAnkle = landmarks[PoseLandmark.RIGHT_ANKLE]!;
      // PoseLandmark leftHeel = landmarks[PoseLandmark.LEFT_HEEL]!;
      // PoseLandmark rightHeel = landmarks[PoseLandmark.RIGHT_HEEL]!;
      // PoseLandmark leftFootIndex = landmarks[PoseLandmark.LEFT_FOOT_INDEX]!;
      // PoseLandmark rightFootIndex = landmarks[PoseLandmark.RIGHT_FOOT_INDEX]!;
      //
      // // Similarly get other landmarks as well
      // PoseLandmark leftPinky = _landmarksMap[PoseLandmark.LEFT_PINKY];
      // PoseLandmark rightPinky = _landmarksMap[PoseLandmark.RIGHT_PINKY];
      // PoseLandmark leftIndex = _landmarksMap[PoseLandmark.LEFT_INDEX];
      // PoseLandmark rightIndex = _landmarksMap[PoseLandmark.RIGHT_INDEX];
      // PoseLandmark leftThumb = _landmarksMap[PoseLandmark.LEFT_THUMB];
      // PoseLandmark rightThumb = _landmarksMap[PoseLandmark.RIGHT_THUMB];
      //
      // //Draw arms
      // canvas.drawLine(Offset(leftElbow.x, leftElbow.y),
      //     Offset(leftWrist.x, leftWrist.y), leftPaint);
      // canvas.drawLine(Offset(leftElbow.x, leftElbow.y),
      //     Offset(leftShoulder.x, leftShoulder.y), leftPaint);
      //
      // canvas.drawLine(Offset(rightElbow.x, rightElbow.y),
      //     Offset(rightWrist.x, rightWrist.y), rightPaint);
      // canvas.drawLine(Offset(rightElbow.x, rightElbow.y),
      //     Offset(rightShoulder.x, rightShoulder.y), rightPaint);
      //
      // //Draw legs
      // canvas.drawLine(Offset(leftHip.x, leftHip.y),
      //     Offset(leftKnee.x, leftKnee.y), leftPaint);
      // canvas.drawLine(Offset(leftKnee.x, leftKnee.y),
      //     Offset(leftAnkle.x, leftAnkle.y), leftPaint);
      // canvas.drawLine(Offset(leftAnkle.x, leftAnkle.y),
      //     Offset(leftHeel.x, leftHeel.y), leftPaint);
      // canvas.drawLine(Offset(leftHeel.x, leftHeel.y),
      //     Offset(leftFootIndex.x, leftFootIndex.y), leftPaint);
      //
      // canvas.drawLine(Offset(rightHip.x, rightHip.y),
      //     Offset(rightKnee.x, rightKnee.y), rightPaint);
      // canvas.drawLine(Offset(rightKnee.x, rightKnee.y),
      //     Offset(rightAnkle.x, rightAnkle.y), rightPaint);
      // canvas.drawLine(Offset(rightAnkle.x, rightAnkle.y),
      //     Offset(rightHeel.x, rightHeel.y), rightPaint);
      // canvas.drawLine(Offset(rightHeel.x, rightHeel.y),
      //     Offset(rightFootIndex.x, rightFootIndex.y), rightPaint);
      //
      // //Draw body
      // canvas.drawLine(Offset(leftHip.x, leftHip.y),
      //     Offset(leftShoulder.x, leftShoulder.y), leftPaint);
      //
      // canvas.drawLine(Offset(rightHip.x, rightHip.y),
      //     Offset(rightShoulder.x, rightShoulder.y), rightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.landmarks != landmarks;
  }
}
