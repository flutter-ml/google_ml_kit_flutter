import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'coordinates_translator.dart';

class BarcodeDetectorPainter extends CustomPainter {
  BarcodeDetectorPainter(this.barcodes, this.absoluteImageSize, this.rotation);

  final List<Barcode> barcodes;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    final Paint background = Paint()..color = Color(0x99000000);

    for (final Barcode barcode in barcodes) {
      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 16,
            textDirection: TextDirection.ltr),
      );
      builder.pushStyle(
          ui.TextStyle(color: Colors.lightGreenAccent, background: background));
      builder.addText('${barcode.displayValue}');
      builder.pop();

      // Store the points for the bounding box
      double left = double.infinity;
      double top = double.infinity;
      double right = double.negativeInfinity;
      double bottom = double.negativeInfinity;

      final cornerPoints = barcode.cornerPoints;
      final boundingBox = barcode.boundingBox;
      if (cornerPoints == null) {
        if (boundingBox != null) {
          left =
              translateX(boundingBox.left, rotation, size, absoluteImageSize);
          top = translateY(boundingBox.top, rotation, size, absoluteImageSize);
          right =
              translateX(boundingBox.right, rotation, size, absoluteImageSize);
          bottom =
              translateY(boundingBox.bottom, rotation, size, absoluteImageSize);

          // Draw a bounding rectangle around the barcode
          canvas.drawRect(
            Rect.fromLTRB(left, top, right, bottom),
            paint,
          );
        }
      } else {
        final List<Offset> offsetPoints = <Offset>[];
        for (final point in cornerPoints) {
          final double x =
              translateX(point.x.toDouble(), rotation, size, absoluteImageSize);
          final double y =
              translateY(point.y.toDouble(), rotation, size, absoluteImageSize);

          offsetPoints.add(Offset(x, y));

          // Due to possible rotations we need to find the smallest and largest
          top = min(top, y);
          bottom = max(bottom, y);
          left = min(left, x);
          right = max(right, x);
        }
        // Add the first point to close the polygon
        offsetPoints.add(offsetPoints.first);
        canvas.drawPoints(PointMode.polygon, offsetPoints, paint);
      }

      canvas.drawParagraph(
        builder.build()
          ..layout(ParagraphConstraints(
            width: right - left,
          )),
        Offset(left, top),
      );
    }
  }

  @override
  bool shouldRepaint(BarcodeDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.barcodes != barcodes;
  }
}
