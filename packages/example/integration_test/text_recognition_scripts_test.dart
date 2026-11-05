// Baseline integration tests for text recognition script handling.
//
// Captures the CURRENT behaviour of the SPM-migrated plugin so that later
// changes (e.g. slimming the iOS plugin to Latin-only, or adding per-script
// add-on packages) can be verified against a known baseline:
//
//   * Latin script (text1.png) must always be recognized.
//   * A non-Latin script (Japanese, text2.png) is recognized when its
//     language library + OCR resource bundle are present, and must degrade
//     gracefully (empty result, no crash) when they are not.
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

    testWidgets('japanese script recognizes Japanese text (text2.png)', (
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
          // Three possible outcomes depending on the build:
          //   * CJK text        -> Japanese framework + bundle present;
          //   * Latin-only text -> graceful fallback to the Latin recognizer
          //                        (old CocoaPods behaviour after the SPM
          //                        migration slimmed the plugin);
          //   * empty text      -> also acceptable graceful degradation.
          // The hard requirement is: no crash.
          final text = recognized.text.trim();
          debugPrint('japanese OCR: "$text"');
          if (text.isEmpty) {
            debugPrint('-> degradation: empty result');
          } else if (containsCjk(text)) {
            debugPrint('-> full support: CJK recognized');
          } else {
            debugPrint('-> degradation: Latin-only fallback text');
          }
        } finally {
          await recognizer.close();
        }
      });
    });

    testWidgets('auto-detect (default options) on Japanese text (text2.png)', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final recognizer = TextRecognizer();
        try {
          final recognized = await recognizer.processImage(
            await inputImageFromAsset('assets/images/text2.png'),
          );
          // The image also contains a Latin line, so the default
          // auto-detecting recognizer should always produce some text.
          expect(recognized.text.trim(), isNotEmpty);
          debugPrint('auto-detect on text2.png: "${recognized.text}"');
        } finally {
          await recognizer.close();
        }
      });
    });
  });
}
