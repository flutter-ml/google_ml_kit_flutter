import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class BarcodeScannerView extends StatefulWidget {
  @override
  _BarcodeScannerViewState createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  String? imagePath;
  BarcodeScanner? barcodeScanner;
  List<Barcode>? barcodes;

  Future<void> readBarcode() async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      barcodeScanner = GoogleMlKit.instance.barcodeScanner();
      final result = await barcodeScanner?.processImage(inputImage);
      setState(() {
        imagePath = pickedFile.path;
        barcodes = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barcode Scanner"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imagePath == null
                ? Container()
                : Container(
                    height: 400,
                    width: 400,
                    child: Image.file(File(imagePath!)),
                  ),
            ElevatedButton(
              onPressed: readBarcode,
              child: const Text("Read Barcode"),
            ),
            SizedBox(
              height: 20,
            ),
            barcodes == null
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: barcodes?.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Text(
                            "Type ${barcodes?[index].barcodeUnknown?.type} \n reads ${barcodes?[index].barcodeUnknown?.displayValue} \n rawData ${barcodes?[index].barcodeUnknown?.rawValue}"),
                      );
                    })
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    barcodeScanner?.close();
    super.dispose();
  }
}
