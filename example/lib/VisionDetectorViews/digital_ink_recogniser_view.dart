import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'toast.dart';

class DigitalInkView extends StatefulWidget {
  @override
  _DigitalInkViewState createState() => _DigitalInkViewState();
}

class _DigitalInkViewState extends State<DigitalInkView> {
  LanguageModelManager languageModelManager =
      GoogleMlKit.vision.languageModelManager();
  DigitalInkRecogniser digitalInkRecogniser =
      GoogleMlKit.vision.digitalInkRecogniser();
  List<Offset?> _points = <Offset>[];
  String _recognisedText = '';
  String _language = 'en-US';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Digital Ink Recognition')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    RenderObject? object = context.findRenderObject();
                    final _localPosition = (object as RenderBox?)
                        ?.globalToLocal(details.localPosition);
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
            ),
            if (_recognisedText.isNotEmpty)
              Text(
                'Candidates: $_recognisedText',
                style: TextStyle(fontSize: 23),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    child: Text('Read Text'),
                    onPressed: _recogniseText,
                  ),
                  ElevatedButton(
                    child: Text('Clear Pad'),
                    onPressed: _clearPad,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    child: Text('Check Model'),
                    onPressed: _isModelDownloaded,
                  ),
                  ElevatedButton(
                    child: Text('Download'),
                    onPressed: _downloadModel,
                  ),
                  ElevatedButton(
                    child: Text('Delete'),
                    onPressed: _deleteModel,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _clearPad() {
    setState(() {
      _points.clear();
      _recognisedText = '';
    });
  }

  Future<void> _isModelDownloaded() async {
    Future<String> Function() function = () async {
      final isModelDownloaded =
          await languageModelManager.isModelDownloaded(_language);
      return isModelDownloaded ? 'exists' : 'not exists';
    };
    Toast()
        .show('Checking if model is downloaded...', function(), context, this);
  }

  Future<void> _deleteModel() async {
    Toast().show('Deleting model...',
        languageModelManager.deleteModel(_language), context, this);
  }

  Future<void> _downloadModel() async {
    Toast().show('Downloading model...',
        languageModelManager.downloadModel(_language), context, this);
  }

  Future<void> _recogniseText() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Recognising'),
            ),
        barrierDismissible: true);
    try {
      final candidates =
          await digitalInkRecogniser.readText(_points, _language);
      _recognisedText = "";
      for (final candidate in candidates) {
        _recognisedText += "\n" + candidate.text;
      }
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
    Navigator.pop(context);
  }
}

class Signature extends CustomPainter {
  List<Offset?> points;

  Signature({this.points = const []});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;
}
