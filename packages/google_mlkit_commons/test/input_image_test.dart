import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

void main() {
  group('InputImage', () {
    test('fromFilePath sets the file type and path', () {
      final image = InputImage.fromFilePath('/tmp/photo.jpg');

      expect(image.type, InputImageType.file);
      expect(image.filePath, '/tmp/photo.jpg');
      expect(image.bytes, isNull);
      expect(image.bitmapData, isNull);
      expect(image.metadata, isNull);
    });

    test('fromFile uses the file path', () {
      final image = InputImage.fromFile(File('/tmp/photo.jpg'));

      expect(image.type, InputImageType.file);
      expect(image.filePath, '/tmp/photo.jpg');
    });

    test('fromBytes stores the bytes and metadata', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final metadata = InputImageMetadata(
        size: const Size(2, 2),
        rotation: InputImageRotation.rotation90deg,
        format: InputImageFormat.nv21,
        bytesPerRow: 8,
      );

      final image = InputImage.fromBytes(bytes: bytes, metadata: metadata);

      expect(image.type, InputImageType.bytes);
      expect(image.bytes, bytes);
      expect(image.metadata, metadata);
      expect(image.filePath, isNull);
    });

    test('fromBitmap derives metadata from the dimensions', () {
      final bitmap = Uint8List.fromList(List.filled(4 * 2 * 2, 0));

      final image = InputImage.fromBitmap(
        bitmap: bitmap,
        width: 2,
        height: 2,
        rotation: 90,
      );

      expect(image.type, InputImageType.bitmap);
      expect(image.bitmapData, bitmap);
      expect(image.rotation, 90);
      final metadata = image.metadata!;
      expect(metadata.size, const Size(2, 2));
      expect(metadata.rotation, InputImageRotation.rotation90deg);
      expect(metadata.format, InputImageFormat.bgra8888);
      expect(metadata.bytesPerRow, 8);
    });

    test('toJson serializes all fields', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final metadata = InputImageMetadata(
        size: const Size(10, 20),
        rotation: InputImageRotation.rotation180deg,
        format: InputImageFormat.yuv_420_888,
        bytesPerRow: 40,
      );

      final json = InputImage.fromBytes(
        bytes: bytes,
        metadata: metadata,
      ).toJson();

      expect(json['bytes'], bytes);
      expect(json['type'], 'bytes');
      expect(json['path'], isNull);
      expect(json['bitmapData'], isNull);
      expect(json['rotation'], isNull);
      expect(json['metadata'], {
        'width': 10.0,
        'height': 20.0,
        'rotation': 180,
        'image_format': 35,
        'bytes_per_row': 40,
      });
    });
  });

  group('InputImageRotation', () {
    test('rawValue maps each rotation to its angle', () {
      expect(InputImageRotation.rotation0deg.rawValue, 0);
      expect(InputImageRotation.rotation90deg.rawValue, 90);
      expect(InputImageRotation.rotation180deg.rawValue, 180);
      expect(InputImageRotation.rotation270deg.rawValue, 270);
    });

    test('fromRawValue round-trips valid angles', () {
      for (final rotation in InputImageRotation.values) {
        expect(
          InputImageRotationValue.fromRawValue(rotation.rawValue),
          rotation,
        );
      }
    });

    test('fromRawValue returns null for unknown angles', () {
      expect(InputImageRotationValue.fromRawValue(45), isNull);
    });
  });

  group('InputImageFormat', () {
    test('rawValue uses the ML Kit constants', () {
      expect(InputImageFormat.nv21.rawValue, 17);
      expect(InputImageFormat.yuv_420_888.rawValue, 35);
      expect(InputImageFormat.yv12.rawValue, 842094169);
      expect(InputImageFormat.yuv420.rawValue, 875704438);
      expect(InputImageFormat.bgra8888.rawValue, 1111970369);
    });

    test('fromRawValue returns null for unknown formats', () {
      expect(InputImageFormatValue.fromRawValue(12345), isNull);
    });
  });

  group('RectJson', () {
    test('fromJson reads the corners', () {
      final rect = RectJson.fromJson(const {
        'left': 1,
        'top': 2,
        'right': 30,
        'bottom': 40,
      });

      expect(rect, const Rect.fromLTWH(1, 2, 29, 38));
    });

    test('fromJson defaults missing corners to zero', () {
      final rect = RectJson.fromJson(const <dynamic, dynamic>{});

      expect(rect, Rect.zero);
    });
  });
}
