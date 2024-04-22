import 'package:flutter/services.dart';

/// A document scanner that allows to convert physical documents into digital formats.
class DocumentScanner {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_document_scanner');

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// The options for the document scanning.
  final DocumentScannerOptions options;

  /// Constructor to create an instance of [DocumentScanner].
  DocumentScanner({required this.options});

  /// Starts the document scanner UI flow.
  Future<DocumentScanningResult> scanDocument() async {
    final dynamic results = await _channel.invokeMapMethod<dynamic, dynamic>(
        'vision#startDocumentScanner', <String, dynamic>{
      'options': options.toJson(),
      'id': id,
    });
    return DocumentScanningResult.fromJson(results);
  }

  /// Closes the detector and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod<void>('vision#closeDocumentScanner', {'id': id});
}

/// Immutable options for configuring features of [DocumentScannerOptions].
///
/// Used to configure features such as pageLimit, scanner mode, document format and gallery import.
class DocumentScannerOptions {
  /// Constructor for [DocumentScannerOptions].
  DocumentScannerOptions({
    this.documentFormat = DocumentFormat.jpeg,
    this.pageLimit = 1,
    this.mode = ScannerMode.full,
    this.isGalleryImport = false,
  });

  /// Sets a page limit for the maximum number of pages that can be scanned in a single scanning session. default = 1.
  final int pageLimit;

  /// Sets scanner result formats.
  /// Available formats: PDF, JPG and default format is JPG.
  final DocumentFormat documentFormat;

  /// Sets the scanner mode which determines what features are enabled. default = ScannerModel.full.
  final ScannerMode mode;

  /// Enable or disable the capability to import from the photo gallery. default = false.
  final bool isGalleryImport;

  /// Returns a json representation of an instance of [DocumentScannerOptions].
  Map<String, dynamic> toJson() => {
        'pageLimit': pageLimit,
        'format': documentFormat.name,
        'mode': mode.name,
        'isGalleryImport': isGalleryImport,
      };
}

/// Result format for the scanner.
enum DocumentFormat {
  jpeg,
  pdf,
}

/// Scanner mode which determines what features are enabled.
enum ScannerMode {
  base,
  filter,
  full,
}

/// Result for document scanning.
class DocumentScanningResult {
  /// Returns the PDF result or null if `DocumentFormat.pdf` was not specified when creating the scanner options.
  final DocumentScanningResultPdf? pdf;

  /// Returns the scanned images or null if `DocumentFormat.jpeg` was not specified when creating the scanner options.
  final List<String> images;

  /// Constructor to create an instance of [DocumentScanningResult].
  DocumentScanningResult({required this.pdf, required this.images});

  /// Returns an instance of [DocumentScanningResult] from a given [json].
  factory DocumentScanningResult.fromJson(Map<dynamic, dynamic> json) {
    final images = json['images'] != null
        ? List<String>.from(json['images'] as List)
        : <String>[];
    final pdf = json['pdf'] != null
        ? DocumentScanningResultPdf.fromJson(json['pdf'])
        : null;
    return DocumentScanningResult(pdf: pdf, images: images);
  }

  @override
  String toString() {
    return '{pdf: $pdf, images: $images}';
  }
}

/// Represents the PDF in the scanning result.
class DocumentScanningResultPdf {
  /// Returns the number of page being scanned.
  final int pageCount;

  /// Returns the PDF file Uri.
  final String uri;

  /// Constructor to create an instance of [DocumentScanningResultPdf].
  DocumentScanningResultPdf({required this.pageCount, required this.uri});

  /// Returns an instance of [DocumentScanningResultPdf] from a given [json].
  factory DocumentScanningResultPdf.fromJson(Map<dynamic, dynamic> json) {
    return DocumentScanningResultPdf(
        pageCount: json['pageCount'], uri: json['uri']);
  }

  @override
  String toString() {
    return '{pageCount: $pageCount, uri: $uri}';
  }
}
