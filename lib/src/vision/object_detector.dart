part of 'vision.dart';

class ObjectDetector {
  ObjectDetector._(this._objectDetectorOptions);
  
  final ObjectDetectorOptions _objectDetectorOptions;
  bool _hasBeenOpened = false;
  bool _isClosed = false;

  Future<List<DetectedObject>> processImage(InputImage inputImage) async {
    _hasBeenOpened = true;

    final result = await Vision.channel.invokeMethod(
        'vision#startObjectDetector', <String, dynamic>{
      'imageData': inputImage._getImageData(),
      'options': _objectDetectorOptions._map
    });

    print(result);
    var objects = <DetectedObject>[];

    for (dynamic data in result) {
      objects.add(DetectedObject._fromMap(data));
    }
    return objects;
  }

  Future<void> close() async{
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<void>.value();
    _isClosed = true;
    return Vision.channel.invokeMethod<void>('vision#closeObjectDetector');
  }
}

class ObjectDetectorOptions {
  final bool classifyObjects;
  final bool trackMutipleObjects;

  ObjectDetectorOptions(
      {this.classifyObjects = false, this.trackMutipleObjects = false});

  Map<String, bool> get _map => <String, bool>{
        'classify': classifyObjects,
        'multiple': trackMutipleObjects
      };
}

class DetectedObject {
  final int? _trackingId;
  final Rect _boundingBox;
  final List<Label> _labels;

  DetectedObject._(this._boundingBox, this._labels, this._trackingId);

  static DetectedObject _fromMap(dynamic data) {
    final rect = _mapToRect(data['rect']);
    var trackingId = data['trackingID'];
    var labels = <Label>[];

    for (dynamic label in data['labels']) {
      labels.add(Label._(label['confidence'], label['index'], label['text']));
    }

    return DetectedObject._(rect, labels, trackingId);
  }

  List<Label> getLabels() => _labels;

  Rect getBoundinBox() => _boundingBox;

  int? getTrackingId() => _trackingId;
}

class Label {
  Label._(this._confidence, this._index, this._text);

  final double _confidence;
  final int _index;
  final String _text;

  double getConfidence() => _confidence;

  int getIndex() => _index;

  String getText() => _text;
}
