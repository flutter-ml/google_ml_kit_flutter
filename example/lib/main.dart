import 'package:google_ml_kit_example/NlpDetectorViews/language_translator.dart';

import 'NlpDetectorViews/language_identifier_view.dart';
import 'VisionDetectorViews/detector_views.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example App'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExpansionTile(
            title: const Text("Vision Api's"),
            children: [
              CustomCard('Image Label Detector', ImageLabelView()),
              CustomCard('Barcode Scanner', BarcodeScannerView()),
              CustomCard('Pose Detector view', PoseDetectorView()),
              CustomCard('Digital Ink Recogniser', DigitalInkView()),
              CustomCard('Text Detector', TextDetectorView()),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          ExpansionTile(
            title: const Text("NLP Api's"),
            children: [
              CustomCard('Language Identifier', LanguageIdentifierView()),
              CustomCard('Language Translator', LanguageTranslatorView()),
            ],
          )
        ],
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String _label;
  final Widget _viewPage;

  const CustomCard(this._label, this._viewPage);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Theme.of(context).accentColor,
        title: Text(
          _label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => _viewPage));
        },
      ),
    );
  }
}
