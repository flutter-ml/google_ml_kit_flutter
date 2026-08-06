import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

typedef MenuEntry = DropdownMenuEntry<String>;
const List<String> list = <String>['Select option', 'pdf', 'jpeg', 'pdf-jpeg'];

class DocumentScannerView extends StatefulWidget {
  @override
  State<DocumentScannerView> createState() => _DocumentScannerViewState();
}

class _DocumentScannerViewState extends State<DocumentScannerView> {
  DocumentScanner? _documentScanner;
  DocumentScanningResult? _result;
  static final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
    list.map<MenuEntry>(
      (String name) => MenuEntry(
        value: name,
        label: name == 'Select option' ? name : 'Scan ${name.toUpperCase()}',
      ),
    ),
  );
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.document_scanner_outlined, size: 50),
                  SizedBox(width: 8),
                  DropdownMenu<String>(
                    initialSelection: list.first,
                    onSelected: (String? value) {
                      if (value != null) {
                        if (value == 'pdf') {
                          startScan({DocumentFormat.pdf});
                        }
                        if (value == 'jpeg') {
                          startScan({DocumentFormat.jpeg});
                        }
                        if (value == 'pdf-jpeg') {
                          startScan({DocumentFormat.pdf, DocumentFormat.jpeg});
                        }
                      }
                    },
                    dropdownMenuEntries: menuEntries,
                  ),
                ],
              ),
              if (_result?.pdf != null) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 8,
                    right: 8,
                    left: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('PDF Document:'),
                  ),
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
              if (_result?.images?.isNotEmpty == true) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 8,
                    right: 8,
                    left: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Images [0]:'),
                  ),
                ),
                SizedBox(
                  height: 400,
                  child: Image.file(File(_result!.images!.first)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void startScan(Set<DocumentFormat> formats) async {
    try {
      _result = null;
      setState(() {});
      _documentScanner?.close();
      _documentScanner = DocumentScanner(
        options: DocumentScannerOptions(
          documentFormats: formats,
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
