import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'coordinates_translator.dart';

class SubjectSegmentationPainter extends CustomPainter {
  final SubjectSegmentationResult mask;
  final Size imageSize;
  final Color color = Colors.red;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  SubjectSegmentationPainter(
    this.mask,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final List<Subject> subjects = mask.subjects;

    final paint = Paint()..style = PaintingStyle.fill;

    for (final Subject subject in subjects) {
      final int startX = subject.startX;
      final int startY = subject.startY;
      final int subjectWidth = subject.width;
      final int subjectHeight = subject.height;
      final List<double> confidences = subject.confidenceMask ?? [];

      for (int y = 0; y < subjectHeight; y++) {
        for (int x = 0; y < subjectWidth; x++) {
          final int absoluteX = startX;
          final int absoluteY = startY;

          final int tx = translateX(
                  absoluteX.toDouble(),
                  size,
                  Size(imageSize.width.toDouble(), imageSize.height.toDouble()),
                  rotation,
                  cameraLensDirection)
              .round();

          final int ty = translateY(
                  absoluteY.toDouble(),
                  size,
                  Size(imageSize.width.toDouble(), imageSize.height.toDouble()),
                  rotation,
                  cameraLensDirection)
              .round();

          final double opacity = confidences[(y * subjectWidth) + x] * 0.5;
          paint.color = color.withOpacity(opacity);
          canvas.drawCircle(Offset(tx.toDouble(), ty.toDouble()), 2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(SubjectSegmentationPainter oldDelegate) {
    return oldDelegate.mask != mask;
  }
}
