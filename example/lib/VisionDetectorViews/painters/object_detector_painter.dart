import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:ui' as ui;

import 'coordinates_translator.dart';

class ObjectDetectorPainter extends CustomPainter{
  ObjectDetectorPainter(this._objects,this.rotation,this.size);

  final List<DetectedObject> _objects;
  final Size size;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
     final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    final Paint background = Paint()..color = Color(0x99000000);

    for(DetectedObject detectedObject in _objects){
      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 16,
            textDirection: TextDirection.ltr),
      );
      builder.pushStyle(
          ui.TextStyle(color: Colors.lightGreenAccent, background: background));

      for(Label label in detectedObject.getLabels()){
        builder.addText('${label.getText()} ${label.getConfidence()}');
      }

      builder.pop();

      final left =
          translateX(detectedObject.getBoundinBox().left, rotation, size, size);
      final top =
          translateY(detectedObject.getBoundinBox().top, rotation, size, size);
      final right =
          translateX(detectedObject.getBoundinBox().right, rotation, size, size);
      final bottom =
          translateY(detectedObject.getBoundinBox().bottom, rotation, size, size);
      
      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint,
      );

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
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}