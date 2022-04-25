import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// An image labeler that processes and labels [InputImage].
class ImageLabeler {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_image_labeler');

  /// The options for the image labeler.
  final ImageLabelerOptions options;

  ImageLabeler({required this.options});

  /// Processes the given image for image labeling, it returns a List of [ImageLabel]
  Future<List<ImageLabel>> processImage(InputImage inputImage) async {
    final result = await _channel.invokeMethod(
        'vision#startImageLabelDetector', <String, dynamic>{
      'options': options.toJson(),
      'imageData': inputImage.toJson()
    });
    final imageLabels = <ImageLabel>[];

    for (final dynamic json in result) {
      imageLabels.add(ImageLabel.fromJson(json));
    }

    return imageLabels;
  }

  /// Closes the detector and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('vision#closeImageLabelDetector');
}

/// Base options for [ImageLabeler].
class ImageLabelerOptions {
  /// The confidence threshold for labels returned by the image labeler.
  /// Labels returned by the image labeler will have a confidence level higher or equal to the given threshold.
  /// The value must be a floating-point value in the range [0, 1].
  /// Default value is set 0.5
  final double confidenceThreshold;

  /// Indicates that it uses google's base model to process images.
  final String labelerType = 'default';

  /// Constructor to create instance of [ImageLabelerOptions]
  ImageLabelerOptions({this.confidenceThreshold = 0.5});

  Map<String, dynamic> toJson() => {
        'confidenceThreshold': confidenceThreshold,
        'labelerType': labelerType,
      };
}

/// Options for [ImageLabeler] using a custom local model.
class LocalLabelerOptions extends ImageLabelerOptions {
  /// Indicates the location of the custom local model.
  /// [LocalModelType.asset] implies the model is stored in assets folder of android module.
  /// This is ignored in iOS.
  final LocalModelType type;

  /// Path where your custom local model is stored.
  final String customModelPath;

  /// Indicates that it uses a custom local model to process images.
  @override
  final String labelerType = 'customLocal';

  /// Max number of results detector will return
  /// This is ignored in iOS.
  /// Default value is set to 5
  final int maxCount;

  /// Constructor to create an instance of [LocalLabelerOptions].
  LocalLabelerOptions(
      {double confidenceThreshold = 0.5,
      required this.type,
      required this.customModelPath,
      this.maxCount = 5})
      : super(confidenceThreshold: confidenceThreshold);

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

// To specify whether tflite models are stored in asset directory or file stored in device.
enum LocalModelType {
  asset,
  file,
}

/// Options for [ImageLabeler] using a Firebase model.
class FirebaseLabelerOption extends ImageLabelerOptions {
  /// Name of the firebase model.
  final String modelName;

  /// Indicates that it uses a Firebase model to process images.
  @override
  final String labelerType = 'customRemote';

  /// Max number of results detector will return
  /// This is ignored in iOS
  final int maxCount;

  /// Constructor to create an instance of [FirebaseLabelerOption]
  FirebaseLabelerOption(
      {double confidenceThreshold = 0.5,
      required this.modelName,
      this.maxCount = 5})
      : super(confidenceThreshold: confidenceThreshold);

  @override
  Map<String, dynamic> toJson() => {
        'confidenceThreshold': confidenceThreshold,
        'labelerType': labelerType,
        'local': false,
        'modelName': modelName,
        'maxCount': maxCount
      };
}

/// A subclass of [ModelManager] that manages [FirebaseModelSource] required to process the image.
class FirebaseImageLabelerModelManager extends ModelManager {
  FirebaseImageLabelerModelManager()
      : super(
            channel: ImageLabeler._channel,
            method: 'vision#manageFirebaseModels');
}

/// Represents a label detected in an image.
class ImageLabel {
  /// The confidence(probability) given to label that was identified in image
  final double confidence;

  /// Label or title given for detected entity in image
  final String label;

  /// Index of label according to google's label map [https://developers.google.com/ml-kit/vision/image-labeling/label-map]
  final int index;

  ImageLabel(
      {required this.confidence, required this.label, required this.index});

  factory ImageLabel.fromJson(dynamic json) => ImageLabel(
        confidence: json['confidence'],
        label: json['text'],
        index: json['index'],
      );
}
