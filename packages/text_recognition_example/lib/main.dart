import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    _cameras = await availableCameras();
  } catch (e) {
    _cameras = [];
  }
  runApp(const TextRecognitionApp());
}

class TextRecognitionApp extends StatelessWidget {
  const TextRecognitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Recognition',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CameraTextRecognitionScreen(),
    );
  }
}

class CameraTextRecognitionScreen extends StatefulWidget {
  const CameraTextRecognitionScreen({super.key});

  @override
  State<CameraTextRecognitionScreen> createState() => _CameraTextRecognitionScreenState();
}

class _CameraTextRecognitionScreenState extends State<CameraTextRecognitionScreen> {
  CameraController? _cameraController;
  final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  String _recognizedText = '';
  bool _isProcessing = false;
  bool _cameraReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (_cameras.isEmpty) {
      setState(() => _errorMessage = 'No camera available');
      return;
    }
    try {
      final controller = CameraController(_cameras.first, ResolutionPreset.medium);
      await controller.initialize();
      setState(() {
        _cameraController = controller;
        _cameraReady = true;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Camera error: $e');
    }
  }

  Future<void> _captureAndRecognize() async {
    if (_cameraController == null || !_cameraReady) return;
    setState(() {
      _isProcessing = true;
      _recognizedText = '';
    });

    try {
      final file = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      final recognisedText = await _recognizer.processImage(inputImage);
      setState(() => _recognizedText = recognisedText.text);
    } catch (e) {
      setState(() => _recognizedText = 'Error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Point & Recognize')),
      body: Column(
        children: [
          // Camera preview
          Expanded(
            flex: 3,
            child: _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  )
                : _cameraReady
                    ? CameraPreview(_cameraController!)
                    : const Center(child: CircularProgressIndicator()),
          ),
          // Capture button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ElevatedButton.icon(
              onPressed: (_isProcessing || !_cameraReady) ? null : _captureAndRecognize,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(_isProcessing ? 'Recognizing...' : 'Capture & Recognize'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ),
          // Results
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.grey[100],
              child: SingleChildScrollView(
                child: _recognizedText.isEmpty && _errorMessage == null
                    ? const Text(
                        'Point camera at text and tap the button',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      )
                    : SelectableText(
                        _recognizedText,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
