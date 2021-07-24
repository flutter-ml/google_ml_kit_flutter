part of 'vision.dart';

/// Detector that detects the labels present in the [InputImage] provided
/// Labels implies the objects,places,people etc.. that were recognised on the image
/// For every entity detected it returns an [ImageLabel] that contains the confidence level
/// of the entity and the index of the label.
/// By default it uses google's base model that identifies around 400+ entities [https://developers.google.com/ml-kit/vision/image-labeling/label-map]
///
/// It also supports usage custom tflite models and auto ml vision models
///
/// Creating an instance of Image Labeler
///
/// ImageLabeler imageLabeler = GoogleMlKit.instance.imageLabeler([options]);
/// The parameter options is optional,it maybe [ImageLabelerOptions],[CustomImageLabelerOptions],[AutoMlImageLabelerOptions
class ImageLabeler {
  /// Private constructor to create instance of image labeler
  ImageLabeler._(dynamic options)
      : assert(options != null),
        _labelerOptions = options;

  final ImageLabelerOptionsBase _labelerOptions;

  bool _isOpened = false;
  bool _isClosed = false;

  /// Function that takes [InputImage] processes it and returns a List of [ImageLabel]
  Future<List<ImageLabel>> processImage(InputImage inputImage) async {
    _isOpened = true;

    final result = await Vision.channel.invokeMethod(
        'vision#startImageLabelDetector', <String, dynamic>{
      'options': _labelerOptions._map,
      'imageData': inputImage._getImageData()
    });
    var imageLabels = <ImageLabel>[];

    for (dynamic data in result) {
      imageLabels.add(ImageLabel(data));
    }

    return imageLabels;
  }

  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await Vision.channel.invokeMethod('vision#closeImageLabelDetector');
      _isClosed = true;
      _isOpened = false;
    }
  }
}

abstract class ImageLabelerOptionsBase {
  Map<String, dynamic> get _map => <String, dynamic>{};
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
  Map<String, dynamic> get _map => <String, dynamic>{
        'confidenceThreshold': confidenceThreshold,
        'labelerType': labelerType,
      };
}

/// To create [ImageLabeler] that processes image based on the custom tflite model provided by user.
class CustomImageLabelerOptions implements ImageLabelerOptionsBase {
  /// The minimum confidence(probability) a label should have to been returned in the result.
  /// Default value is set 0.5
  final double confidenceThreshold;

  /// Indicates the location of custom model.[CustomLocalModel.asset] implies the model is stored in assets folder of android module.
  /// This is ignored in iOS
  final CustomLocalModel customModel;

  /// Path where your custom model is stores.
  final String customModelPath;

  /// Indicates that it uses custom tflite model.
  final String labelerType = 'customLocal';

  /// Max number of results detector will return
  /// This is ignored in iOS
  final int maxCount;

  /// Constructor to create an instance of [CustomImageLabelerOptions]
  CustomImageLabelerOptions(
      {this.confidenceThreshold = 0.5,
      required this.customModel,
      required this.customModelPath,
      this.maxCount = 5});

  @override
  Map<String, dynamic> get _map => <String, dynamic>{
        'confidenceThreshold': confidenceThreshold,
        'labelerType': labelerType,
        'local': true,
        'type': customModel == CustomLocalModel.asset ? 'asset' : 'file',
        'path': customModelPath,
        'maxCount': maxCount
      };
}

class CustomRemoteLabelerOption implements ImageLabelerOptionsBase {
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

  CustomRemoteLabelerOption(
      {required this.confidenceThreshold,
      required this.modelName,
      this.maxCount = 5});

  @override
  Map<String, dynamic> get _map => <String, dynamic>{
        'confidenceThreshold': confidenceThreshold,
        'labelerType': labelerType,
        'local': false,
        'modelName': modelName,
        'maxCount': maxCount
      };
}

/// This represents a label detected in image.
class ImageLabel {
  ImageLabel(dynamic data)
      : confidence = data['confidence'],
        label = data['text'],
        index = data['index'];

  /// The confidence(probability) given to label that was identified in image
  final double confidence;

  /// Label or title given for detected entity in image
  final String label;

  /// Index of label according to google's label map [https://developers.google.com/ml-kit/vision/image-labeling/label-map]
  final int index;
}
