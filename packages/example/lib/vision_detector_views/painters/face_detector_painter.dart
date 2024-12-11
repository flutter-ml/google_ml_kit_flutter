import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'coordinates_translator.dart';

class FaceDetectorPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final Rect? squareRect; // Optional square rectangle

  FaceDetectorPainter(
    this.faces,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection, {
    this.squareRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 255, 0, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw faces' bounding boxes with translated coordinates
    for (final face in faces) {
      final left = translateX(
        face.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        face.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        face.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        face.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint,
      );
    }

    // Draw the optional square rectangle if it exists
    if (squareRect != null) {
      final squarePaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final left = translateX(
        squareRect!.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        squareRect!.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        squareRect!.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        squareRect!.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        squarePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize ||
        oldDelegate.faces != faces ||
        oldDelegate.squareRect != squareRect;
  }
}
