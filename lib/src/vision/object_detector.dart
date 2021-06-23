part of 'vision.dart';

class ObjectDetector {
  ObjectDetector._(this._objectDetectorOptions);

  final ObjectDetectorOptionsBase _objectDetectorOptions;
  bool _hasBeenOpened = false;
  bool _isClosed = false;

  ///Detects objects in image.
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

  ///Release resources of object detector.
  Future<void> close() async {
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<void>.value();
    _isClosed = true;
    return Vision.channel.invokeMethod<void>('vision#closeObjectDetector');
  }
}

///Abstract class to serve as a base for [ObjectDetectorOptions] and [CustomObjectDetectorOptions].
abstract class ObjectDetectorOptionsBase {
  Map<String, dynamic> get _map => <String, dynamic>{};
}

///Options to configure the detector while using with base model.
class ObjectDetectorOptions extends ObjectDetectorOptionsBase {
  ///Determines whether to coarsely classify detected objects.
  final bool classifyObjects;

  ///Determines whether to track objects or not.
  final bool trackMutipleObjects;

  ///Constructor for [ObjectDetectorOptions]
  ObjectDetectorOptions(
      {this.classifyObjects = false, this.trackMutipleObjects = false});

  @override
  Map<String, dynamic> get _map => <String, dynamic>{
        'classify': classifyObjects,
        'multiple': trackMutipleObjects,
        'custom': false
      };
}

///Options to configure the detector while using custom models.
class CustomObjectDetectorOptions extends ObjectDetectorOptionsBase {
  ///Determines whether to coarsely classify detected objects.
  final bool classifyObjects;

  ///Determines whether to track objects or not.
  final bool trackMutipleObjects;

  final CustomModel _customModel;

  ///Maximum number of labels that detector returns per object. Default is 10.
  final int maximumLabelsPerObject;

  ///Minimum confidence score required to consider detected labels. Default is 0.5.
  final double confidenceThreshold;

  ///Constructor for [CustomObjectDetectorOptions].
  CustomObjectDetectorOptions(this._customModel,
      {this.classifyObjects = false,
      this.trackMutipleObjects = false,
      this.maximumLabelsPerObject = 10,
      this.confidenceThreshold = 0.5});

  @override
  Map<String, dynamic> get _map => <String, dynamic>{
        'classify': classifyObjects,
        'multiple': trackMutipleObjects,
        'custom': true,
        'modelPath': _customModel.modelIdentifier,
        'threshold': confidenceThreshold,
        'maxLabels': maximumLabelsPerObject,
        'modelType': _customModel.modelType,
      };
}

///Class that represents an object detected by [ObjectDetector].
class DetectedObject {
  ///Tracking ID of object. If tracking is disabled it is null.
  final int? _trackingId;

  ///Rect within which the object was detected.
  final Rect _boundingBox;

  ///List of [Label], identified for the object.
  final List<Label> _labels;

  ///Constructor for [DetectedObject].
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

  ///Returns a list of [Label] when classification is enabled.
  ///If disabled it returns an empty list.
  List<Label> getLabels() => _labels;

  ///Gets the axis-aligned bounding rectangle of the detected object.
  Rect getBoundinBox() => _boundingBox;

  int? getTrackingId() => _trackingId;
}

///Represents an image label of a [DetectedObject]
class Label {
  Label._(this._confidence, this._index, this._text);

  final double _confidence;
  final int _index;
  final String _text;

  ///Gets the confidence of this label.
  double getConfidence() => _confidence;

  ///Gets the index of this label.
  int getIndex() => _index;

  ///Gets the text of this label.
  String getText() => _text;
}

///Abstract class to serve as base for [LocalModel] and [RemoteModel].
abstract class CustomModel {
  ///For [LocalModel] this will refer to the path of local model.
  ///For [RemoteModel] this will refer to the name of hosted model.
  final String modelIdentifier;

  final String modelType = 'base';

  CustomModel(this.modelIdentifier);
}

class LocalModel extends CustomModel {
  ///Constructor for [LocalModel]. Takes the model path relative to assets path(Android).
  LocalModel(String modelPath) : super(modelPath);

  @override
  final String modelType = 'local';
}

class RemoteModel extends CustomModel {
  ///Constructor for [RemoteModel]. Takes the model name.
  RemoteModel(String modelName) : super(modelName);

  @override
  final String modelType = 'remote';
}
