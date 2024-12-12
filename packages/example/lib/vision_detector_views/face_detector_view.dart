import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
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

  late Interpreter _interpreter;
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/ml/food_resnet50.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    _interpreter.close();
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
      _text = ''; // Initialize the text to update
    });

    final Uint8List? bytes = inputImage.bytes;
    final metadata = inputImage.metadata;
    img.Image? image = createImage(bytes!, metadata!);

    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      _isBusy = false;
      return;
    }

    // Face detection and cropping
    final squareRect = _getSquareRect(faces, inputImage.metadata!.size);
    if (squareRect != null) {
      image = cropImage(image, squareRect);
      if (image != null) {
        //print('Cropped Image width: ${image.width}, height: ${image.height}');
      
        final input = convertToFloat32List(await getCnnInput(image)).reshape([1,224,224,3]);
        
        // print('input shape: ${input.shape}');
        // print('input dtype: ${input.runtimeType}'); // TensorFlow의 float32인가 확인

        // print(_interpreter.getInputTensors()[0]);
        // print(_interpreter.getOutputTensors()[0]);
        // Run inference and get the output
        final output = List.filled(1 * 1, 0.0).reshape([1, 1]); // Assuming output size 1000
        // print('output shape: ${output.shape}');
        _interpreter.run(input, output);

        setState(() {
          _text = 'Inference Result: ${output[0]}';
          print(_text);
        });
      }
    } else {
      print("No square rect detected.");
    }

    // Update the CustomPaint with detected faces
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
Float32List convertToFloat32List(List<List<List<double>>> input) {
  final flattened = input.expand((row) => row.expand((col) => col)).toList();
  return Float32List.fromList(flattened.map((e) => e.toDouble()).toList());
}

Future<List<List<List<double>>>> getCnnInput(img.Image image) async {
  //print('cnn input');
  // 이미지를 [224, 224] 크기로 리사이즈합니다.
  img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

  // 결과를 저장할 배열을 초기화합니다.
  List<List<List<double>>> result = List.generate(224, 
    (_) => List.generate(224, 
      (_) => List.filled(3, 0.0)));
  // 픽셀 데이터를 [0, 1] 범위로 정규화하여 배열에 저장합니다.
  for (int y = 0; y < resizedImage.height; y++) {
    for (int x = 0; x < resizedImage.width; x++) {
      Pixel pixel = resizedImage.getPixel(x, y);
      double r = pixel[0] / 1;
      double g = pixel[1] / 1;
      double b = pixel[2] / 1;
      result[y][x][0] = r; // Red
      result[y][x][1] = g; // Green
      result[y][x][2] = b; // Blue
    }
  }
  //print(result.shape);
  return result;
}


  

  img.Image? createImage(Uint8List bytes, InputImageMetadata metadata) {
    int width = metadata.size.width.toInt();
    int height = metadata.size.height.toInt();

    img.Image image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: bytes.buffer,
      numChannels: 4, // Assuming RGBA format
    );

    if (metadata.rotation != InputImageRotation.rotation0deg) {
      image = img.copyRotate(image, angle: metadata.rotation.rawValue * 90);
    }

    return image;
  }

  img.Image? cropImage(img.Image? image, Rect? squareRect) {
    if (image == null || squareRect == null) return null;

    int x = squareRect.left.round();
    int y = squareRect.top.round();
    int width = squareRect.width.round();
    int height = squareRect.height.round();
    width = width.abs();
    height = height.abs();

    return img.copyCrop(image, x: x, y: y, width: width, height: height);
  }



  Rect? _getSquareRect(List<Face> faces, Size imageSize) {
    for (final face in faces) {
      final landmarks = face.landmarks;
      final bottomLip = landmarks[FaceLandmarkType.bottomMouth]?.position;
      final nose = landmarks[FaceLandmarkType.noseBase]?.position;
      final leftMouth = landmarks[FaceLandmarkType.leftMouth]?.position;
      final rightMouth = landmarks[FaceLandmarkType.rightMouth]?.position;

      if (bottomLip != null && nose != null && leftMouth != null && rightMouth != null) {
        final centerX = (leftMouth.x + rightMouth.x + bottomLip.x + nose.x) / 4;
        final centerY = (leftMouth.y + rightMouth.y + bottomLip.y + nose.y) / 4;
        final squareSize = (leftMouth.x - rightMouth.x) * 2.0;
        final squareLeft = (centerX - squareSize / 2);
        final squareTop = (centerY - squareSize / 2);

        return Rect.fromLTWH(squareLeft, squareTop, squareSize, squareSize);
      }
    }
    return null;
  }
}