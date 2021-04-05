part of 'vision.dart';

///Detector that detects the labels present in the [InputImage] provided
///Labels implies the objects,places,people etc.. that were recognised on the image
///For every entity detected it returns an [ImageLabel] that contains the confidence level
///of the entity and the index of the label.
///By default it uses google's base model that identifies around 400+ entities [https://developers.google.com/ml-kit/vision/image-labeling/label-map]
///
/// It also supports usage custom tflite models and auto ml vision models
///
/// Creating an instance of Image Labeler
///
/// ImageLabeler imageLabeler = GoogleMlKit.instance.imageLabeler([options]);
/// The parameter options is optional,it maybe [ImageLabelerOptions],[CustomImageLabelerOptions],[AutoMlImageLabelerOptions
class ImageLabeler {
  ///private constructor to create instance of image labeler
  ImageLabeler._(dynamic options)
      : assert(options != null),
        _labelerOptions = options;

  final dynamic _labelerOptions;

  bool _isOpened = false;
  bool _isClosed = false;

  ///Function that takes [InputImage] processes it and returns a List of [ImageLabel]
  Future<List<ImageLabel>> processImage(InputImage inputImage) async {
    _isOpened = true;

    final result = await Vision.channel
        .invokeMethod('vision#startImageLabelDetector', <String, dynamic>{
      'options': _getImageOptions(_labelerOptions),
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

///To create [ImageLabeler] that process image considering google's base model
class ImageLabelerOptions {
  ///The minimum confidence(probability) a label should have to been returned in the result
  ///Default value is set 0.5
  final double confidenceThreshold;

  ///Indicates that it uses google's base model to process images.
  final String labelerType = 'default';

  ///Constructor to create instance of [ImageLabelerOptions]
  ImageLabelerOptions({this.confidenceThreshold = 0.5});
}

///To create [ImageLabeler] that processes image based on the custom tflite model provided by user.
class CustomImageLabelerOptions {
  ///The minimum confidence(probability) a label should have to been returned in the result.
  ///Default value is set 0.5
  final double confidenceThreshold;

  ///Indicates the location of custom model.[CustomTrainedModel.asset] implies the model is stored in assets folder of android module.
  final CustomTrainedModel customModel;

  ///Path where your custom model is stores.
  final String customModelPath;

  ///Indicates that it uses custom tflite model.
  final String labelerType = 'custom';

  ///Constructor to create an instance of [CustomImageLabelerOptions]
  CustomImageLabelerOptions(
      {this.confidenceThreshold = 0.5,
      required this.customModel,
      required this.customModelPath});
}

///To create [ImageLabeler] that processes image based on the custom auto ml vision model provided by user.
///It extends [CustomImageLabelerOptions] as they share same properties
class AutoMlImageLabelerOptions extends CustomImageLabelerOptions {
  //Overridden to indicate that it uses auto ml vision model
  @override
  final String labelerType = 'autoMl';

  ///Constructor to create instance of [AutoMlImageLabelerOptions]
  AutoMlImageLabelerOptions(
      CustomTrainedModel customTrainedModel, String customModelPath)
      : super(
            customModel: customTrainedModel, customModelPath: customModelPath);
}

///This represents a label detected in image.
class ImageLabel {
  ImageLabel(dynamic data)
      : confidence = data['confidence'],
        label = data['text'],
        index = data['index'];

  ///The confidence(probability) given to label that was identified in image
  final double confidence;

  ///Label or title given for detected entity in image
  final String label;

  ///Index of label according to google's label map [https://developers.google.com/ml-kit/vision/image-labeling/label-map]
  final int index;
}

///Function to convert the data in [ImageLabelerOptions],[AutoMlImageLabelerOptions],[CustomImageLabelerOptions]
///to [Map] to pass the data when the method is invoked.
Map<String, dynamic> _getImageOptions(dynamic _labelerOptions) {
  if (_labelerOptions.runtimeType == ImageLabelerOptions) {
    return <String, dynamic>{
      'labelerType': _labelerOptions.labelerType,
      'confidenceThreshold': _labelerOptions.confidenceThreshold
    };
  } else {
    return <String, dynamic>{
      'labelerType': _labelerOptions.labelerType,
      'confidenceThreshold': _labelerOptions.confidenceThreshold,
      'customModel': _labelerOptions.customModel == CustomTrainedModel.asset
          ? 'asset'
          : 'file',
      'path': _labelerOptions.customModelPath
    };
  }
}
