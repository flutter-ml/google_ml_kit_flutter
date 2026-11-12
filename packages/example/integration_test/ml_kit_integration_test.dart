// Integration tests for the google_ml_kit example app.
//
// Exercises every plugin's native code path on a real device or emulator
// using the sample images bundled in `assets/images/`, so no physical
// camera is required. The camera itself is covered by a smoke test at the
// bottom (it skips itself when the CAMERA permission was not granted).
//
// Run with:
//   cd packages/example
//   flutter test integration_test/ml_kit_integration_test.dart
//
// To let the camera smoke test run on an emulator, pre-grant the
// permission before launching:
//   adb shell pm grant <applicationId> android.permission.CAMERA

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// Loads an asset from the bundle and returns it as a file-based [InputImage].
///
/// The plugin's native side decodes from a file path, so the asset bytes are
/// first copied to the app's temporary directory.
Future<InputImage> inputImageFromAsset(String assetPath) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${assetPath.split('/').last}');
  if (!file.existsSync()) {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await file.writeAsBytes(bytes, flush: true);
  }
  return InputImage.fromFilePath(file.path);
}

/// Decodes an asset into a raw RGBA bitmap and returns it as an
/// [InputImage] — the same shape a camera frame produces, which lets us
/// exercise the bitmap/`fromBytes` native path without a real camera.
Future<InputImage> bitmapFromAsset(String assetPath) async {
  final data = await rootBundle.load(assetPath);
  final codec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
  final frame = await codec.getNextFrame();
  final byteData = await frame.image.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  );
  return InputImage.fromBitmap(
    bitmap: byteData!.buffer.asUint8List(),
    width: frame.image.width,
    height: frame.image.height,
  );
}

