// Integration tests for text recognition script handling.
//
// Verifies behaviour across Latin and non-Latin scripts:
//
//   * Latin script (text1.png) is always recognized on both platforms.
//   * Non-Latin script (Japanese, text2.png):
//     - On Android (where `com.google.mlkit:text-recognition-japanese` is
//       included in the example app), CJK characters are recognized.
//     - On iOS (which links only the base Latin `MLKitTextRecognition`
//       library), the plugin gracefully falls back to the Latin recognizer
//       without crashing and recognizes the Latin lines in the image.
//
// Run with:
//   cd packages/example
//   flutter test integration_test/text_recognition_scripts_test.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// Loads an asset from the bundle and returns it as a file-based [InputImage].
///
/// The plugin's native side decodes from a file path, so the asset bytes are
/// first copied to the app's temporary directory.
Future<InputImage> inputImageFromAsset(String assetPath) async {
  final data = await rootBundle.load(assetPath);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${assetPath.split('/').last}');
  await file.writeAsBytes(bytes, flush: true);
  return InputImage.fromFilePath(file.path);
}

/// True if [text] contains at least one CJK (Han/Kana) code point.
bool containsCjk(String text) =>
    RegExp(r'[\u3040-\u30ff\u4e00-\u9fff]').hasMatch(text);

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('text recognition scripts', () {
    testWidgets('latin script recognizes Latin text (text1.png)', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
        try {
          final recognized = await recognizer.processImage(
            await inputImageFromAsset('assets/images/text1.png'),
          );
          expect(recognized.text.trim(), isNotEmpty);
          // OCR may wrap the phrase across lines, so normalize whitespace.
          expect(
            recognized.text.replaceAll(RegExp(r'\s+'), ' '),
            contains('best of times'),
          );
          debugPrint('latin OCR: "${recognized.text}"');
        } finally {
          await recognizer.close();
        }
      });
    });

    testWidgets('japanese script on mixed Japanese/Latin image (text2.png)', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final recognizer = TextRecognizer(
          script: TextRecognitionScript.japanese,
        );
        try {
          final recognized = await recognizer.processImage(
            await inputImageFromAsset('assets/images/text2.png'),
          );
          final text = recognized.text.trim();
          debugPrint('japanese OCR: "$text"');

          // text2.png contains both Japanese and Latin lines, so both the
          // Japanese recognizer (Android) and the Latin fallback recognizer
          // (iOS) must produce non-empty text without crashing.
          expect(text, isNotEmpty);
          if (Platform.isAndroid) {
            expect(containsCjk(text), isTrue);
          } else if (Platform.isIOS) {
            expect(containsCjk(text), isFalse);
          }
        } finally {
          await recognizer.close();
        }
      });
    });

    testWidgets(
      'default script (latin) on mixed Japanese/Latin image (text2.png)',
      (tester) async {
        await tester.runAsync(() async {
          // TextRecognizer() defaults to TextRecognitionScript.latin.
          final recognizer = TextRecognizer();
          try {
            final recognized = await recognizer.processImage(
              await inputImageFromAsset('assets/images/text2.png'),
            );
            // The image also contains Latin lines, so the default Latin
            // recognizer should recognize them and never return empty text.
            final text = recognized.text.trim();
            expect(text, isNotEmpty);
            expect(containsCjk(text), isFalse);
            debugPrint('default (latin) on text2.png: "$text"');
          } finally {
            await recognizer.close();
          }
        });
      },
    );
  });
}
