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


  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;
  late Interpreter _interpreter;  // Interpreter 객체 선언

  @override
  void initState() {
    super.initState();
    _loadModel();  // 앱 시작 시 모델을 불러옴
  }


  // .tflite 모델을 로드하는 함수
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/food_resnet50.tflite');  // your_model.tflite 파일 경로
      print("Model loaded successfully.");
    } catch (e) {
      print("Error loading model: $e");
    }
  }


  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    _interpreter.close();  // Interpreter 객체를 종료합니다.
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

    final Uint8List? bytes = inputImage.bytes;
    final metadata = inputImage.metadata;
    img.Image? image = createImage(bytes!, metadata!);

    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      _isBusy = false;
      return;
    }

    // 사각형 영역을 구하기
    final squareRect = _getSquareRect(faces, inputImage.metadata!.size);
    if (squareRect != null) {
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

  // squareRect 메서드
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

        final squareSize = imageSize.width * 0.2;
        final squareLeft = (centerX - squareSize / 2);
        final squareTop = (centerY - squareSize / 2);

        return Rect.fromLTWH(squareLeft, squareTop, squareSize, squareSize);
      }
    }
    return null;
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

  Uint8List convertYUV420ToRGBA(Uint8List yuvBytes, int width, int height) {
    final int frameSize = width * height;
    final int chromaSize = frameSize ~/ 4;

    Uint8List rgbaBytes = Uint8List(frameSize * 4);

    for (int j = 0, yp = 0; j < height; j++) {
      int uvp = frameSize + (j >> 1) * width;
      int u = 0, v = 0;
      for (int i = 0; i < width; i++, yp++) {
        int y = (0xff & yuvBytes[yp]) - 16;
        if (y < 0) y = 0;
        if ((i & 1) == 0) {
          v = (0xff & yuvBytes[uvp++]) - 128;
          u = (0xff & yuvBytes[uvp++]) - 128;
        }

        int r = (1.164 * y + 1.596 * v).round().clamp(0, 255);
        int g = (1.164 * y - 0.813 * v - 0.391 * u).round().clamp(0, 255);
        int b = (1.164 * y + 2.018 * u).round().clamp(0, 255);

        int index = yp * 4;
        rgbaBytes[index] = r;
        rgbaBytes[index + 1] = g;
        rgbaBytes[index + 2] = b;
        rgbaBytes[index + 3] = 255; // Alpha value
      }
    }

    return rgbaBytes;
  }

  img.Image? createImage(Uint8List bytes, InputImageMetadata metadata) {
    try {
      int width = metadata.size.width.toInt();
      int height = metadata.size.height.toInt();

      print('Creating image with width: $width, height: $height');
      Uint8List rgbaBytes = convertYUV420ToRGBA(bytes, width, height);
      int expectedLength = width * height * 4; // Assuming RGBA format
      if (rgbaBytes.length != expectedLength) {
        print('Invalid byte length: Expected $expectedLength but got ${rgbaBytes.length}');
        return null;
      }

      img.Image image = img.Image.fromBytes(
        width: width,
        height: height,
        bytes: rgbaBytes.buffer,
        numChannels: 4, // Assuming RGBA format
      );

      print('Image created successfully');

      if (metadata.rotation != InputImageRotation.rotation0deg) {
        image = img.copyRotate(image, angle: metadata.rotation.rawValue * 90);
        print('Image rotated by ${metadata.rotation.rawValue * 90} degrees');
      }

      return image;
    } catch (e) {
      print('Error creating image: $e');
      return null;
    }
  }
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Step 1: Resize the image to 224x224
    final img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    // Step 2: Normalize the image pixel values to [0, 1]
    final List<List<List<List<double>>>> input = List.generate(
      1, // Batch size of 1
      (_) => List.generate(
        224, // Height
        (y) => List.generate(
          224, // Width
          (x) {
            // Extract pixel value (rgba format)
            final pixel = resizedImage.getPixelSafe(x, y);

            // Access RGBA components directly
            final r = pixel.r / 255.0;
            final g = pixel.g / 255.0;
            final b = pixel.b / 255.0;

            // Normalize to [-1, 1] if required
            return [r * 2 - 1, g * 2 - 1, b * 2 - 1];
          },
        ),
      ),
    );

    return input;
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

}