/// Whether the test is running on the iOS simulator.
///
/// MediaPipe-backed detectors (pose, selfie segmentation) hit a LOG(FATAL)
/// inside the closed-source ML Kit binaries when run on the simulator, so
/// those tests skip themselves there. The value comes from a small channel
/// registered in the example app's AppDelegate.
Future<bool> get isSimulator async {
  try {
    final result = await const MethodChannel(
      'example/simulator',
    ).invokeMethod<bool>('isSimulator');
    return result ?? false;
  } on MissingPluginException {
    return false;
  }
}

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('barcode scanning', () {
    testWidgets('detects a barcode in barcode1.webp', (tester) async {
      await tester.runAsync(() async {
        final scanner = BarcodeScanner();
        try {
          final barcodes = await scanner.processImage(
            await inputImageFromAsset('assets/images/barcode1.webp'),
          );
          expect(barcodes, isNotEmpty);
          expect(barcodes.first.rawValue, isNotEmpty);
        } finally {
          await scanner.close();
        }
      });
    });
  });

  group('text recognition', () {
    testWidgets('recognizes text in text1.png', (tester) async {
      await tester.runAsync(() async {
        final recognizer = TextRecognizer();
        try {
          final recognized = await recognizer.processImage(
            await inputImageFromAsset('assets/images/text1.png'),
          );
          expect(recognized.text.trim(), isNotEmpty);
        } finally {
          await recognizer.close();
        }
      });
    });
  });

  group('face detection', () {
    testWidgets('detects a face in face1.webp', (tester) async {
      await tester.runAsync(() async {
        final detector = FaceDetector(
          options: FaceDetectorOptions(
            enableClassification: true,
            enableLandmarks: true,
          ),
        );
        try {
          final faces = await detector.processImage(
            await inputImageFromAsset('assets/images/face1.webp'),
          );
          expect(faces, isNotEmpty);
          expect(faces.first.boundingBox, isNotNull);
        } finally {
          await detector.close();
        }
      });
    });
  });

  group('face mesh detection', () {
    testWidgets('detects a face mesh in face1.webp', (tester) async {
      await tester.runAsync(() async {
        // ML Kit has no face mesh API for iOS; the plugin reports
        // "not implemented" there, which we treat as a pass.
        if (Platform.isIOS) {
          final detector = FaceMeshDetector(
            option: FaceMeshDetectorOptions.boundingBoxOnly,
          );
          try {
            try {
              await detector.processImage(
                await inputImageFromAsset('assets/images/face1.webp'),
              );
              fail('Expected the iOS face mesh detector to be unimplemented');
            } on MissingPluginException {
              // Expected: the API does not exist on iOS.
            }
          } finally {
            await detector.close();
          }
          return;
        }
        final detector = FaceMeshDetector(
          option: FaceMeshDetectorOptions.boundingBoxOnly,
        );
        try {
          final meshes = await detector.processImage(
            await inputImageFromAsset('assets/images/face1.webp'),
          );
          expect(meshes, isNotEmpty);
        } finally {
          await detector.close();
        }
      });
    });
  });

  group('image labeling', () {
    testWidgets('labels daisy.jpg', (tester) async {
      await tester.runAsync(() async {
        final labeler = ImageLabeler(
          options: ImageLabelerOptions(confidenceThreshold: 0.5),
        );
        try {
          final labels = await labeler.processImage(
            await inputImageFromAsset('assets/images/daisy.jpg'),
          );
          expect(labels, isNotEmpty);
          expect(labels.first.confidence, greaterThan(0.4));
        } finally {
          await labeler.close();
        }
      });
    });
  });

  group('object detection', () {
    testWidgets('detects objects in child_dog.jpg', (tester) async {
      await tester.runAsync(() async {
        final detector = ObjectDetector(
          options: ObjectDetectorOptions(
            mode: DetectionMode.single,
            classifyObjects: true,
            multipleObjects: true,
          ),
        );
        try {
          final objects = await detector.processImage(
            await inputImageFromAsset('assets/images/child_dog.jpg'),
          );
          expect(objects, isNotEmpty);
        } finally {
          await detector.close();
        }
      });
    });
  });

  group('pose detection', () {
    testWidgets('detects a pose in pose1.jpeg', (tester) async {
      await tester.runAsync(() async {
        if (await isSimulator) {
          markTestSkipped(
            'Pose detection is MediaPipe-backed and crashes on the '
            'iOS simulator (no GPU); covered on a real device.',
          );
          return;
        }
        final detector = PoseDetector(
          options: PoseDetectorOptions(
            model: PoseDetectionModel.base,
            mode: PoseDetectionMode.single,
          ),
        );
        try {
          final poses = await detector.processImage(
            await inputImageFromAsset('assets/images/pose1.jpeg'),
          );
          expect(poses, isNotEmpty);
          expect(poses.first.landmarks, isNotEmpty);
        } finally {
          await detector.close();
        }
      });
    });
  });

  group('subject segmentation', () {
    testWidgets('segments a subject in pose1.jpeg', (tester) async {
      await tester.runAsync(() async {
        // ML Kit has no subject segmentation API for iOS; the plugin is a
        // stub there, so we only verify that it fails gracefully.
        if (Platform.isIOS) {
          final segmenter = SubjectSegmenter(
            options: SubjectSegmenterOptions(
              enableForegroundBitmap: false,
              enableForegroundConfidenceMask: true,
              enableMultipleSubjects: SubjectResultOptions(
                enableConfidenceMask: true,
                enableSubjectBitmap: false,
              ),
            ),
          );
          try {
            try {
              await segmenter.processImage(
                await inputImageFromAsset('assets/images/pose1.jpeg'),
              );
              fail('Expected the iOS subject segmenter to be unimplemented');
            } on MissingPluginException {
              // Expected: the API does not exist on iOS.
            }
          } finally {
            try {
              await segmenter.close();
            } on MissingPluginException {
              // The stub does not implement close either.
            }
          }
          return;
        }
        final segmenter = SubjectSegmenter(
          options: SubjectSegmenterOptions(
            enableForegroundBitmap: false,
            enableForegroundConfidenceMask: true,
            enableMultipleSubjects: SubjectResultOptions(
              enableConfidenceMask: true,
              enableSubjectBitmap: false,
            ),
          ),
        );
        try {
          final result = await segmenter.processImage(
            await inputImageFromAsset('assets/images/pose1.jpeg'),
          );
          expect(result.subjects, isNotEmpty);
        } on PlatformException catch (e) {
          if (e.message?.contains('Waiting for the subject segmentation') ??
              false) {
            markTestSkipped(
              'Subject segmentation optional module is not downloaded on this emulator.',
            );
            return;
          }
          rethrow;
        } finally {
          await segmenter.close();
        }
      });
    });
  });

  group('selfie segmentation', () {
    testWidgets('segments a selfie in face1.webp', (tester) async {
      await tester.runAsync(() async {
        if (await isSimulator) {
          markTestSkipped(
            'Selfie segmentation is MediaPipe-backed and crashes on the '
            'iOS simulator (no GPU); covered on a real device.',
          );
          return;
        }
        final segmenter = SelfieSegmenter();
        try {
          final mask = await segmenter.processImage(
            await inputImageFromAsset('assets/images/face1.webp'),
          );
          expect(mask, isNotNull);
          expect(mask!.confidences, isNotEmpty);
        } finally {
          await segmenter.close();
        }
      });
    });
  });

  group('digital ink recognition', () {
    testWidgets('recognizes a handwritten digit', (tester) async {
      await tester.runAsync(() async {
        final manager = DigitalInkRecognizerModelManager();
        if (!await manager.isModelDownloaded('en')) {
          markTestSkipped(
            'Digital ink model "en" is not downloaded on this device/emulator.',
          );
          return;
        }
        // A simple vertical stroke — the base model should return at
        // least one candidate (typically "1").
        final ink = Ink()
          ..strokes.add(
            Stroke()
              ..points.addAll([
                for (var i = 0; i <= 20; i++)
                  StrokePoint(x: 50, y: 10 + i * 4.0, t: i * 16),
              ]),
          );
        final recognizer = DigitalInkRecognizer(languageCode: 'en');
        try {
          final candidates = await recognizer.recognize(
            ink,
            context: DigitalInkRecognitionContext(
              writingArea: WritingArea(width: 273, height: 110),
            ),
          );
          expect(candidates, isNotEmpty);
          expect(candidates.first.text, isNotEmpty);
        } finally {
          await recognizer.close();
        }
      });
    });
  });

  group('language identification', () {
    testWidgets('identifies english text', (tester) async {
      await tester.runAsync(() async {
        final identifier = LanguageIdentifier(confidenceThreshold: 0.5);
        try {
          expect(await identifier.identifyLanguage('Hello, world!'), 'en');
        } finally {
          await identifier.close();
        }
      });
    });
  });

  group('entity extraction', () {
    testWidgets('annotates a sentence with entities', (tester) async {
      await tester.runAsync(() async {
        final manager = EntityExtractorModelManager();
        if (!await manager.isModelDownloaded('english')) {
          markTestSkipped(
            'Entity extractor model "english" is not downloaded on this device/emulator.',
          );
          return;
        }
        final extractor = EntityExtractor(
          language: EntityExtractorLanguage.english,
        );
        try {
          final annotations = await extractor.annotateText(
            'I visited Paris with Google last year.',
          );
          expect(annotations, isNotEmpty);
        } finally {
          await extractor.close();
        }
      });
    });
  });

  group('translation', () {
    testWidgets('translates english to russian', (tester) async {
      await tester.runAsync(() async {
        final modelManager = OnDeviceTranslatorModelManager();
        if (!await modelManager.isModelDownloaded(
              TranslateLanguage.english.bcpCode,
            ) ||
            !await modelManager.isModelDownloaded(
              TranslateLanguage.russian.bcpCode,
            )) {
          markTestSkipped(
            'Translation models are not downloaded on this device/emulator.',
          );
          return;
        }
        final translator = OnDeviceTranslator(
          sourceLanguage: TranslateLanguage.english,
          targetLanguage: TranslateLanguage.russian,
        );
        try {
          final translated = await translator.translateText(
            'Hello, how are you?',
          );
          expect(translated, isNotEmpty);
        } finally {
          await translator.close();
        }
      });
    });
  });

  group('smart reply', () {
    testWidgets('suggests replies for a conversation', (tester) async {
      await tester.runAsync(() async {
        final smartReply = SmartReply();
        try {
          smartReply.addMessageToConversationFromRemoteUser(
            'Want to grab a coffee tomorrow?',
            DateTime.now().millisecondsSinceEpoch,
            'remote-user',
          );
          final result = await smartReply.suggestReplies();
          expect(result.suggestions, isNotEmpty);
        } finally {
          await smartReply.close();
        }
      });
    });
  });

  group('camera frame pipeline (emulated)', () {
    // Emulates what the camera views do: an image is turned into a raw
    // RGBA bitmap InputImage (the same shape as a camera frame) and run
    // through a detector — no physical camera involved.
    testWidgets('labels a bitmap built from an asset', (tester) async {
      await tester.runAsync(() async {
        final labeler = ImageLabeler(
          options: ImageLabelerOptions(confidenceThreshold: 0.5),
        );
        try {
          final labels = await labeler.processImage(
            await bitmapFromAsset('assets/images/sunflower.jpg'),
          );
          expect(labels, isNotEmpty);
        } finally {
          await labeler.close();
        }
      });
    });
  });

  group('camera', () {
    testWidgets('opens the camera and receives frames', (tester) async {
      await tester.runAsync(() async {
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          markTestSkipped('No cameras available on this device/emulator.');
          return;
        }
        final controller = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        try {
          // Throws or times out if the CAMERA permission was not granted (e.g. the
          // dialog was not accepted on an emulator/simulator).
          await controller.initialize().timeout(const Duration(seconds: 1));
        } catch (error) {
          // Do not await dispose(): if initialize() timed out due to a pending
          // system permission dialog, awaiting dispose() blocks on the dialog result.
          unawaited(controller.dispose().catchError((_) {}));
          markTestSkipped(
            'Camera unavailable or permission not granted: $error',
          );
          return;
        }
        try {
          var receivedPlanes = false;
          final frameReceived = Completer<void>();
          await controller.startImageStream((image) {
            if (image.planes.isNotEmpty) {
              receivedPlanes = true;
            }
            if (!frameReceived.isCompleted) {
              frameReceived.complete();
            }
          });
          await frameReceived.future.timeout(const Duration(seconds: 3));
          await controller.stopImageStream();
          expect(receivedPlanes, isTrue);
        } finally {
          await controller.dispose();
        }
      });
    });
  });

  // Pre-grant on an emulator so the test above does not skip:
  //   adb shell pm grant <applicationId> android.permission.CAMERA
}
