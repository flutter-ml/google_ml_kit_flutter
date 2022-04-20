import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// Detector that detects the labels present in the [InputImage] provided
/// Labels implies the objects,places,people etc.. that were recognized on the image
/// For every entity detected it returns an [ImageLabel] that contains the confidence level
/// of the entity and the index of the label.
/// By default it uses google's base model that identifies around 400+ entities [https://developers.google.com/ml-kit/vision/image-labeling/label-map]
///
/// It also supports usage custom tflite models and auto ml vision models
///
/// Creating an instance of Image Labeler
///
/// ImageLabeler imageLabeler = GoogleMlKit.instance.imageLabeler([options]);
/// The parameter options is optional,it maybe [ImageLabelerOptions],[LocalLabelerOptions],[AutoMlImageLabelerOptions
class ImageLabeler {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_image_labeler');

  final ImageLabelerOptionsBase options;

  ImageLabeler({required this.options});

  /// Function that takes [InputImage] processes it and returns a List of [ImageLabel]
  Future<List<ImageLabel>> processImage(InputImage inputImage) async {
    final result = await _channel.invokeMethod(
        'vision#startImageLabelDetector', <String, dynamic>{
      'options': options.toJson(),
      'imageData': inputImage.toJson()
    });
    final imageLabels = <ImageLabel>[];

    for (final dynamic json in result) {
      imageLabels.add(ImageLabel(json));
    }

    return imageLabels;
  }

  Future<void> close() =>
      _channel.invokeMethod('vision#closeImageLabelDetector');
}

abstract class ImageLabelerOptionsBase {
  Map<String, dynamic> toJson();
}

/// To create [ImageLabeler] that process image considering google's base model
class ImageLabelerOptions implements ImageLabelerOptionsBase {
  /// The minimum confidence(probability) a label should have to been returned in the result
  /// Default value is set 0.5
  final double confidenceThreshold;

  ///Indicates that it uses google's base model to process images.
  final String labelerType = 'default';

  ///Constructor to create instance of [ImageLabelerOptions]
  ImageLabelerOptions({this.confidenceThreshold = 0.5});

  @override
  Map<String, dynamic> toJson() => {
        'confidenceThreshold': confidenceThreshold,
        'labelerType': labelerType,
      };
}

/// To create [ImageLabeler] that processes image based on the custom tflite model provided by user.
class LocalLabelerOptions implements ImageLabelerOptionsBase {
  /// The minimum confidence(probability) a label should have to been returned in the result.
  /// Default value is set 0.5
  final double confidenceThreshold;

  /// Indicates the location of custom model.[LocalModelType.asset] implies the model is stored in assets folder of android module.
  /// This is ignored in iOS
  final LocalModelType type;

  /// Path where your custom model is stores.
  final String customModelPath;

  /// Indicates that it uses custom tflite model.
  final String labelerType = 'customLocal';

  /// Max number of results detector will return
  /// This is ignored in iOS
  final int maxCount;

  /// Constructor to create an instance of [LocalLabelerOptions]
  LocalLabelerOptions(
      {this.confidenceThreshold = 0.5,
      required this.type,
      required this.customModelPath,
      this.maxCount = 5});

  @override
  Map<String, dynamic> toJson() => {
        'confidenceThreshold': confidenceThreshold,
        'labelerType': labelerType,
        'local': true,
        'type': type.name,
        'path': customModelPath,
        'maxCount': maxCount
      };
}

// To specify whether tflite models are stored in asset directory or file stored in device
enum LocalModelType {
  asset,
  file,
}

class FirebaseLabelerOption implements ImageLabelerOptionsBase {
  /// The minimum confidence(probability) a label should have to been returned in the result.
  /// Default value is set 0.5
  final double confidenceThreshold;

  /// Name of the firebase model.
  final String modelName;

  /// Indicates that it uses remote firebase models.
  final String labelerType = 'customRemote';

  /// Max number of results detector will return
  /// This is ignored in iOS
  final int maxCount;

  FirebaseLabelerOption(
      {required this.confidenceThreshold,
      required this.modelName,
      this.maxCount = 5});

  @override
  Map<String, dynamic> toJson() => {
        'confidenceThreshold': confidenceThreshold,
        'labelerType': labelerType,
        'local': false,
        'modelName': modelName,
        'maxCount': maxCount
      };
}

class FirebaseImageLabelerModelManager extends ModelManager {
  FirebaseImageLabelerModelManager()
      : super(
            channel: ImageLabeler._channel,
            method: 'vision#manageFirebaseModels');
}

/// This represents a label detected in image.
class ImageLabel {
  ImageLabel(dynamic json)
      : confidence = json['confidence'],
        label = json['text'],
        index = json['index'];

  /// The confidence(probability) given to label that was identified in image
  final double confidence;

  /// Label or title given for detected entity in image
  final String label;

  /// Index of label according to google's label map [https://developers.google.com/ml-kit/vision/image-labeling/label-map]
  final int index;
}
