import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/commons.dart';

class ObjectDetector {
  ObjectDetector(this.objectDetectorOptions);

  static const MethodChannel _channel =
      MethodChannel('google_mlkit_object_detector');

  final ObjectDetectorOptions objectDetectorOptions;
  bool _hasBeenOpened = false;
  bool _isClosed = false;

  ///Detects objects in image.
  Future<List<DetectedObject>> processImage(InputImage inputImage) async {
    _hasBeenOpened = true;
    final result = await _channel.invokeMethod(
        'vision#startObjectDetector', <String, dynamic>{
      'imageData': inputImage.toJson(),
      'options': objectDetectorOptions.toJson()
    });
    final objects = <DetectedObject>[];
    for (final dynamic json in result) {
      objects.add(DetectedObject.fromJson(json));
    }
    return objects;
  }

  ///Release resources of object detector.
  Future<void> close() async {
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<void>.value();
    _isClosed = true;
    return _channel.invokeMethod<void>('vision#closeObjectDetector');
  }
}

enum DetectionMode {
  stream,
  singleImage,
}

///Options to configure the detector while using with base model.
class ObjectDetectorOptions {
  ///Determines the detection mode.
  final DetectionMode mode;

  ///Determines whether to coarsely classify detected objects.
  final bool classifyObjects;

  ///Determines whether to track objects or not.
  final bool multipleObjects;

  ///Constructor for [ObjectDetectorOptions]
  const ObjectDetectorOptions(
      {this.mode = DetectionMode.stream,
      this.classifyObjects = false,
      this.multipleObjects = false});

  Map<String, dynamic> toJson() => {
        'mode': mode.index,
        'classify': classifyObjects,
        'multiple': multipleObjects,
        'custom': false
      };
}

///Options to configure the detector while using custom models.
class CustomObjectDetectorOptions extends ObjectDetectorOptions {
  final CustomModel customModel;

  ///Maximum number of labels that detector returns per object. Default is 10.
  final int maximumLabelsPerObject;

  ///Minimum confidence score required to consider detected labels. Default is 0.5.
  final double confidenceThreshold;

  ///Constructor for [CustomObjectDetectorOptions].
  CustomObjectDetectorOptions(this.customModel,
      {DetectionMode mode = DetectionMode.stream,
      bool classifyObjects = false,
      bool multipleObjects = false,
      this.maximumLabelsPerObject = 10,
      this.confidenceThreshold = 0.5})
      : super(
            mode: mode,
            classifyObjects: classifyObjects,
            multipleObjects: multipleObjects);

  @override
  Map<String, dynamic> toJson() => {
        'mode': mode.index,
        'classify': classifyObjects,
        'multiple': multipleObjects,
        'custom': true,
        'threshold': confidenceThreshold,
        'maxLabels': maximumLabelsPerObject,
        'modelType': customModel.modelType,
        'modelIdentifier': customModel.modelIdentifier,
      };
}

///Class that represents an object detected by [ObjectDetector].
class DetectedObject {
  ///Tracking ID of object. If tracking is disabled it is null.
  final int? trackingId;

  ///Rect within which the object was detected.
  final Rect boundingBox;

  ///List of [Label], identified for the object.
  final List<Label> labels;

  ///Constructor for [DetectedObject].
  DetectedObject(this.boundingBox, this.labels, this.trackingId);

  factory DetectedObject.fromJson(Map<dynamic, dynamic> json) {
    final rect = RectJson.fromJson(json['rect']);
    final trackingId = json['trackingId'];
    final labels = <Label>[];
    for (final dynamic label in json['labels']) {
      labels.add(Label.fromJson(label));
    }
    return DetectedObject(rect, labels, trackingId);
  }
}

///Represents an image label of a [DetectedObject]
class Label {
  Label(this.confidence, this.index, this.text);

  ///Gets the confidence of this label.
  final double confidence;

  ///Gets the index of this label.
  final int index;

  ///Gets the text of this label.
  final String text;

  factory Label.fromJson(Map<dynamic, dynamic> json) {
    return Label(json['confidence'], json['index'], json['text']);
  }
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
