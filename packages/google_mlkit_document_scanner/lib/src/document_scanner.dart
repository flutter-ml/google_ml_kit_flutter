import 'package:flutter/services.dart';

class DocumentScanner {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_document_scanner');

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// The options for the document scanning
  final DocumentScannerOptions options;

  /// Constructor to create an instance of [DocumentScanner].
  DocumentScanner({required this.options});

  /// Processes the given image for document scanner.
  Future<void> scanDocument() async {
    final result = await _channel.invokeListMethod<dynamic>(
        'vision#startDocumentScanner', <String, dynamic>{
      'options': options.toJson(),
      'id': id,
    });

    print(result.toString());
  }

  /// Closes the detector and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod<void>('vision#closeDocumentScanner', {'id': id});
}

/// Immutable options for configuring features of [DocumentScannerOptions].
///
/// Used to configure features such as classification, face tracking, speed,
/// etc.
class DocumentScannerOptions {
  /// Constructor for [DocumentScannerOptions].
  ///
  DocumentScannerOptions({
    this.pageLimit = 1,
    this.isGalleryImport = false,
    this.documentFormat = DocumentFormat.jpeg,
    this.mode = ScannerMode.full,
  });

  /// Sets a page limit for the maximum number of pages that can be scanned in a single scanning session
  final int pageLimit;

  // Sets scanner result formats
  // Available formats: PDF, JPG and default format is JPG
  final DocumentFormat documentFormat;

  // Sets the scanner mode which determines what features are enabled.
  final ScannerMode mode;

  // Enable or disable the capability to import from the photo gallery. default = false
  final bool isGalleryImport;

  /// Returns a json representation of an instance of [DocumentScannerOptions].
  Map<String, dynamic> toJson() => {
        'pageLimit': pageLimit,
        'format': documentFormat,
        'mode': mode,
        'isGalleryImport': isGalleryImport,
      };
}

enum DocumentFormat {
  jpeg,
  pdf,
}

enum ScannerMode {
  full,
  filter,
  base,
}
