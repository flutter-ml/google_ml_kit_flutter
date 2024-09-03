import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class DocumentScannerView extends StatefulWidget {
  @override
  State<DocumentScannerView> createState() => _DocumentScannerViewState();
}

class _DocumentScannerViewState extends State<DocumentScannerView> {
  DocumentScanner? _documentScanner;
  DocumentScanningResult? _result;

  @override
  void dispose() {
    _documentScanner?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Scanner'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.document_scanner_outlined,
                  size: 50,
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.black),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  onPressed: () => startScan(DocumentFormat.pdf),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Text(
                      'Scan PDF',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.black),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  onPressed: () => startScan(DocumentFormat.jpeg),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Text(
                      'Scan JPEG',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            if (_result?.pdf != null) ...[
              Padding(
                padding: const EdgeInsets.only(
                    top: 16, bottom: 8, right: 8, left: 8),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('PDF Document:')),
              ),
              SizedBox(
                height: 300,
                child: PDFView(
                  filePath: _result!.pdf!.uri,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: false,
                ),
              ),
            ],
            if (_result?.images.isNotEmpty == true) ...[
              Padding(
                padding: const EdgeInsets.only(
                    top: 16, bottom: 8, right: 8, left: 8),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Images [0]:')),
              ),
              SizedBox(
                  height: 400, child: Image.file(File(_result!.images.first))),
            ],
          ],
        ),
      ),
    );
  }

  void startScan(DocumentFormat format) async {
    try {
      _result = null;
      setState(() {});
      _documentScanner?.close();
      _documentScanner = DocumentScanner(
        options: DocumentScannerOptions(
          documentFormat: format,
          mode: ScannerMode.full,
          isGalleryImport: false,
          pageLimit: 1,
        ),
      );
      _result = await _documentScanner?.scanDocument();
      print('result: $_result');
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }
}
