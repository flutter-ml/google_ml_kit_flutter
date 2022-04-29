import 'package:flutter/material.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

class SegmentationPainter extends CustomPainter {
  final SegmentationMask mask;
  final Size absoluteImageSize;
  final Color color = Colors.red;
  final InputImageRotation rotation;

  SegmentationPainter(
    this.mask,
    this.absoluteImageSize,
    this.rotation,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    final width = mask.width;
    final height = mask.height;
    final confidences = mask.confidences;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int tx = transformX(x.toDouble(), size).round();
        final int ty = transformY(y.toDouble(), size).round();

        final double opacity = confidences[(y * width) + x] * 0.25;
        paint.color = color.withOpacity(opacity);
        canvas.drawCircle(Offset(tx.toDouble(), ty.toDouble()), 1, paint);
      }
    }
  }

  double transformX(double x, Size size) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return x * size.width / absoluteImageSize.height;
      case InputImageRotation.rotation270deg:
        return size.width - x * size.width / absoluteImageSize.height;
      default:
        return x * size.width / absoluteImageSize.width;
    }
  }

  double transformY(double y, Size size) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return y * size.height / absoluteImageSize.width;
      default:
        return y * size.height / absoluteImageSize.height;
    }
  }

  @override
  bool shouldRepaint(SegmentationPainter oldDelegate) {
    return oldDelegate.mask != mask;
  }
}
