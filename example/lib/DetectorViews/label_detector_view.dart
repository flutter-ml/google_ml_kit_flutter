import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class ImageLabelView extends StatefulWidget {
  @override
  _ImageLabelViewState createState() => _ImageLabelViewState();
}

class _ImageLabelViewState extends State<ImageLabelView> {
  String result = '';
  List<ImageLabel> imageLabels = <ImageLabel>[];
  String? filePath;
  ImageLabeler imageLabeler = GoogleMlKit.instance.imageLabeler();

  Future<void> fromStorage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      imageLabeler = GoogleMlKit.instance.imageLabeler();
      final labels = await imageLabeler.processImage(inputImage);
      setState(() {
        filePath = pickedFile.path;
        imageLabels = labels;
      });
      await imageLabeler.close();
    }
  }

  Future<void> fromCustomModel() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      CustomImageLabelerOptions options = CustomImageLabelerOptions(
          customModel: CustomTrainedModel.asset,
          customModelPath: "antartic.tflite");
      imageLabeler = GoogleMlKit.instance.imageLabeler(options);
      final labels = await imageLabeler.processImage(inputImage);
      setState(() {
        filePath = pickedFile.path;
        imageLabels = labels;
      });
      await imageLabeler.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Labeler'),
      ),
      body: ListView(shrinkWrap: true, children: [
        filePath == null
            ? Container()
            : Container(
                height: 400,
                width: 400,
                child: Image.file(File(filePath!)),
              ),
        ElevatedButton(
          onPressed: fromStorage,
          child: Text("Inbuilt model"),
        ),
        ElevatedButton(
          onPressed: fromCustomModel,
          child: Text("Custom Model(Trained tflite models)"),
        ),
        imageLabels.length == 0
            ? Container()
            : ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: imageLabels.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(
                          "${imageLabels[index].label} with confidence ${imageLabels[index].confidence.toString()}"));
                },
              )
      ]),
    );
  }
}
