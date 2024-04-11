import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class DocumentScannerView extends StatefulWidget {
  @override
  State<DocumentScannerView> createState() => _DocumentScannerViewState();
}

class _DocumentScannerViewState extends State<DocumentScannerView> {
  DocumentScanner documentScanner = DocumentScanner(
    options: DocumentScannerOptions(),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    documentScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google ML Kit Demo App'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final documents = await documentScanner.scanDocument();

            print('documents: $documents');
          } catch (e) {
            print('Error: $e');
          }
        },
        child: Icon(Icons.scanner),
      ),
    );
  }
}
