import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class DigitalInkView extends StatefulWidget {
  @override
  _DigitalInkViewState createState() => _DigitalInkViewState();
}

class _DigitalInkViewState extends State<DigitalInkView> {
  List<Offset> _points = <Offset>[];
  LanguageModelManager _languageModelManager =
      GoogleMlKit.instance.languageModelManager();
  DigitalInkRecogniser _digitalInkRecogniser =
      GoogleMlKit.instance.digitalInkRecogniser();
  String _recognisedText = '';

  Future<void> _isModelDownloaded() async {
    final verificationResult =
        await _languageModelManager.isModelDownloaded('en-US');
    print('And the... result is ${verificationResult.toString()}');
  }

  Future<void> _deleteModel() async {
    final deleteResult = await _languageModelManager.deleteModel('en-US');
    print('And the... result is ${deleteResult.toString()}');
  }

  Future<void> _downloadModel() async {
    final downloadResult = await _languageModelManager.downloadModel('en-US');
    print('And the... result is ${downloadResult.toString()}');
  }

  Future<void> recogniseText() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Recognising'),
            ),
        barrierDismissible: true);
    final text = await _digitalInkRecogniser.readText(_points, 'en-US');
    Navigator.pop(context);
    setState(() {
      _recognisedText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Text("Clear Pad"),
          onPressed: () {
            setState(() {
              _points.clear();
              _recognisedText = '';
            });
          }),
      body: Container(
        child: Stack(
          children: [
            GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  RenderBox object = context.findRenderObject();
                  Offset _localPosition =
                      object.globalToLocal(details.globalPosition);
                  _points = List.from(_points)..add(_localPosition);
                });
              },
              onPanEnd: (DragEndDetails details) {
                _points.add(null);
              },
              child: CustomPaint(
                painter: Signature(points: _points),
                size: Size.infinite,
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height / 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _recognisedText,
                    style: TextStyle(fontSize: 23),
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 50,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        child: Text('Read Text'),
                        onPressed: () async {
                          await recogniseText();
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RaisedButton(
                            child: Text('Check Download'),
                            onPressed: () async {
                              await _isModelDownloaded();
                            },
                          ),
                          RaisedButton(
                            child: Text('Download'),
                            onPressed: () async {
                              await _downloadModel();
                            },
                          ),
                          RaisedButton(
                            child: Text('Delete'),
                            onPressed: () async {
                              await _deleteModel();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class Signature extends CustomPainter {
  List<Offset> points;

  Signature({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;
}
