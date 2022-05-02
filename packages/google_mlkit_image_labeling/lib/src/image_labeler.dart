import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// An image labeler that processes and labels [InputImage].
class ImageLabeler {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_image_labeler');

  /// The options for the image labeler.
  final ImageLabelerOptions options;

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Constructor to create an instance of [ImageLabeler].
  ImageLabeler({required this.options});

  /// Processes the given image for image labeling, it returns a List of [ImageLabel].
  Future<List<ImageLabel>> processImage(InputImage inputImage) async {
    final result = await _channel.invokeMethod(
        'vision#startImageLabelDetector', <String, dynamic>{
      'options': options.toJson(),
      'id': id,
      'imageData': inputImage.toJson()
    });
    final imageLabels = <ImageLabel>[];

    for (final dynamic json in result) {
      imageLabels.add(ImageLabel.fromJson(json));
    }

    return imageLabels;
  }

  /// Closes the labeler and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('vision#closeImageLabelDetector', {'id': id});
}

/// Type of [ImageLabeler].
enum ImageLabelerType {
  base,
  local,
  remote,
}

/// Base options for [ImageLabeler].
class ImageLabelerOptions {
  /// The confidence threshold for labels returned by the image labeler.
  /// Labels returned by the image labeler will have a confidence level higher or equal to the given threshold.
  /// The value must be a floating-point value in the range [0, 1].
  /// Default value is set 0.5.
  final double confidenceThreshold;

  /// Indicates that it uses Google's base model to process images.
  final ImageLabelerType type = ImageLabelerType.base;

  /// Constructor to create an instance of [ImageLabelerOptions].
  ImageLabelerOptions({this.confidenceThreshold = 0.5});

  /// Returns a json representation of an instance of [ImageLabelerOptions].
  Map<String, dynamic> toJson() => {
        'confidenceThreshold': confidenceThreshold,
        'type': type.name,
      };
}

/// Options for [ImageLabeler] using a custom local model.
class LocalLabelerOptions extends ImageLabelerOptions {
  /// Path where the local custom model is stored.
  final String modelPath;

  /// Max number of results detector will return.
  /// Default value is set to 10.
  final int maxCount;

  /// Indicates that it uses a custom local model to process images.
  @override
  final ImageLabelerType type = ImageLabelerType.local;

  /// Constructor to create an instance of [LocalLabelerOptions].
  LocalLabelerOptions(
      {double confidenceThreshold = 0.5,
      required this.modelPath,
      this.maxCount = 10})
      : super(confidenceThreshold: confidenceThreshold);

  /// Returns a json representation of an instance of [LocalLabelerOptions].
  @override
  Map<String, dynamic> toJson() => {
        'confidenceThreshold': confidenceThreshold,
        'type': type.name,
        'path': modelPath,
        'maxCount': maxCount
      };
}

/// Options for [ImageLabeler] using a Firebase model.
class FirebaseLabelerOption extends ImageLabelerOptions {
  /// Name of the firebase model.
  final String modelName;

  /// Max number of results detector will return.
  /// Default value is set to 10.
  final int maxCount;

  /// Indicates that it uses a Firebase model to process images.
  @override
  final ImageLabelerType type = ImageLabelerType.remote;

  /// Constructor to create an instance of [FirebaseLabelerOption].
  FirebaseLabelerOption(
      {double confidenceThreshold = 0.5,
      required this.modelName,
      this.maxCount = 10})
      : super(confidenceThreshold: confidenceThreshold);

  /// Returns a json representation of an instance of [FirebaseLabelerOption].
  @override
  Map<String, dynamic> toJson() => {
        'confidenceThreshold': confidenceThreshold,
        'type': type.name,
        'modelName': modelName,
        'maxCount': maxCount
      };
}

/// A subclass of [ModelManager] that manages [FirebaseModelSource] required to process the image.
class FirebaseImageLabelerModelManager extends ModelManager {
  /// Constructor to create an instance of [FirebaseImageLabelerModelManager].
  FirebaseImageLabelerModelManager()
      : super(
            channel: ImageLabeler._channel,
            method: 'vision#manageFirebaseModels');
}

/// Represents a label detected in an image.
class ImageLabel {
  /// The confidence(probability) given to label that was identified in image.
  final double confidence;

  /// Label or title given for detected entity in image.
  final String label;

  /// Index of label according to google's label map: https://developers.google.com/ml-kit/vision/image-labeling/label-map
  final int index;

  /// Constructor to create an instance of [ImageLabel].
  ImageLabel(
      {required this.confidence, required this.label, required this.index});

  /// Returns an instance of [ImageLabel] from a given [json].
  factory ImageLabel.fromJson(Map<dynamic, dynamic> json) => ImageLabel(
        confidence: json['confidence'],
        label: json['text'],
        index: json['index'],
      );
}
