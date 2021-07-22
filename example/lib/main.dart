import 'dart:io';

import 'package:camera/camera.dart';
import 'package:google_ml_kit_example/NlpDetectorViews/entity_extraction_view.dart';
import 'package:google_ml_kit_example/NlpDetectorViews/language_translator_view.dart';
import 'package:google_ml_kit_example/NlpDetectorViews/smart_reply_view.dart';
import 'package:google_ml_kit_example/VisionDetectorViews/object_detector_view.dart';

import 'NlpDetectorViews/language_identifier_view.dart';
import 'VisionDetectorViews/detector_views.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
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
        title: Text('Google ML Kit Demo App'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ExpansionTile(
                    title: const Text("Vision"),
                    children: [
                      CustomCard(
                        'Image Label Detector',
                        ImageLabelView(),
                        featureCompleted: true,
                      ),
                      CustomCard(
                        'Face Detector',
                        FaceDetectorView(),
                        featureCompleted: true,
                      ),
                      CustomCard(
                        'Barcode Scanner',
                        BarcodeScannerView(),
                        featureCompleted: true,
                      ),
                      CustomCard(
                        'Pose Detector',
                        PoseDetectorView(),
                        featureCompleted: true,
                      ),
                      CustomCard(
                        'Digital Ink Recogniser',
                        DigitalInkView(),
                        featureCompleted: true,
                      ),
                      CustomCard(
                        'Text Detector',
                        TextDetectorView(),
                        featureCompleted: true,
                      ),
                      CustomCard(
                        'Object Detector',
                        ObjectDetectorView(),
                      ),
                      CustomCard(
                        'Remote Model Manager',
                        RemoteModelView(),
                        featureCompleted: true,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ExpansionTile(
                    title: const Text("Natural Language"),
                    children: [
                      CustomCard(
                          'Language Identifier', LanguageIdentifierView()),
                      CustomCard(
                          'Language Translator', LanguageTranslatorView()),
                      CustomCard('Entity Extractor', EntityExtractionView()),
                      CustomCard('Smart Reply', SmartReplyView())
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String _label;
  final Widget _viewPage;
  final bool featureCompleted;

  const CustomCard(this._label, this._viewPage,
      {this.featureCompleted = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Theme.of(context).primaryColor,
        title: Text(
          _label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (Platform.isIOS && !featureCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                    'This feature has not been implemented for iOS yet')));
          } else
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => _viewPage));
        },
      ),
    );
  }
}
