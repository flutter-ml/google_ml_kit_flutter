import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class DocumentScannerView extends StatefulWidget {
  @override
  State<DocumentScannerView> createState() => _DocumentScannerViewState();
}

class _DocumentScannerViewState extends State<DocumentScannerView> {
  DocumentScanner documentScanner = DocumentScanner(
    options: DocumentScannerOptions(
      mode: ScannerMode.filter, // to control the feature sets in the flow
      isGalleryImport: false, // importing from the photo gallery
      pageLimit: 1, // setting a limit to the number of pages scanned
    ),
  );
  List<String>? documents;
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
        title: Text('Document Scanner'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.document_scanner_outlined,
              size: 250,
            ),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              onPressed: startScan,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Start Scan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startScan() async {
    try {
      documents = await documentScanner.scanDocument();
      print('documents: $documents');
    } catch (e) {
      print('Error: $e');
    }
  }
}
