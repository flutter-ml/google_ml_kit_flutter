import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class PoseDetectorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  bool showImage = false;
  ui.Image? image;

  Map<int, PoseLandmark>? poseLandmarks;

  Future<void> getImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageData = File(pickedFile.path).readAsBytesSync();
      final uiImage = await decodeImageFromList(imageData);

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      // final options = PoseDetectorOptions(
      //     poseDetectionModel: PoseDetectionModel.AccuratePoseDetector,
      //     poseDetectionMode: PoseDetectionMode.StaticImage);
      final poseDetector = GoogleMlKit.instance.poseDetector();
      var landMarksMap = await poseDetector.processImage(inputImage);
      setState(() {
        poseLandmarks = landMarksMap;
        image = uiImage;
        showImage = true;
      });
      await poseDetector.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pose Detector"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            showImage
                ? FittedBox(
                    child: SizedBox(
                      height: image?.height.toDouble(),
                      width: image?.width.toDouble(),
                      child: CustomPaint(
                        painter: PosePainter(image!, poseLandmarks!),
                      ),
                    ),
                  )
                : Container(),
            ElevatedButton(
              onPressed: getImage,
              child: Text('Select Image'),
            )
          ],
        ),
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final ui.Image _image;
  final Map<int, PoseLandmark> _landmarksMap;

  PosePainter(this._image, this._landmarksMap);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = Colors.black;
    canvas.drawImage(_image, Offset.zero, Paint());

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = Colors.yellow;
    canvas.drawImage(_image, Offset.zero, Paint());

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = Colors.blueAccent;
    canvas.drawImage(_image, Offset.zero, Paint());

    if (_landmarksMap.length > 0) {
      _landmarksMap.forEach((key, value) {
        canvas.drawCircle(Offset(value.x, value.y), 1, paint);
      });

      PoseLandmark leftShoulder = _landmarksMap[PoseLandmark.LEFT_SHOULDER]!;
      PoseLandmark rightShoulder = _landmarksMap[PoseLandmark.RIGHT_SHOULDER]!;
      PoseLandmark leftElbow = _landmarksMap[PoseLandmark.LEFT_ELBOW]!;
      PoseLandmark rightElbow = _landmarksMap[PoseLandmark.RIGHT_ELBOW]!;
      PoseLandmark leftWrist = _landmarksMap[PoseLandmark.LEFT_WRIST]!;
      PoseLandmark rightWrist = _landmarksMap[PoseLandmark.RIGHT_WRIST]!;
      PoseLandmark leftHip = _landmarksMap[PoseLandmark.LEFT_HIP]!;
      PoseLandmark rightHip = _landmarksMap[PoseLandmark.RIGHT_HIP]!;
      PoseLandmark leftKnee = _landmarksMap[PoseLandmark.LEFT_KNEE]!;
      PoseLandmark rightKnee = _landmarksMap[PoseLandmark.RIGHT_KNEE]!;
      PoseLandmark leftAnkle = _landmarksMap[PoseLandmark.LEFT_ANKLE]!;
      PoseLandmark rightAnkle = _landmarksMap[PoseLandmark.RIGHT_ANKLE]!;
      PoseLandmark leftHeel = _landmarksMap[PoseLandmark.LEFT_HEEL]!;
      PoseLandmark rightHeel = _landmarksMap[PoseLandmark.RIGHT_HEEL]!;
      PoseLandmark leftFootIndex = _landmarksMap[PoseLandmark.LEFT_FOOT_INDEX]!;
      PoseLandmark rightFootIndex =
          _landmarksMap[PoseLandmark.RIGHT_FOOT_INDEX]!;

      //Similarly get other landmarks as well
      // PoseLandmark leftPinky = _landmarksMap[PoseLandmark.LEFT_PINKY];
      // PoseLandmark rightPinky = _landmarksMap[PoseLandmark.RIGHT_PINKY];
      // PoseLandmark leftIndex = _landmarksMap[PoseLandmark.LEFT_INDEX];
      // PoseLandmark rightIndex = _landmarksMap[PoseLandmark.RIGHT_INDEX];
      // PoseLandmark leftThumb = _landmarksMap[PoseLandmark.LEFT_THUMB];
      // PoseLandmark rightThumb = _landmarksMap[PoseLandmark.RIGHT_THUMB];

      //Draw arms
      canvas.drawLine(Offset(leftElbow.x, leftElbow.y),
          Offset(leftWrist.x, leftWrist.y), leftPaint);
      canvas.drawLine(Offset(leftElbow.x, leftElbow.y),
          Offset(leftShoulder.x, leftShoulder.y), leftPaint);

      canvas.drawLine(Offset(rightElbow.x, rightElbow.y),
          Offset(rightWrist.x, rightWrist.y), rightPaint);
      canvas.drawLine(Offset(rightElbow.x, rightElbow.y),
          Offset(rightShoulder.x, rightShoulder.y), rightPaint);

      //Draw legs
      canvas.drawLine(Offset(leftHip.x, leftHip.y),
          Offset(leftKnee.x, leftKnee.y), leftPaint);
      canvas.drawLine(Offset(leftKnee.x, leftKnee.y),
          Offset(leftAnkle.x, leftAnkle.y), leftPaint);
      canvas.drawLine(Offset(leftAnkle.x, leftAnkle.y),
          Offset(leftHeel.x, leftHeel.y), leftPaint);
      canvas.drawLine(Offset(leftHeel.x, leftHeel.y),
          Offset(leftFootIndex.x, leftFootIndex.y), leftPaint);

      canvas.drawLine(Offset(rightHip.x, rightHip.y),
          Offset(rightKnee.x, rightKnee.y), rightPaint);
      canvas.drawLine(Offset(rightKnee.x, rightKnee.y),
          Offset(rightAnkle.x, rightAnkle.y), rightPaint);
      canvas.drawLine(Offset(rightAnkle.x, rightAnkle.y),
          Offset(rightHeel.x, rightHeel.y), rightPaint);
      canvas.drawLine(Offset(rightHeel.x, rightHeel.y),
          Offset(rightFootIndex.x, rightFootIndex.y), rightPaint);

      //Draw body
      canvas.drawLine(Offset(leftHip.x, leftHip.y),
          Offset(leftShoulder.x, leftShoulder.y), leftPaint);

      canvas.drawLine(Offset(rightHip.x, rightHip.y),
          Offset(rightShoulder.x, rightShoulder.y), rightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) =>
      _image != oldDelegate._image;
}
