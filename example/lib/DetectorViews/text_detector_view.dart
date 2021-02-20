import 'package:flutter/material.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TextDetectorView extends StatefulWidget {
  @override
  _TextDetectorViewState createState() => _TextDetectorViewState();
}

class _TextDetectorViewState extends State<TextDetectorView> {
  String result = '';
  List<ImageLabel> imageLabels = <ImageLabel>[];
  RecognisedText _recognisedText;
  TextDetector _textDetector = GoogleMlKit.instance.textDetector();
  String filePath;

  Future<void> fromStorage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    final inputImage = InputImage.fromFilePath(pickedFile.path);

    final text = await _textDetector.processImage(inputImage);
    setState(() {
      filePath = pickedFile.path;
      _recognisedText = text;
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await _textDetector.close();
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
                child: Image.file(File(filePath)),
              ),
        RaisedButton(
          onPressed: fromStorage,
          child: const Text("Detect text"),
        ),
        _recognisedText == null
            ? Container()
            : ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: _recognisedText.textBlocks.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(4),
                    child: ExpansionTile(
                      title: Text('Block ${index + 1}'),
                      children: _textBlockWidget(
                          _recognisedText.textBlocks[index].textLines),
                    ),
                  );
                },
              )
      ]),
    );
  }
}

List<Widget> _textBlockWidget(List<TextLine> textLines) {
  var widgets = <Widget>[];
  int i=1;
  for (var line in textLines) {
    // print(line.lineRect.top);
    // print(line.linePoints[0].dx);
    widgets.add(ExpansionTile(
      title: Text("Line $i \nLine Text : ${line.lineText}"),
      children: _textLineWidget(line.textElements),
    ));
    i+=1;
  }
  return widgets;
}

List<Widget> _textLineWidget(List<TextElement> textElements) {
  var widgets = <Widget>[];
  for (var ele in textElements) {
    // print(ele.rect.bottom);
    // print(ele.points[0].dy);
    widgets.add(Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("Text: ${ele.getText} Language: ${ele.getLanguage}"),
    ));
  }
  return widgets;
}
