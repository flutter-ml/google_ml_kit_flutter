import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// An object detector and tracker that detects objects in an [InputImage] and supports tracking them.
class ObjectDetector {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_object_detector');

  /// The options for the detector.
  final ObjectDetectorOptions options;

  /// Constructor to create an instance of [ObjectDetector].
  ObjectDetector({required this.options});

  /// Processes the given image for object detection and tracking.
  Future<List<DetectedObject>> processImage(InputImage inputImage) async {
    final result = await _channel.invokeMethod(
        'vision#startObjectDetector', <String, dynamic>{
      'imageData': inputImage.toJson(),
      'options': options.toJson()
    });
    final objects = <DetectedObject>[];
    for (final dynamic json in result) {
      objects.add(DetectedObject.fromJson(json));
    }

    return objects;
  }

  /// Closes the detector and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod<void>('vision#closeObjectDetector');
}

/// The mode for the object detector.
enum DetectionMode {
  stream,
  singleImage,
}

/// Options to configure the detector while using with base model.
class ObjectDetectorOptions {
  /// Determines the detection mode.
  /// The default value is [DetectionMode.stream].
  final DetectionMode mode;

  /// Indicates whether the object classification feature is enabled.
  /// The default value is false.
  final bool classifyObjects;

  /// Indicates whether all detected objects in the image or frame should be returned by the detector.
  /// If set to false, the detector returns only the most prominent object detected.
  /// The default value is false
  final bool multipleObjects;

  /// Constructor to create an instance of [ObjectDetectorOptions].
  ObjectDetectorOptions(
      {this.mode = DetectionMode.stream,
      this.classifyObjects = false,
      this.multipleObjects = false});

  /// Returns a json representation of an instance of [ObjectDetectorOptions].
  Map<String, dynamic> toJson() => {
        'mode': mode.index,
        'classify': classifyObjects,
        'multiple': multipleObjects,
        'custom': false
      };
}

/// Options to configure the detector while using a custom model.
class CustomObjectDetectorOptions extends ObjectDetectorOptions {
  /// A reference to the custom model used by [ObjectDetector].
  final CustomModel customModel;

  /// Maximum number of labels that detector returns per object.
  /// Must be positive.
  /// Default is 10.
  final int maximumLabelsPerObject;

  /// The confidence threshold for labels returned by the object detector.
  /// Labels returned by the object detector will have a confidence level higher or equal to the given threshold.
  /// The threshold is a floating-point value and must be in range [0, 1].
  /// Default is 0.5.
  final double confidenceThreshold;

  /// Constructor to create an instance of [CustomObjectDetectorOptions].
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

  /// Returns a json representation of an instance of [CustomObjectDetectorOptions].
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

/// An object detected in an [InputImage] by [ObjectDetector].
class DetectedObject {
  /// Tracking ID of object. If tracking is disabled it is null.
  final int? trackingId;

  /// Rect that contains the detected object.
  final Rect boundingBox;

  /// List of [Label], identified for the object.
  final List<Label> labels;

  /// Constructor to create an instance of [DetectedObject].
  DetectedObject(
      {required this.boundingBox,
      required this.labels,
      required this.trackingId});

  /// Returns an instance of [DetectedObject] from a given [json].
  factory DetectedObject.fromJson(Map<dynamic, dynamic> json) {
    final rect = RectJson.fromJson(json['rect']);
    final trackingId = json['trackingId'];
    final labels = <Label>[];
    for (final dynamic label in json['labels']) {
      labels.add(Label.fromJson(label));
    }
    return DetectedObject(
      boundingBox: rect,
      labels: labels,
      trackingId: trackingId,
    );
  }
}

/// A label that describes an object detected in an image.
class Label {
  /// Gets the confidence of this label.
  /// Its range depends on the classifier model used, but by convention it should be [0, 1].
  final double confidence;

  /// Gets the index of this label.
  final int index;

  /// Gets the text of this label.
  final String text;

  /// Constructor to create an instance of [Label].
  Label({required this.confidence, required this.index, required this.text});

  /// Returns an instance of [Label] from a given [json].
  factory Label.fromJson(Map<dynamic, dynamic> json) => Label(
        confidence: json['confidence'],
        index: json['index'],
        text: json['text'],
      );
}

/// Abstract class to refer to the custom model used by [ObjectDetector].
abstract class CustomModel {
  /// For [LocalModel] this will refer to the path of local model.
  /// For [FirebaseModel] this will refer to the name of hosted model.
  final String modelIdentifier;

  // Type of custom model.
  final String modelType = 'base';

  /// Constructor to create an instance of [CustomModel].
  CustomModel(this.modelIdentifier);
}

/// A reference to a local custom model used by [ObjectDetector].
class LocalModel extends CustomModel {
  // Type of custom model. Set to 'local'.
  @override
  final String modelType = 'local';

  /// Constructor to create an instance of [LocalModel].
  /// Takes the model path relative to assets path(Android).
  LocalModel(String modelPath) : super(modelPath);
}

/// A reference to a Firebase model used by [ObjectDetector].
class FirebaseModel extends CustomModel {
  // Type of custom model. Set to 'remote'.
  @override
  final String modelType = 'remote';

  /// Constructor to create an instance of [FirebaseModel].
  /// Takes the model name.
  FirebaseModel(String modelName) : super(modelName);
}

/// A subclass of [ModelManager] that manages [FirebaseModelSource] required to process the image.
class FirebaseObjectDetectorModelManager extends ModelManager {
  /// Constructor to create an instance of [FirebaseObjectDetectorModelManager].
  FirebaseObjectDetectorModelManager()
      : super(
            channel: ObjectDetector._channel,
            method: 'vision#manageFirebaseModels');
}
